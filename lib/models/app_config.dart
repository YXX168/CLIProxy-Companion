class AppConfig {
  const AppConfig({required this.baseUrl, required this.key});

  static const defaultBaseUrl = '';

  final String baseUrl;
  final String key;

  Uri get baseUri => Uri.parse(baseUrl);

  AppConfig copyWith({String? baseUrl, String? key}) {
    return AppConfig(baseUrl: baseUrl ?? this.baseUrl, key: key ?? this.key);
  }
}
