import fs from 'node:fs';
import path from 'node:path';
import type { IncomingMessage, ServerResponse } from 'node:http';
import type { Plugin } from 'vite';

interface VisitStore {
  ips: string[];
}

function loadStore(filePath: string): Set<string> {
  try {
    const raw = fs.readFileSync(filePath, 'utf-8');
    const data = JSON.parse(raw) as VisitStore;
    return new Set(Array.isArray(data.ips) ? data.ips : []);
  } catch {
    return new Set();
  }
}

function saveStore(filePath: string, ips: Set<string>): void {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify({ ips: [...ips] }, null, 2));
}

function getClientIp(req: IncomingMessage): string {
  const forwarded = req.headers['x-forwarded-for'];
  if (typeof forwarded === 'string') {
    return forwarded.split(',')[0]?.trim() || 'unknown';
  }

  const realIp = req.headers['x-real-ip'];
  if (typeof realIp === 'string') {
    return realIp.trim();
  }

  return req.socket.remoteAddress?.replace(/^::ffff:/, '') ?? 'unknown';
}

function sendJson(res: ServerResponse, status: number, body: unknown): void {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(body));
}

function createVisitHandler(
  dataFile: string,
  getIps: () => Set<string>,
  setIps: (ips: Set<string>) => void
) {
  return (req: IncomingMessage, res: ServerResponse, next: () => void) => {
    const url = req.url?.split('?')[0];

    if (url === '/api/visit' && req.method === 'POST') {
      const ips = getIps();
      const ip = getClientIp(req);
      const isNew = !ips.has(ip);

      if (isNew) {
        ips.add(ip);
        setIps(ips);
        saveStore(dataFile, ips);
      }

      sendJson(res, 200, { count: ips.size, isNew });
      return;
    }

    if (url === '/api/visits' && req.method === 'GET') {
      sendJson(res, 200, { count: getIps().size });
      return;
    }

    next();
  };
}

export function visitCounterPlugin(dataFile = path.resolve('data/visitors.json')): Plugin {
  let ips = new Set<string>();

  const initStore = () => {
    ips = loadStore(dataFile);
  };

  const handler = createVisitHandler(
    dataFile,
    () => ips,
    (nextIps) => {
      ips = nextIps;
    }
  );

  return {
    name: 'visit-counter',
    configureServer(server) {
      initStore();
      server.middlewares.use(handler);
    },
    configurePreviewServer(server) {
      initStore();
      server.middlewares.use(handler);
    }
  };
}
