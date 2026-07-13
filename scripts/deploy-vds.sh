#!/usr/bin/env bash
#
# Деплой web-xhiveee на VDS (Ubuntu/Debian).
#
# Первый запуск на сервере (от root):
#   DOMAIN=xhiveee.ru EMAIL=you@mail.ru GIT_REPO=https://github.com/Xhiveee/web-xhiveee.git \
#     bash scripts/deploy-vds.sh --init
#
# Обновление после git pull / rsync:
#   bash scripts/deploy-vds.sh --update
#
# Деплой с локальной машины (PowerShell / bash):
#   rsync -avz --delete \
#     --exclude node_modules --exclude dist --exclude .bun-cache --exclude data/visitors.json \
#     ./ root@YOUR_VDS_IP:/var/www/web-xhiveee/
#   ssh root@YOUR_VDS_IP 'bash /var/www/web-xhiveee/scripts/deploy-vds.sh --update'
#
set -euo pipefail

# ── Настройки (можно переопределить через переменные окружения) ──────────────
DOMAIN="${DOMAIN:-xhiveee.ru}"
EMAIL="${EMAIL:-admin@${DOMAIN}}"
GIT_REPO="${GIT_REPO:-}"
APP_NAME="${APP_NAME:-web-xhiveee}"
APP_DIR="${APP_DIR:-/var/www/${APP_NAME}}"
APP_USER="${APP_USER:-${APP_NAME}}"
APP_PORT="${APP_PORT:-4173}"
BUN_VERSION="${BUN_VERSION:-1.3.14}"
NGINX_SITE="/etc/nginx/sites-available/${APP_NAME}"
SYSTEMD_UNIT="/etc/systemd/system/${APP_NAME}.service"

# ── Цвета ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}!!>${NC} $*"; }
die()  { echo -e "${RED}ERROR:${NC} $*" >&2; exit 1; }

require_root() {
  [[ "${EUID:-$(id -u)}" -eq 0 ]] || die "Запустите скрипт от root: sudo bash $0 $*"
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-}"
  else
    die "Не удалось определить ОС. Поддерживаются Ubuntu/Debian."
  fi

  case "${OS_ID}" in
    ubuntu|debian) ;;
    *) die "Поддерживаются только Ubuntu/Debian, обнаружено: ${OS_ID}" ;;
  esac
}

install_system_packages() {
  log "Обновление пакетов и установка зависимостей..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq \
    ca-certificates \
    curl \
    git \
    nginx \
    certbot \
    python3-certbot-nginx \
    rsync \
    ufw
}

install_bun() {
  if command -v bun >/dev/null 2>&1; then
    log "Bun уже установлен: $(bun --version)"
    return
  fi

  log "Установка Bun ${BUN_VERSION}..."
  curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}"

  local bun_bin
  if [[ -x /root/.bun/bin/bun ]]; then
    bun_bin="/root/.bun/bin/bun"
  elif [[ -x "${HOME}/.bun/bin/bun" ]]; then
    bun_bin="${HOME}/.bun/bin/bun"
  else
    die "Bun установлен, но бинарник не найден"
  fi

  ln -sf "${bun_bin}" /usr/local/bin/bun
  log "Bun установлен: $(bun --version)"
}

setup_app_user() {
  if ! id "${APP_USER}" >/dev/null 2>&1; then
    log "Создание пользователя ${APP_USER}..."
    useradd --system --home "${APP_DIR}" --shell /usr/sbin/nologin "${APP_USER}"
  fi

  mkdir -p "${APP_DIR}/data"
  chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"
}

clone_or_update_repo() {
  if [[ -n "${GIT_REPO}" ]]; then
    if [[ ! -d "${APP_DIR}/.git" ]]; then
      log "Клонирование репозитория..."
      rm -rf "${APP_DIR}"
      git clone "${GIT_REPO}" "${APP_DIR}"
    else
      log "Обновление репозитория (git pull)..."
      git -C "${APP_DIR}" pull --ff-only
    fi
  elif [[ -f "${APP_DIR}/package.json" ]]; then
    log "Используется существующий код в ${APP_DIR}"
  elif [[ -f "./package.json" && "$(realpath .)" != "$(realpath "${APP_DIR}")" ]]; then
    log "Копирование проекта в ${APP_DIR}..."
    rsync -a --delete \
      --exclude node_modules \
      --exclude dist \
      --exclude .bun-cache \
      --exclude .git \
      ./ "${APP_DIR}/"
  else
    die "Нет кода для деплоя. Укажите GIT_REPO или скопируйте проект в ${APP_DIR}"
  fi

  chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"

  if [[ ! -f "${APP_DIR}/data/visitors.json" ]]; then
    log "Создание data/visitors.json..."
    echo '{ "ips": [] }' > "${APP_DIR}/data/visitors.json"
    chown "${APP_USER}:${APP_USER}" "${APP_DIR}/data/visitors.json"
  fi
}

build_app() {
  log "Установка зависимостей и сборка..."
  cd "${APP_DIR}"

  sudo -u "${APP_USER}" env PATH="/usr/local/bin:${PATH}" bun install --frozen-lockfile 2>/dev/null \
    || sudo -u "${APP_USER}" env PATH="/usr/local/bin:${PATH}" bun install

  sudo -u "${APP_USER}" env PATH="/usr/local/bin:${PATH}" bun run build
  log "Сборка завершена"
}

write_systemd_unit() {
  log "Настройка systemd-сервиса..."
  cat > "${SYSTEMD_UNIT}" <<EOF
[Unit]
Description=${APP_NAME} — Svelte landing (vite preview)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}
Environment=PATH=/usr/local/bin:/usr/bin:/bin
Environment=NODE_ENV=production
ExecStart=/usr/local/bin/bun run preview
Restart=on-failure
RestartSec=5
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable "${APP_NAME}"
  systemctl restart "${APP_NAME}"
  log "Сервис ${APP_NAME} запущен на 127.0.0.1:${APP_PORT}"
}

write_nginx_config() {
  log "Настройка Nginx для ${DOMAIN}..."

  cat > "${NGINX_SITE}" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};

    client_max_body_size 20m;

    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 60s;
    }
}
EOF

  ln -sf "${NGINX_SITE}" "/etc/nginx/sites-enabled/${APP_NAME}"
  rm -f /etc/nginx/sites-enabled/default

  nginx -t
  systemctl reload nginx
}

setup_ssl() {
  if [[ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]]; then
    log "SSL-сертификат уже существует, обновление..."
    certbot renew --quiet || true
    return
  fi

  log "Получение SSL-сертификата Let's Encrypt..."
  certbot --nginx \
    -d "${DOMAIN}" \
    -d "www.${DOMAIN}" \
    --non-interactive \
    --agree-tos \
    -m "${EMAIL}" \
    --redirect

  log "SSL настроен"
}

setup_firewall() {
  if ! command -v ufw >/dev/null 2>&1; then
    return
  fi

  log "Настройка UFW (22, 80, 443)..."
  ufw allow OpenSSH >/dev/null 2>&1 || ufw allow 22/tcp
  ufw allow 'Nginx Full' >/dev/null 2>&1 || { ufw allow 80/tcp; ufw allow 443/tcp; }
  ufw --force enable
}

print_summary() {
  echo ""
  log "Деплой завершён"
  echo "  Сайт:     https://${DOMAIN}"
  echo "  Код:      ${APP_DIR}"
  echo "  Сервис:   systemctl status ${APP_NAME}"
  echo "  Логи:     journalctl -u ${APP_NAME} -f"
  echo "  Nginx:    ${NGINX_SITE}"
  echo ""
  warn "Убедитесь, что DNS A-запись ${DOMAIN} → IP этого сервера уже настроена."
}

cmd_init() {
  require_root
  detect_os
  install_system_packages
  install_bun
  setup_app_user
  clone_or_update_repo
  build_app
  write_systemd_unit
  write_nginx_config
  setup_ssl
  setup_firewall
  print_summary
}

cmd_update() {
  require_root
  detect_os

  command -v bun >/dev/null 2>&1 || install_bun
  [[ -d "${APP_DIR}" ]] || die "Каталог ${APP_DIR} не найден. Сначала запустите --init"

  clone_or_update_repo
  build_app
  systemctl restart "${APP_NAME}"
  nginx -t && systemctl reload nginx
  print_summary
}

usage() {
  cat <<EOF
Использование: $0 [--init | --update]

  --init    Первичная установка на чистый VDS
  --update  Обновление кода и перезапуск

Переменные окружения:
  DOMAIN     Домен (по умолчанию: xhiveee.ru)
  EMAIL      Email для Let's Encrypt
  GIT_REPO   URL git-репозитория (опционально)
  APP_DIR    Путь установки (по умолчанию: /var/www/web-xhiveee)
EOF
}

main() {
  local mode="${1:-}"

  case "${mode}" in
    --init)  cmd_init ;;
    --update) cmd_update ;;
    -h|--help|"") usage ;;
    *) die "Неизвестный аргумент: ${mode}. Используйте --init или --update" ;;
  esac
}

main "$@"
