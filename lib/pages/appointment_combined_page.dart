import 'package:flutter/material.dart';
import 'appointment_summary_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentCombinedPage extends StatefulWidget {
  final String petId;
  final DateTime selectedDate;
  final String selectedTime;

  const AppointmentCombinedPage({
    super.key,
    required this.petId,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<AppointmentCombinedPage> createState() => _AppointmentCombinedPageState();
}

class _AppointmentCombinedPageState extends State<AppointmentCombinedPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;

  final List<String> _categories = [
    'Vaccinations / booster shots',
    'Vomiting or diarrhea',
    'Coughing',
    'General health check-up / wellness exam',
    'sneezing',
    'nasal discharge',
    'Skin issues',
    'Limping or mobility issues',
    'Eye problems',
    'Ear issues',
    'Dental concerns',
    'Urinary problems',
    'Post-surgery follow-up',
    'Parasite check or treatment',
    'Reproductive or pregnancy concerns',
    'Spaying/neutering consultation',
  ];

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _symptomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Veterinary Consult')),
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: AppointmentSummaryPage(
                        selectedDate: widget.selectedDate,
                        selectedTime: widget.selectedTime,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildDetailForm(),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppointmentSummaryPage(
                    selectedDate: widget.selectedDate,
                    selectedTime: widget.selectedTime,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select reason for visit'),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Please select a category' : null,
                isExpanded: true,
                menuMaxHeight: 300,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symptomController,
                decoration: const InputDecoration(labelText: 'Concerns / Symptoms'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final appointmentData = {
      'petId': widget.petId,
      'userId': 'test_user_1', // 로그인 연동 시 교체 필요
      'date': widget.selectedDate.toIso8601String().split('T')[0],
      'time': widget.selectedTime,
      'category': _selectedCategory,
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'symptoms': _symptomController.text,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('appointments').add(appointmentData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment successfully booked!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Failed to save appointment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book appointment. Please try again.')),
        );
      }
    }
  }
}
