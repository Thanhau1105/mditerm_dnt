import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { HttpError } from '../utils/errors.js';
import { TOKEN_AUDIENCE, TOKEN_ISSUER, equalFingerprint, passwordFingerprint } from '../utils/token.js';

export async function authenticate(req, res, next) {
  const authorization = req.get('authorization') || '';
  if (!authorization.startsWith('Bearer ')) throw new HttpError(401, 'Vui lòng đăng nhập.');
  let payload;
  try {
    payload = jwt.verify(authorization.slice(7), req.app.locals.config.jwtSecret, {
      algorithms: ['HS256'], issuer: TOKEN_ISSUER, audience: TOKEN_AUDIENCE,
    });
  } catch {
    throw new HttpError(401, 'Phiên đăng nhập hết hạn hoặc không hợp lệ.');
  }
  if (typeof payload !== 'object' || !/^[a-f\d]{24}$/i.test(payload.sub || '')) {
    throw new HttpError(401, 'Phiên đăng nhập không hợp lệ.');
  }
  const user = await User.findById(payload.sub).select('+matkhau');
  if (!user || !equalFingerprint(payload.pwd, passwordFingerprint(user.matkhau, req.app.locals.config.jwtSecret))) {
    throw new HttpError(401, 'Tài khoản đã thay đổi. Vui lòng đăng nhập lại.');
  }
  req.user = user;
  req.isAdmin = user.email === req.app.locals.config.adminEmail;
  next();
}

export function requireAdmin(req, res, next) {
  if (!req.isAdmin) throw new HttpError(403, 'Chỉ quản trị viên được thực hiện thao tác này.');
  next();
}
