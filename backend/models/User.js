import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import { EMAIL_PATTERN, validateImage, validatePassword } from '../utils/validation.js';

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, trim: true, lowercase: true, maxlength: 254, match: EMAIL_PATTERN, unique: true },
  matkhau: { type: String, required: true, select: false },
  hoten: { type: String, required: true, trim: true, minlength: 2, maxlength: 100 },
  hinhanh: {
    type: String,
    default: '',
    validate: { validator(value) { try { validateImage(value); return true; } catch { return false; } }, message: 'Ảnh không hợp lệ.' },
  },
}, { collection: 'users', versionKey: false, timestamps: false, strict: 'throw' });

userSchema.pre('save', async function hashChangedPassword() {
  if (this.isModified('matkhau')) {
    validatePassword(this.matkhau);
    this.matkhau = await bcrypt.hash(this.matkhau, 12);
  }
});

// Whitelist fields explicitly: even selected credentials never reach API JSON.
export function publicUser(user) {
  return { _id: user._id.toString(), email: user.email, hoten: user.hoten, hinhanh: user.hinhanh || '' };
}

userSchema.set('toJSON', { transform(doc, ret) { delete ret.matkhau; return ret; } });

export const User = mongoose.model('User', userSchema);
export default User;
