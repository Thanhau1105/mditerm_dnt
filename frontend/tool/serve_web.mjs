// Local preview of a compiled Flutter build. Not a production hosting server.
import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';

const root = resolve(process.argv[2] || 'build/web');
const port = Number(process.argv[3] || 5174);
const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'application/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm',
  '.png': 'image/png', '.svg': 'image/svg+xml', '.ttf': 'font/ttf',
};
http.createServer(async (req, res) => {
  if (!['GET', 'HEAD'].includes(req.method)) { res.writeHead(405); res.end(); return; }
  try {
    const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    const filename = resolve(root, `.${pathname === '/' ? '/index.html' : pathname}`);
    if (filename !== root && !filename.startsWith(`${root}${sep}`)) {
      res.writeHead(403); res.end(); return;
    }
    const bytes = await readFile(filename);
    res.writeHead(200, {'Content-Type': types[extname(filename)] || 'application/octet-stream',
      'Cache-Control': 'no-store'});
    res.end(req.method === 'HEAD' ? undefined : bytes);
  } catch { res.writeHead(404); res.end('Not found'); }
}).listen(port, '127.0.0.1', () => console.log(`Local Flutter preview: http://localhost:${port}`));
