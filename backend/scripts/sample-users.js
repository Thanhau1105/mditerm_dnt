import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import { validateUserBody } from '../utils/validation.js';

export const DEVELOPMENT_PASSWORD = 'Vku@123456';
export const DEFAULT_ADMIN_EMAIL = 'hautt.23it@vku.udn.vn';

export function sampleUsers(adminEmail = DEFAULT_ADMIN_EMAIL) {
  return [
    { email: adminEmail, matkhau: DEVELOPMENT_PASSWORD, hoten: 'Trần Thành Hậu', hinhanh: '' },
    { email: 'an.nguyen23@vku.udn.vn', matkhau: DEVELOPMENT_PASSWORD, hoten: 'Nguyễn Hoài An', hinhanh: '' },
    { email: 'binh.tran23@vku.udn.vn', matkhau: DEVELOPMENT_PASSWORD, hoten: 'Trần Thanh Bình', hinhanh: '' },
    { email: 'chi.le23@vku.udn.vn', matkhau: DEVELOPMENT_PASSWORD, hoten: 'Lê Ngọc Chi', hinhanh: '' },
    { email: 'dung.pham23@vku.udn.vn', matkhau: DEVELOPMENT_PASSWORD, hoten: 'Phạm Anh Dũng', hinhanh: '' },
  ].map((user) => validateUserBody(user));
}

export async function fixtureDocuments(adminEmail = DEFAULT_ADMIN_EMAIL) {
  return Promise.all(sampleUsers(adminEmail).map(async (user) => ({
    ...user, matkhau: await bcrypt.hash(user.matkhau, 12),
  })));
}

export async function seedSampleUsers(adminEmail = DEFAULT_ADMIN_EMAIL) {
  let inserted = 0;
  let skipped = 0;
  await User.init();
  for (const user of sampleUsers(adminEmail)) {
    if (await User.exists({ email: user.email })) {
      skipped += 1;
      continue;
    }
    try {
      await User.create(user);
      inserted += 1;
    } catch (error) {
      if (error.code === 11000) skipped += 1;
      else throw error;
    }
  }
  return { inserted, skipped };
}
