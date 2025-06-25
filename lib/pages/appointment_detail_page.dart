import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatefulWidget {
  final String petId;
  final DateTime selectedDate;
  final String selectedTime;

  const AppointmentDetailPage({
    super.key,
    required this.petId,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    print('✅ Appointment Info');
    print('Date: ${widget.selectedDate}');
    print('Time: ${widget.selectedTime}');
    print('Pet ID: ${widget.petId}');
    print('Category: $_selectedCategory');
    print('Name: ${_firstNameController.text} ${_lastNameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('Symptom: ${_symptomController.text}');
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Veterinary Consult')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please confirm your appointment details below.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),

                    Text('Date: $formattedDate'),
                    const SizedBox(height: 4),
                    Text('Time: ${widget.selectedTime}'),
                    const SizedBox(height: 4),
                    const Text('Duration: 1 hour'),
                    const SizedBox(height: 4),
                    const Text('Quantity: 1'),
                    const SizedBox(height: 24),

                    // 👇 Dropdown: Always below with limited height
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select reason for visit',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: (val) =>
                          val == null ? 'Please select a category' : null,
                      menuMaxHeight: 300, // 제한
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
                      decoration:
                          const InputDecoration(labelText: 'Concerns / Symptoms'),
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
          ),
        ),
      ),
    );
  }
}
