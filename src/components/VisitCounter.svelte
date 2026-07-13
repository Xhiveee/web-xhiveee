<script lang="ts">
  import { onMount } from 'svelte';
  import { tweened } from 'svelte/motion';
  import { cubicOut } from 'svelte/easing';
  import { Users } from 'lucide-svelte';
  import { ru } from '../lib/ru';

  const displayCount = tweened(0, { duration: 520, easing: cubicOut });

  let bump = false;
  let pulse = false;
  let ready = false;
  let failed = false;

  async function registerVisit() {
    try {
      const response = await fetch('/api/visit', { method: 'POST' });
      if (!response.ok) throw new Error('visit failed');

      const data = (await response.json()) as { count: number; isNew: boolean };
      const nextCount = Math.max(0, data.count);

      if (data.isNew && nextCount > Math.round($displayCount)) {
        bump = true;
        pulse = true;
        window.setTimeout(() => {
          bump = false;
          pulse = false;
        }, 700);
      }

      await displayCount.set(nextCount);
      ready = true;
    } catch {
      failed = true;
    }
  }

  onMount(() => {
    void registerVisit();
  });
</script>

{#if !failed}
  <div
    class="visit-counter"
    class:visit-counter--ready={ready}
    class:visit-counter--bump={bump}
    class:visit-counter--pulse={pulse}
    aria-live="polite"
    aria-atomic="true"
    title={ru.nav.visitorsTitle}
  >
    <Users size={15} strokeWidth={2} aria-hidden="true" />
    <span class="visit-counter__value mono">{Math.round($displayCount)}</span>
  </div>
{/if}

<style>
  .visit-counter {
    position: absolute;
    right: 1rem;
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.375rem 0.625rem;
    color: var(--muted);
    background: oklch(0.12 0.02 265 / 0.55);
    border: 1px solid oklch(0.99 0.005 265 / 0.1);
    border-radius: 999px;
    opacity: 0;
    transform: translateY(-4px);
    transition:
      opacity 0.35s ease,
      transform 0.35s ease,
      border-color 0.35s ease,
      box-shadow 0.35s ease,
      color 0.35s ease;
  }

  .visit-counter--ready {
    opacity: 1;
    transform: translateY(0);
  }

  .visit-counter--bump .visit-counter__value {
    animation: counter-bump 0.55s cubic-bezier(0.25, 1, 0.5, 1);
  }

  .visit-counter--pulse {
    border-color: oklch(0.72 0.16 155 / 0.45);
    box-shadow: 0 0 0 1px oklch(0.72 0.16 155 / 0.12), 0 0 18px oklch(0.72 0.16 155 / 0.18);
    color: var(--ink);
  }

  .visit-counter__value {
    min-width: 1.25rem;
    font-size: 0.8125rem;
    font-weight: 600;
    color: var(--ink);
    text-align: center;
    line-height: 1;
  }

  @keyframes counter-bump {
    0% {
      transform: scale(1);
    }
    35% {
      transform: scale(1.28);
      color: var(--success);
    }
    100% {
      transform: scale(1);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .visit-counter {
      transition: none;
    }

    .visit-counter--bump .visit-counter__value {
      animation: none;
      color: var(--success);
    }
  }
</style>
