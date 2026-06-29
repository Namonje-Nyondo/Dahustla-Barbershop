import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final String status;
  final String time;
  final String customerName;
  final String serviceName;
  final double price;

  const AppointmentCard({
    super.key,
    required this.status,
    required this.time,
    required this.customerName,
    required this.serviceName,
    required this.price,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.greenAccent;
      case 'pending':
        return AppTheme.primaryGold;
      case 'completed':
        return Colors.blueAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(serviceName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),

                  style: TextStyle(color: _statusColor(), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(customerName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Text('K${price.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}