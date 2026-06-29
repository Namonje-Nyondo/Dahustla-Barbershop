import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import '../services/api_services.dart';
import 'appointments.dart'; // Direct forwarding target

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late Future<List<dynamic>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = ApiService.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
            'SERVICES OFFERED',
            style: TextStyle(
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontSize: 16
            )
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold)
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No active grooming treatments found.',
                    style: TextStyle(color: AppTheme.textSecondary))
            );
          }

          final rawList = snapshot.data!;

          // CHANGED: ListView.builder replaced with GridView.builder
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            // Controls the side-by-side layout
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // Number of columns
              crossAxisSpacing: 16,       // Space between cards (horizontal)
              mainAxisSpacing: 16,        // Space between cards (vertical)
              childAspectRatio: 0.75,     // Ratio of width to height (adjust if cards are too tall/short)
            ),
            itemCount: rawList.length,
            itemBuilder: (context, index) {
              // Safely construct model structure
              final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawList[index]);
              ServiceModel item = ServiceModel.fromJson(jsonMap);

              return ServiceCard(
                service: item,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointmentsScreen(selectedService: item)
                    ),
                  );
                },
                onDelete: () {}, // Handled if needed
              );
            },
          );
        },
      ),
    );
  }
}