import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final ApiService _apiService = ApiService();
  bool _micGranted = true;
  bool _notifGranted = true;
  String _lang = 'vi';

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () {
              Navigator.pop(ctx);
              _apiService.currentUser = null;
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa 120MB dữ liệu bộ nhớ đệm.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = _apiService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cá nhân', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF4F46E5),
              child: Text(
                user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? 'Người dùng', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? 'email@example.com', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Storage
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dung lượng lưu trữ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 8),
                    const Text('Đã dùng 3GB / 5GB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: Color(0xFF4F46E5)),
                    title: const Text('Ngôn ngữ nhận diện ưu tiên'),
                    trailing: DropdownButton<String>(
                      value: _lang,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (val) => setState(() => _lang = val!),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.mic_rounded, color: Color(0xFF4F46E5)),
                    title: const Text('Quyền truy cập Micro'),
                    value: _micGranted,
                    onChanged: (val) => setState(() => _micGranted = val),
                    activeColor: const Color(0xFF10B981),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_rounded, color: Color(0xFF4F46E5)),
                    title: const Text('Thông báo nhắc việc'),
                    value: _notifGranted,
                    onChanged: (val) => setState(() => _notifGranted = val),
                    activeColor: const Color(0xFF10B981),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_rounded, color: Colors.orange),
                    title: const Text('Xóa bộ nhớ đệm'),
                    onTap: _clearCache,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE11D48),
                  side: const BorderSide(color: Color(0xFFE11D48)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
