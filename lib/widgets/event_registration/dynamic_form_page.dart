import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/app_theme.dart';
import 'form_models.dart';
import 'field_validators.dart';

/// Dynamic form page that renders fields based on configuration
class DynamicFormPage extends StatefulWidget {
  final FormPageConfig pageConfig;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onPrevious;
  final bool isFirstPage;
  final bool isLastPage;

  const DynamicFormPage({
    super.key,
    required this.pageConfig,
    required this.initialData,
    required this.onNext,
    required this.onPrevious,
    required this.isFirstPage,
    required this.isLastPage,
  });

  @override
  State<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  void _initializeForm() {
    for (var field in widget.pageConfig.fields) {
      // Initialize with existing data or default value
      _fieldValues[field.id] = widget.initialData[field.id] ?? field.defaultValue;

      // Create controllers for text-based fields
      if (_needsController(field.type)) {
        _controllers[field.id] = TextEditingController(
          text: _fieldValues[field.id]?.toString() ?? '',
        );
        _focusNodes[field.id] = FocusNode();
      }
    }
  }

  bool _needsController(FieldType type) {
    return type == FieldType.text ||
        type == FieldType.email ||
        type == FieldType.phone ||
        type == FieldType.number ||
        type == FieldType.textarea;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Update field values from controllers
      _controllers.forEach((key, controller) {
        _fieldValues[key] = controller.text;
      });

      widget.onNext(_fieldValues);
    }
  }

  bool _shouldShowField(FormFieldConfig field) {
    if (field.conditionalDisplay == null) return true;

    final condition = field.conditionalDisplay!;
    final dependsOnField = condition['field'] as String?;
    final expectedValue = condition['value'];

    if (dependsOnField == null) return true;

    final actualValue = _fieldValues[dependsOnField];
    return actualValue == expectedValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Text(
                    widget.pageConfig.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.pageConfig.subtitle != null) ...[
                    SizedBox(height: 8),
                    Text(
                      widget.pageConfig.subtitle!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (widget.pageConfig.description != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF667eea).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.pageConfig.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 32),

                  // Form Fields
                  ...widget.pageConfig.fields.map((field) {
                    if (!_shouldShowField(field)) return SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: _buildField(field),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.mainDeepBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (!widget.isFirstPage)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onPrevious,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.previous,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor
                        ),
                      ),
                    ),
                  ),
                if (!widget.isFirstPage) SizedBox(width: 16),
                Expanded(
                  flex: widget.isFirstPage ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBackgroundColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isLastPage ? l10n.submit : l10n.next,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          widget.isLastPage ? Icons.check : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.email:
      case FieldType.phone:
      case FieldType.number:
        return _buildTextField(field);
      case FieldType.textarea:
        return _buildTextAreaField(field);
      case FieldType.dropdown:
        return _buildDropdownField(field);
      case FieldType.radio:
        return _buildRadioField(field);
      case FieldType.checkbox:
        return _buildCheckboxField(field);
      case FieldType.multiCheckbox:
        return _buildMultiCheckboxField(field);
      case FieldType.date:
        return _buildDateField(field);
      case FieldType.time:
        return _buildTimeField(field);
      default:
        return _buildTextField(field);
    }
  }

  

  Widget _buildTextField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 8),
        TextFormField(
          controller: _controllers[field.id],
          focusNode: _focusNodes[field.id],
          enabled: field.enabled,
          keyboardType: _getKeyboardType(field.type),
          inputFormatters: _getInputFormatters(field.type),
          decoration: InputDecoration(
            hintText: field.placeholder,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: _getSuffixIcon(field.type),
          ),
          validator: (value) => FieldValidators.validate(value, field),
          onSaved: (value) => _fieldValues[field.id] = value,
        ),
        if (field.hint != null) ...[
          SizedBox(height: 6),
          Text(
            field.hint!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextAreaField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 8),
        TextFormField(
          controller: _controllers[field.id],
          focusNode: _focusNodes[field.id],
          enabled: field.enabled,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: field.placeholder,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          validator: (value) => FieldValidators.validate(value, field),
          onSaved: (value) => _fieldValues[field.id] = value,
        ),
        if (field.hint != null) ...[
          SizedBox(height: 6),
          Text(
            field.hint!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _fieldValues[field.id]?.toString(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text(field.placeholder ?? 'Select an option'),
          items: field.options?.map((option) {
            return DropdownMenuItem(
              value: option.value,
              enabled: !option.disabled,
              child: Text(option.label),
            );
          }).toList(),
          onChanged: field.enabled
              ? (value) {
                  setState(() {
                    _fieldValues[field.id] = value;
                  });
                }
              : null,
          validator: (value) => FieldValidators.validate(value, field),
          onSaved: (value) => _fieldValues[field.id] = value,
        ),
        if (field.hint != null) ...[
          SizedBox(height: 6),
          Text(field.hint!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildRadioField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 12),
        ...?field.options?.map((option) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: field.enabled && !option.disabled
                  ? () {
                      setState(() {
                        _fieldValues[field.id] = option.value;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _fieldValues[field.id] == option.value
                      ? Color(0xFF667eea).withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fieldValues[field.id] == option.value
                        ? Color(0xFF667eea)
                        : Colors.grey[300]!,
                    width: _fieldValues[field.id] == option.value ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: option.value,
                      groupValue: _fieldValues[field.id]?.toString(),
                      onChanged: field.enabled && !option.disabled
                          ? (value) {
                              setState(() {
                                _fieldValues[field.id] = value;
                              });
                            }
                          : null,
                      activeColor: Color(0xFF667eea),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          if (option.description != null) ...[
                            SizedBox(height: 4),
                            Text(
                              option.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        if (field.hint != null) ...[
          SizedBox(height: 6),
          Text(field.hint!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildCheckboxField(FormFieldConfig field) {
    return CheckboxListTile(
      title: Text(
        field.label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: field.hint != null ? Text(field.hint!) : null,
      value: _fieldValues[field.id] == true,
      onChanged: field.enabled
          ? (value) {
              setState(() {
                _fieldValues[field.id] = value;
              });
            }
          : null,
      activeColor: Color(0xFF667eea),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMultiCheckboxField(FormFieldConfig field) {
    // Initialize as list if not already
    _fieldValues[field.id] ??= <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 12),
        ...?field.options?.map((option) {
          final List<String> selectedValues = List<String>.from(_fieldValues[field.id] ?? []);
          final isSelected = selectedValues.contains(option.value);

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: field.enabled && !option.disabled
                  ? () {
                      setState(() {
                        if (isSelected) {
                          selectedValues.remove(option.value);
                        } else {
                          selectedValues.add(option.value);
                        }
                        _fieldValues[field.id] = selectedValues;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFF667eea).withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Color(0xFF667eea) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: field.enabled && !option.disabled
                          ? (value) {
                              setState(() {
                                if (value == true) {
                                  selectedValues.add(option.value);
                                } else {
                                  selectedValues.remove(option.value);
                                }
                                _fieldValues[field.id] = selectedValues;
                              });
                            }
                          : null,
                      activeColor: Color(0xFF667eea),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (option.description != null) ...[
                            SizedBox(height: 4),
                            Text(
                              option.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDateField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 8),
        InkWell(
          onTap: field.enabled ? () => _selectDate(field) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF667eea)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text(
              _fieldValues[field.id] != null
                  ? DateFormat('MMM dd, yyyy').format(_fieldValues[field.id])
                  : field.placeholder ?? 'Select date',
              style: TextStyle(
                fontSize: 16,
                color: _fieldValues[field.id] != null ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ),
        if (field.hint != null) ...[
          SizedBox(height: 6),
          Text(field.hint!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildTimeField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        SizedBox(height: 8),
        InkWell(
          onTap: field.enabled ? () => _selectTime(field) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              suffixIcon: Icon(Icons.access_time, color: Color(0xFF667eea)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text(
              _fieldValues[field.id] != null
                  ? (_fieldValues[field.id] as TimeOfDay).format(context)
                  : field.placeholder ?? 'Select time',
              style: TextStyle(
                fontSize: 16,
                color: _fieldValues[field.id] != null ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(FormFieldConfig field) {
    final hasRequiredValidation = field.validations.any((v) => v.rule == ValidationRule.required);

    return RichText(
      text: TextSpan(
        text: field.label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (hasRequiredValidation)
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardType(FieldType type) {
    switch (type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters(FieldType type) {
    if (type == FieldType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  Widget? _getSuffixIcon(FieldType type) {
    switch (type) {
      case FieldType.email:
        return Icon(Icons.email_outlined, color: Colors.grey[400]);
      case FieldType.phone:
        return Icon(Icons.phone_outlined, color: Colors.grey[400]);
      default:
        return null;
    }
  }

  Future<void> _selectDate(FormFieldConfig field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fieldValues[field.id] ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fieldValues[field.id] = picked;
      });
    }
  }

  Future<void> _selectTime(FormFieldConfig field) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _fieldValues[field.id] ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fieldValues[field.id] = picked;
      });
    }
  }
}
