class AppFonts {
  static const String defaultFont = 'SF-Pro-Rounded-Regular';
  static const String arabicFont = 'Cairo';

  static String current = defaultFont;

  static String forLanguageCode(String? languageCode) {
    return languageCode == 'ar' ? arabicFont : defaultFont;
  }

  static void update(String? languageCode) {
    current = forLanguageCode(languageCode);
  }
}
