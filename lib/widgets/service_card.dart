import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "http://10.0.2.2:8000/storage/";

    // 🛠️ RESOLVE IMAGE URL
    String rawPath = service.imageUrl ?? '';
    String fullImageUrl;

    if (rawPath.startsWith('http')) {
      fullImageUrl = rawPath;
    } else {
      String cleanPath = rawPath.replaceFirst(RegExp(r'^public/'), '');
      cleanPath = cleanPath.replaceFirst(RegExp(r'^/'), '');
      fullImageUrl = '$baseUrl$cleanPath';
    }

    return Container(
      // Removed margin because GridView handles spacing via crossAxisSpacing
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE BLOCK (TOP)
            Expanded(
              flex: 3, // Takes up 3/5 of the card height
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image,
                          color: AppTheme.primaryGold, size: 30);
                    },
                  ),
                )
                    : const Icon(Icons.content_cut,
                    color: AppTheme.textSecondary, size: 30),
              ),
            ),

            // 2. TEXT CONTENT (BOTTOM)
            Expanded(
              flex: 2, // Takes up 2/5 of the card height
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (service.name ?? '').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      service.description ?? 'Professional grooming.',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'K${(service.price ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                            const SizedBox(width: 2),
                            Text(
                              '${service.duration}m',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}