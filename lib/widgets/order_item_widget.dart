import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:flutter/material.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderDetails details;
  final String category;

  const OrderItemWidget({
    super.key,
    required this.details,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            if (details.liters != null) ...[
              Text(
                '${translations.liters}: ${details.liters} @ \$${details.pricePerLiter?.toStringAsFixed(2)}/L',
              ),
            ],
            if (details.item != null) ...[
              Text(
                '${translations.item}: ${details.item!.type}',
              ),
              if (details.item!.brand != null)
                Text('${translations.brand}: ${details.item!.brand}'),
              if (details.item!.size != null)
                Text('${translations.size}: ${details.item!.size}'),
              if (details.item!.name != null)
                Text('${translations.accessory}: ${details.item!.name}'),
              Text(
                '${translations.quantity}: ${details.item!.quantity}',
              ),
              Text(
                '${translations.price}: \$${details.item!.price.toStringAsFixed(2)}',
              ),
            ],
            if (details.type != null) ...[
              Text('${translations.type}: ${details.type}'),
              if (details.bags != null)
                Text('${translations.bags}: ${details.bags}'),
              if (details.basePrice != null)
                Text(
                  '${translations.basePrice}: \$${details.basePrice!.toStringAsFixed(2)}',
                ),
              if (details.additionalBags != null)
                Text(
                  '${translations.additionalBags}: ${details.additionalBags} @ \$${details.additionalBagPrice?.toStringAsFixed(2)}',
                ),
              if (details.pricePerBag != null)
                Text(
                  '${translations.pricePerBag}: \$${details.pricePerBag!.toStringAsFixed(2)}',
                ),
            ],
            if (details.trips != null) ...[
              Text('${translations.trips}: ${details.trips}'),
              if (details.pricePerTrip != null)
                Text(
                  '${translations.pricePerTrip}: \$${details.pricePerTrip!.toStringAsFixed(2)}',
                ),
            ],
            const SizedBox(height: 8.0),
            Text(
              '${translations.deliveryFee}: \$${details.deliveryFee.toStringAsFixed(2)}',
            ),
            Text(
              '${translations.totalCost}: \$${details.totalCost.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}