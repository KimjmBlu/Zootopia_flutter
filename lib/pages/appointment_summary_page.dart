import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AppointmentSummaryPage extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedTime;

  const AppointmentSummaryPage({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy.MM.dd').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Veterinary Consult', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Please confirm your appointment details below.'),
        const SizedBox(height: 16),
        _summaryRow('Date', formattedDate),
        _summaryRow('Time', selectedTime),
        _summaryRow('Duration', '30 min'),
        _summaryRow('Quantity', '1'),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
