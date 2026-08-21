import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: themeProvider.isDark
            ? const Color(0xFF1E1E1E)
            : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: themeProvider.isDark ? Colors.yellow : Colors.orange,
                ),
                title: Text(
                  themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Switch(
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  // Updated: Use activeThumbColor instead of activeColor
                  activeThumbColor: Colors.blue,
                  activeTrackColor: Colors.blue.shade200,
                  // Optional: Customize inactive colors
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
