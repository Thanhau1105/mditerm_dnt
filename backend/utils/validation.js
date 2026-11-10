import { HttpError } from './errors.js';

export const MAX_IMAGE_BYTES = 2 * 1024 * 1024;
export const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const allowedUserFields = ['email', 'matkhau', 'hoten', 'hinhanh'];

export function assertBody(body, allowedFields) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    throw new HttpError(400, 'Nội dung yêu cầu phải là một đối tượng JSON.');
  }
  if (Object.keys(body).some((key) => !allowedFields.includes(key))) {
    throw new HttpError(400, 'Yêu cầu chứa trường không được phép.');
  }
}

export function normalizeEmail(value) {
  if (typeof value !== 'string' || value.trim().length > 254 || !EMAIL_PATTERN.test(value.trim())) {
    throw new HttpError(400, 'Email không hợp lệ.', { email: 'Nhập email hợp lệ, tối đa 254 ký tự.' });
  }
  return value.trim().toLowerCase();
}

export function validatePassword(value) {
  if (typeof value !== 'string' || value.length < 6 || Buffer.byteLength(value, 'utf8') > 72) {
    throw new HttpError(400, 'Mật khẩu cần ít nhất 6 ký tự và không quá 72 byte UTF-8.', {
      matkhau: 'Mật khẩu cần ít nhất 6 ký tự và không quá 72 byte UTF-8.',
    });
  }
  return value;
}

export function validateImage(value) {
  if (value === '') return value;
  if (typeof value !== 'string' || value.length > 4 * Math.ceil(MAX_IMAGE_BYTES / 3)
      || value.length % 4 !== 0 || !/^[A-Za-z0-9+/]*={0,2}$/.test(value)) {
    throw new HttpError(400, 'Ảnh phải là Base64 thuần của JPEG, PNG hoặc WebP, tối đa 2 MiB.');
  }
  const bytes = Buffer.from(value, 'base64');
  const isPng = bytes.length >= 24
    && bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))
    && bytes.subarray(12, 16).toString('ascii') === 'IHDR';
  const isJpeg = bytes.length >= 4 && bytes[0] === 0xff && bytes[1] === 0xd8
    && bytes[2] === 0xff && bytes.at(-2) === 0xff && bytes.at(-1) === 0xd9;
  const isWebp = bytes.length >= 16 && bytes.subarray(0, 4).toString('ascii') === 'RIFF'
    && bytes.subarray(8, 12).toString('ascii') === 'WEBP';
  if (bytes.length > MAX_IMAGE_BYTES || bytes.toString('base64') !== value || !(isPng || isJpeg || isWebp)) {
    throw new HttpError(400, 'Chỉ chấp nhận ảnh JPEG, PNG hoặc WebP tối đa 2 MiB.');
  }
  return value;
}

export function validateUserBody(body, { update = false } = {}) {
  assertBody(body, allowedUserFields);
  const clean = {};
  if (!update || Object.hasOwn(body, 'email')) clean.email = normalizeEmail(body.email);
  if (!update || Object.hasOwn(body, 'hoten')) {
    if (typeof body.hoten !== 'string' || body.hoten.trim().length < 2 || body.hoten.trim().length > 100) {
      throw new HttpError(400, 'Họ tên cần từ 2 đến 100 ký tự.', { hoten: 'Họ tên cần từ 2 đến 100 ký tự.' });
    }
    clean.hoten = body.hoten.trim();
  }
  if (!update || (Object.hasOwn(body, 'matkhau') && body.matkhau !== '')) {
    clean.matkhau = validatePassword(body.matkhau);
  }
  if (Object.hasOwn(body, 'hinhanh')) clean.hinhanh = validateImage(body.hinhanh);
  else if (!update) clean.hinhanh = '';
  if (update && Object.keys(clean).length === 0) throw new HttpError(400, 'Chưa có thông tin cần cập nhật.');
  return clean;
}

export function assertId(id) {
  if (typeof id !== 'string' || !/^[a-f\d]{24}$/i.test(id)) {
    throw new HttpError(400, 'Mã sinh viên không hợp lệ.');
  }
}
