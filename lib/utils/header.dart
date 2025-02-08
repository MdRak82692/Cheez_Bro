import 'package:flutter/material.dart';
import '../screens/admin/admin_profile/admin_profile_page.dart';
import '../screens/login_page.dart';
import 'text.dart';

Widget buildHeader(BuildContext context) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              hintStyle: style1(18, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            style: style(18, color: Colors.black),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const SizedBox(width: 16),
            // Profile Dropdown
            PopupMenuButton<String>(
              icon: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
              onSelected: (value) {
                if (value == 'Profile') {
                  // Navigate to Profile Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                } else if (value == 'Logout') {
                  // Logout Logic
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'Profile',
                  child:
                      Text('Profile', style: style1(18, color: Colors.black)),
                ),
                PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout', style: style1(18, color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
