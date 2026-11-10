import { createHmac, timingSafeEqual } from 'node:crypto';
import jwt from 'jsonwebtoken';

export const TOKEN_ISSUER = 'vku-student-management';
export const TOKEN_AUDIENCE = 'vku-student-management-client';

export function passwordFingerprint(passwordHash, secret) {
  return createHmac('sha256', secret).update(passwordHash).digest('hex');
}

export function equalFingerprint(left, right) {
  if (typeof left !== 'string' || typeof right !== 'string') return false;
  const a = Buffer.from(left, 'utf8');
  const b = Buffer.from(right, 'utf8');
  return a.length === b.length && timingSafeEqual(a, b);
}

export function issueToken(user, secret) {
  return jwt.sign({ pwd: passwordFingerprint(user.matkhau, secret) }, secret, {
    algorithm: 'HS256', expiresIn: '8h', subject: user._id.toString(),
    issuer: TOKEN_ISSUER, audience: TOKEN_AUDIENCE,
  });
}
