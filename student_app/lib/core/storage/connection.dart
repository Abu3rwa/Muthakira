/// Picks the drift executor for the current platform.
library;

export 'connection_native.dart' if (dart.library.js_interop) 'connection_web.dart';