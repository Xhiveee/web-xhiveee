# Руководство по управлению сайтом после установки

Документ описывает, как управлять сайтом **web-xhiveee** на VDS после запуска `scripts/deploy-vds.sh --init`.

---

## 1. Как устроен сервер после установки

```
Интернет
   │
   ▼
Nginx (порты 80/443, SSL)
   │  proxy_pass + заголовки X-Real-IP / X-Forwarded-For
   ▼
systemd-сервис web-xhiveee
   │  bun run preview → 127.0.0.1:4173
   ▼
Vite preview + visitCounter plugin
   ├── отдаёт собранный dist/
   └── API /api/visit, /api/visits
           │
           ▼
       data/visitors.json
```

| Что | Где / как называется |
|-----|----------------------|
| Код проекта | `/var/www/web-xhiveee` |
| Пользователь сервиса | `web-xhiveee` |
| systemd-сервис | `web-xhiveee` |
| Nginx-конфиг | `/etc/nginx/sites-available/web-xhiveee` |
| Сборка | `/var/www/web-xhiveee/dist` |
| Счётчик посещений | `/var/www/web-xhiveee/data/visitors.json` |
| SSL-сертификат | `/etc/letsencrypt/live/<домен>/` |
| Внутренний порт приложения | `127.0.0.1:4173` |

По умолчанию домен: **xhiveee.ru** (задаётся переменной `DOMAIN` при установке).

---

## 2. Быстрые команды

Все команды ниже выполняются **на VDS от root** (или через `sudo`).

### Статус и перезапуск

```bash
# Статус приложения
systemctl status web-xhiveee

# Перезапуск сайта
systemctl restart web-xhiveee

# Остановить / запустить
systemctl stop web-xhiveee
systemctl start web-xhiveee

# Статус Nginx
systemctl status nginx

# Перезагрузить Nginx (после правки конфига)
nginx -t && systemctl reload nginx
```

### Логи

```bash
# Логи приложения в реальном времени
journalctl -u web-xhiveee -f

# Последние 100 строк
journalctl -u web-xhiveee -n 100 --no-pager

# Логи Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Проверка, что сайт отвечает

```bash
curl -I https://xhiveee.ru
curl -s https://xhiveee.ru/api/visits
```

---

## 3. Обновление сайта

### Вариант A — через Git (если при установке указали GIT_REPO)

```bash
cd /var/www/web-xhiveee
bash scripts/deploy-vds.sh --update
```

Скрипт сам:
1. сделает `git pull`
2. установит зависимости
3. пересоберёт проект
4. перезапустит сервис

### Вариант B — загрузка с локального компьютера (rsync)

**С Linux / macOS / WSL:**

```bash
rsync -avz --delete \
  --exclude node_modules \
  --exclude dist \
  --exclude .bun-cache \
  --exclude data/visitors.json \
  ./ root@IP_СЕРВЕРА:/var/www/web-xhiveee/

ssh root@IP_СЕРВЕРА 'bash /var/www/web-xhiveee/scripts/deploy-vds.sh --update'
```

**Важно:** не перезаписывайте `data/visitors.json` — там хранится счётчик уникальных IP.

### Ручное обновление (без скрипта)

```bash
cd /var/www/web-xhiveee
sudo -u web-xhiveee env PATH="/usr/local/bin:$PATH" bun install
sudo -u web-xhiveee env PATH="/usr/local/bin:$PATH" bun run build
systemctl restart web-xhiveee
```

---

## 4. Редактирование контента

Основные файлы, которые обычно меняют:

| Файл | Что меняется |
|------|--------------|
| `src/lib/ru.ts` | Тексты: заголовки, роль в шапке, терминал, подвал |
| `src/lib/socials.ts` | Ссылки на соцсети |
| `src/lib/stackIcons.ts` | Чипы технологий (Java, TS и т.д.) |
| `public/background.mp4` | Фоновое видео |
| `public/favicon.png` | Иконка вкладки |
| `public/cursor.png` | Кастомный курсор |

### Порядок действий

1. Отредактировать файл(ы) локально или на сервере.
2. Выполнить обновление (см. раздел 3).
3. Проверить сайт в браузере (лучше с Ctrl+F5).

### Редактирование прямо на сервере

```bash
nano /var/www/web-xhiveee/src/lib/ru.ts
# после правок:
bash /var/www/web-xhiveee/scripts/deploy-vds.sh --update
```

---

## 5. Счётчик посещений

Счётчик считает **уникальные IP-адреса** и хранит их в:

```
/var/www/web-xhiveee/data/visitors.json
```

Пример содержимого:

```json
{
  "ips": [
    "1.2.3.4",
    "5.6.7.8"
  ]
}
```

Количество элементов в `ips` = число на счётчике в шапке.

### Посмотреть текущее значение

```bash
cat /var/www/web-xhiveee/data/visitors.json
# или через API:
curl -s https://xhiveee.ru/api/visits
```

### Сбросить счётчик

```bash
echo '{ "ips": [] }' > /var/www/web-xhiveee/data/visitors.json
chown web-xhiveee:web-xhiveee /var/www/web-xhiveee/data/visitors.json
systemctl restart web-xhiveee
```

### Резервная копия счётчика

```bash
cp /var/www/web-xhiveee/data/visitors.json \
   /var/www/web-xhiveee/data/visitors.json.bak.$(date +%F)
```

### Если счётчик не отображается

1. Проверьте, что сервис запущен: `systemctl status web-xhiveee`
2. Проверьте API: `curl -X POST https://xhiveee.ru/api/visit`
3. Убедитесь, что Nginx передаёт IP-заголовки (они настроены скриптом автоматически)
4. Посмотрите логи: `journalctl -u web-xhiveee -n 50`

---

## 6. Домен и SSL

### Смена домена

1. Настройте DNS: A-запись нового домена → IP сервера.
2. Отредактируйте Nginx:

```bash
nano /etc/nginx/sites-available/web-xhiveee
# замените server_name на новый домен
nginx -t && systemctl reload nginx
```

3. Получите новый сертификат:

```bash
certbot --nginx -d новый-домен.ru -d www.новый-домен.ru
```

### Продление SSL

Certbot обычно ставит автообновление через systemd timer / cron.

```bash
# Проверка автообновления
systemctl list-timers | grep certbot

# Ручное продление
certbot renew --dry-run   # тест
certbot renew             # реальное продление
```

После продления Nginx перезагружается автоматически.

---

## 7. Nginx

Конфиг: `/etc/nginx/sites-available/web-xhiveee`

Типичные задачи:

```bash
# Проверить синтаксис
nginx -t

# Перечитать конфиг без простоя
systemctl reload nginx

# Полный перезапуск (если reload не помог)
systemctl restart nginx
```

Если сайт отдаёт 502 Bad Gateway — чаще всего не запущен `web-xhiveee`:

```bash
systemctl restart web-xhiveee
systemctl status web-xhiveee
```

---

## 8. Файрвол (UFW)

Скрипт установки открывает порты **22**, **80**, **443**.

```bash
ufw status

# Если нужно открыть порт вручную
ufw allow 80/tcp
ufw allow 443/tcp
```

**Не открывайте порт 4173 наружу** — приложение слушает только localhost, доступ идёт через Nginx.

---

## 9. Резервное копирование

### Что стоит бэкапить

| Путь | Зачем |
|------|-------|
| `/var/www/web-xhiveee/data/visitors.json` | Счётчик посещений |
| `/var/www/web-xhiveee/src/` | Контент и правки |
| `/etc/nginx/sites-available/web-xhiveee` | Конфиг Nginx |
| `/etc/letsencrypt/` | SSL (опционально) |

### Пример архива

```bash
tar -czf ~/backup-web-xhiveee-$(date +%F).tar.gz \
  /var/www/web-xhiveee/data/visitors.json \
  /var/www/web-xhiveee/src \
  /etc/nginx/sites-available/web-xhiveee
```

### Восстановление счётчика

```bash
tar -xzf backup-web-xhiveee-YYYY-MM-DD.tar.gz -C /
chown web-xhiveee:web-xhiveee /var/www/web-xhiveee/data/visitors.json
systemctl restart web-xhiveee
```

---

## 10. Диагностика проблем

### Сайт не открывается

```bash
systemctl status nginx
systemctl status web-xhiveee
curl -I http://127.0.0.1:4173
ufw status
```

### Ошибка при сборке

```bash
cd /var/www/web-xhiveee
sudo -u web-xhiveee env PATH="/usr/local/bin:$PATH" bun run build
```

### Bun не найден

```bash
which bun
bun --version
# если нет — переустановите:
curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.14"
ln -sf /root/.bun/bin/bun /usr/local/bin/bun
```

### Права на файлы

Владелец проекта — пользователь `web-xhiveee`:

```bash
chown -R web-xhiveee:web-xhiveee /var/www/web-xhiveee
```

### После смены vite.config.ts или systemd

```bash
bash /var/www/web-xhiveee/scripts/deploy-vds.sh --update
# или только перезапуск:
systemctl daemon-reload
systemctl restart web-xhiveee
```

---

## 11. Полезные алиасы (опционально)

Добавьте в `~/.bashrc` на сервере:

```bash
alias site-status='systemctl status web-xhiveee nginx'
alias site-logs='journalctl -u web-xhiveee -f'
alias site-update='bash /var/www/web-xhiveee/scripts/deploy-vds.sh --update'
alias site-restart='systemctl restart web-xhiveee && systemctl reload nginx'
```

Применить: `source ~/.bashrc`

---

## 12. Чеклист после любых изменений

- [ ] `bun run build` прошёл без ошибок
- [ ] `systemctl status web-xhiveee` — `active (running)`
- [ ] `curl -I https://xhiveee.ru` — ответ 200/301
- [ ] Счётчик в шапке обновляется
- [ ] SSL валиден (замок в браузере)
- [ ] `data/visitors.json` на месте и с правильным владельцем

---

## 13. Переменные скрипта деплоя

При повторном запуске можно переопределять:

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `DOMAIN` | `xhiveee.ru` | Домен сайта |
| `EMAIL` | `admin@<домен>` | Email для Let's Encrypt |
| `GIT_REPO` | — | URL репозитория |
| `APP_DIR` | `/var/www/web-xhiveee` | Путь установки |
| `APP_PORT` | `4173` | Внутренний порт preview |
| `BUN_VERSION` | `1.3.14` | Версия Bun |

Пример:

```bash
DOMAIN=xhiveee.ru EMAIL=you@mail.ru \
  bash /var/www/web-xhiveee/scripts/deploy-vds.sh --update
```
