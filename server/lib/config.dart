import 'dart:io';

late final String stripeSecretKey;
late final String stripePublishableKey;
late final String stripeEnv;

void loadConfig() {
  stripeEnv = Platform.environment['stripe_env'] ?? 'sandbox';

  final secret = Platform.environment['stripe_${stripeEnv}_secret_key'];
  final publishable =
      Platform.environment['stripe_${stripeEnv}_publishable_key'];

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
