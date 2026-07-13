<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { SkinViewer, IdleAnimation, NameTagObject } from 'skinview3d';
  import { Rotate3d } from 'lucide-svelte';
  import { prefersReducedMotion } from '../lib/motion';
  import { ru } from '../lib/ru';

  export let username = 'xhiveee';

  let container: HTMLDivElement;
  let canvas: HTMLCanvasElement;
  let viewer: SkinViewer | null = null;
  let loading = true;
  let error = false;
  let resizeObserver: ResizeObserver | undefined;

  const heightRatio = 1.25 * 1.1;
  const modelZoom = 0.85 * 0.8;
  const nameTagFont = '40px Minecraft';

  async function ensureMinecraftFont() {
    if (!document.fonts.check(nameTagFont)) {
      await document.fonts.load(nameTagFont);
    }
  }

  function setNameTag() {
    if (!viewer) return;

    viewer.nameTag = new NameTagObject(username, {
      font: nameTagFont,
      textStyle: '#ffffff',
      backgroundStyle: 'rgba(0, 0, 0, 0.35)',
      repaintAfterLoaded: true
    });
  }

  function getSize() {
    const width = Math.min(container?.clientWidth ?? 320, 360);
    const height = Math.round(width * heightRatio);
    return { width, height };
  }

  function updateViewerSize() {
    if (!viewer || !container) return;
    const { width, height } = getSize();
    viewer.setSize(width, height);
    viewer.adjustCameraDistance();
  }

  async function initViewer() {
    if (!canvas || !container) return;

    const { width, height } = getSize();
    const reducedMotion = prefersReducedMotion();

    viewer = new SkinViewer({
      canvas,
      width,
      height
    });

    viewer.background = null;
    viewer.zoom = modelZoom;
    viewer.fov = 45;
    viewer.autoRotate = !reducedMotion;
    viewer.autoRotateSpeed = 0.7;

    if (!reducedMotion) {
      viewer.animation = new IdleAnimation();
    }

    await ensureMinecraftFont();

    try {
      await viewer.loadSkin(`https://mc-heads.net/skin/${encodeURIComponent(username)}`);

      try {
        await viewer.loadCape(`https://mc-heads.net/cape/${encodeURIComponent(username)}`);
      } catch {
        viewer.loadCape(null);
      }

      setNameTag();
      loading = false;
      viewer.adjustCameraDistance();
    } catch {
      error = true;
      loading = false;
      viewer.dispose();
      viewer = null;
    }
  }

  onMount(() => {
    void initViewer();

    resizeObserver = new ResizeObserver(() => updateViewerSize());
    resizeObserver.observe(container);

    return () => resizeObserver?.disconnect();
  });

  onDestroy(() => {
    viewer?.dispose();
    viewer = null;
  });
</script>

<div class="skin-viewer" bind:this={container}>
  <div class="skin-panel">
    {#if loading && !error}
      <div class="skin-state">Загрузка скина…</div>
    {/if}

    {#if error}
      <div class="skin-state">Скин не найден</div>
    {/if}

    <canvas
      bind:this={canvas}
      class="skin-canvas"
      class:hidden={loading || error}
      aria-label="3D скин Minecraft: {username}. {ru.landing.skinRotateHint}"
    ></canvas>

    {#if !loading && !error}
      <p class="skin-hint">
        <Rotate3d size={14} strokeWidth={1.75} aria-hidden="true" />
        <span>{ru.landing.skinRotateHint}</span>
      </p>
    {/if}
  </div>
</div>

<style>
  .skin-viewer {
    width: 100%;
    max-width: 22rem;
    margin-inline: auto;
  }

  .skin-panel {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 22rem;
    aspect-ratio: 4 / 5.5;
    background: transparent;
    border-radius: var(--radius-2xl);
    overflow: hidden;
  }

  .skin-canvas {
    width: 100%;
    height: 100%;
    display: block;
  }

  .skin-canvas.hidden {
    opacity: 0;
    pointer-events: none;
  }

  .skin-state {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1rem;
    text-align: center;
    color: var(--muted);
    font-size: 0.875rem;
  }

  .skin-hint {
    position: absolute;
    bottom: 0.875rem;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    align-items: center;
    gap: 0.375rem;
    margin: 0;
    padding: 0.375rem 0.75rem;
    font-size: 0.75rem;
    color: var(--muted);
    background: oklch(0.1 0.018 265 / 0.75);
    border: 1px solid oklch(0.99 0.005 265 / 0.08);
    border-radius: 999px;
    pointer-events: none;
    white-space: nowrap;
  }
</style>
