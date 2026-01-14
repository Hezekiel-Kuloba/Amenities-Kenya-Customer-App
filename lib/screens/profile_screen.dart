import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider)!;
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(userProvider.notifier).updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
      setState(() => _isEditing = false);
      CustomDialogs.showSuccessDialog(
        context: context,
        title: AppLocalizations.of(context)!.success,
        content: AppLocalizations.of(context)!.profileUpdated,
      );
    } catch (e) {
      CustomDialogs.showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.error,
        content: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider)!;

    return Scaffold(
      appBar: AppBar(title: Text(translations.profile)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.lightPrimary,
                child: Text(
                  user.firstName![0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: translations.firstName),
                enabled: _isEditing,
                validator: (value) =>
                    value!.isEmpty ? translations.firstNameRequired : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: translations.lastName),
                enabled: _isEditing,
                validator: (value) =>
                    value!.isEmpty ? translations.lastNameRequired : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: translations.email),
                enabled: _isEditing,
                validator: (value) {
                  if (value!.isEmpty) return translations.emailRequired;
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return translations.emailInvalid;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: translations.phoneNumber),
                enabled: _isEditing,
                validator: (value) {
                  if (value!.isEmpty) return translations.phoneRequired;
                  if (!RegExp(r'^\+\d{10,12}$').hasMatch(value)) {
                    return translations.phoneInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text(translations.save),
                )
              else
                ElevatedButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: Text(translations.editProfile),
                ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(translations.settings),
                leading: const Icon(Icons.settings),
                onTap: () =>
                    Navigator.pushNamed(context, NavigationService.settings),
              ),
              ListTile(
                title: Text(translations.logout),
                leading: const Icon(Icons.logout),
                onTap: () async {
                  await ref.read(userProvider.notifier).logout();
                  Navigator.pushReplacementNamed(
                      context, NavigationService.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}