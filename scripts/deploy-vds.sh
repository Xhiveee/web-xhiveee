#!/usr/bin/env bash
#
# Деплой xhiveee на VDS (Ubuntu/Debian).
#
# Установка (от root):
#   curl -fsSL https://raw.githubusercontent.com/Xhiveee/web-xhiveee/main/scripts/deploy-vds.sh -o deploy-vds.sh
#   bash deploy-vds.sh
#
# Обновление:
#   bash /opt/xhiveee/scripts/deploy-vds.sh --update
#
set -euo pipefail

GIT_REPO="https://github.com/Xhiveee/web-xhiveee.git"
APP_NAME="xhiveee"
APP_DIR="/opt/xhiveee"
APP_USER="xhiveee"
APP_PORT="4173"
BUN_VERSION="1.3.14"
BUN_BIN="/usr/local/bin/bun"
NGINX_SITE="/etc/nginx/sites-available/${APP_NAME}"
SYSTEMD_UNIT="/etc/systemd/system/${APP_NAME}.service"
DEPLOY_ENV="${APP_DIR}/.deploy.env"
REPO_SCRIPT="${APP_DIR}/scripts/deploy-vds.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}!!>${NC} $*"; }
die()  { echo -e "${RED}ERROR:${NC} $*" >&2; exit 1; }

require_root() {
  [[ "${EUID:-$(id -u)}" -eq 0 ]] || die "Запустите от root: sudo bash $0"
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
      ubuntu|debian) ;;
      *) die "Поддерживаются только Ubuntu/Debian, обнаружено: ${ID:-unknown}" ;;
    esac
  else
    die "Не удалось определить ОС"
  fi
}

configure_git_safe_directory() {
  [[ "${EUID:-0}" -eq 0 ]] || return 0
  [[ -d "${APP_DIR}/.git" ]] || return 0
  git config --global --add safe.directory "${APP_DIR}"
}

bootstrap_git() {
  command -v git >/dev/null 2>&1 && return
  log "Установка git..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq git ca-certificates
}

bootstrap_repo() {
  bootstrap_git
  configure_git_safe_directory

  if [[ -d "${APP_DIR}/.git" ]]; then
    log "Обновление репозитория (git pull)..."
    git -C "${APP_DIR}" pull --ff-only
  else
    log "Клонирование репозитория в ${APP_DIR}..."
    rm -rf "${APP_DIR}"
    git clone "${GIT_REPO}" "${APP_DIR}"
  fi

  [[ -f "${REPO_SCRIPT}" ]] || die "Скрипт не найден: ${REPO_SCRIPT}"
}

handoff_to_repo_script() {
  log "Запуск установки из репозитория..."
  exec env DEPLOY_FROM_REPO=1 bash "${REPO_SCRIPT}" "$@"
}

setup_app_user() {
  if id -u "${APP_USER}" >/dev/null 2>&1; then
    log "Пользователь ${APP_USER} уже существует"
    return
  fi

  log "Создание пользователя ${APP_USER}..."
  if useradd --system --no-create-home --shell /usr/sbin/nologin "${APP_USER}" 2>/dev/null; then
    return
  fi

  groupadd --system "${APP_USER}" 2>/dev/null || true
  useradd --system --no-create-home --gid "${APP_USER}" --shell /usr/sbin/nologin "${APP_USER}" \
    || die "Не удалось создать пользователя ${APP_USER}"
}

prepare_repo_data() {
  setup_app_user
  mkdir -p "${APP_DIR}/data"

  if [[ ! -f "${APP_DIR}/data/visitors.json" ]]; then
    echo '{ "ips": [] }' > "${APP_DIR}/data/visitors.json"
  fi

  chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"
}

install_packages() {
  log "Установка системных пакетов..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq \
    ca-certificates \
    curl \
    git \
    unzip \
    nginx \
    certbot \
    python3-certbot-nginx \
    ufw
}

install_bun() {
  if [[ -x "${BUN_BIN}" ]] && sudo -u "${APP_USER}" "${BUN_BIN}" --version >/dev/null 2>&1; then
    log "Bun уже установлен: $("${BUN_BIN}" --version)"
    return
  fi

  rm -f "${BUN_BIN}"

  if ! command -v unzip >/dev/null 2>&1; then
    log "Установка unzip (нужен для Bun)..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq unzip
  fi

  log "Установка Bun ${BUN_VERSION} в /usr/local..."
  export BUN_INSTALL="/usr/local"
  curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}"

  [[ -x "${BUN_BIN}" ]] || die "Bun не найден: ${BUN_BIN}"
  chmod 755 "${BUN_BIN}"

  if ! sudo -u "${APP_USER}" "${BUN_BIN}" --version >/dev/null 2>&1; then
    die "Пользователь ${APP_USER} не может запустить ${BUN_BIN}"
  fi

  log "Bun установлен: $("${BUN_BIN}" --version)"
}

is_valid_domain() {
  [[ "${1}" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$ ]]
}

is_valid_email() {
  [[ "${1}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

prompt_domain() {
  if [[ -f "${DEPLOY_ENV}" ]]; then
    # shellcheck disable=SC1090
    source "${DEPLOY_ENV}"
    DOMAIN=$(echo "${DOMAIN:-}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    EMAIL=$(echo "${EMAIL:-}" | tr -d '[:space:]')

    if is_valid_domain "${DOMAIN}" && is_valid_email "${EMAIL}"; then
      log "Домен: ${DOMAIN}"
      return
    fi

    warn "Файл ${DEPLOY_ENV} содержит некорректные данные — запросим заново"
    rm -f "${DEPLOY_ENV}"
  fi

  echo ""
  echo "Настройка домена для Nginx и SSL."
  warn "DNS A-запись домена должна указывать на IP этого сервера."
  echo ""

  while true; do
    read -rp "Домен (например xhiveee.ru): " DOMAIN
    DOMAIN=$(echo "${DOMAIN}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if is_valid_domain "${DOMAIN}"; then
      break
    fi
    warn "Введите домен латиницей, например: xhiveee.ru"
  done

  while true; do
    read -rp "Email для Let's Encrypt [admin@${DOMAIN}]: " EMAIL
    EMAIL=$(echo "${EMAIL}" | tr -d '[:space:]')
    EMAIL="${EMAIL:-admin@${DOMAIN}}"
    if is_valid_email "${EMAIL}"; then
      break
    fi
    warn "Введите корректный email латиницей, например: admin@${DOMAIN}"
  done

  cat > "${DEPLOY_ENV}" <<EOF
DOMAIN=${DOMAIN}
EMAIL=${EMAIL}
EOF
  chmod 600 "${DEPLOY_ENV}"
  chown "${APP_USER}:${APP_USER}" "${DEPLOY_ENV}"
}

build_app() {
  log "Установка зависимостей и сборка..."
  cd "${APP_DIR}"
  sudo -u "${APP_USER}" env PATH="/usr/local/bin:${PATH}" "${BUN_BIN}" install --frozen-lockfile 2>/dev/null \
    || sudo -u "${APP_USER}" env PATH="/usr/local/bin:${PATH}" "${BUN_BIN}" install
  sudo -u "${APP_USER}" env PATH="/usr/local/bin:${PATH}" "${BUN_BIN}" run build
  log "Сборка завершена"
}

write_systemd_unit() {
  log "Настройка systemd..."
  cat > "${SYSTEMD_UNIT}" <<EOF
[Unit]
Description=${APP_NAME} — Svelte landing
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}
Environment=PATH=/usr/local/bin:/usr/bin:/bin
Environment=NODE_ENV=production
ExecStart=${BUN_BIN} run preview
Restart=on-failure
RestartSec=5
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable "${APP_NAME}"
  systemctl restart "${APP_NAME}"
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
    log "SSL-сертификат уже существует"
    certbot renew --quiet || true
    return
  fi

  log "Получение SSL-сертификата..."
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
  command -v ufw >/dev/null 2>&1 || return
  log "Настройка UFW..."
  ufw allow OpenSSH >/dev/null 2>&1 || ufw allow 22/tcp
  ufw allow 'Nginx Full' >/dev/null 2>&1 || { ufw allow 80/tcp; ufw allow 443/tcp; }
  ufw --force enable
}

print_summary() {
  echo ""
  log "Готово!"
  echo "  Сайт:    https://${DOMAIN}"
  echo "  Код:     ${APP_DIR}"
  echo "  Статус:  systemctl status ${APP_NAME}"
  echo "  Логи:    journalctl -u ${APP_NAME} -f"
  echo "  Update:  bash ${REPO_SCRIPT} --update"
  echo ""
}

cmd_install() {
  require_root
  detect_os

  if [[ "${DEPLOY_FROM_REPO:-0}" != "1" ]]; then
    bootstrap_repo
    handoff_to_repo_script
  fi

  prepare_repo_data
  install_packages
  install_bun
  prompt_domain
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

  if [[ "${DEPLOY_FROM_REPO:-0}" != "1" ]]; then
    bootstrap_repo
    handoff_to_repo_script --update
  fi

  [[ -d "${APP_DIR}/.git" ]] || die "Проект не установлен. Запустите: bash ${REPO_SCRIPT}"
  configure_git_safe_directory
  git -C "${APP_DIR}" pull --ff-only
  prepare_repo_data
  install_bun
  # shellcheck disable=SC1090
  [[ -f "${DEPLOY_ENV}" ]] && source "${DEPLOY_ENV}"
  build_app
  systemctl restart "${APP_NAME}"
  nginx -t && systemctl reload nginx
  print_summary
}

main() {
  case "${1:-}" in
    --update) cmd_update ;;
    --reconfigure) rm -f "${DEPLOY_ENV}"; cmd_install ;;
    -h|--help)
      cat <<EOF
Использование:
  bash $0               Установка
  bash $0 --update      Обновление
  bash $0 --reconfigure Заново запросить домен и email

Проект: ${APP_DIR}
EOF
      ;;
    "") cmd_install ;;
    *) die "Неизвестный аргумент: $1. Используйте: bash $0 --help" ;;
  esac
}

main "$@"
