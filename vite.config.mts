/// <reference types="vitest" />
/// <reference types="vite/client" />

import { defineConfig } from 'vite';
import createReactPlugin from '@vitejs/plugin-react';
import createReScriptPlugin from '@jihchi/vite-plugin-rescript';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [createReactPlugin(), createReScriptPlugin()],
  base: './',
  test: {
    include: ['test/**/*_test.bs.js'],
    globals: true,
    environment: 'jsdom',
    setupFiles: './test/setup.ts',
  },
});
