// order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/models/order.dart';
import 'package:amenities_kenya/providers/order_provider.dart'; // Import the order provider
import 'package:amenities_kenya/utilities/date_formatter.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:amenities_kenya/widgets/order_item_widget.dart';
import 'package:amenities_kenya/providers/auth_provider.dart'; // For current user ID
import 'package:amenities_kenya/providers/chat_provider.dart'; // NEW: Import chat provider
import 'package:amenities_kenya/screens/chat_screen.dart'; // NEW: Import chat screen
import 'package:url_launcher/url_launcher.dart'; // For making calls
import 'dart:async'; // For Timer
import 'dart:convert'; // For JSON decoding
import 'package:flutter/services.dart'
    show rootBundle; // For loading local JSON
import 'package:collection/collection.dart'; // For firstWhereOrNull

// NEW: Mock service to get deliverer phone numbers from db.json
class MockDelivererServiceForUserApp {
  Future<String?> getDelivererPhoneNumber(String delivererId) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/db.json');
      final data = json.decode(jsonString);
      final deliverers = data['deliverers'] as List<dynamic>;

      final deliverer = deliverers.firstWhereOrNull(
        (d) => d['deliverer_id'] == delivererId,
      );

      return deliverer?['contact_phone'] as String?;
    } catch (e) {
      print('Error fetching deliverer phone number: $e');
      return null;
    }
  }
}

class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  Timer? _pollingTimer;
  late String _orderId; // Store the orderId from arguments
  final MockDelivererServiceForUserApp _delivererService =
      MockDelivererServiceForUserApp();
  String? _delivererPhoneNumber;

  @override
  void initState() {
    super.initState();
    // No need to fetch arguments here in initState.
    // didChangeDependencies is called after initState and before build,
    // and is suitable for accessing ModalRoute.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Order object passed as arguments
    final Order initialOrder =
        ModalRoute.of(context)!.settings.arguments as Order;
    _orderId = initialOrder.orderId; // Get the order ID
    // _chatId = initialOrder.chatId; // Get the order ID

    // Start polling when the screen is initialized
    _startPolling();

    // Fetch deliverer phone number if available
    _fetchDelivererDetails(initialOrder.assignedDelivererId);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  void _startPolling() {
    // Poll every 5 seconds (adjust as needed)
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      ref.read(specificOrderProvider(_orderId).notifier).refreshOrder();
    });
  }

  Future<void> _fetchDelivererDetails(String? delivererId) async {
    if (delivererId != null) {
      final phoneNumber = await _delivererService.getDelivererPhoneNumber(
        delivererId,
      );
      setState(() {
        _delivererPhoneNumber = phoneNumber;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $phoneNumber')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    // Watch the specific order provider for updates
    final args = ModalRoute.of(context)!.settings.arguments as Order;
    final currentUser = ref.watch(userProvider);
    final orderAsyncValue = ref.watch(specificOrderProvider(_orderId));
    final currentUserId = currentUser?.userId;

    // Check if there's an assigned deliverer
    final bool canCommunicate =
        args.assignedDelivererId != null && currentUserId != null;

    return Scaffold(
      appBar: AppBar(title: Text(translations.orderTracking)),
      body: orderAsyncValue.when(
        data: (order) {
          if (order == null) {
            return Center(child: Text("orderNotFound"));
          }
          // Now 'order' is the most up-to-date Order object
          final args = order; // Use the fetched order as 'args' for consistency

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${"orderId"}: ${args.orderId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '${"currentStatus"}: ${args.status}',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(args.status),
                  ),
                ),
                const SizedBox(height: 16.0),
                LinearProgressIndicator(
                  value: _getStatusProgress(args.status),
                  backgroundColor: Colors.grey[300],
                  color: _getStatusColor(args.status),
                  minHeight: 10,
                ),
                const SizedBox(height: 24.0),
                _buildStatusTimeline(translations, args.status),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translations.orderDetails,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        OrderItemWidget(
                          details: args.details,
                          category: args.category,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          '${translations.deliveryAddress}: ${args.deliveryAddress.address}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      Text(
  '${translations.schedule}: ${args.schedule.type}',
  style: Theme.of(context).textTheme.bodyMedium,
),
if (args.estimatedDeliveryTime != null)
  Text(
    '${"estimatedDeliveryTime"}: ${DateFormatter.formatDateTime(args.estimatedDeliveryTime!)}',
    style: Theme.of(context).textTheme.bodyMedium,
  ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: Text("contactSupport"),
                        onPressed: () {
                                // Trigger the fetch/create logic in the notifier first
                                ref.read(chatSessionProvider(order).notifier).fetchChatSession().then((_) {
                                  // After fetch/create is complete, check the state and navigate.
                                  // We use .when to explicitly handle all states, but always navigate
                                  // if it's in a data state. ChatScreen will handle null data.
                                  final chatSessionState = ref.read(chatSessionProvider(order));
                                  chatSessionState.when( // Changed from whenOrNull
                                    loading: () {
                                      // This case should ideally not be hit after await, but for completeness.
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Chat session still loading... Please wait.')),
                                      );
                                    },
                                    error: (err, stack) {
                                      // If there's an actual error, show a SnackBar and don't navigate.
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error initiating chat: ${err.toString()}')),
                                      );
                                    },
                                    data: (chatSession) {
                                      // If we reach the data state (even if chatSession is null), navigate.
                                      // ChatScreen handles displaying "No chat session found" if chatSession is null
                                      // or "Start a conversation!" if chatSession.messages is empty.
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => ChatScreen(
                                            order: order, // Pass the entire order object
                                            // otherParticipantPhoneNumber: userPhoneNumberAsync.value, // Pass fetched phone number
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone),
                        label: Text("callDeliverer"),
                        onPressed: _delivererPhoneNumber != null
                            ? () => _makePhoneCall(_delivererPhoneNumber!)
                            : null, // Disable if no number
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: _delivererPhoneNumber != null
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(
                                  context,
                                ).colorScheme.tertiary.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.5),
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.rate_review),
                    label: Text(translations.rateSupplier),
                    onPressed:
                        args.status == 'Completed' || args.status == 'Fulfilled'
                        ? () {
                            Navigator.pushNamed(
                              context,
                              NavigationService.rateSupplier,
                              arguments: args,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                      disabledForegroundColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        error: (err, stack) =>
            Center(child: Text('${"errorLoadingOrder"}: $err')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Waiting for Confirmation':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Fulfilled':
        return Colors.lightGreen;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _getStatusProgress(String status) {
    switch (status) {
      case 'Waiting for Confirmation':
        return 0.1;
      case 'In Progress':
        return 0.33;
      case 'Fulfilled':
        return 0.66;
      case 'Completed':
        return 1.0;
      case 'Cancelled':
        return 0.0; // Or some other representation for cancelled
      default:
        return 0.0;
    }
  }

  Widget _buildStatusTimeline(
    AppLocalizations translations,
    String currentStatus,
  ) {
    final List<String> statuses = [
      'Waiting for Confirmation',
      'In Progress',
      'Fulfilled',
      'Completed',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((status) {
        final bool isActive =
            statuses.indexOf(status) <= statuses.indexOf(currentStatus);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isActive ? _getStatusColor(status) : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _translateStatus(translations, status),
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _translateStatus(AppLocalizations translations, String status) {
    switch (status) {
      case 'Waiting for Confirmation':
        return 'Waiting for Confirmation';
      case 'In Progress':
        return 'In Progress';
      case 'Fulfilled':
        return 'Fulfilled';
      case 'Completed':
        return 'Completed';
      case 'Cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
