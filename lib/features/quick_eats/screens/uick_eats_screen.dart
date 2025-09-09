import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class QuickEatsScreen extends StatefulWidget {
  const QuickEatsScreen({super.key});

  @override
  State<QuickEatsScreen> createState() => _QuickEatsScreenState();
}

class _QuickEatsScreenState extends State<QuickEatsScreen> {
  String filter = "quick"; // "quick" or "late"
  final dbRef = FirebaseDatabase.instance.ref("restaurants");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quick Eats"),
        actions: [
          ToggleButtons(
            isSelected: [filter == "quick", filter == "late"],
            onPressed: (index) {
              setState(() {
                filter = index == 0 ? "quick" : "late";
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Quick"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Late Night"),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No spots found."));
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          // Filter restaurants by quick or late
          final restaurants = data.entries.where((entry) {
            final r = Map<String, dynamic>.from(entry.value);
            if (filter == "quick") {
              return r["quickServiceFlag"] == true;
            } else {
              return r["openLateFlag"] == true;
            }
          }).toList();

          if (restaurants.isEmpty) {
            return const Center(child: Text("No quick-service spots yet."));
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final resto = Map<String, dynamic>.from(restaurants[index].value);
              return ListTile(
                title: Text(resto["name"] ?? "Unnamed"),
                subtitle: Text(
                  "Tags: ${(resto["serviceTags"] as List?)?.join(', ') ?? "none"}",
                ),
                trailing: filter == "quick"
                    ? const Icon(Icons.fastfood)
                    : const Icon(Icons.nightlife),
              );
            },
          );
        },
      ),
    );
  }
}
