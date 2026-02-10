import 'dart:io';

late final String stripeSecretKey;
late final String stripePublishableKey;
late final String stripeEnv;

Map<String, String> _loadEnvFile() {
  final envVars = <String, String>{};
  final script = Platform.script.toFilePath();
  // Walk up from server/bin/server.dart to the project root
  var dir = File(script).parent.parent.parent;
  final envFile = File('${dir.path}/.env');
  if (envFile.existsSync()) {
    for (final line in envFile.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx > 0) {
        envVars[trimmed.substring(0, idx).trim()] =
            trimmed.substring(idx + 1).trim();
      }
    }
  }
  return envVars;
}

String? _env(String key, Map<String, String> fileVars) {
  return Platform.environment[key] ?? fileVars[key];
}

void loadConfig() {
  final fileVars = _loadEnvFile();

  stripeEnv = _env('stripe_env', fileVars) ?? 'sandbox';

  final secret = _env('stripe_${stripeEnv}_secret_key', fileVars);
  final publishable = _env('stripe_${stripeEnv}_publishable_key', fileVars);

  if (secret == null || publishable == null) {
    stderr.writeln(
      'Missing stripe_${stripeEnv}_secret_key or '
      'stripe_${stripeEnv}_publishable_key in environment',
    );
    exit(1);
  }

  stripeSecretKey = secret;
  stripePublishableKey = publishable;
}
