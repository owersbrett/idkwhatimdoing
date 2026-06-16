import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import { installLessonBridge } from './lesson-bridge';
import './styles.css';

installLessonBridge();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
