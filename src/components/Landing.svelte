<script lang="ts">
  import { onMount } from 'svelte';
  import GithubIcon from './icons/GithubIcon.svelte';
  import TelegramIcon from './icons/social/TelegramIcon.svelte';
  import { stackPills } from '../lib/stackIcons';
  import { ru } from '../lib/ru';
  import { prefersReducedMotion } from '../lib/motion';
  import MinecraftSkin from './MinecraftSkin.svelte';

  let motionReady = false;

  onMount(() => {
    motionReady = !prefersReducedMotion();
    if (motionReady) {
      document.documentElement.classList.add('motion-ready');
    }
  });
</script>

<section class="hero">
  <div class="container-wide">
    <div class="hero-grid">
      <div class="hero-content">
        <div class="stack-row" class:hero-enter={motionReady} style="--hero-delay: 0ms">
          {#each stackPills as pill}
            <span class="chip">
              {#if pill.badge}
                <span class="stack-icon-badge" aria-hidden="true">
                  <img
                    class="stack-icon stack-icon--badged"
                    src={pill.icon}
                    alt=""
                    width="18"
                    height="18"
                    loading="lazy"
                    decoding="async"
                  />
                </span>
              {:else}
                <img
                  class="stack-icon stack-icon--plain"
                  src={pill.icon}
                  alt=""
                  width="20"
                  height="20"
                  loading="lazy"
                  decoding="async"
                />
              {/if}
              {pill.label}
            </span>
          {/each}
        </div>

        <h1
          class="hero-title"
          class:hero-enter={motionReady}
          style="--hero-delay: 80ms"
        >
          <span class="title-display font-display">
            {ru.landing.title}{' '}
            <span class="title-accent mono">{ru.nav.brand}</span>
          </span>
          <span class="title-terminal" aria-hidden="false">
            <span class="terminal-bar">
              <span class="terminal-dots" aria-hidden="true">
                <span></span><span></span><span></span>
              </span>
              <span class="terminal-window mono">{ru.landing.titleWindow}</span>
              <span class="terminal-path mono">{ru.landing.titlePath}</span>
            </span>
            <span class="terminal-body mono">
              {#each ru.landing.titleTerminal as line}
                {#if line.type === 'command'}
                  <span class="terminal-line">
                    <span class="terminal-prompt" aria-hidden="true">$</span>
                    <span class="terminal-text">{line.text}</span>
                  </span>
                {:else if line.type === 'skill'}
                  <span class="terminal-line terminal-line--skill">
                    <span class="terminal-skill-label">
                      <img src={line.icon} alt="" width="16" height="16" />
                      {line.label}
                    </span>
                    <span class="terminal-text">{line.text}</span>
                  </span>
                {:else if line.type === 'success'}
                  <span class="terminal-line terminal-line--success">
                    <span class="terminal-text">{line.text}</span>
                  </span>
                {/if}
              {/each}
              <span class="terminal-line terminal-line--active">
                <span class="terminal-prompt" aria-hidden="true">$</span>
                <span class="terminal-text terminal-text--dim">_</span>
                <span class="terminal-cursor" aria-hidden="true"></span>
              </span>
            </span>
          </span>
        </h1>

        <div
          class="hero-actions"
          class:hero-enter={motionReady}
          style="--hero-delay: 160ms"
        >
          <a
            href="https://github.com/Xhiveee"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-github"
          >
            <GithubIcon size={20} />
            {ru.common.github}
          </a>
          <a
            href="https://t.me/xhiveee"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-order"
          >
            <TelegramIcon size={20} />
            Заказать
          </a>
        </div>
      </div>

      <div class="hero-visual" class:hero-enter={motionReady} style="--hero-delay: 200ms">
        <MinecraftSkin username={ru.nav.brand} />
      </div>
    </div>
  </div>
</section>

<style>
  .hero {
    position: relative;
    min-height: calc(100vh - 4.25rem);
    min-height: calc(100dvh - 4.25rem);
    display: flex;
    align-items: center;
    align-items: safe center;
    padding-inline: 1rem;
  }

  @media (max-width: 640px) {
    .hero {
      padding-bottom: 2rem;
    }
  }

  .hero .container-wide {
    width: 100%;
    position: relative;
    z-index: 1;
  }

  .hero-grid {
    display: grid;
    gap: 3rem;
    align-items: center;
  }

  @media (min-width: 1024px) {
    .hero-grid {
      grid-template-columns: 1.1fr minmax(16rem, 0.75fr);
      gap: 4rem;
    }

    .hero-content {
      max-width: 42rem;
    }
  }

  .hero-content {
    display: flex;
    flex-direction: column;
    gap: 2.75rem;
  }

  @media (min-width: 768px) {
    .hero-content {
      gap: 3.25rem;
    }
  }

  .hero-visual {
    display: flex;
    justify-content: center;
  }

  @media (max-width: 1023px) {
    .hero-visual {
      order: -1;
      max-width: 16rem;
      margin-inline: auto;
    }
  }

  .stack-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0.625rem;
  }

  .stack-icon-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    width: 1.625rem;
    height: 1.625rem;
    background: oklch(0.99 0.005 265 / 0.96);
    border: 1px solid oklch(0.99 0.005 265 / 0.12);
    border-radius: var(--radius-sm);
    box-shadow: 0 1px 4px oklch(0 0 0 / 0.2);
  }

  .stack-icon {
    display: block;
    flex-shrink: 0;
    object-fit: contain;
  }

  .stack-icon--badged {
    width: 1.125rem;
    height: 1.125rem;
  }

  .stack-icon--plain {
    width: 1.25rem;
    height: 1.25rem;
  }

  .hero-title {
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
  }

  .title-display {
    display: block;
    font-size: clamp(1.95rem, 3.36vw, 2.4rem);
    font-weight: 700;
    line-height: 1.15;
    letter-spacing: -0.025em;
    text-shadow: 0 0 24px oklch(0.99 0.005 265 / 0.08);
  }

  .title-accent {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.94em;
    font-weight: 700;
    letter-spacing: 0;
    color: transparent;
    background: linear-gradient(
      90deg,
      oklch(0.7 0.14 150) 0%,
      oklch(0.85 0.14 190) 38%,
      oklch(0.75 0.14 230) 50%,
      oklch(0.85 0.14 190) 62%,
      oklch(0.7 0.14 150) 100%
    );
    background-size: 200% 100%;
    -webkit-background-clip: text;
    background-clip: text;
    -webkit-text-fill-color: transparent;
    text-shadow: none;
    animation: title-accent-shimmer 1.5s linear infinite;
  }

  .title-terminal {
    display: flex;
    flex-direction: column;
    width: 100%;
    max-width: 36rem;
    border: 1px solid oklch(0.99 0.005 265 / 0.14);
    border-radius: var(--radius-xl);
    overflow: hidden;
    background: oklch(0.08 0.015 265 / 0.9);
    box-shadow:
      0 0 0 1px oklch(0.99 0.005 265 / 0.05),
      0 16px 48px oklch(0 0 0 / 0.35);
  }

  .terminal-bar {
    display: flex;
    align-items: center;
    gap: 0.875rem;
    padding: 0.75rem 1rem;
    background: oklch(0.12 0.02 265 / 0.95);
    border-bottom: 1px solid oklch(0.99 0.005 265 / 0.1);
  }

  .terminal-dots {
    display: flex;
    gap: 0.4375rem;
    flex-shrink: 0;
  }

  .terminal-dots span {
    width: 0.625rem;
    height: 0.625rem;
    border-radius: 50%;
    background: oklch(0.99 0.005 265 / 0.15);
  }

  .terminal-dots span:first-child {
    background: oklch(0.65 0.18 25 / 0.7);
  }

  .terminal-dots span:nth-child(2) {
    background: oklch(0.78 0.14 85 / 0.7);
  }

  .terminal-dots span:last-child {
    background: oklch(0.72 0.16 155 / 0.7);
  }

  .terminal-window {
    font-size: 0.75rem;
    font-weight: 500;
    color: var(--ink);
    letter-spacing: 0.02em;
    white-space: nowrap;
  }

  .terminal-path {
    margin-left: auto;
    font-size: 0.75rem;
    color: var(--muted);
    letter-spacing: 0.04em;
    white-space: nowrap;
  }

  .terminal-body {
    display: flex;
    flex-direction: column;
    gap: 0.375rem;
    padding: 1rem 1.125rem 1.125rem;
    font-size: clamp(0.875rem, 1.9vw, 1rem);
    line-height: 1.45;
  }

  .terminal-line {
    display: flex;
    align-items: baseline;
    gap: 0.625rem;
    min-height: 1.45em;
  }

  .terminal-line--success .terminal-text {
    padding-left: 1.25rem;
  }

  .terminal-line--skill {
    display: grid;
    grid-template-columns: 7.5rem 1fr;
    gap: 0.75rem;
    padding-left: 1.25rem;
  }

  .terminal-skill-label {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    font-weight: 400;
    text-transform: uppercase;
    color: var(--ink);
  }

  .terminal-line--skill .terminal-text {
    color: var(--highlight-faint);
  }

  .terminal-line--success .terminal-text {
    color: var(--success);
  }

  .terminal-line--active {
    margin-top: 0.25rem;
  }

  .terminal-prompt {
    flex-shrink: 0;
    color: var(--accent);
    font-weight: 600;
    user-select: none;
  }

  .terminal-text {
    color: var(--ink);
  }

  .terminal-text--dim {
    color: var(--muted);
    opacity: 0.35;
  }

  .terminal-cursor {
    display: inline-block;
    flex-shrink: 0;
    width: 0.55rem;
    height: 1.05em;
    margin-left: 0.125rem;
    background: var(--accent);
    animation: terminal-blink 1.15s step-end infinite;
  }

  @keyframes title-accent-shimmer {
    from {
      background-position: 0% 0;
    }
    to {
      background-position: 200% 0;
    }
  }

  @keyframes terminal-blink {
    0%,
    45% {
      opacity: 1;
    }
    50%,
    100% {
      opacity: 0;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .terminal-cursor {
      animation: none;
      opacity: 1;
    }

    .title-accent {
      animation: none;
    }
  }

  .hero-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
  }
</style>
