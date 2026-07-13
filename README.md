<div align="center">

# xhiveee

**Персональный лендинг-визитка**

DevOps, разработка приложений и Minecraft

<br />

[![Svelte](https://img.shields.io/badge/Svelte-FF3E00?style=for-the-badge&logo=svelte&logoColor=white)](https://svelte.dev/)
[![Vite](https://img.shields.io/badge/Vite-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Bun](https://img.shields.io/badge/Bun-000000?style=for-the-badge&logo=bun&logoColor=white)](https://bun.sh/)

</div>

---

## О проекте

Одностраничный сайт на **Svelte 4** с тёмной темой, видеофоном и анимациями. В шапке — счётчик уникальных посетителей по IP, в hero-блоке — 3D-скин Minecraft и терминальный блок с навыками.

| Раздел | Описание |
|--------|----------|
| Hero | Стек технологий, терминал с навыками, 3D-скин, кнопки GitHub и Telegram |
| Навигация | Аватар Minecraft, роль, счётчик посещений |
| Подвал | Соцсети, теглайн, копирайт |

---

## Быстрый старт

**Требования:** [Bun](https://bun.sh/) 1.3+

```bash
git clone https://github.com/Xhiveee/web-xhiveee.git
cd web-xhiveee
bun install
bun run dev
```

Сайт откроется на `http://127.0.0.1:5173`

---

## Скрипты

| Команда | Назначение |
|---------|------------|
| `bun run dev` | Локальная разработка |
| `bun run build` | Сборка в `dist/` |
| `bun run preview` | Предпросмотр production-сборки |
| `bun run check` | Проверка типов (svelte-check) |

---

## Структура проекта

```
web-xhiveee/
├── public/              Статика: фон, favicon, курсор
├── src/
│   ├── components/      UI-компоненты
│   ├── lib/             Тексты, соцсети, утилиты
│   ├── App.svelte       Корневой layout
│   ├── app.css          Глобальные стили
│   └── main.ts          Точка входа
├── vite-plugins/        Плагин счётчика посещений
├── scripts/
│   ├── deploy-vds.sh    Деплой на VDS
│   └── SITE-MANAGEMENT.md  Руководство по управлению
├── index.html
├── vite.config.ts
└── tailwind.config.js
```

---

## Деплой на VDS

**Требования:** Ubuntu/Debian, root, DNS A-запись домена → IP сервера.

### Установка одной командой

На чистом VDS (от root):

```bash
curl -fsSL https://raw.githubusercontent.com/Xhiveee/web-xhiveee/main/scripts/deploy-vds.sh -o deploy-vds.sh && bash deploy-vds.sh
```

Или по шагам:

```bash
curl -fsSL https://raw.githubusercontent.com/Xhiveee/web-xhiveee/main/scripts/deploy-vds.sh -o deploy-vds.sh
bash deploy-vds.sh
```

Скрипт автоматически:
- клонирует репозиторий в `/opt/xhiveee`
- установит nginx, certbot, bun, unzip и другие пакеты
- спросит **домен** и email для SSL
- соберёт и запустит сайт

### Повторный запуск / обновление

Если репозиторий уже установлен:

```bash
bash /opt/xhiveee/scripts/deploy-vds.sh
```

Обновление кода с GitHub:

```bash
bash /opt/xhiveee/scripts/deploy-vds.sh --update
```

Подробнее — в [SITE-MANAGEMENT.md](scripts/SITE-MANAGEMENT.md).

---

## Стек

[![Svelte](https://img.shields.io/badge/Svelte-FF3E00?style=for-the-badge&logo=svelte&logoColor=white)](https://svelte.dev/)
[![Vite](https://img.shields.io/badge/Vite-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Bun](https://img.shields.io/badge/Bun-000000?style=for-the-badge&logo=bun&logoColor=white)](https://bun.sh/)

---

## Лицензия

© 2026 **xhiveee**. Все права защищены.

Распространение, копирование и коммерческое использование без письменного разрешения запрещены.  
Полный текст — в файле [LICENSE](LICENSE).

---

<div align="center">

**[GitHub](https://github.com/Xhiveee)** · **[Telegram](https://t.me/xhiveee)**

</div>
