# Despliegue de CuidArte Flutter

## Backend (Django en Vercel)

| Dato | Valor |
| --- | --- |
| API base | `https://cuid-arte-gamma.vercel.app/api/v1` |
| Origen | `https://cuid-arte-gamma.vercel.app` |
| CORS | `Access-Control-Allow-Origin: *` (verificado) |
| Salud | `GET /api/v1/health/` → `{"status":"ok"}` |

La URL está definida en un solo lugar: `lib/core/network/api_client.dart`
(`ApiClient.productionBaseUrl`). Es el valor por defecto para web, Android,
iOS, Windows, macOS y Linux.

### Cambiar la URL sin tocar código

```bash
flutter build web --release --dart-define=API_URL=https://otro-dominio.com/api/v1
```

### Volver al Django local (desarrollo)

```bash
flutter run --dart-define=USE_LOCAL_API=true
```

Con esa bandera se usa `http://127.0.0.1:8000/api/v1` (y `http://10.0.2.2:8000/api/v1`
en el emulador de Android).

Prioridad de configuración:

1. `--dart-define=API_URL=...`
2. `--dart-define=USE_LOCAL_API=true` → backend local
3. `ApiClient.productionBaseUrl` → backend en Vercel

### Imágenes y archivos

`ApiClient.resolveUrl()` convierte rutas relativas del backend
(`/media/foto.jpg`, `/static/...`) en URLs absolutas contra el origen del
backend. Se aplica en los modelos (`product_model`, `workshop_model`,
`caregiver_model`, `user_model`, `visit_model`, `admin_models`,
`educational_resource_model`, `client_dashboard_model`, `chat_thread_model`),
así que las fotos de perfil y catálogo funcionan aunque Django devuelva rutas
relativas. Las URLs absolutas (por ejemplo las de Supabase) se dejan intactas.

## Frontend (Flutter Web en Vercel)

Requisitos: Flutter `>= 3.47.0` (lo exige `pubspec.lock`) y Node/npm para el CLI
de Vercel.

### Opción A – Despliegue automático desde GitHub (recomendado)

1. En Vercel: **Add New → Project → Import Git Repository** y elige
   `Santygf2/CuidArte_Flutter`.
2. Framework Preset: **Other**. No cambies Build Command ni Output Directory:
   los toma de `vercel.json`.
3. (Opcional) Variable de entorno `API_URL` con la URL del backend. Si no se
   define, el script usa `https://cuid-arte-gamma.vercel.app/api/v1`.
4. **Deploy**. `scripts/vercel-build.sh` descarga Flutter 3.47.8, ejecuta
   `flutter pub get` y `flutter build web --release`, y publica `build/web`.

Cada push a la rama conectada vuelve a desplegar.

### Opción B – Compilar en local y subir el build

```powershell
flutter pub get
flutter build web --release --dart-define=API_URL="https://cuid-arte-gamma.vercel.app/api/v1"
npx vercel deploy build/web --prod
```

La primera vez `npx vercel` pide iniciar sesión en el navegador y vincular el
proyecto. O también:

```powershell
.\scripts\deploy_web.ps1
```

## Verificación después del despliegue

1. Abrir la URL de Vercel y confirmar que carga el splash y la página pública.
2. En DevTools → Network, las peticiones deben ir a
   `https://cuid-arte-gamma.vercel.app/api/v1/...` con estado 200/201.
3. Iniciar sesión con un usuario real de la base de datos de Django.
4. Revisar que las peticiones autenticadas lleven `Authorization: Bearer ...` y
   que el refresco de token (`/auth/refresh/`) funcione.

## Notas

- El backend ya envía `Access-Control-Allow-Origin: *`. Si más adelante se
  restringe, hay que agregar el dominio de Flutter a `CORS_ALLOWED_ORIGINS`
  en Django.
- Flutter Web usa enrutamiento por hash por defecto, y `vercel.json` ya incluye
  el rewrite a `index.html` para recargas directas.
- Los archivos subidos a Django en Vercel no persisten (filesystem de solo
  lectura en serverless); las imágenes actuales vienen de Supabase Storage, así
  que no hay problema.
