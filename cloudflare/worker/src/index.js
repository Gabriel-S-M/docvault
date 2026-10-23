const FIREBASE_JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
const MAX_UPLOAD_BYTES = 100 * 1024 * 1024;
const ALLOWED_TYPES = new Set([
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/bmp',
]);

let cachedJwks;
let jwksExpiresAt = 0;

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, PUT, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Access-Control-Max-Age': '86400',
  };
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
  });
}

function decodeBase64Url(value) {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const binary = atob(normalized + '='.repeat((4 - (normalized.length % 4)) % 4));
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

async function getJwks() {
  if (cachedJwks && Date.now() < jwksExpiresAt) return cachedJwks;

  const response = await fetch(FIREBASE_JWKS_URL, {
    cf: { cacheTtl: 3600, cacheEverything: true },
  });
  if (!response.ok) throw new Error('Não foi possível obter as chaves do Firebase.');
  cachedJwks = await response.json();
  jwksExpiresAt = Date.now() + 3600 * 1000;
  return cachedJwks;
}

async function verifyFirebaseToken(request, projectId) {
  const authorization = request.headers.get('Authorization') || '';
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) return false;

  try {
    const [encodedHeader, encodedPayload, encodedSignature] = match[1].split('.');
    if (!encodedHeader || !encodedPayload || !encodedSignature) return false;
    const header = JSON.parse(new TextDecoder().decode(decodeBase64Url(encodedHeader)));
    const claims = JSON.parse(new TextDecoder().decode(decodeBase64Url(encodedPayload)));
    if (header.alg !== 'RS256' || typeof header.kid !== 'string') return false;

    const now = Math.floor(Date.now() / 1000);
    if (
      claims.aud !== projectId ||
      claims.iss !== `https://securetoken.google.com/${projectId}` ||
      typeof claims.sub !== 'string' ||
      claims.sub.length === 0 ||
      claims.exp <= now ||
      claims.iat > now ||
      claims.auth_time > now
    ) {
      return false;
    }

    const jwks = await getJwks();
    const jwk = jwks.keys.find((key) => key.kid === header.kid && key.kty === 'RSA');
    if (!jwk) return false;
    const publicKey = await crypto.subtle.importKey(
      'jwk',
      jwk,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      false,
      ['verify'],
    );
    const signingInput = new TextEncoder().encode(`${encodedHeader}.${encodedPayload}`);
    return crypto.subtle.verify(
      'RSASSA-PKCS1-v1_5',
      publicKey,
      decodeBase64Url(encodedSignature),
      signingInput,
    );
  } catch {
    return false;
  }
}

function parseObjectKey(pathname, prefix) {
  const encodedParts = pathname.slice(prefix.length).split('/');
  if (encodedParts.length !== 3) return null;
  let parts;
  try {
    parts = encodedParts.map(decodeURIComponent);
  } catch {
    return null;
  }
  if (parts.some((part) => !/^[a-zA-Z0-9._-]+$/.test(part))) return null;
  return parts.join('/');
}

function publicFileUrl(requestUrl, key) {
  const url = new URL(requestUrl);
  url.pathname = `/files/${key.split('/').map(encodeURIComponent).join('/')}`;
  url.search = '';
  return url.toString();
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    if (request.method === 'GET' && url.pathname.startsWith('/files/')) {
      const key = parseObjectKey(url.pathname, '/files/');
      if (!key) return json({ error: 'Caminho de arquivo inválido.' }, 400);
      const object = await env.DOCVAULT_BUCKET.get(key);
      if (!object) return json({ error: 'Arquivo não encontrado.' }, 404);
      const headers = new Headers(corsHeaders());
      object.writeHttpMetadata(headers);
      headers.set('ETag', object.httpEtag);
      headers.set('Cache-Control', 'public, max-age=86400');
      return new Response(object.body, { headers });
    }

    if (request.method === 'PUT' && url.pathname.startsWith('/upload/')) {
      if (!(await verifyFirebaseToken(request, env.FIREBASE_PROJECT_ID))) {
        return json({ error: 'Faça login para enviar ou editar arquivos.' }, 401);
      }

      const key = parseObjectKey(url.pathname, '/upload/');
      if (!key) return json({ error: 'Caminho de arquivo inválido.' }, 400);
      const contentType = (request.headers.get('Content-Type') || '')
        .split(';')[0]
        .trim()
        .toLowerCase();
      if (!ALLOWED_TYPES.has(contentType)) {
        return json({ error: 'Tipo de arquivo não permitido.' }, 415);
      }
      const contentLength = Number(request.headers.get('Content-Length'));
      if (Number.isFinite(contentLength) && contentLength > MAX_UPLOAD_BYTES) {
        return json({ error: 'O arquivo excede o limite de 100 MB.' }, 413);
      }
      if (!request.body) return json({ error: 'Arquivo vazio.' }, 400);

      await env.DOCVAULT_BUCKET.put(key, request.body, {
        httpMetadata: {
          contentType,
          cacheControl: 'public, max-age=86400',
        },
      });
      return json({ url: publicFileUrl(request.url, key) });
    }

    return json({ error: 'Rota não encontrada.' }, 404);
  },
};
