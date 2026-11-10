// Development QA only. Production startup never imports this module.
import { randomBytes } from 'node:crypto';
import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import { createApp } from '../app.js';
import { connectDB } from '../config/db.js';
import { seedSampleUsers, DEFAULT_ADMIN_EMAIL } from '../scripts/sample-users.js';

if (process.env.NODE_ENV !== 'test') {
  throw new Error('Smoke server requires NODE_ENV=test. Use npm start for the real app.');
}

const mongo = await MongoMemoryServer.create();
await connectDB(mongo.getUri());
await seedSampleUsers();
const app = createApp({
  config: {
    adminEmail: DEFAULT_ADMIN_EMAIL,
    jwtSecret: randomBytes(48).toString('hex'),
    corsOrigins: ['http://localhost:5173', 'http://127.0.0.1:5173', 'http://localhost:5174', 'http://127.0.0.1:5174'],
  },
});
const server = app.listen(3001, '127.0.0.1', () => console.log('Isolated MongoDB smoke-test API ready on port 3001. Data is temporary.'));
async function stop() {
  await new Promise((resolve) => server.close(resolve));
  await mongoose.disconnect();
  await mongo.stop();
  process.exit(0);
}
process.once('SIGINT', stop);
process.once('SIGTERM', stop);
