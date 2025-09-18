import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 20),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: size.width * 0.15,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: size.width * 0.15, color: Colors.white),
          ),
          SizedBox(height: 20),

          // Name
          Text(
            "John Doe",
            style: TextStyle(
              fontSize: size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),

          // Role / Designation
          Text(
            "Software Engineer",
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6),

          // Email / Contact
          Text(
            "johndoe@example.com",
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),

          // Stats / Info Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStat("12", "Projects", size),
              _buildProfileStat("8", "Teams", size),
              _buildProfileStat("3", "Awards", size),
            ],
          ),
          SizedBox(height: 30),

          // Action buttons / settings
          _buildProfileOption(Icons.edit, "Edit Profile", size),
          _buildProfileOption(Icons.lock, "Change Password", size),
          _buildProfileOption(Icons.settings, "Settings", size),
          _buildProfileOption(Icons.logout, "Logout", size, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String count, String label, Size size) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String label, Size size, {Color? color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.teal),
        title: Text(
          label,
          style: TextStyle(fontSize: size.width * 0.045, color: color ?? Colors.black),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle option tap
        },
      ),
    );
  }
}