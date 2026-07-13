import { defineConfig } from 'vite';
import { svelte, vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import { visitCounterPlugin } from './vite-plugins/visitCounter';

export default defineConfig({
  plugins: [
    svelte({
      preprocess: vitePreprocess()
    }),
    visitCounterPlugin()
  ],
  server: {
    host: '127.0.0.1',
    port: 5173
  },
  preview: {
    host: '127.0.0.1',
    port: 4173,
    strictPort: true
  }
});
