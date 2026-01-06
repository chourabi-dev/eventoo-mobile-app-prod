/// Data models for dynamic form configuration

enum FieldType {
  text,
  email,
  phone,
  number,
  textarea,
  dropdown,
  radio,
  checkbox,
  multiCheckbox,
  date,
  time,
  dateTime,
  file,
  image,
}

enum ValidationRule {
  required,
  email,
  phone,
  minLength,
  maxLength,
  min,
  max,
  pattern,
}

/// Represents a single form field
class FormFieldConfig {
  final String id;
  final String label;
  final FieldType type;
  final String? placeholder;
  final String? hint;
  final dynamic defaultValue;
  final List<FieldOption>? options; // For dropdown, radio, checkbox
  final List<ValidationConfig> validations;
  final bool enabled;
  final Map<String, dynamic>? conditionalDisplay; // Show/hide based on other fields
  
  FormFieldConfig({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    this.hint,
    this.defaultValue,
    this.options,
    this.validations = const [],
    this.enabled = true,
    this.conditionalDisplay,
  });

  factory FormFieldConfig.fromJson(Map<String, dynamic> json) {
    return FormFieldConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      type: _parseFieldType(json['type'] as String),
      placeholder: json['placeholder'] as String?,
      hint: json['hint'] as String?,
      defaultValue: json['defaultValue'],
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => FieldOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      validations: (json['validations'] as List<dynamic>?)
          ?.map((e) => ValidationConfig.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      enabled: json['enabled'] as bool? ?? true,
      conditionalDisplay: json['conditionalDisplay'] as Map<String, dynamic>?,
    );
  }

  static FieldType _parseFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return FieldType.text;
      case 'email':
        return FieldType.email;
      case 'phone':
        return FieldType.phone;
      case 'number':
        return FieldType.number;
      case 'textarea':
        return FieldType.textarea;
      case 'dropdown':
      case 'select':
        return FieldType.dropdown;
      case 'radio':
        return FieldType.radio;
      case 'checkbox':
        return FieldType.checkbox;
      case 'multicheckbox':
      case 'multi_checkbox':
        return FieldType.multiCheckbox;
      case 'date':
        return FieldType.date;
      case 'time':
        return FieldType.time;
      case 'datetime':
        return FieldType.dateTime;
      case 'file':
        return FieldType.file;
      case 'image':
        return FieldType.image;
      default:
        return FieldType.text;
    }
  }
}

/// Represents options for dropdown/radio/checkbox fields
class FieldOption {
  final String value;
  final String label;
  final String? description;
  final bool disabled;

  FieldOption({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });

  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
      value: json['value'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      disabled: json['disabled'] as bool? ?? false,
    );
  }
}

/// Validation configuration
class ValidationConfig {
  final ValidationRule rule;
  final dynamic value; // For min/max/minLength/maxLength/pattern
  final String? message;

  ValidationConfig({
    required this.rule,
    this.value,
    this.message,
  });

  factory ValidationConfig.fromJson(Map<String, dynamic> json) {
    return ValidationConfig(
      rule: _parseValidationRule(json['rule'] as String),
      value: json['value'],
      message: json['message'] as String?,
    );
  }

  static ValidationRule _parseValidationRule(String rule) {
    switch (rule.toLowerCase()) {
      case 'required':
        return ValidationRule.required;
      case 'email':
        return ValidationRule.email;
      case 'phone':
        return ValidationRule.phone;
      case 'minlength':
      case 'min_length':
        return ValidationRule.minLength;
      case 'maxlength':
      case 'max_length':
        return ValidationRule.maxLength;
      case 'min':
        return ValidationRule.min;
      case 'max':
        return ValidationRule.max;
      case 'pattern':
        return ValidationRule.pattern;
      default:
        return ValidationRule.required;
    }
  }
}

/// Represents a page in the multi-page form
class FormPageConfig {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final List<FormFieldConfig> fields;
  final int order;

  FormPageConfig({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.fields,
    required this.order,
  });

  factory FormPageConfig.fromJson(Map<String, dynamic> json) {
    return FormPageConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => FormFieldConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: json['order'] as int? ?? 0,
    );
  }
}
