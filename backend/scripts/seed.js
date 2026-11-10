import mongoose from 'mongoose';
import { readConfig } from '../config/env.js';
import { connectDB } from '../config/db.js';
import { seedSampleUsers } from './sample-users.js';

try {
  const config = readConfig();
  await connectDB(config.mongoUri);
  const result = await seedSampleUsers(config.adminEmail);
  console.log(`Seed complete: inserted ${result.inserted}; preserved ${result.skipped} existing users.`);
  console.log('Development fixture only. Change its known password before using real data.');
} catch (error) {
  console.error(error.name === 'Error' ? error.message : 'Seed failed. Check your local configuration and MongoDB connection.');
  process.exitCode = 1;
} finally {
  await mongoose.disconnect();
}
