import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';

class CountryCodeHelper {
  static final List<AllowedCountry> fallbackCountries = [
    AllowedCountry(name: 'Saudi Arabia', code: 'SA', dialCode: '966'),
    AllowedCountry(name: 'Kuwait', code: 'KW', dialCode: '965'),
    AllowedCountry(name: 'Bahrain', code: 'BH', dialCode: '973'),
    AllowedCountry(name: 'Qatar', code: 'QA', dialCode: '974'),
    AllowedCountry(name: 'Oman', code: 'OM', dialCode: '968'),
  ];

  static List<AllowedCountry> resolve(List<AllowedCountry>? fromApi) {
    if (fromApi == null || fromApi.isEmpty) {
      return fallbackCountries;
    }

    final cleaned = <AllowedCountry>[];
    for (final country in fromApi) {
      final code = country.code?.trim().toUpperCase() ?? '';
      final dialCode = country.dialCode?.replaceAll('+', '').trim() ?? '';
      if (code.isEmpty || dialCode.isEmpty) continue;
      cleaned.add(AllowedCountry(
        name: country.name?.trim().isNotEmpty == true ? country.name!.trim() : code,
        code: code,
        dialCode: dialCode,
      ));
    }

    return cleaned.isEmpty ? fallbackCountries : cleaned;
  }

  static List<String> isoCodes(List<AllowedCountry>? fromApi) {
    return resolve(fromApi).map((country) => country.code!).toList();
  }

  static String defaultIsoCode(List<AllowedCountry>? fromApi) {
    final countries = resolve(fromApi);
    for (final country in countries) {
      if (country.code == 'SA') return 'SA';
    }
    return countries.first.code!;
  }

  static String dialCodeForIso(String isoCode) {
    try {
      return CountryCode.fromCountryCode(isoCode).dialCode ?? '+$isoCode';
    } catch (_) {
      final match = resolve(null).where((country) => country.code == isoCode.toUpperCase());
      if (match.isNotEmpty) return '+${match.first.dialCode}';
      return '+966';
    }
  }

  static String? isoFromValue(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final raw = value.trim();
    final upper = raw.toUpperCase();
    final dial = raw.startsWith('+')
        ? raw
        : RegExp(r'^\d+$').hasMatch(raw)
            ? '+$raw'
            : null;

    for (final item in codes) {
      final code = (item['code'] ?? '').toUpperCase();
      final name = (item['name'] ?? '').toUpperCase();
      final itemDial = item['dial_code'] ?? '';
      if (code == upper || name == upper || (dial != null && itemDial == dial)) {
        return code;
      }
    }
    return upper.length == 2 ? upper : null;
  }

  static bool isAllowed(List<AllowedCountry>? fromApi, String? value) {
    final iso = isoFromValue(value);
    if (iso == null) return false;
    return isoCodes(fromApi).contains(iso);
  }

  static String resolveInitialDialCode(List<AllowedCountry>? fromApi, String? current) {
    final iso = isoFromValue(current);
    if (iso != null && isAllowed(fromApi, iso)) {
      return dialCodeForIso(iso);
    }
    return dialCodeForIso(defaultIsoCode(fromApi));
  }

  static String resolveInitialCountryName(List<AllowedCountry>? fromApi, String? current) {
    final iso = isoFromValue(current);
    final selectedIso = (iso != null && isAllowed(fromApi, iso)) ? iso : defaultIsoCode(fromApi);
    try {
      return CountryCode.fromCountryCode(selectedIso).name ?? selectedIso;
    } catch (_) {
      final match = resolve(fromApi).where((country) => country.code == selectedIso);
      return match.isNotEmpty ? (match.first.name ?? selectedIso) : selectedIso;
    }
  }

  static List<String> displayCountryNames({
    required List<String> restricted,
    required List<AllowedCountry>? fromApi,
    required bool restrictionEnabled,
  }) {
    final allowed = resolve(fromApi);
    final allowedNames = allowed
        .map((country) => resolveInitialCountryName(allowed, country.code))
        .toSet()
        .toList();

    if (!restrictionEnabled || restricted.isEmpty) {
      return allowedNames;
    }

    final filtered = restricted.where((name) {
      return isAllowed(fromApi, name);
    }).toList();

    return filtered.isEmpty ? allowedNames : filtered;
  }

  static String? getCountryCode(String? number) {
    String? countryCode = '';
    try {
      countryCode = codes.firstWhere((item) =>
          number!.contains('${item['dial_code']}'))['dial_code'];
    } catch (error) {
      debugPrint('country error: $error');
    }
    return countryCode;
  }

  static String extractPhoneNumber(String countryCode, String phoneNumber) {
    return phoneNumber.replaceAll(countryCode, '');
  }
}
