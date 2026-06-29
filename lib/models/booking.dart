class BookingModel {
  final int? id;
  final String customerName;
  final String? customerEmail;
  final String customerPhone;
  final int serviceId;
  final String bookingDate;
  final String bookingTime;
  final String? notes;
  final String status;
  final Map<String, dynamic>? service; // nested service object from Laravel's with('service')

  BookingModel({
    this.id,
    required this.customerName,
    this.customerEmail,
    required this.customerPhone,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    this.notes,
    this.status = 'Pending',
    this.service,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'] ?? '',
      serviceId: json['service_id'] ?? 0,
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'Pending',
      service: json['service'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'service_id': serviceId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'notes': notes,
      'status': status,
    };
  }

  String get serviceName => service?['service_name'] ?? 'Haircut Treatment';
  double get servicePrice => double.tryParse(service?['price']?.toString() ?? '') ?? 0.0;
}