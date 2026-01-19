import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/auth_service.dart';

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet();

  @override
  State<DeleteAccountSheet> createState() => DeleteAccountSheetState();
}

class DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  AuthService _authService = AuthService();
  static const _storage = FlutterSecureStorage();

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _error = "Password required");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      /// 🔥 CALL YOUR API HERE
      final response = await _authService.deleteEventooAccount(
        _passwordController.text,
      );

      dynamic body = jsonDecode(response.body);
      print(body);

      if (!body['success'] ) {
        setState(() {
          _loading = false;
          _error = body['message'];
        });
        return;
      }

      /// ✅ SUCCESS
      await _storage.deleteAll();
      if (!mounted) return;
      
      context.go('/');
       
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Something went wrong";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.red, size: 48),

          const SizedBox(height: 12),

          Text(
            l10n.deleteMyAccount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.deleteAccountWarning,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.password,
              errorText: _error,
            ),
          ),

          const SizedBox(height: 20),

          _loading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _deleteAccount,
                    child: Text(l10n.confirmLabel),
                  ),
                ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelLabel),
          ),
        ],
      ),
    );
  }
}
