<script lang="ts">
  import { ru } from '../lib/ru';
  import MinecraftHeadAvatar from './MinecraftHeadAvatar.svelte';
  import VisitCounter from './VisitCounter.svelte';
</script>

<div class="nav-shell">
  <nav class="nav">
    <div class="container-wide nav-inner">
      <button type="button" on:click={() => window.scrollTo(0, 0)} class="brand">
        <MinecraftHeadAvatar username={ru.nav.brand} size={26} />
        {ru.nav.brand}
      </button>
      <span class="nav-role">{ru.nav.role}</span>
      <VisitCounter />
    </div>
  </nav>
</div>

<style>
  .nav-shell {
    position: sticky;
    top: 0;
    z-index: var(--z-sticky);
    padding: 0.625rem 1rem 0;
  }

  .nav {
    max-width: 80rem;
    margin-inline: auto;
    border: 1px solid oklch(0.99 0.005 265 / 0.12);
    border-radius: var(--radius-xl);
    background: oklch(0.08 0.015 265 / 0.28);
    backdrop-filter: blur(18px) saturate(1.15);
    box-shadow: 0 8px 32px oklch(0 0 0 / 0.12);
  }

  .nav-inner {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 4.25rem;
    padding-inline: 1rem;
  }

  .brand {
    position: absolute;
    left: 1rem;
    display: flex;
    align-items: center;
    gap: 0.6rem;
    padding: 0;
    border: none;
    background: none;
    font-family: 'Syne', system-ui, sans-serif;
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--ink);
    letter-spacing: -0.02em;
    transition: color 0.3s ease;
  }

  .brand:hover {
    color: var(--accent);
  }

  .nav-role {
    display: inline-block;
    max-width: calc(100% - 18rem);
    font-size: 0.875rem;
    font-weight: 400;
    color: var(--muted);
    letter-spacing: 0.02em;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  @media (min-width: 520px) {
    .nav-shell {
      padding-inline: 1.5rem;
    }
  }

  @media (max-width: 640px) {
    .nav-role {
      display: none;
    }
  }
</style>
