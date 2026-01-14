import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      CustomDialogs.showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.error,
        content: 'Please select a rating.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Mock submission (replace with actual service call in production)
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        CustomDialogs.showSuccessDialog(
          context: context,
          title: AppLocalizations.of(context)!.success,
          content: AppLocalizations.of(context)!.ratingSuccess,
        ).then((_) => Navigator.popUntil(
              context,
              ModalRoute.withName(NavigationService.home),
            ));
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Order;
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(translations.rateSupplier)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations.rating,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.yellow,
                    size: 40.0,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16.0),
            Text(
              translations.comment,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: translations.comment,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(translations.submitRating),
            ),
          ],
        ),
      ),
    );
  }
}