import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/appointment_card.dart';
import '../services/api_services.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  void _refreshBookings() {
    setState(() {
      _bookingsFuture = ApiService.fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MY SCHEDULE',
            style: TextStyle(
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontSize: 16
            )
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryGold),
            onPressed: _refreshBookings,
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No active grooming appointments scheduled.',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          final allBookings = snapshot.data!;

          // Filtering bookings by status
          final upcomingBookings = allBookings.where((b) {
            final status = b['status'].toString().toLowerCase();
            return status == 'confirmed' || status == 'pending';
          }).toList();

          final pastBookings = allBookings.where((b) {
            final status = b['status'].toString().toLowerCase();
            return status == 'completed' || status == 'cancelled';
          }).toList();

          return RefreshIndicator(
            color: AppTheme.primaryGold,
            onRefresh: () async => _refreshBookings(),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text('Upcoming Visits',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (upcomingBookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('No pending or confirmed time slots locked.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  )
                else
                  ...upcomingBookings.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AppointmentCard(
                      status: b['status'] ?? 'pending',
                      time: '${b['booking_date']} at ${b['booking_time']}',
                      customerName: b['customer_name'] ?? 'Walk-In Client',
                      serviceName: b['service'] != null
                          ? (b['service']['service_name'] ?? 'Haircut Treatment')
                          : 'Haircut Treatment',
                      // SAFE PARSING: Converts String price to Double
                      price: b['service'] != null
                          ? (double.tryParse(b['service']['price'].toString()) ?? 0.0)
                          : 0.0,
                    ),
                  )),

                const SizedBox(height: 24),

                const Text('Past History',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (pastBookings.isEmpty)
                  const Text('No archived session history.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))
                else
                  ...pastBookings.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: AppointmentCard(
                        status: b['status'] ?? 'completed',
                        time: '${b['booking_date']}',
                        customerName: b['customer_name'] ?? 'Walk-In Client',
                        serviceName: b['service'] != null
                            ? (b['service']['service_name'] ?? 'Haircut Treatment')
                            : 'Haircut Treatment',
                        // SAFE PARSING: Converts String price to Double
                        price: b['service'] != null
                            ? (double.tryParse(b['service']['price'].toString()) ?? 0.0)
                            : 0.0,
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}
