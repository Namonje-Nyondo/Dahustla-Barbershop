import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../themes/app_theme.dart';
import '../models/service.dart';
import '../services/api_services.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final ServiceModel service;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.service,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _paymentStatus = 'idle'; // idle, pending, paid, failed
  String? _reference;
  String? _detectedNetwork;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_detectNetworkLogic);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _detectNetworkLogic() {
    String text = _phoneController.text.trim();
    if (text.startsWith('097') || text.startsWith('077')) {
      setState(() => _detectedNetwork = 'Airtel');
    } else if (text.startsWith('096') || text.startsWith('076')) {
      setState(() => _detectedNetwork = 'MTN');
    } else if (text.startsWith('095') || text.startsWith('075')) {
      setState(() => _detectedNetwork = 'Zamtel');
    } else {
      setState(() => _detectedNetwork = null);
    }
  }

  Future<void> _initiatePayment() async {
    String phone = _phoneController.text.trim();

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    // Convert 097... to 26097... for Zambian Gateway compatibility
    if (phone.startsWith('0')) {
      phone = '260${phone.substring(1)}';
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/payments/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'booking_id': widget.bookingId,
          'phone_number': phone,
          'amount': widget.service.price,
        }),
      );

      final data = jsonDecode(response.body);
      debugPrint("Initiate Status: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _paymentStatus = 'pending';
          _reference = data['reference'];
        });
        _pollPaymentStatus();
      } else {
        setState(() => _paymentStatus = 'failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Payment error')),
        );
      }
    } catch (e) {
      setState(() => _paymentStatus = 'failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pollPaymentStatus() async {
    if (_reference == null) return;

    // Wait 65 seconds before first check — ZynlePay needs at least 60s
    await Future.delayed(const Duration(seconds: 65));
    if (!mounted) return;

    // Then poll every 15 seconds for up to 3 more minutes
    for (int i = 0; i < 12; i++) {
      try {
        final response = await http.post(
          Uri.parse('${ApiService.baseUrl}/payments/status'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'reference': _reference}),
        );

        if (!mounted) return;

        final data = jsonDecode(response.body);
        final status = data['status'];
        debugPrint('Polling Status for $_reference: $status');

        if (status == 'paid' || status == 'completed' || status == 'successful') {
          setState(() => _paymentStatus = 'paid');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful! Booking confirmed.'),
                backgroundColor: Colors.green,
              ),
            );
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
          }
          return;
        } else if (status == 'failed' || status == 'cancelled') {
          setState(() => _paymentStatus = 'failed');
          return;
        }
        // status == 'pending' → wait and try again
      } catch (e) {
        debugPrint('Polling error: $e');
      }

      // Wait 15 seconds before next poll
      await Future.delayed(const Duration(seconds: 15));
      if (!mounted) return;
    }

    // Timed out after ~3 minutes
    if (mounted && _paymentStatus == 'pending') {
      setState(() => _paymentStatus = 'failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timed out. Your booking is saved — visit the shop to pay.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildNetworkBadge() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Center(
        child: _detectedNetwork != null
            ? Image.asset(
          'assets/images/${_detectedNetwork!.toLowerCase()}.PNG', // FIXED: Changed to lowercase .png
          width: 32,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, color: AppTheme.primaryGold),
        )
            : const Icon(Icons.phone_android, color: AppTheme.textSecondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Payment', style: TextStyle(color: AppTheme.primaryGold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('K${widget.service.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (_paymentStatus == 'idle') ...[
              const Text('MoMo Phone Number', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildNetworkBadge(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: '0971234567',
                        hintStyle: TextStyle(color: Colors.white24),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                  onPressed: _isLoading ? null : _initiatePayment,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('PAY NOW', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],

            if (_paymentStatus == 'pending') ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(color: AppTheme.primaryGold),
                    const SizedBox(height: 24),
                    const Text(
                      'Waiting for Approval...',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please approve the payment prompt on your phone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'This may take up to 60 seconds. Please keep this screen open.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_paymentStatus == 'failed') ...[
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
                    const SizedBox(height: 16),
                    const Text('Payment Failed', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('We could not confirm your payment. Please ensure you have enough balance and try again.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                        onPressed: () => setState(() => _paymentStatus = 'idle'),
                        child: const Text('TRY AGAIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text('Cancel Booking', style: TextStyle(color: Colors.redAccent)),
                    )
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}