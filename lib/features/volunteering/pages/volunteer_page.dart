import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VolunteerPage extends StatelessWidget {
  const VolunteerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Volunteer Opportunities'),
      ),
      body: Column(
        children: [
          // Header with search and filters
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search opportunities...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('All', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const _FilterChip(label: 'This Week', isSelected: true),
                    const SizedBox(width: 8),
                    const _FilterChip(label: 'Dhaka', isSelected: true),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List of Opportunities
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                _VolunteerCard(
                  title: 'Teaching Assistant - Weekend Classes',
                  organization: 'Shishu Palli Orphanage',
                  date: 'Every Saturday',
                  time: '10:00 AM - 1:00 PM',
                  location: 'Dhanmondi, Dhaka',
                  description: 'Help children with homework and reading activities. Patient and caring volunteers needed.',
                ),
                SizedBox(height: 16),
                _VolunteerCard(
                  title: 'Event Helper - Sports Day',
                  organization: 'Amar Shishu',
                  date: 'March 20, 2026',
                  time: '8:00 AM - 4:00 PM',
                  location: 'Agrabad, Chattogram',
                  description: 'Help organize and supervise sports activities for children. Energetic volunteers welcome!',
                ),
                SizedBox(height: 16),
                _VolunteerCard(
                  title: 'Art & Craft Instructor',
                  organization: 'Ashar Alo Childcare Home',
                  date: 'Every Friday',
                  time: '3:00 PM - 5:00 PM',
                  location: 'Mirpur, Dhaka',
                  description: 'Teach basic art and craft skills to children aged 6-12 years.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey.shade100,
        border: Border.all(color: isSelected ? Colors.grey.shade400 : Colors.transparent),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black87 : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final String title;
  final String organization;
  final String date;
  final String time;
  final String location;
  final String description;

  const _VolunteerCard({
    required this.title,
    required this.organization,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  organization,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.calendar_today_outlined, text: date),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.access_time_outlined, text: time),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.location_on_outlined, text: location),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  color: Colors.grey, // or a primary color in actual design
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}