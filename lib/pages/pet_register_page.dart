import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetRegisterPage extends StatefulWidget {
  const PetRegisterPage({super.key});

  @override
  State<PetRegisterPage> createState() => _PetRegisterPageState();
}

class _PetRegisterPageState extends State<PetRegisterPage> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  DateTime? _birthdate;
  String? _type;
  String? _gender;
  bool _neutered = false;

  final String ownerId = 'test_user_1'; // TODO: 로그인된 사용자 ID로 교체

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _birthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and birthdate are required')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('pets').add({
      'name': _nameController.text,
      'species': _speciesController.text,
      'birthdate': _birthdate!.toIso8601String(),
      'type': _type,
      'gender': _gender,
      'neutered': _neutered,
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet successfully registered!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Pet')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Pet Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _speciesController,
                    decoration: const InputDecoration(labelText: 'Breed (e.g., Poodle)'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      _birthdate == null
                          ? 'Select Birthdate'
                          : 'Birthdate: ${_birthdate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2020),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _birthdate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Type'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _type == 'Dog' ? Colors.teal : null,
                          ),
                          onPressed: () => setState(() => _type = 'Dog'),
                          child: const Text('Dog'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _type == 'Cat' ? Colors.teal : null,
                          ),
                          onPressed: () => setState(() => _type = 'Cat'),
                          child: const Text('Cat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Gender'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gender == 'Male' ? Colors.teal : null,
                          ),
                          onPressed: () => setState(() => _gender = 'Male'),
                          child: const Text('Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gender == 'Female' ? Colors.teal : null,
                          ),
                          onPressed: () => setState(() => _gender = 'Female'),
                          child: const Text('Female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    title: const Text('Neutered'),
                    value: _neutered,
                    onChanged: (val) => setState(() => _neutered = val!),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                      label: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
