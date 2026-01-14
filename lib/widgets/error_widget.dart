import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16.0),
            Text(
              translations.error,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(translations.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}