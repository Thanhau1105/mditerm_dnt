import mongoose from 'mongoose';
import { DATABASE_NAME } from './env.js';

export async function connectDB(mongoUri) {
  // dbName deliberately fixes the database even if the URI contains another name.
  await mongoose.connect(mongoUri, {
    dbName: DATABASE_NAME,
    serverSelectionTimeoutMS: 10000,
    maxPoolSize: 10,
  });
}
