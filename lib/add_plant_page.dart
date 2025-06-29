import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_buddy/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _wateringController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addPlant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = supabase.auth.currentUser;
        if (user == null) return;

        await supabase.from('plants').insert({
          'user_id': user.id,
          'name': _nameController.text.trim(),
          'species': _speciesController.text.trim(),
          'watering_frequency_days': int.tryParse(_wateringController.text.trim()),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plant added successfully!')),
          );
          Navigator.of(context).pop();
        }
      } on PostgrestException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Plant')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(labelText: 'Species (e.g., Monstera deliciosa)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _wateringController,
                  decoration: const InputDecoration(labelText: 'Watering Frequency (in days)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addPlant,
                  child: Text(_isLoading ? 'Saving...' : 'Add Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
