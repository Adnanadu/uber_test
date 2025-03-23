import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: ".env")
final class Env {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static String apiKey = _Env.apiKey;
  @EnviedField(varName: 'API_KEY2', obfuscate: true)
  static String apiKey2 = _Env.apiKey2;
}
