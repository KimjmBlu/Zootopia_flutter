import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zootopia_hospital/pages/appointment_combined_page.dart';
import 'package:zootopia_hospital/pages/pet_register_page.dart';

class PetSelectPage extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTime;

  const PetSelectPage({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<PetSelectPage> createState() => _PetSelectPageState();
}

class _PetSelectPageState extends State<PetSelectPage> {
  final String userId = 'test_user_1'; // TODO: 로그인된 사용자 ID로 교체
  String? _selectedPetId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Pet')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pets')
                        .where('ownerId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('❌ Error loading pet list.'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('There are no registered pets'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PetRegisterPage(),
                                    ),
                                  );
                                  setState(() {}); // 돌아오면 목록 갱신
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Register a Pet'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final petId = doc.id;
                          final selected = _selectedPetId == petId;

                          return Card(
                            color: selected ? Colors.teal[50] : null,
                            child: ListTile(
                              title: Text('${data['name']} (${data['species'] ?? '-'})'),
                              subtitle: Text('Gender: ${data['gender'] ?? '-'}'),
                              trailing: selected
                                  ? const Icon(Icons.check, color: Colors.teal)
                                  : null,
                              onTap: () {
                                setState(() => _selectedPetId = petId);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PetRegisterPage(),
                          ),
                        );
                        setState(() {}); // 등록 후 목록 갱신
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Register'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _selectedPetId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AppointmentCombinedPage(
                                    petId: _selectedPetId!,
                                    selectedDate: widget.selectedDate,
                                    selectedTime: widget.selectedTime,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
