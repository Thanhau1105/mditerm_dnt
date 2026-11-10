import mongoose from 'mongoose';
import { readConfig } from './config/env.js';
import { connectDB } from './config/db.js';
import User from './models/User.js';
import { createApp } from './app.js';

let server;
async function start() {
  const config = readConfig();
  await connectDB(config.mongoUri);
  await User.init(); // Wait for the unique email index before serving writes.
  const app = createApp({ config });
  server = app.listen(config.port, config.host, () => {
    console.log(`VKU API ready on port ${config.port}. MongoDB connected.`);
  });
  server.on('error', async () => {
    console.error('Could not listen on the configured host/port.');
    await mongoose.disconnect();
    process.exitCode = 1;
  });
}

async function stop() {
  if (server) await new Promise((resolve) => server.close(resolve));
  await mongoose.disconnect();
}
process.once('SIGINT', () => { stop().then(() => process.exit(0)); });
process.once('SIGTERM', () => { stop().then(() => process.exit(0)); });

start().catch(async (error) => {
  // Configuration errors are safe messages; database errors may contain secrets.
  console.error(error.name === 'Error' ? error.message : 'MongoDB connection failed. Check backend/.env and your Server/Atlas connection.');
  await mongoose.disconnect();
  process.exitCode = 1;
});
