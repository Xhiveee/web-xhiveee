<script lang="ts">
  import Landing from './components/Landing.svelte';
  import Navigation from './components/Navigation.svelte';
  import Footer from './components/Footer.svelte';
</script>

<div class="page-bg" aria-hidden="true">
  <video
    class="page-bg-video"
    src="/background.mp4"
    autoplay
    muted
    loop
    playsinline
    preload="auto"
  ></video>
</div>

<Navigation />

<main class="app-main">
  <div class="page-shell">
    <Landing />
  </div>
</main>

<Footer />

<style>
  .page-bg {
    position: fixed;
    inset: 0;
    z-index: 0;
    overflow: hidden;
    pointer-events: none;
  }

  .page-bg-video {
    width: 100%;
    height: 100%;
    object-fit: cover;
    filter: brightness(0.55);
  }

  .app-main {
    position: relative;
    z-index: 1;
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .page-shell {
    width: 100%;
    flex: 1;
  }
</style>
