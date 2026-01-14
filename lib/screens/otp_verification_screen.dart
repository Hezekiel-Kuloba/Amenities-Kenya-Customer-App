import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool isRegistration;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.isRegistration,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).verifyOtp(
            widget.phoneNumber,
            _otpController.text.trim(),
          );
      if (mounted) {
        if (widget.isRegistration) {
          Navigator.pushReplacementNamed(
            context,
            NavigationService.profileSetup,
            arguments: {'phoneNumber': widget.phoneNumber},
          );
        } else {
          CustomDialogs.showSuccessDialog(
            context: context,
            title: AppLocalizations.of(context)!.success,
            content: AppLocalizations.of(context)!.loginSuccess,
          ).then((_) => Navigator.pushReplacementNamed(context, NavigationService.home));
        }
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.showErrorDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          content: 'Invalid OTP. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final otp = await ref.read(userProvider.notifier).sendOtp(widget.phoneNumber);
      if (mounted) {
        CustomDialogs.showSuccessDialog(
          context: context,
          title: AppLocalizations.of(context)!.success,
          content: 'New OTP sent: $otp', // For demo purposes
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
                            'assets/images/logo_amenities.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        // Description
                        Text(
                          'Enter the 6-digit code sent to ${widget.phoneNumber}.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // OTP Input
                        PinCodeTextField(
                          appContext: context,
                          controller: _otpController,
                          length: 6,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(8),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Colors.grey[200],
                            selectedFillColor: Colors.grey[200],
                            inactiveFillColor: Colors.grey[200],
                            activeColor: Colors.blue[900],
                            selectedColor: Colors.blue[900],
                            inactiveColor: Colors.grey[400],
                          ),
                          validator: (value) {
                            if (value == null || value.length != 6) {
                              return translations.otpInvalid;
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        // Verify Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtp,
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
                                  translations.verify,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16.0),
                        // Resend OTP Link
                        Center(
                          child: TextButton(
                            onPressed: _isLoading ? null : _resendOtp,
                            child: Text(
                              translations.resendOtp,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
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