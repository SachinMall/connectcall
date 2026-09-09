class AppConfig {
  AppConfig._();

  static const int zegoAppId = 341564945;
  static const String zegoAppSign = 'c4e9622f4f43f702788e04cbe75a1e307aa970530c0855ce625290c062e744c5';

  static bool get isZegoConfigured => zegoAppId != 0 && zegoAppSign.isNotEmpty;
}
