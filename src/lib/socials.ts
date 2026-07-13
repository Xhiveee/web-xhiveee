export type SocialId = 'github' | 'telegram' | 'discord' | 'youtube' | 'tiktok';

export interface SocialLink {
  id: SocialId;
  label: string;
  href: string;
  bg: string;
  fg: string;
}

export const socialLinks: SocialLink[] = [
  { id: 'github', label: 'GitHub', href: 'https://github.com/Xhiveee', bg: '#24292f', fg: '#ffffff' },
  { id: 'telegram', label: 'Telegram', href: 'https://t.me/xhiveee', bg: '#26a5e4', fg: '#ffffff' },
  { id: 'discord', label: 'Discord', href: 'https://discord.gg/zEGEdhHneu', bg: '#5865f2', fg: '#ffffff' },
  { id: 'youtube', label: 'YouTube', href: 'https://www.youtube.com/@xhiveee', bg: '#ff0000', fg: '#ffffff' },
  { id: 'tiktok', label: 'TikTok', href: 'https://www.tiktok.com/@xhiveee', bg: '#000000', fg: '#ffffff' }
];
