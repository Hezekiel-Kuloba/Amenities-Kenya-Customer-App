
import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/supplier_display_data.dart'; // NEW IMPORT
import 'package:amenities_kenya/providers/location_provider.dart'; // Keep for user location if needed
import 'package:amenities_kenya/utilities/distance_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierCard extends ConsumerWidget {
  final SupplierDisplayData supplierDisplayData; // CHANGED TYPE
  final VoidCallback onTap;

  const SupplierCard({
    super.key,
    required this.supplierDisplayData, // CHANGED PARAMETER NAME
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Use the pre-calculated distance from supplierDisplayData if available,
    // otherwise calculate it here (e.g., if the card is used in a context
    // where distance wasn't pre-calculated, though for this app it should be).
    double? distance = supplierDisplayData.distanceToUser;
    if (distance == null) {
      ref.watch(locationProvider).whenData((coords) {
        if (coords != null) {
          distance = DistanceCalculator.calculateDistance(
            coords.lat,
            coords.lon,
            supplierDisplayData.locationCoordinates.lat,
            supplierDisplayData.locationCoordinates.lon,
          );
        }
      });
    }

   return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image: Full container width
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network( // Changed to Image.network as supplier.image_url is a URL
                  supplierDisplayData.imageUrl, // Use supplierDisplayData.imageUrl
                  width: double.infinity, // Span full container width
                  height: screenWidth * 3 / 8, // Maintain height from previous request
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: screenWidth * 3 / 8,
                    color: AppColors.lightGray,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Supplier Name (Main Supplier Name)
              Text(
                supplierDisplayData.supplierName, // Use supplierDisplayData.supplierName
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              // Location Name (Specific location)
              Text(
                supplierDisplayData.locationName, // Display location name
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              // Address (Specific location address)
              Text(
                supplierDisplayData.locationAddress, // Use supplierDisplayData.locationAddress
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              // Rating and Distance
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.yellow, size: 20.0),
                  const SizedBox(width: 4.0),
                  Text(
                    '${supplierDisplayData.averageRating!.toStringAsFixed(1)} (${supplierDisplayData.reviewCount} ${translations.reviews})',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (distance != null)
                    Text(
                      '${distance!.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              // Promotion
              if (supplierDisplayData.promotions.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  '${translations.promotion}: ${supplierDisplayData.promotions.first.description}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.lightPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}