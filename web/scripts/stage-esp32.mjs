import { cpSync, existsSync, mkdirSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const source = join(webRoot, 'dist');
const target = resolve(webRoot, '..', 'firmware', 'data', 'www');

if (!existsSync(join(source, 'index.html'))) {
  throw new Error('web/dist/index.html is missing. Run npm run build first.');
}

// Only copy the generated UI. Never remove sibling data such as ECU logs.
mkdirSync(target, { recursive: true });
cpSync(source, target, { recursive: true });

function totalBytes(directory) {
  return readdirSync(directory).reduce((total, name) => {
    const path = join(directory, name);
    return total + (statSync(path).isDirectory() ? totalBytes(path) : statSync(path).size);
  }, 0);
}

console.log(`Staged web assets: ${target}`);
console.log(`Generated web size: ${totalBytes(source).toLocaleString()} bytes`);
console.log('No device was flashed. ESP32 file serving is not implemented yet.');
