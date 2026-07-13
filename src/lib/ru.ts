export const ru = {
  nav: {
    brand: 'xhiveee',
    role: 'DevOps — автоматизация и инфраструктура  |  Разработчик — создание приложений',
    visitorsTitle: 'Уникальные посетители по IP'
  },
  footer: {
    tagline: 'Разработка, Minecraft и инфраструктура',
    copyright: (year: number) => `© ${year} xhiveee. Все права защищены.`
  },
  landing: {
    title: 'Привет, я',
    titleWindow: 'xhiveee@home',
    titlePath: '~/profile',
    titleTerminal: [
      { type: 'command', text: 'ls --skills' },
      { type: 'skill', label: 'web', text: 'приложения, API, сервисы', icon: 'https://api.iconify.design/mdi/web.svg?color=%23ffffff' },
      { type: 'skill', label: 'desktop', text: 'приложения для ПК', icon: 'https://api.iconify.design/mdi/monitor.svg?color=%23ffffff' },
      { type: 'skill', label: 'mobile', text: 'мобильные приложения', icon: 'https://api.iconify.design/mdi/cellphone.svg?color=%23ffffff' },
      { type: 'skill', label: 'minecraft', text: 'моды, плагины, серверы', icon: 'https://api.iconify.design/mdi/cube.svg?color=%23ffffff' },
      { type: 'skill', label: 'servers', text: 'Linux, деплой, мониторинг', icon: 'https://api.iconify.design/mdi/server.svg?color=%23ffffff' },
      { type: 'command', text: 'status' },
      { type: 'success', text: '● online — открыт к проектам' }
    ],
    skinRotateHint: 'Перетащите, чтобы повернуть',
  },
  common: {
    github: 'GitHub'
  }
} as const;
