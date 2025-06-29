import 'package:flutter/material.dart';
import 'package:plant_buddy/add_plant_page.dart';
import 'package:plant_buddy/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Stream<List<Map<String, dynamic>>> _plantsStream;

  @override
  void initState() {
    super.initState();
    _plantsStream = supabase
        .from('plants')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _plantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final plants = snapshot.data!;
          if (plants.isEmpty) {
            return const Center(
              child: Text(
                'You have no plants yet.\nAdd one to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final lastWatered = plant['last_watered_at'] != null
                  ? timeago.format(DateTime.parse(plant['last_watered_at']))
                  : 'Never';
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: plant['image_url'] != null
                      ? NetworkImage(plant['image_url'])
                      : null,
                  child: plant['image_url'] == null
                      ? const Icon(Icons.local_florist)
                      : null,
                ),
                title: Text(plant['name']),
                subtitle: Text('Watered: $lastWatered'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to plant detail page
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPlantPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
