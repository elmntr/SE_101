// lib/utils/phone_formatter.dart
import 'package:flutter/services.dart';

/// Philippine phone number formatter
/// Formats mobile numbers as: 09XX XXX XXXX (11 digits)
/// Formats landline numbers as: (0XX) XXX XXXX
class PhilippinePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 11 digits (Philippine mobile format)
    final limited = digitsOnly.length > 11 
        ? digitsOnly.substring(0, 11) 
        : digitsOnly;
    
    // Format the number
    final formatted = _formatPhilippinePhone(limited);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  String _formatPhilippinePhone(String digits) {
    if (digits.isEmpty) return '';
    
    final buffer = StringBuffer();
    
    // Format as 09XX XXX XXXX
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    
    return buffer.toString();
  }
}

/// Philippine landline formatter
/// Formats as: (0XX) XXX XXXX
class PhilippineLandlineFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 10-11 digits
    final limited = digitsOnly.length > 11 
        ? digitsOnly.substring(0, 11) 
        : digitsOnly;
    
    // Format the number
    final formatted = _formatLandline(limited);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  String _formatLandline(String digits) {
    if (digits.isEmpty) return '';
    
    final buffer = StringBuffer();
    
    // Format as (0XX) XXX XXXX
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      buffer.write(digits[i]);
      if (i == 2) {
        buffer.write(') ');
      } else if (i == 6) {
        buffer.write(' ');
      }
    }
    
    return buffer.toString();
  }
}

/// Length limiting formatter for Philippine phone numbers
class PhilippinePhoneLengthFormatter extends TextInputFormatter {
  final int maxDigits;
  
  PhilippinePhoneLengthFormatter({this.maxDigits = 11});
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Count only digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length > maxDigits) {
      return oldValue;
    }
    
    return newValue;
  }
}
