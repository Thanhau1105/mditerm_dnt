import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';

dotenv.config({ path: fileURLToPath(new URL('../.env', import.meta.url)), quiet: true });

export const DATABASE_NAME = 'vku_student_management';

export function readConfig(env = process.env) {
  const jwtSecret = env.JWT_SECRET || '';
  if (Buffer.byteLength(jwtSecret, 'utf8') < 32 || jwtSecret.startsWith('replace-')) {
    throw new Error('JWT_SECRET must be a private, random value of at least 32 bytes.');
  }
  const mongoUri = env.MONGODB_URI || '';
  if (!/^mongodb(?:\+srv)?:\/\//.test(mongoUri)) {
    throw new Error('Set MONGODB_URI in backend/.env to a local Server or Atlas URI.');
  }
  const adminEmail = (env.ADMIN_EMAIL || '').trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(adminEmail)) {
    throw new Error('Set a valid ADMIN_EMAIL in backend/.env.');
  }
  const port = Number(env.PORT || 3000);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535.');
  }
  const corsOrigins = (env.CORS_ORIGINS || 'http://localhost:5173,http://127.0.0.1:5173')
    .split(',').map((origin) => origin.trim()).filter(Boolean);
  if (corsOrigins.includes('*')) {
    throw new Error('CORS_ORIGINS must list explicit web origins, not *.');
  }
  return { mongoUri, jwtSecret, adminEmail, port, host: env.HOST || '0.0.0.0', corsOrigins };
}
