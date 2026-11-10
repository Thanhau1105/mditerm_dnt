import express from 'express';
import cors from 'cors';
import mongoose from 'mongoose';
import { createAuthRoutes } from './routes/authRoutes.js';
import userRoutes from './routes/userRoutes.js';
import { HttpError, errorHandler } from './utils/errors.js';

export function createApp({ config, rateLimitEnabled = true }) {
  const app = express();
  app.disable('x-powered-by');
  app.locals.config = config;
  app.use((req, res, next) => {
    res.set('Cache-Control', 'no-store');
    res.set('X-Content-Type-Options', 'nosniff');
    res.set('Referrer-Policy', 'no-referrer');
    next();
  });
  app.use(cors({
    origin(origin, callback) {
      if (!origin || config.corsOrigins.includes(origin)) return callback(null, true);
      return callback(new HttpError(403, 'Nguồn truy cập web chưa được cho phép.'));
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    maxAge: 600,
  }));
  app.use(express.json({ limit: '3mb' }));
  app.get('/api/health', (req, res) => {
    const connected = mongoose.connection.readyState === 1;
    res.status(connected ? 200 : 503).json({ status: connected ? 'ok' : 'unavailable', database: connected ? 'connected' : 'disconnected' });
  });
  app.use('/api/auth', createAuthRoutes({ rateLimitEnabled }));
  app.use('/api/users', userRoutes);
  app.use((req, res) => res.status(404).json({ message: 'Không tìm thấy API.' }));
  app.use(errorHandler);
  return app;
}
