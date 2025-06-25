import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zootopia_hospital/pages/petselect_page.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    setState(() {
      _isLoading = true;
      _selectedTime = null;
    });

    final dateKey = _selectedDate.toIso8601String().split('T')[0];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('time_slots')
          .where('date', isEqualTo: dateKey)
          .orderBy('time')
          .get();

      final slots = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'time': data['time'] as String,
          'available': data['available'] == true,
        };
      }).toList();

      setState(() {
        _timeSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading time slots: $e');
      setState(() {
        _timeSlots = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Veterinary Consult')),
      body: Column(
        children: [
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: _buildCalendar()),
                      Expanded(child: _buildTimeSlots()),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCalendar(),
                        _buildTimeSlots(),
                      ],
                    ),
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedTime != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetSelectPage(
                                selectedDate: _selectedDate,
                                selectedTime: _selectedTime!,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
        child: CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          onDateChanged: (picked) {
            setState(() => _selectedDate = picked);
            _loadTimeSlots();
          },
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_timeSlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No available time slots for the selected date.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              children: _timeSlots.map((slot) {
                final time = slot['time'] as String;
                final available = slot['available'];
                final selected = _selectedTime == time;

                return Card(
                  elevation: 1,
                  color: !available
                      ? Colors.grey[300]
                      : selected
                          ? Colors.teal[100]
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: available
                        ? () => setState(() => _selectedTime = time)
                        : null,
                    child: Center(
                      child: Text(
                        time,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                          color: available ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
