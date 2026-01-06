import 'form_models.dart';

/// Utility class for validating form fields
class FieldValidators {
  /// Validate a field value against its configuration
  static String? validate(dynamic value, FormFieldConfig field) {
    for (var validation in field.validations) {
      final error = _validateRule(value, validation, field);
      if (error != null) return error;
    }
    return null;
  }

  static String? _validateRule(
    dynamic value,
    ValidationConfig validation,
    FormFieldConfig field,
  ) {
    switch (validation.rule) {
      case ValidationRule.required:
        return _validateRequired(value, validation.message ?? '${field.label} is required');

      case ValidationRule.email:
        return _validateEmail(
          value,
          validation.message ?? 'Please enter a valid email address',
        );

      case ValidationRule.phone:
        return _validatePhone(
          value,
          validation.message ?? 'Please enter a valid phone number',
        );

      case ValidationRule.minLength:
        return _validateMinLength(
          value,
          validation.value as int,
          validation.message ?? '${field.label} must be at least ${validation.value} characters',
        );

      case ValidationRule.maxLength:
        return _validateMaxLength(
          value,
          validation.value as int,
          validation.message ?? '${field.label} must be at most ${validation.value} characters',
        );

      case ValidationRule.min:
        return _validateMin(
          value,
          validation.value,
          validation.message ?? '${field.label} must be at least ${validation.value}',
        );

      case ValidationRule.max:
        return _validateMax(
          value,
          validation.value,
          validation.message ?? '${field.label} must be at most ${validation.value}',
        );

      case ValidationRule.pattern:
        return _validatePattern(
          value,
          validation.value as String,
          validation.message ?? '${field.label} format is invalid',
        );

      default:
        return null;
    }
  }

  static String? _validateRequired(dynamic value, String message) {
    if (value == null) return message;
    
    if (value is String && value.trim().isEmpty) return message;
    
    if (value is List && value.isEmpty) return message;
    
    return null;
  }

  static String? _validateEmail(dynamic value, String message) {
    if (value == null || (value is String && value.isEmpty)) return null;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.toString())) {
      return message;
    }
    
    return null;
  }

  static String? _validatePhone(dynamic value, String message) {
    if (value == null || (value is String && value.isEmpty)) return null;
    
    // Remove common phone number characters
    final cleaned = value.toString().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Check if it contains only digits and has reasonable length
    if (!RegExp(r'^\d{8,15}$').hasMatch(cleaned)) {
      return message;
    }
    
    return null;
  }

  static String? _validateMinLength(dynamic value, int minLength, String message) {
    if (value == null) return null;
    
    if (value is String && value.length < minLength) {
      return message;
    }
    
    if (value is List && value.length < minLength) {
      return message;
    }
    
    return null;
  }

  static String? _validateMaxLength(dynamic value, int maxLength, String message) {
    if (value == null) return null;
    
    if (value is String && value.length > maxLength) {
      return message;
    }
    
    if (value is List && value.length > maxLength) {
      return message;
    }
    
    return null;
  }

  static String? _validateMin(dynamic value, dynamic minValue, String message) {
    if (value == null || value.toString().isEmpty) return null;
    
    try {
      final numValue = num.parse(value.toString());
      final numMin = num.parse(minValue.toString());
      
      if (numValue < numMin) {
        return message;
      }
    } catch (e) {
      return message;
    }
    
    return null;
  }

  static String? _validateMax(dynamic value, dynamic maxValue, String message) {
    if (value == null || value.toString().isEmpty) return null;
    
    try {
      final numValue = num.parse(value.toString());
      final numMax = num.parse(maxValue.toString());
      
      if (numValue > numMax) {
        return message;
      }
    } catch (e) {
      return message;
    }
    
    return null;
  }

  static String? _validatePattern(dynamic value, String pattern, String message) {
    if (value == null || (value is String && value.isEmpty)) return null;
    
    try {
      final regex = RegExp(pattern);
      if (!regex.hasMatch(value.toString())) {
        return message;
      }
    } catch (e) {
      return 'Invalid pattern validation';
    }
    
    return null;
  }
}
