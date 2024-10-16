import 'package:jarvis/lang/lang.dart';

Object? resolveHTTPStatusCode(int statusCode,
    {bool isChat = false, String? message}) {
  switch (statusCode) {
    case 400:
      return const LanguageText('Invalid request parameters');
    case 401:
      return const LanguageText(AppLocale.signInRequired, action: 'sign-in');
    case 404:
      if (isChat) {
        return const LanguageText(AppLocale.modelNotFound);
      }
      break;
    case 429:
      if (isChat) {
        return const LanguageText(AppLocale.tooManyRequestsOrPaymentRequired);
      }

      return const LanguageText(AppLocale.tooManyRequests);
    case 451:
      return const LanguageText(AppLocale.modelNotValid);
    case 402:
      return const LanguageText(AppLocale.quotaExceeded, action: 'payment');
    case 500:
      if (message != null && message.isNotEmpty) {
        return message;
      }

      return const LanguageText(AppLocale.internalServerError);
    case 502:
      return const LanguageText(AppLocale.badGateway);
  }

  return null;
}
