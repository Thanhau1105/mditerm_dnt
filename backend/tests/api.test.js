import test, { before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import request from 'supertest';
import { MongoMemoryServer } from 'mongodb-memory-server';
import { createApp } from '../app.js';
import { connectDB } from '../config/db.js';
import { readConfig, DATABASE_NAME } from '../config/env.js';
import User from '../models/User.js';
import { MAX_IMAGE_BYTES, validateImage } from '../utils/validation.js';
import { issueToken } from '../utils/token.js';
import { seedSampleUsers, fixtureDocuments } from '../scripts/sample-users.js';

process.env.NODE_ENV = 'test';
const config = {
  jwtSecret: randomBytes(48).toString('hex'),
  adminEmail: 'hautt.23it@vku.udn.vn',
  corsOrigins: ['http://localhost:5173'],
};
const password = 'Vku@123456';
const png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aQ1cAAAAASUVORK5CYII=';
let mongo;
let app;
let admin;
let student;

before(async () => {
  mongo = await MongoMemoryServer.create();
  await connectDB(mongo.getUri());
  await User.init();
  app = createApp({ config, rateLimitEnabled: false });
});

beforeEach(async () => {
  await User.deleteMany({});
  [admin, student] = await User.create([
    { email: config.adminEmail, matkhau: password, hoten: 'Trần Thành Hậu', hinhanh: '' },
    { email: 'student@vku.udn.vn', matkhau: password, hoten: 'Nguyễn Văn An', hinhanh: '' },
  ]);
});

after(async () => {
  await mongoose.disconnect();
  if (mongo) await mongo.stop();
});

function authorize(req, user = admin) {
  return req.set('Authorization', `Bearer ${issueToken(user, config.jwtSecret)}`);
}

function assertPublic(user) {
  assert.deepEqual(Object.keys(user).sort(), ['_id', 'email', 'hinhanh', 'hoten']);
  assert.equal(user.matkhau, undefined);
}

test('connects to the required real MongoDB database and stores exactly four business fields', async () => {
  assert.equal(mongoose.connection.name, DATABASE_NAME);
  const raw = await User.collection.findOne({ _id: admin._id });
  assert.deepEqual(Object.keys(raw).sort(), ['_id', 'email', 'hinhanh', 'hoten', 'matkhau']);
  assert.match(raw.matkhau, /^\$2[aby]\$12\$/);
  assert.notEqual(raw.matkhau, password);
  assert.equal(await bcrypt.compare(password, raw.matkhau), true);
  assert.equal((await User.findById(admin._id)).matkhau, undefined);
  assert.throws(() => new User({ email: 'x@vku.udn.vn', matkhau: password, hoten: 'Name', role: 'admin' }), /not in schema/);
  assert.equal((await request(app).get('/api/health')).status, 200);
});

test('authenticates against MongoDB, normalizes email and never returns the password', async () => {
  const res = await request(app).post('/api/auth/login').send({ email: `  ${config.adminEmail.toUpperCase()}  `, matkhau: password });
  assert.equal(res.status, 200);
  assert.equal(res.body.isAdmin, true);
  assert.equal(typeof res.body.token, 'string');
  assertPublic(res.body.user);
  const me = await request(app).get('/api/auth/me').set('Authorization', `Bearer ${res.body.token}`);
  assert.equal(me.status, 200);
  assert.equal(me.body.isAdmin, true);
  assertPublic(me.body.user);
  const unknown = await request(app).post('/api/auth/login').send({ email: 'missing@vku.udn.vn', matkhau: password });
  const wrong = await request(app).post('/api/auth/login').send({ email: config.adminEmail, matkhau: 'wrong-password' });
  assert.equal(unknown.status, 401);
  assert.equal(wrong.status, 401);
  assert.equal(unknown.body.message, wrong.body.message);
});

test('requires authentication and revalidates admin status from the current user document', async () => {
  assert.equal((await request(app).get('/api/users')).status, 401);
  const login = await request(app).post('/api/auth/login').send({ email: student.email, matkhau: password });
  assert.equal(login.status, 200);
  assert.equal(login.body.isAdmin, false);
  const token = login.body.token;
  for (const req of [
    request(app).get('/api/users'), request(app).get(`/api/users/${student.id}`),
    request(app).post('/api/users').send({}), request(app).put(`/api/users/${student.id}`).send({}),
    request(app).delete(`/api/users/${student.id}`),
  ]) assert.equal((await req.set('Authorization', `Bearer ${token}`)).status, 403);
  const oldAdminToken = issueToken(admin, config.jwtSecret);
  admin.email = 'demoted@vku.udn.vn';
  await admin.save();
  assert.equal((await request(app).get('/api/users').set('Authorization', `Bearer ${oldAdminToken}`)).status, 403);
});

test('rejects forged, expired and deleted-user tokens', async () => {
  const forged = jwt.sign({ sub: admin.id }, 'a-different-secret-that-is-long-enough');
  assert.equal((await request(app).get('/api/users').set('Authorization', `Bearer ${forged}`)).status, 401);
  const expired = jwt.sign({ sub: admin.id }, config.jwtSecret, { expiresIn: -1, issuer: 'vku-student-management', audience: 'vku-student-management-client' });
  assert.equal((await request(app).get('/api/users').set('Authorization', `Bearer ${expired}`)).status, 401);
  const deletedToken = issueToken(student, config.jwtSecret);
  await student.deleteOne();
  assert.equal((await request(app).get('/api/auth/me').set('Authorization', `Bearer ${deletedToken}`)).status, 401);
});

test('creates, reads, updates and deletes a persisted student including a Base64 image', async () => {
  const created = await authorize(request(app).post('/api/users')).send({
    email: '  NEW@VKU.UDN.VN ', hoten: '  Lê Minh Châu  ', matkhau: password, hinhanh: png,
  });
  assert.equal(created.status, 201);
  assertPublic(created.body.user);
  const user = created.body.user;
  assert.equal(user.email, 'new@vku.udn.vn');
  assert.equal(user.hoten, 'Lê Minh Châu');
  assert.equal(user.hinhanh, png);
  const stored = await User.collection.findOne({ _id: new mongoose.Types.ObjectId(user._id) });
  assert.equal(await bcrypt.compare(password, stored.matkhau), true);
  assert.equal(stored.hinhanh, png);
  const read = await authorize(request(app).get(`/api/users/${user._id}`));
  assert.equal(read.status, 200);
  assert.deepEqual(read.body.user, user);
  const changed = await authorize(request(app).put(`/api/users/${user._id}`)).send({
    hoten: 'Lê Minh Châu Mới', email: 'changed@vku.udn.vn', matkhau: '', hinhanh: '',
  });
  assert.equal(changed.status, 200);
  assert.equal(changed.body.user.hinhanh, '');
  const afterChange = await User.collection.findOne({ _id: stored._id });
  assert.equal(afterChange.matkhau, stored.matkhau);
  assert.equal(afterChange.email, 'changed@vku.udn.vn');
  assert.equal(afterChange.hoten, 'Lê Minh Châu Mới');
  assert.equal((await authorize(request(app).delete(`/api/users/${user._id}`))).status, 200);
  assert.equal(await User.exists({ _id: stored._id }), null);
});

test('rejects duplicate normalized emails on both create and update', async () => {
  const create = await authorize(request(app).post('/api/users')).send({
    email: config.adminEmail.toUpperCase(), hoten: 'Duplicate Name', matkhau: password,
  });
  assert.equal(create.status, 409);
  const update = await authorize(request(app).put(`/api/users/${student.id}`)).send({ email: config.adminEmail });
  assert.equal(update.status, 409);
  assert.equal((await User.findById(student.id)).email, student.email);
});

test('invalidates existing sessions when a password changes', async () => {
  const oldToken = issueToken(student, config.jwtSecret);
  const changed = await authorize(request(app).put(`/api/users/${student.id}`)).send({ matkhau: 'New-password-2026' });
  assert.equal(changed.status, 200);
  assert.equal((await request(app).get('/api/auth/me').set('Authorization', `Bearer ${oldToken}`)).status, 401);
  assert.equal((await request(app).post('/api/auth/login').send({ email: student.email, matkhau: password })).status, 401);
  assert.equal((await request(app).post('/api/auth/login').send({ email: student.email, matkhau: 'New-password-2026' })).status, 200);
});

test('prevents deleting the active admin or changing its configured email', async () => {
  assert.equal((await authorize(request(app).delete(`/api/users/${admin.id}`))).status, 409);
  assert.equal((await authorize(request(app).put(`/api/users/${admin.id}`)).send({ email: 'lost@vku.udn.vn' })).status, 409);
  assert.equal((await authorize(request(app).put(`/api/users/${admin.id}`)).send({ hoten: 'Tên quản trị mới', matkhau: '' })).status, 200);
});

test('searches literal names or emails, sorts names and reports the global count', async () => {
  await User.create({ email: 'binh@vku.udn.vn', hoten: 'Bình', matkhau: password, hinhanh: '' });
  const found = await authorize(request(app).get('/api/users').query({ search: 'student@', sort: 'asc' }));
  assert.equal(found.status, 200);
  assert.equal(found.body.users.length, 1);
  assert.equal(found.body.total, 3);
  found.body.users.forEach(assertPublic);
  const literal = await authorize(request(app).get('/api/users').query({ search: '.*' }));
  assert.equal(literal.body.users.length, 0);
  const asc = await authorize(request(app).get('/api/users?sort=asc'));
  const desc = await authorize(request(app).get('/api/users?sort=desc'));
  assert.deepEqual(desc.body.users.map((u) => u.hoten), asc.body.users.map((u) => u.hoten).reverse());
  assert.equal((await authorize(request(app).get('/api/users?sort=other'))).status, 400);
  assert.equal((await authorize(request(app).get('/api/users?search[x]=y'))).status, 400);
});

test('validates IDs, request fields, JSON, passwords and required fields', async () => {
  assert.equal((await authorize(request(app).get('/api/users/not-an-id'))).status, 400);
  assert.equal((await authorize(request(app).get('/api/users/000000000000000000000000'))).status, 404);
  const valid = { email: 'new@vku.udn.vn', matkhau: password, hoten: 'Valid Name', hinhanh: '' };
  for (const change of [
    { role: 'admin' }, { timestamps: true }, { _id: admin.id }, { email: { $ne: '' } },
    { email: 'invalid' }, { hoten: '' }, { matkhau: 'short' }, { matkhau: '😀'.repeat(20) },
  ]) assert.equal((await authorize(request(app).post('/api/users')).send({ ...valid, ...change })).status, 400);
  assert.equal((await authorize(request(app).post('/api/users')).send([])).status, 400);
  assert.equal((await authorize(request(app).post('/api/users')).set('Content-Type', 'application/json').send('{')).status, 400);
  assert.equal((await authorize(request(app).put(`/api/users/${student.id}`)).send({ matkhau: '' })).status, 400);
  assert.equal((await request(app).post('/api/auth/login').send({ email: config.adminEmail, matkhau: password, role: 'admin' })).status, 400);
});

test('validates image signatures, canonical Base64 and maximum image/body size', async () => {
  const body = { email: 'photo@vku.udn.vn', hoten: 'Photo User', matkhau: password };
  for (const image of [
    'not base64!', Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"></svg>').toString('base64'),
    `data:image/png;base64,${png}`, Buffer.from('text file').toString('base64'),
    png.replace(/=$/, ''),
  ]) assert.equal((await authorize(request(app).post('/api/users')).send({ ...body, hinhanh: image })).status, 400);
  const maximum = Buffer.alloc(MAX_IMAGE_BYTES);
  Buffer.from(png, 'base64').copy(maximum);
  assert.doesNotThrow(() => validateImage(maximum.toString('base64')));
  const oversized = Buffer.alloc(MAX_IMAGE_BYTES + 1);
  Buffer.from(png, 'base64').copy(oversized);
  assert.throws(() => validateImage(oversized.toString('base64')));
  assert.equal((await authorize(request(app).post('/api/users')).send({ ...body, hinhanh: oversized.toString('base64') })).status, 400);
  assert.equal((await authorize(request(app).post('/api/users')).send({ ...body, hinhanh: 'a'.repeat(4 * 1024 * 1024) })).status, 413);
});

test('allows configured Flutter CORS origins and rejects unconfigured web origins', async () => {
  const allowed = await request(app).options('/api/users').set('Origin', 'http://localhost:5173').set('Access-Control-Request-Method', 'POST');
  assert.equal(allowed.status, 204);
  assert.equal(allowed.headers['access-control-allow-origin'], 'http://localhost:5173');
  const denied = await request(app).get('/api/health').set('Origin', 'https://untrusted.example');
  assert.equal(denied.status, 403);
  assert.equal(denied.headers['access-control-allow-origin'], undefined);
});

test('seed is non-destructive and fixture JSON has exactly four fields with usable hashes', async () => {
  const originalHash = admin.matkhau;
  const first = await seedSampleUsers(config.adminEmail);
  const second = await seedSampleUsers(config.adminEmail);
  assert.deepEqual(first, { inserted: 4, skipped: 1 });
  assert.deepEqual(second, { inserted: 0, skipped: 5 });
  assert.equal((await User.findById(admin.id).select('+matkhau')).matkhau, originalHash);
  const documents = await fixtureDocuments();
  assert.equal(documents.length, 5);
  for (const doc of documents) {
    assert.deepEqual(Object.keys(doc).sort(), ['email', 'hinhanh', 'hoten', 'matkhau']);
    assert.equal(await bcrypt.compare(password, doc.matkhau), true);
  }
});

test('rejects missing secrets and pins the application database independently from URI', () => {
  assert.throws(() => readConfig({}), /JWT_SECRET/);
  const env = { MONGODB_URI: 'mongodb://127.0.0.1:27017/other', JWT_SECRET: config.jwtSecret, ADMIN_EMAIL: config.adminEmail };
  assert.equal(readConfig(env).adminEmail, config.adminEmail);
  assert.throws(() => readConfig({ ...env, CORS_ORIGINS: '*' }), /CORS_ORIGINS/);
  assert.throws(() => readConfig({ ...env, PORT: 'invalid' }), /PORT/);
  assert.equal(DATABASE_NAME, 'vku_student_management');
});
