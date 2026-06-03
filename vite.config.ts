import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Dev server: http://localhost:4747
export default defineConfig({
  plugins: [react()],
  server: { port: 4747, strictPort: true },
});
