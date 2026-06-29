import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../themes/app_theme.dart';
import '../models/service.dart';
import '../services/api_services.dart';
import 'payment.dart';

class AppointmentsScreen extends StatefulWidget {
  final ServiceModel selectedService;
  const AppointmentsScreen({super.key, required this.selectedService});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = 'Select Time';
  bool _isSubmitting = false;
  List<String> _bookedSlots = []; // To store taken times from DB

  final List<String> _timeSlots = ['09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'];

  @override
  void initState() {
    super.initState();
    _checkAvailability(_selectedDate);
  }

  // 🛠️ CHECK DATABASE FOR TAKEN TIMES
  Future<void> _checkAvailability(DateTime date) async {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/bookings/availability?date=$formattedDate'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _bookedSlots = data.map((e) => e.toString()).toList();
          _selectedTime = 'Select Time'; // Reset selection when date changes
        });
      }
    } catch (e) {
      debugPrint("Availability error: $e");
    }
  }

  String _formatTimeFor24Hour(String time) {
    if (time == 'Select Time') return '';
    final parts = time.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final minute = hm[1];
    final period = parts[1];
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == 'Select Time') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final formattedTime = _formatTimeFor24Hour(_selectedTime);

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/bookings'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'customer_name': _nameController.text.trim(),
          'customer_email': _emailController.text.trim(),
          'customer_phone': _phoneController.text.trim(),
          'service_id': widget.selectedService.id,
          'booking_date': formattedDate,
          'booking_time': formattedTime,
          'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(bookingId: data['booking']['id'], service: widget.selectedService),
          ),
        );
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white), title: const Text('RESERVE CHAIR')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(widget.selectedService.name.toUpperCase(), style: const TextStyle(color: AppTheme.primaryGold, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            // Details Fields (Name, Email, Phone, Notes...)
            _buildField(_nameController, 'Full Name', 'John Doe'),
            const SizedBox(height: 16),
            _buildField(_emailController, 'Email', 'john@example.com', isEmail: true),
            const SizedBox(height: 16),
            _buildField(_phoneController, 'Phone', '097...', isPhone: true),
            const SizedBox(height: 32),

            const Text('SELECT DATE', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _checkAvailability(picked);
                }
              },
              child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            ),

            const SizedBox(height: 24),
            const Text('SELECT TIME', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                final String? picked = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: AppTheme.cardBg,
                  builder: (context) {
                    return ListView(
                      shrinkWrap: true,
                      children: _timeSlots.map((time) {
                        final bool isTaken = _bookedSlots.contains(_formatTimeFor24Hour(time));
                        return ListTile(
                          enabled: !isTaken,
                          title: Text(time, style: TextStyle(color: isTaken ? Colors.white24 : Colors.white, decoration: isTaken ? TextDecoration.lineThrough : null)),
                          subtitle: isTaken ? const Text("Already Booked", style: TextStyle(color: Colors.red, fontSize: 10)) : null,
                          onTap: () => Navigator.pop(context, time),
                        );
                      }).toList(),
                    );
                  },
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
              child: Text(_selectedTime),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                onPressed: _isSubmitting ? null : _submitBooking,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('PROCEED TO PAYMENT', style: TextStyle(color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, String hint, {bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(labelText: label, hintText: hint, labelStyle: const TextStyle(color: AppTheme.textSecondary)),
      validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
    );
  }
}