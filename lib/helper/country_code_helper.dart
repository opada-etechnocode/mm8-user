import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CountryCodeHelper{
  static const List<String> gccCountryCodes = [
    'AE', // United Arab Emirates
    'SA', // Saudi Arabia
    'KW', // Kuwait
    'BH', // Bahrain
    'QA', // Qatar
    'OM', // Oman
  ];
  static String? getCountryCode(String? number) {
    String? countryCode = '';
    try{
      countryCode = codes.firstWhere((item) =>
          number!.contains('${item['dial_code']}'))['dial_code'];
    }catch(error){
      debugPrint('country error: $error');
    }
    return countryCode;
  }

  static String extractPhoneNumber(String countryCode, String phoneNumber) {
    return phoneNumber.replaceAll(countryCode, '');
  }

}