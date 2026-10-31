import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'meeting_detail_screen.dart';

class HistorySearchScreen extends StatefulWidget {
  const HistorySearchScreen({super.key});

  @override
  State<HistorySearchScreen> createState() => _HistorySearchScreenState();
}

class _HistorySearchScreenState extends State<HistorySearchScreen> {
  final ApiService _apiService = ApiService();
  String searchQuery = '';
  String statusFilter = 'all'; // all, completed, transcribing, error
  String langFilter = 'all'; // all, vi, en

  void _deleteMeeting(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc chắn muốn xóa bản ghi này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              Navigator.pop(ctx);
              await _apiService.deleteMeeting(id);
              setState(() {});
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MeetingModel> displayList = _apiService.mockMeetings.where((m) {
      bool matchSearch = m.title.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchStatus = statusFilter == 'all' || m.status == statusFilter;
      bool matchLang = langFilter == 'all' || m.language == langFilter;
      return matchSearch && matchStatus && matchLang;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lịch sử', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu đề...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Mọi trạng thái')),
                    DropdownMenuItem(value: 'completed', child: Text('Đã hoàn tất')),
                    DropdownMenuItem(value: 'transcribing', child: Text('Đang xử lý')),
                  ],
                  onChanged: (val) => setState(() => statusFilter = val!),
                  underline: const SizedBox(),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: langFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Mọi ngôn ngữ')),
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (val) => setState(() => langFilter = val!),
                  underline: const SizedBox(),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text('Không tìm thấy ghi chú nào', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayList.length,
                    itemBuilder: (ctx, i) {
                      final m = displayList[i];
                      return Dismissible(
                        key: Key(m.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: const Color(0xFFE11D48),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          _deleteMeeting(m.id);
                          return false; // Dialog handles deletion
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: m.status == 'completed' ? const Color(0xFF10B981).withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              child: Icon(
                                m.status == 'completed' ? Icons.check_circle_rounded : Icons.pending_rounded,
                                color: m.status == 'completed' ? const Color(0xFF10B981) : Colors.orange,
                              ),
                            ),
                            title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${m.createdAt.day}/${m.createdAt.month}/${m.createdAt.year} • ${m.language == "vi" ? "Tiếng Việt" : "English"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFE11D48)),
                              onPressed: () => _deleteMeeting(m.id),
                            ),
                            onTap: () {
                              if (m.status == 'completed') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => MeetingDetailScreen(meetingId: m.id)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bản ghi đang được xử lý...')));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
