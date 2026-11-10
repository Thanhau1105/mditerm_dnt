import bcrypt from 'bcryptjs';
import User, { publicUser } from '../models/User.js';
import { assertBody, normalizeEmail, validatePassword } from '../utils/validation.js';
import { HttpError } from '../utils/errors.js';
import { issueToken } from '../utils/token.js';

// Keep a costly comparison for unknown emails as well as existing accounts.
const dummyHash = bcrypt.hashSync('unusable-dummy-password', 12);

export async function login(req, res) {
  assertBody(req.body, ['email', 'matkhau']);
  const email = normalizeEmail(req.body.email);
  const password = validatePassword(req.body.matkhau);
  const user = await User.findOne({ email }).select('+matkhau');
  const matches = await bcrypt.compare(password, user?.matkhau || dummyHash);
  if (!user || !matches) throw new HttpError(401, 'Email hoặc mật khẩu không đúng.');
  res.json({
    token: issueToken(user, req.app.locals.config.jwtSecret),
    user: publicUser(user),
    isAdmin: user.email === req.app.locals.config.adminEmail,
  });
}

export function me(req, res) {
  res.json({ user: publicUser(req.user), isAdmin: req.isAdmin });
}
