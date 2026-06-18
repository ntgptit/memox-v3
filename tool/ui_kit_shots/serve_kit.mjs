// Tiny static HTTP server for the UI kit, rooted at the mobile kit dir.
//
// Why this exists: the kit was refactored from one inline index.html into
// folderised `screens/**/*.jsx` loaded via `<script type="text/babel" src=...>`.
// Babel-standalone fetches those external scripts at runtime — and browsers BLOCK
// fetch of local files under file://, so the previous `pathToFileURL(index.html)`
// approach left every component "not defined". Serving over http://127.0.0.1 makes
// the same-origin fetches succeed. (React/Babel/Lucide still come from unpkg.)
//
// No deps beyond node core. Returns { origin, close }.

import { createServer } from 'node:http';
import { existsSync, statSync, createReadStream } from 'node:fs';
import { join, normalize, extname } from 'node:path';

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.jsx': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.woff2': 'font/woff2',
};

// Start a static server rooted at `rootDir`. Resolves to { origin, close }.
export function startKitServer(rootDir) {
  const server = createServer((req, res) => {
    let urlPath = decodeURIComponent((req.url || '/').split('?')[0]);
    if (urlPath === '/') urlPath = '/index.html';
    // Resolve under root and block path traversal.
    const filePath = normalize(join(rootDir, urlPath));
    if (!filePath.startsWith(normalize(rootDir))) {
      res.writeHead(403).end('forbidden');
      return;
    }
    if (!existsSync(filePath) || !statSync(filePath).isFile()) {
      res.writeHead(404).end('not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': MIME[extname(filePath).toLowerCase()] || 'application/octet-stream' });
    createReadStream(filePath).pipe(res);
  });

  return new Promise((resolvePromise) => {
    server.listen(0, '127.0.0.1', () => {
      const { port } = server.address();
      resolvePromise({
        origin: `http://127.0.0.1:${port}`,
        close: () => new Promise((r) => server.close(r)),
      });
    });
  });
}
