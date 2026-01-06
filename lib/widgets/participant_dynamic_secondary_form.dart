import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/feildtype.dart';



FieldType fieldTypeFromString(String type) {
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
      return FieldType.dropdown;
    case 'radio':
      return FieldType.radio;
    case 'checkbox':
      return FieldType.checkbox;
    case 'multi_checkbox':
    case 'multicheckbox':
      return FieldType.multiCheckbox;
    case 'date':
      return FieldType.date;
    case 'time':
      return FieldType.time;
    default:
      return FieldType.text;
  }
}

/* =========================================================
   PARTICIPANT FIELD MODEL (1:1 BACKEND)
========================================================= */

class ParticipantField {
  final int id;
  final String label;
  final String type;
  final String? value;
  final List<String> feildValues;
  final List<String> multipleValuesSelected;

  final bool showOnBadge;
  final bool showOnParticipantListPage;
  final bool showOnParticipantPage;
  final bool showOnNetworkingApp;
  final bool showOnNetworkingExperienceFilters;

  ParticipantField({
    required this.id,
    required this.label,
    required this.type,
    this.value,
    required this.feildValues,
    required this.multipleValuesSelected,
    required this.showOnBadge,
    required this.showOnParticipantListPage,
    required this.showOnParticipantPage,
    required this.showOnNetworkingApp,
    required this.showOnNetworkingExperienceFilters,
  });

  factory ParticipantField.fromJson(Map<String, dynamic> json) {
    return ParticipantField(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      value: json['value'],
      feildValues:
          (json['feild_values'] as List).map((e) => e.toString()).toList(),
      multipleValuesSelected:
          (json['multiple_values_selected'] as List)
              .map((e) => e.toString())
              .toList(),
      showOnBadge: json['show_on_badge'] ?? false,
      showOnParticipantListPage:
          json['show_on_participant_list_page'] ?? false,
      showOnParticipantPage: json['show_on_participant_page'] ?? false,
      showOnNetworkingApp: json['show_on_networking_app'] ?? false,
      showOnNetworkingExperienceFilters:
          json['show_on_networking_experience_app_filters'] ?? false,
    );
  }

  FieldType get fieldType => fieldTypeFromString(type);
}

/* =========================================================
   DYNAMIC FORM WIDGET
========================================================= */

class ParticipantDynamicSecondaryForm extends StatefulWidget {
  final List<ParticipantField> fields;
  final Function(List<Map<String, dynamic>>) onSubmit;
  final String phone;
  final String fullname;

  const ParticipantDynamicSecondaryForm({
    super.key,
    required this.fields,
    required this.onSubmit, required this.phone, required this.fullname,
  });

  @override
  State<ParticipantDynamicSecondaryForm> createState() =>
      _ParticipantDynamicSecondaryFormState();
}

class _ParticipantDynamicSecondaryFormState
    extends State<ParticipantDynamicSecondaryForm> {
  final Map<int, dynamic> _values = {};

  @override
  void initState() {
    super.initState();

    for (final f in widget.fields) {
      if (f.multipleValuesSelected.isNotEmpty) {
        _values[f.id] = List<String>.from(f.multipleValuesSelected);
      } else if (f.value != null) {
        _values[f.id] = f.value;
      }
    }
  }

  /* =========================================================
     FIELD SWITCH
  ========================================================= */

  Widget _buildField(ParticipantField field) {
    switch (field.fieldType) {
      case FieldType.text:
      case FieldType.email:
      case FieldType.phone:
      case FieldType.number:
        return _textField(field);

      case FieldType.textarea:
        return _textArea(field);

      case FieldType.dropdown:
        return _dropdown(field);

      case FieldType.radio:
        return _radio(field);

      case FieldType.checkbox:
        return _checkbox(field);

      case FieldType.multiCheckbox:
        return _multiCheckbox(field);

      case FieldType.date:
        return _datePicker(field);

      case FieldType.time:
        return _timePicker(field);

      default:
        return _textField(field);
    }
  }

  /* =========================================================
     FIELD BUILDERS
  ========================================================= */

  Widget _textField(ParticipantField f) {
     
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: '${f.value}',
        decoration: InputDecoration(
          labelText: f.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (v) => _values[f.id] = v,
      ),
    );
  }

  Widget _textArea(ParticipantField f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _values[f.id],
        maxLines: 4,
        decoration: InputDecoration(
          labelText: f.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (v) => _values[f.id] = v,
      ),
    );
  }

  Widget _dropdown(ParticipantField f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _values[f.id],
        decoration: InputDecoration(
          labelText: f.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: f.feildValues
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => _values[f.id] = v,
      ),
    );
  }

  Widget _radio(ParticipantField f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...f.feildValues.map(
          (o) => RadioListTile<String>(
            value: o,
            groupValue: _values[f.id],
            title: Text(o),
            onChanged: (v) => setState(() => _values[f.id] = v),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _checkbox(ParticipantField f) {
    return CheckboxListTile(
      title: Text(f.label),
      value: _values[f.id] ?? false,
      onChanged: (v) => setState(() => _values[f.id] = v),
    );
  }

  Widget _multiCheckbox(ParticipantField f) {
    _values[f.id] ??= <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...f.feildValues.map((o) {
          final list = _values[f.id] as List<String>;
          return CheckboxListTile(
            title: Text(o),
            value: list.contains(o),
            onChanged: (v) {
              setState(() {
                v == true ? list.add(o) : list.remove(o);
              });
            },
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _datePicker(ParticipantField f) {
    return ListTile(
      title: Text(f.label),
      subtitle: Text(_values[f.id] ?? ''),
      trailing: const Icon(Icons.date_range),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
        );
        if (d != null) {
          setState(() => _values[f.id] = d.toIso8601String());
        }
      },
    );
  }

  Widget _timePicker(ParticipantField f) {
    return ListTile(
      title: Text(f.label),
      subtitle: Text(_values[f.id] ?? ''),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final t =
            await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (t != null) {
          setState(() => _values[f.id] = t.format(context));
        }
      },
    );
  }

  /* =========================================================
     SUBMIT
  ========================================================= */

  void _submit() {
    final payload = _values.entries
        .map((e) => {"field_id": e.key, "value": e.value})
        .toList();

    widget.onSubmit(payload);
  }

  /* =========================================================
     UI
  ========================================================= */

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);





    return Column(
      children: [ 
        ...widget.fields.map(_buildField),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submit,
            child:  Text( l10n.submit ),
          ),
        ),
      ],
    );
  }
}