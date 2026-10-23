# DocVault R2 Worker

The Worker accepts authenticated PDF/image uploads and exposes public, read-only
file URLs. It uses the existing Firebase Authentication project to authorize
uploads; R2 API secrets are not embedded in the Flutter app.

## Deploy

1. Confirm the `docvault` bucket exists in the Cloudflare account configured in
   `wrangler.jsonc`.
2. In this directory, authenticate Wrangler and deploy:

   ```powershell
   npx wrangler login
   npx wrangler deploy
   ```

3. Wrangler prints a URL similar to
   `https://docvault-r2.<your-workers-subdomain>.workers.dev`.
4. Run/build Flutter with that URL:

   ```powershell
   flutter run -d chrome --dart-define=R2_WORKER_URL=https://docvault-r2.<your-workers-subdomain>.workers.dev
   ```

   Use the same `--dart-define` when producing release builds.

`GET /files/{companyId}/{documentId}/{fileName}` is public. `PUT
/upload/{companyId}/{documentId}/{fileName}` requires a valid Firebase ID token
from project `docvault-1436f`. The Worker verifies the token signature against
Google's published Firebase token keys before writing to R2.
