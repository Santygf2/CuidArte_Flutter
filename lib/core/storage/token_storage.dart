import 'token_storage_stub.dart'
    if (dart.library.io) 'token_storage_io.dart'
    if (dart.library.js_interop) 'token_storage_web.dart' as platform;

import 'token_storage_base.dart';

export 'token_storage_base.dart';

TokenStorageBase createTokenStorage() => platform.createPlatformTokenStorage();
