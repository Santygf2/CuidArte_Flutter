# HANDOFF - CuidArte Flutter

Fecha: 2026-10-22

## Ubicaciones

- Proyecto Flutter: `/home/tarde/Documentos/Santiago/Flutter`
- Proyecto Django de referencia: `/home/tarde/Documentos/Santiago/Django/CuidArte`
- Export de esta sesión: `/home/tarde/Documentos/Santiago/Flutter/cuidarte-sesion.json`
- ID de sesión: `ses_e9a85b323ffe480GatL3z6PhGn`

## Estado actual

La página pública sin iniciar sesión ya estaba terminada. En esta sesión se trabajó
únicamente el flujo de autenticación previo a los dashboards:

1. El login ya no muestra selector de rol Cliente/Cuidador.
2. El rol se detecta automáticamente al iniciar sesión.
3. El botón "Crear una cuenta" abre la selección de tipo de cuenta con el mismo
   diseño, textos y colores del proyecto Django.
4. Los formularios de registro de Cliente y Cuidador se alinearon al
   `registro.html` real de Django.

## Cambios realizados

### Login

Archivo: `lib/presentation/screens/auth/login_screen.dart`

- Diseño tipo tarjeta dividida: panel de bienvenida con imagen + formulario.
- Fondo con degradado institucional y tarjeta blanca con sombra.
- Textos tomados de Django: "Iniciar Sesión", "Ingresa tus credenciales para
  continuar", "Correo electrónico", "Contraseña", "¿Olvidaste tu contraseña?",
  "Ingresar", "¿No tienes cuenta?", "Crear una cuenta".
- Sin selector de rol.
- Redirección automática a `MainNavigationScreen` (cliente) o
  `CaregiverDashboardScreen` (cuidador).

### Selección de tipo de cuenta

Archivo: `lib/presentation/screens/auth/select_account_type_screen.dart`

- Textos exactos de Django:
  - "¿Cómo deseas unirte a CuidArte?"
  - "Selecciona el tipo de cuenta que mejor se ajuste a tus necesidades"
  - Tarjeta "Busco Cuidador" -> "Registrarme como Cliente"
  - Tarjeta "Soy Cuidador" -> "Registrarme como Cuidador"
  - Footer "¿Ya tienes una cuenta? Inicia sesión aquí"
- Colores: azul `#27BEF5` para cliente y naranja `#FF9800` para cuidador.
- Beneficios e iconos iguales a Django.

### Registro de Cliente

Archivo: `lib/presentation/screens/auth/register_client_screen.dart`

Campos alineados a Django:

- Nombre *
- Apellido *
- Correo electrónico *
- Fecha de nacimiento * (mayor de 18 años)
- Contraseña *
- Confirmar Contraseña *
- Acepto los términos y condiciones *

Título: "Registro de Cliente".
Subtítulo: "Encuentra al cuidador ideal para ti".
Botón: "Crear cuenta".

### Registro de Cuidador

Archivo: `lib/presentation/screens/auth/register_caregiver_screen.dart`

Campos alineados a Django:

- Nombre *
- Apellido *
- Correo electrónico *
- Teléfono * (10 dígitos)
- Fecha de nacimiento *
- Especialidades * (lista idéntica a Django)
- Experiencia * (5 a 200 caracteres)
- Contraseña *
- Confirmar Contraseña *
- Acepto los términos y condiciones *

Título: "Registro de Cuidador".
Subtítulo: "Comienza tu carrera en cuidados".
Botón: "Crear cuenta".

### Provider de autenticación

Archivo: `lib/providers/auth_provider.dart`

- `detectRole(email)`: reconoce cuentas de cuidador registradas y correos con
  "cuidador".
- `loginAutoDetect(email, password)`: inicia sesión y devuelve el rol detectado.
- `registerClientAccount(...)` y `registerCaregiverAccount(...)`.
- Al registrar un cuidador, su correo se agrega al conjunto de correos de
  cuidador para futuros inicios de sesión.

### Widgets compartidos de autenticación

- `lib/presentation/widgets/auth/auth_background.dart`
- `lib/presentation/widgets/auth/auth_app_bar.dart`
- `lib/presentation/widgets/auth/auth_text_field.dart`
- `lib/presentation/widgets/auth/auth_buttons.dart`
- `lib/presentation/widgets/auth/auth_terms_checkbox.dart`
- `lib/presentation/widgets/auth/registration_layout.dart`

### Otros cambios

- `lib/core/theme/app_colors.dart`: agregados `caregiver` y `caregiverLight`.
- `lib/main.dart`: locale `es_CO` y delegados de localización.
- `pubspec.yaml`: dependencia `flutter_localizations`.
- Se agregó el logo en el AppBar de las pantallas de autenticación.
- Los date pickers se muestran en español.

## Diseño tomado de Django

Archivo de referencia: `aplicacion/static/styles.css`

- Primario: `#27BEF5`
- Primario oscuro: `#1BA0D1`
- Primario claro: `#6DD5FA`
- Naranja cuidador: `#FF9800`
- Acento rosa: `#FF6B9D`
- Fondo: `#F7F8FC`
- Texto principal: `#2D2D2D`
- Texto secundario: `#6B7280`
- Fuente: Poppins
- Radios: 12 px botones/inputs, 20-24 px tarjetas

## Credenciales de prueba

El login acepta cualquier contraseña en esta etapa de mock:

- Cliente: `carlos.mendoza@email.com`
- Cuidadora: `claudia.morales@cuidarte.org`

## Verificación

- `flutter analyze`: sin errores.
- `flutter test`: 5/5 pruebas aprobadas.
- `flutter build web --release`: compilación correcta.

## Pendiente

- Dashboards de cliente, cuidador y admin.
- El modelo actual solo contempla los roles `client` y `caregiver`; falta `admin`.
- Conectar autenticación y datos reales con Django/Supabase.
- El registro aún es local (mock), no persiste en backend.

## Cómo retomar en otro equipo

```bash
opencode import /ruta/a/cuidarte-sesion.json
opencode session list
opencode -s ses_e9a85b323ffe480GatL3z6PhGn
```
