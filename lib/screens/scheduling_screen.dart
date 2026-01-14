import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  String _scheduleType = 'Immediate';
  DateTime? _selectedDateTime;
  String? _selectedDay;
  String? _selectedTime;
  int? _dayOfMonth;
  final _instructionsController = TextEditingController();

  // Arguments from previous screen
  late Supplier _supplier;
  late OrderDetails _orderDetails;
  late String _deliveryAddress;
  late Coordinates _deliveryCoordinates;
  late String _selectedSupplierLocationId; // NEW: To store the selected location ID

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _supplier = args['supplier'] as Supplier;
    _orderDetails = args['orderDetails'] as OrderDetails;
    _deliveryAddress = args['deliveryAddress'] as String;
    _deliveryCoordinates = args['deliveryCoordinates'] as Coordinates;
    _selectedSupplierLocationId = args['selectedSupplierLocationId'] as String; // Retrieve NEW ARG
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.scheduleDelivery,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500), // Limit dropdown width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              translations.scheduleDelivery,
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          value: _scheduleType,
                          decoration: InputDecoration(
                            labelText: translations.scheduleType,
                            prefixIcon: const Icon(Icons.event, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            'Immediate',
                            'Specific Date/Time',
                            'Weekly',
                            'Monthly',
                          ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (value) => setState(() => _scheduleType = value!),
                        ),
                        const SizedBox(height: 16.0),
                        if (_scheduleType == 'Specific Date/Time') ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today_outlined, size: 20),
                            label: Text(
                              _selectedDateTime != null
                                  ? DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!)
                                  : translations.selectDateTime,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)), // Allow selecting up to a year in advance
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() {
                                    _selectedDateTime = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ],
                        if (_scheduleType == 'Weekly') ...[
                          const SizedBox(height: 16.0),
                          DropdownButtonFormField<String>(
                            value: _selectedDay,
                            decoration: InputDecoration(
                              labelText: translations.day,
                              prefixIcon: const Icon(Icons.calendar_view_week, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _supplier.availability.days // Use supplier's availability
                                .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedDay = value),
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            initialValue: _selectedTime,
                            decoration: InputDecoration(
                              labelText: translations.time,
                              prefixIcon: const Icon(Icons.access_time_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) => setState(() => _selectedTime = value),
                          ),
                        ],
                        if (_scheduleType == 'Monthly') ...[
                          const SizedBox(height: 16.0),
                          TextFormField(
                            initialValue: _dayOfMonth?.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: translations.dayOfMonth,
                              prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) => setState(() => _dayOfMonth = int.tryParse(value)),
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            initialValue: _selectedTime,
                            decoration: InputDecoration(
                              labelText: translations.time,
                              prefixIcon: const Icon(Icons.access_time_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) => setState(() => _selectedTime = value),
                          ),
                        ],
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _instructionsController,
                          decoration: InputDecoration(
                            labelText: translations.instructions,
                            prefixIcon: const Icon(Icons.note_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(translations.proceed),
                  onPressed: () {
                    final schedule = Schedule(
                      type: _scheduleType,
                      dateTime: _selectedDateTime?.toUtc().toIso8601String(),
                      day: _selectedDay,
                      time: _selectedTime,
                      dayOfMonth: _dayOfMonth,
                    );
                    Navigator.pushNamed(
                      context,
                      NavigationService.orderConfirmation,
                      arguments: {
                        'supplier': _supplier,
                        'orderDetails': _orderDetails,
                        'deliveryAddress': DeliveryAddress(
                          address: _deliveryAddress,
                          coordinates: _deliveryCoordinates,
                        ),
                        'schedule': schedule,
                        'instructions': _instructionsController.text,
                        'selectedSupplierLocationId': _selectedSupplierLocationId, // Pass through
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}