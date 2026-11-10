import mongoose from 'mongoose';
import { mkdir, writeFile } from 'node:fs/promises';
import { readConfig } from '../config/env.js';
import { connectDB } from '../config/db.js';
import User from '../models/User.js';

try {
  const config = readConfig();
  await connectDB(config.mongoUri);
  const users = await User.find({}).select('+matkhau').sort({ email: 1 }).lean();
  // MongoDB Extended JSON preserves ObjectId when imported using Compass.
  const exported = users.map((user) => ({
    _id: { $oid: user._id.toString() },
    email: user.email, matkhau: user.matkhau, hoten: user.hoten, hinhanh: user.hinhanh || '',
  }));
  const folder = new URL('../../database/', import.meta.url);
  await mkdir(folder, { recursive: true });
  await writeFile(new URL('users.export.json', folder), `${JSON.stringify(exported, null, 2)}\n`, 'utf8');
  console.log(`Exported ${users.length} users to database/users.export.json.`);
  console.log('The export contains private data and password hashes. Keep it out of Git.');
} catch (error) {
  console.error(error.name === 'Error' ? error.message : 'Export failed. Check your local configuration and MongoDB connection.');
  process.exitCode = 1;
} finally {
  await mongoose.disconnect();
}
