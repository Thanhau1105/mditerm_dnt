import { mkdir, writeFile } from 'node:fs/promises';
import { fixtureDocuments } from './sample-users.js';

const folder = new URL('../../database/', import.meta.url);
await mkdir(folder, { recursive: true });
await writeFile(new URL('users.json', folder), `${JSON.stringify(await fixtureDocuments(), null, 2)}\n`, 'utf8');
console.log('Wrote database/users.json: 5 development users with bcrypt password hashes.');
