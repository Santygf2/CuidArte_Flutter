# cuidarte_app

Aplicación Flutter de CuidArte (Silver Economy & Bienestar).

## Backend

La app consume la API de Django desplegada en Vercel:

- API base: `https://cuid-arte-gamma.vercel.app/api/v1`
- Configuración: `lib/core/network/api_client.dart` (`ApiClient.productionBaseUrl`)
- Sobreescritura sin tocar código: `--dart-define=API_URL=...`
- Desarrollo con Django local: `--dart-define=USE_LOCAL_API=true`

## Despliegue

Instrucciones completas en [DEPLOY.md](DEPLOY.md):

```powershell
flutter build web --release --dart-define=API_URL="https://cuid-arte-gamma.vercel.app/api/v1"
npx vercel deploy build/web --prod
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
