import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for day/date formatting
import 'package:supabase_flutter/supabase_flutter.dart';


extension StringCasingExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class ReportUploadScreen extends StatefulWidget {
  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  String? selectedFile;
  String? selectedFilePath;
  String greeting = '';
  String userName = 'User';
  String dayAndDate = '';

  @override
  void initState() {
    super.initState();
    updateGreetingAndName();
  }

  void updateGreetingAndName() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour < 20) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null) {
      final email = user.email!;
      userName = email.split('@')[0].split('.').first.capitalize();
    }

    final now = DateTime.now();
    final formatter = DateFormat('EEE, d MMM yyyy');
    dayAndDate = formatter.format(now);

    setState(() {});
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first.name;
        selectedFilePath = result.files.first.path;
      });
    }
  }

  Future<void> uploadFileToServer(BuildContext context) async {
    if (selectedFilePath == null) return;

    Navigator.pushNamed(context, '/load');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/docs'),
    );
    request.files.add(
        await http.MultipartFile.fromPath('file', selectedFilePath!));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();
        Navigator.pushReplacementNamed(context, '/get_results',
            arguments: result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prediction failed. Please try again.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar section
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E2A47), Color(0xFF143F67)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile + date + notification icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('images/avatar.png'),
                    ),
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              dayAndDate,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '$greeting, $userName!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xAA9BEFBD), Color(0xAA4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    ' New User',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              'Upload your Report',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E3A59),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Upload your medical report and receive an analysis',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Center(
            child: Text(
              'of your health status.',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: GestureDetector(
              onTap: pickFile,
              child: DottedBorder(
                color: Colors.grey,
                strokeWidth: 1.5,
                dashPattern: [6, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                child: Container(
                  height: 80,
                  width: 80,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'images/upload.png',
                    height: 32,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                Text(
                  selectedFile ?? 'Upload from Local File',
                  style: const TextStyle(color: Color(0xFF4B4B4B), fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Format: jpg, png, pdf',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: InkWell(
              onTap: selectedFilePath != null
                  ? () => uploadFileToServer(context)
                  : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E2A47), Color(0xFF143F67)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: const Text(
                  'Analyse  →',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 32, right: 32),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF0F2C59),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Image.asset('images/nav_home.png', height: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('images/nav_stats.png', height: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('images/nav_chat.png', height: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('images/nav_plus.png', height: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('images/nav_profile.png', height: 24),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
