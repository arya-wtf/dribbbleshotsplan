import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import * as schema from './schema';
import path from 'path';

// Keep the connection cached during development
const sqlite = new Database(path.join(process.cwd(), 'data/elux-shots.db'));
export const db = drizzle(sqlite, { schema });
