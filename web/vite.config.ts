import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  build: {
    // Deterministic names let staging replace generated assets without deleting
    // any other data stored alongside the web directory.
    rolldownOptions: {
      output: {
        entryFileNames: 'assets/app.js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name][extname]',
      },
    },
  },
});
