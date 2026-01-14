import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/supplier.dart';
import 'package:amenities_kenya/providers/location_provider.dart';
import 'package:amenities_kenya/services/google_maps_service.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lottie/lottie.dart';

final googleMapsServiceProvider = Provider<GoogleMapsService>((ref) {
  // Replace with your actual Google Maps API key
  const apiKey = 'AIzaSyAaqWjbul7rblbie3MSYw-5Kvv7L5ZKxYs';
  return GoogleMapsService(apiKey);
});

class LocationInputScreen extends ConsumerStatefulWidget {
  final String category;

  const LocationInputScreen({super.key, required this.category});

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends ConsumerState<LocationInputScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Coordinates? _selectedCoordinates;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final googleMapsService = ref.read(googleMapsServiceProvider);
      final location = await googleMapsService.getCurrentLocation();

         // FIX 1: Check if the widget is still mounted after getting location
      if (!mounted) return;

      final address = await googleMapsService.getAddressFromCoordinates(
        location.lat,
        location.lon,
      );
    // It's now safe to update the UI and navigate
      _addressController.text = address;
      _selectedCoordinates = location;
      ref.read(locationProvider.notifier).setLocation(location);
      Navigator.pushNamed(
        context,
        NavigationService.supplierSelection,
        arguments: {
          'category': widget.category,
          'address': _addressController.text,
          'coordinates': location,
        },
      );
    } catch (e) {
            if (!mounted) return;

      CustomDialogs.showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.error,
        content: e.toString(),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCoordinates == null) {
      CustomDialogs.showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.error,
        content: AppLocalizations.of(context)!.selectValidAddress,
      );
      return;
    }

        if (!mounted) return;

    ref.read(locationProvider.notifier).setLocation(_selectedCoordinates!);
    Navigator.pushNamed(
      context,
      NavigationService.supplierSelection,
      arguments: {
        'category': widget.category,
        'address': _addressController.text,
        'coordinates': _selectedCoordinates,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final googleMapsService = ref.read(googleMapsServiceProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(translations.enterLocation)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info box with bulb icon, text, and Lottie animation
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 4.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blueAccent, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bulb icon and text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blueAccent,
                          size: 24.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            // translations.locationInfoMessage ??
                                'We need your delivery address to find the nearest suppliers for ${widget.category}.',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // Lottie animation
                   
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  // color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bulb icon and text
                    SizedBox(
                      height: screenHeight * 2 / 8, // 3/8 of screen height
                      child: Lottie.asset('assets/images/delivery_json.json'),
                    ),
                  ],
                ),
              ),
               TypeAheadField<Map<String, dynamic>>(
                  builder: (context, controller, focusNode) => TextFormField(
                    // IMPORTANT: You are already using _addressController here.
                    // The `builder` provides a controller, but you should use your own
                    // to link it to the rest of the state.
                    controller: _addressController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: translations.deliveryAddress,
                      icon: const Icon(Icons.location_on),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? translations.addressRequired : null,
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    // Using a try-catch here is great!
                    return await googleMapsService.getPlaceSuggestions(pattern);
                  },
                  itemBuilder: (context, Map<String, dynamic> suggestion) {
                    return ListTile(
                      title: Text(suggestion['description'] ?? 'No description'),
                    );
                  },
                  onSelected: (Map<String, dynamic> suggestion) async {
                    try {
                      final placeId = suggestion['place_id'] as String;

                      // --- ASYNC GAP 3 ---
                      final details = await googleMapsService.getPlaceDetails(placeId);

                      // FIX 5: The most critical fix for the TextEditingController error!
                      if (!mounted) return;

                      // Now it's safe to update the controller and state
                      _addressController.text = details['formatted_address'] ?? '';
                      final location = details['geometry']['location'];
                      setState(() {
                        _selectedCoordinates = Coordinates(
                          lat: location['lat'] as double,
                          lon: location['lng'] as double,
                        );
                      });
                    } catch (e) {
                      if (!mounted) return;
                      CustomDialogs.showErrorDialog(
                        context: context,
                        title: translations.error,
                        content: e.toString(),
                      );
                    }
                  },
                  emptyBuilder: (context) => const ListTile(
                    title: Text('No results found'),
                  ),
                ),
                const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitAddress,
                child: Text(translations.submit),
              ),
              const SizedBox(height: 16.0),
           TextButton(
                  onPressed: _isLoading ? null : _useCurrentLocation,
                  child: _isLoading
                      ? const SizedBox( // Use a sized box for consistent height
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : Text(translations.useCurrentLocation),
                ),
            ],
          ),
        ),
      ),
    );
  }
}