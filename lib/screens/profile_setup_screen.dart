import 'dart:convert';

import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const ProfileSetupScreen({super.key, required this.phoneNumber});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final db = await _loadDb();
      final users = db['users'] as List<dynamic>;
      final user = users.firstWhere(
        (user) => user['phone_number'] == widget.phoneNumber,
        orElse: () => null,
      );
      if (user == null) throw 'User not found';

      await ref.read(userProvider.notifier).signUp(
            userId: user['user_id'],
            phoneNumber: widget.phoneNumber,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
          );
      if (mounted) {
        CustomDialogs.showSuccessDialog(
          context: context,
          title: AppLocalizations.of(context)!.success,
          content: AppLocalizations.of(context)!.verifyEmailSent,
        ).then((_) => Navigator.pushReplacementNamed(context, NavigationService.home));
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.showErrorDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          content: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _loadDb() async {
    final String jsonString = await rootBundle.loadString('assets/data/db.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.completeProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: translations.firstName,
                  icon: const Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? translations.firstNameRequired : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: translations.lastName,
                  icon: const Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? translations.lastNameRequired : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: translations.email,
                  icon: const Icon(Icons.email),
                  helperText: translations.emailHelper,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return translations.emailRequired;
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return translations.emailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: translations.username,
                  icon: const Icon(Icons.account_circle),
                ),
                validator: (value) =>
                    value!.isEmpty ? translations.usernameRequired : null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleProfileSetup,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(translations.finish),
              ),
            ],
          ),
        ),
      ),
    );
  }
}