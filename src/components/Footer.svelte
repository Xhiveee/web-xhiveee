<script lang="ts">
  import { ru } from '../lib/ru';
  import { socialLinks } from '../lib/socials';
  import SocialIcon from './icons/SocialIcon.svelte';
  import MinecraftHeadAvatar from './MinecraftHeadAvatar.svelte';

  const year = new Date().getFullYear();
</script>

<footer class="site-footer">
  <div class="footer-card">
    <div class="container-wide footer-shell">
      <div class="footer-grid">
        <div class="footer-brand">
          <MinecraftHeadAvatar username={ru.nav.brand} size={36} />
          <div class="footer-brand-text">
            <button type="button" on:click={() => window.scrollTo(0, 0)} class="brand-link">
              {ru.nav.brand}
            </button>
            <p class="footer-tagline">{ru.footer.tagline}</p>
          </div>
        </div>

        <div class="footer-socials">
          {#each socialLinks as social (social.id)}
            <a
              href={social.href}
              target="_blank"
              rel="noopener noreferrer"
              class="social-btn"
              style:--social-bg={social.bg}
              style:--social-fg={social.fg}
              aria-label={social.label}
              title={social.label}
            >
              <SocialIcon id={social.id} size={16} />
            </a>
          {/each}
        </div>
      </div>

      <div class="footer-divider" aria-hidden="true"></div>

      <p class="footer-copy">{ru.footer.copyright(year)}</p>
    </div>
  </div>
</footer>

<style>
  .site-footer {
    position: relative;
    z-index: 1;
    margin: 0;
    margin-top: auto;
    padding: 0 1rem;
    background: none;
  }

  .footer-card {
    max-width: 80rem;
    margin-inline: auto;
    border: 1px solid oklch(0.99 0.005 265 / 0.12);
    border-bottom: none;
    border-radius: var(--radius-2xl) var(--radius-2xl) 0 0;
    background: oklch(0.08 0.015 265 / 0.28);
    backdrop-filter: blur(18px) saturate(1.15);
    box-shadow: 0 -8px 32px oklch(0 0 0 / 0.1);
  }

  .footer-shell {
    padding: 1rem 1rem max(0.875rem, env(safe-area-inset-bottom, 0px));
  }

  .footer-grid {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.875rem;
  }

  .footer-brand {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    width: 100%;
    max-width: 20rem;
  }

  .footer-brand-text {
    min-width: 0;
  }

  .brand-link {
    display: block;
    padding: 0;
    border: none;
    background: none;
    font-family: 'Syne', system-ui, sans-serif;
    font-size: 1rem;
    font-weight: 700;
    color: var(--ink);
    letter-spacing: -0.02em;
    transition: color 0.3s ease;
  }

  .brand-link:hover {
    color: var(--accent);
  }

  .footer-tagline {
    margin: 0.125rem 0 0;
    font-size: 0.75rem;
    color: var(--muted);
    line-height: 1.4;
  }

  .footer-socials {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: center;
    gap: 0.375rem;
  }

  .social-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2.25rem;
    height: 2.25rem;
    color: var(--social-fg);
    background: var(--social-bg);
    border: none;
    border-radius: 0.5rem;
    box-shadow: 0 1px 2px oklch(0 0 0 / 0.35);
    transition: transform 0.2s ease, filter 0.2s ease, box-shadow 0.2s ease;
  }

  .social-btn:hover {
    filter: brightness(1.08);
    box-shadow: 0 4px 12px oklch(0 0 0 / 0.4);
    transform: translateY(-1px);
  }

  .social-btn:active {
    transform: translateY(0);
    filter: brightness(0.96);
  }

  .footer-divider {
    height: 1px;
    margin: 1.375rem 0 1rem;
    background: linear-gradient(
      90deg,
      transparent,
      oklch(0.99 0.005 265 / 0.14) 20%,
      oklch(0.99 0.005 265 / 0.14) 80%,
      transparent
    );
  }

  .footer-copy {
    margin: 0;
    padding: 0;
    font-size: 0.6875rem;
    line-height: 1.3;
    text-align: center;
    color: var(--muted);
    font-family: 'JetBrains Mono', monospace;
  }

  @media (min-width: 520px) {
    .site-footer {
      padding-inline: 1.5rem;
    }
  }

  @media (min-width: 900px) {
    .footer-shell {
      padding: 1.25rem 1rem max(1rem, env(safe-area-inset-bottom, 0px));
    }

    .footer-grid {
      flex-direction: row;
      align-items: center;
      justify-content: space-between;
      gap: 1.5rem;
    }

    .footer-brand {
      max-width: none;
    }

    .brand-link {
      font-size: 1.125rem;
    }

    .footer-tagline {
      margin-top: 0.25rem;
      font-size: 0.8125rem;
    }

    .footer-socials {
      justify-content: flex-end;
      flex-wrap: nowrap;
      gap: 0.5rem;
    }

    .social-btn {
      width: 2.5rem;
      height: 2.5rem;
    }

    .footer-divider {
      margin: 1.625rem 0 1.125rem;
    }

    .footer-copy {
      font-size: 0.75rem;
    }
  }
</style>
