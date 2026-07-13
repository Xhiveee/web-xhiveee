<script lang="ts">
  import type { ComponentType, SvelteComponent } from 'svelte';
  import type { SocialId } from '../../lib/socials';
  import GithubIcon from './GithubIcon.svelte';
  import TelegramIcon from './social/TelegramIcon.svelte';
  import DiscordIcon from './social/DiscordIcon.svelte';
  import YoutubeIcon from './social/YoutubeIcon.svelte';
  import TiktokIcon from './social/TiktokIcon.svelte';

  export let id: SocialId;
  export let size = 18;

  const icons: Record<SocialId, ComponentType<SvelteComponent<{ size?: number }>>> = {
    github: GithubIcon,
    telegram: TelegramIcon,
    discord: DiscordIcon,
    youtube: YoutubeIcon,
    tiktok: TiktokIcon
  };
</script>

<svelte:component this={icons[id]} {size} />
