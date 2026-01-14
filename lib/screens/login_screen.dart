import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/screens/otp_verification_screen.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final otp = await ref.read(userProvider.notifier).sendOtp(_phoneNumber);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: _phoneNumber,
              isRegistration: false,
            ),
          ),
        );
        CustomDialogs.showSuccessDialog(
          context: context,
          title: AppLocalizations.of(context)!.success,
          content: 'OTP sent: $otp', // For demo purposes
        );
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.1),
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/logo_amenities.png', // Use provided image
                            width: 150, // Match original Lottie dimensions
                            height: 150,
                            fit: BoxFit.contain, // Ensure image scales properly
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        // Description
                        Text(
                          // translations.enterPhoneNumber,
                          "'We will send you a code by SMS to confirm your phone number",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Phone Number Input
                        IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: translations.phoneNumber,
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide(color: Colors.blue[900]!),
                            ),
                          ),
                          initialCountryCode: 'KE',
                          disableLengthCheck: true,
                          onChanged: (phone) {
                            _phoneNumber = phone.completeNumber;
                            print(phone.completeNumber);
                          },
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return translations.phoneRequired;
                            }
                            if (phone.number.length != 9) {
                              return 'Please enter a valid 9-digit number.';
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        // Terms and Conditions
                        Text(
                          'If you sign up, you confirm to have read in detail and agreed to the Terms & Conditions and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Next Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                )
                              : Text(
                                  translations.sendOtp,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16.0),
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(translations.noAccount),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  NavigationService.register,
                                );
                              },
                              child: Text(
                                translations.signUp,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
