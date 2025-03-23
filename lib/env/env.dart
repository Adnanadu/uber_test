import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
final class Env {
  @EnviedField(varName: 'API_KEY')
  static const String apiKey = _Env.apiKey;
}
