import User, { publicUser } from '../models/User.js';
import { HttpError } from '../utils/errors.js';
import { assertId, validateUserBody } from '../utils/validation.js';

async function findUser(id, withPassword = false) {
  assertId(id);
  const query = User.findById(id);
  if (withPassword) query.select('+matkhau');
  const user = await query;
  if (!user) throw new HttpError(404, 'Không tìm thấy sinh viên.');
  return user;
}

export async function listUsers(req, res) {
  const { search = '', sort = 'asc' } = req.query;
  if (typeof search !== 'string' || search.length > 100 || !['asc', 'desc'].includes(sort)
      || Object.keys(req.query).some((key) => !['search', 'sort'].includes(key))) {
    throw new HttpError(400, 'Tham số tìm kiếm hoặc sắp xếp không hợp lệ.');
  }
  const escapedSearch = search.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const filter = escapedSearch ? { $or: [{ hoten: { $regex: escapedSearch, $options: 'i' } }, { email: { $regex: escapedSearch, $options: 'i' } }] } : {};
  const [users, total] = await Promise.all([
    User.find(filter).collation({ locale: 'vi', strength: 2 }).sort({ hoten: sort === 'asc' ? 1 : -1, _id: 1 }),
    User.countDocuments({}),
  ]);
  res.json({ users: users.map(publicUser), total });
}

export async function getUser(req, res) {
  res.json({ user: publicUser(await findUser(req.params.id)) });
}

export async function createUser(req, res) {
  const user = await User.create(validateUserBody(req.body));
  res.status(201).json({ user: publicUser(user) });
}

export async function updateUser(req, res) {
  const changes = validateUserBody(req.body, { update: true });
  const user = await findUser(req.params.id, true);
  if (user._id.equals(req.user._id) && changes.email && changes.email !== user.email) {
    throw new HttpError(409, 'Không thể đổi email của tài khoản quản trị đang đăng nhập.');
  }
  Object.assign(user, changes);
  await user.save();
  res.json({ user: publicUser(user) });
}

export async function deleteUser(req, res) {
  const user = await findUser(req.params.id);
  if (user._id.equals(req.user._id)) throw new HttpError(409, 'Không thể xóa tài khoản quản trị đang đăng nhập.');
  await user.deleteOne();
  res.json({ message: 'Đã xóa sinh viên.' });
}
