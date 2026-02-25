import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function loadEnvFile(): Record<string, string> {
  const vars: Record<string, string> = {};
  // Walk up from server/dist/config.js to server/ then project root
  const serverDir = path.resolve(__dirname, '..');
  const projectRoot = path.resolve(serverDir, '..');
  const envFile = path.join(projectRoot, '.env');
  if (fs.existsSync(envFile)) {
    const lines = fs.readFileSync(envFile, 'utf-8').split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const idx = trimmed.indexOf('=');
      if (idx > 0) {
        vars[trimmed.slice(0, idx).trim()] = trimmed.slice(idx + 1).trim();
      }
    }
  }
  return vars;
}

function env(key: string, fileVars: Record<string, string>): string | undefined {
  return process.env[key] ?? fileVars[key];
}

const fileVars = loadEnvFile();

export const stripeEnv = env('stripe_env', fileVars) ?? 'sandbox';

const secret = env(`stripe_${stripeEnv}_secret_key`, fileVars);
const publishable = env(`stripe_${stripeEnv}_publishable_key`, fileVars);

if (!secret || !publishable) {
  process.stderr.write(
    `Missing stripe_${stripeEnv}_secret_key or stripe_${stripeEnv}_publishable_key in environment\n`,
  );
  process.exit(1);
}

export const stripeSecretKey = secret;
export const stripePublishableKey = publishable;
