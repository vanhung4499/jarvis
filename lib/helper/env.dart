/// Default API Server URL
const defaultAPIServerURL = 'https://api.openai.com';

/// API Server URL
String get apiServerURL {
  var url = const String.fromEnvironment(
    'API_SERVER_URL',
    defaultValue: defaultAPIServerURL,
  );

  // When the configured URL is /, it is automatically replaced with empty, used for the Web side
  if (url == '/') {
    return '';
  }

  return url;
}
