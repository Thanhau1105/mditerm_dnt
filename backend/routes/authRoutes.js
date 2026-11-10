import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { login, me } from '../controllers/authController.js';
import { authenticate } from '../middleware/authMiddleware.js';

export function createAuthRoutes({ rateLimitEnabled = true } = {}) {
  const router = Router();
  if (rateLimitEnabled) {
    router.post('/login', rateLimit({
      windowMs: 15 * 60 * 1000, limit: 20, standardHeaders: 'draft-8', legacyHeaders: false,
      message: { message: 'Quá nhiều lần đăng nhập. Vui lòng thử lại sau 15 phút.' },
    }));
  }
  router.post('/login', login);
  router.get('/me', authenticate, me);
  return router;
}
