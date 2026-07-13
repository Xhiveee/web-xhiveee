<script lang="ts">
  export let username = 'xhiveee';
  export let size = 24;

  let errored = false;

  $: src = `https://mc-heads.net/head/${encodeURIComponent(username)}/${size * 2}`;
</script>

{#if !errored}
  <img
    class="mc-head"
    {src}
    alt=""
    width={size}
    height={size}
    loading="lazy"
    decoding="async"
    on:error={() => (errored = true)}
  />
{:else}
  <span
    class="mc-head-fallback"
    style:width="{size}px"
    style:height="{size}px"
    aria-hidden="true"
  ></span>
{/if}

<style>
  .mc-head {
    display: block;
    flex-shrink: 0;
    border-radius: 4px;
    image-rendering: pixelated;
    image-rendering: crisp-edges;
  }

  .mc-head-fallback {
    display: block;
    flex-shrink: 0;
    border-radius: 4px;
    background: oklch(0.99 0.005 265 / 0.12);
    border: 1px solid oklch(0.99 0.005 265 / 0.18);
  }
</style>
