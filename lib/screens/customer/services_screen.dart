import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'title': 'Consultation',
        'description': 'Get expert advice on our services',
        'icon': Icons.phone_in_talk,
        'color': Colors.blue,
      },
      {
        'title': 'Support',
        'description': '24/7 customer support available',
        'icon': Icons.support_agent,
        'color': Colors.green,
      },
      {
        'title': 'Product Information',
        'description': 'Learn more about our products',
        'icon': Icons.info,
        'color': Colors.orange,
      },
      {
        'title': 'Booking',
        'description': 'Schedule appointments and services',
        'icon': Icons.calendar_today,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (service['color'] as Color).withOpacity(0.1),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                ),
              ),
              title: Text(
                service['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(service['description'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${service['title']} service selected'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

