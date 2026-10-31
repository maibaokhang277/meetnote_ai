import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  List<TaskItemModel> allTasks = [];
  String filter = 'all'; // all, todo, completed, unconfirmed

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final t = await _apiService.getTasks();
    setState(() {
      allTasks = t;
    });
  }

  void _toggleNotification(TaskItemModel task, bool val) {
    if (task.dueAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thiết lập hạn chót trước khi bật nhắc nhở.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? 'Đã lên lịch nhắc nhở cục bộ' : 'Đã hủy lịch nhắc nhở')));
  }

  void _editTask(TaskItemModel task) {
    // Tương tự màn hình chi tiết nhưng cho phép sửa trạng thái
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa công việc'),
        content: const Text('Chức năng mở rộng sửa chi tiết công việc'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TaskItemModel> displayTasks = allTasks;
    if (filter != 'all') {
      displayTasks = allTasks.where((t) => t.status == filter).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Công việc', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: Color(0xFF4F46E5)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng thêm việc thủ công')));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Bộ lọc
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Cần làm', 'todo'),
                const SizedBox(width: 8),
                _buildFilterChip('Đã hoàn tất', 'completed'),
                const SizedBox(width: 8),
                _buildFilterChip('Cần duyệt từ AI', 'unconfirmed'),
              ],
            ),
          ),
          Expanded(
            child: displayTasks.isEmpty
                ? const Center(child: Text('Không có công việc nào', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayTasks.length,
                    itemBuilder: (ctx, i) {
                      final task = displayTasks[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () => _editTask(task),
                          leading: Checkbox(
                            value: task.status == 'completed',
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  final updatedTask = task.copyWith(status: (val ?? false) ? 'completed' : 'todo');
                                  final index = allTasks.indexWhere((t) => t.id == task.id);
                                  if (index != -1) {
                                    allTasks[index] = updatedTask;
                                  }
                                });
                              }
                            },
                            activeColor: const Color(0xFF10B981),
                          ),
                          title: Text(task.title, style: TextStyle(decoration: task.status == 'completed' ? TextDecoration.lineThrough : null)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phụ trách: ${task.assigneeName ?? "Chưa có"}'),
                              if (task.dueAt != null)
                                Text('Hạn chót: ${task.dueAt!.day}/${task.dueAt!.month}/${task.dueAt!.year}', style: const TextStyle(color: Color(0xFFE11D48))),
                              if (task.status == 'unconfirmed')
                                const Text('Cần bổ sung thông tin', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Switch(
                            value: false, // mock
                            onChanged: (val) => _toggleNotification(task, val),
                            activeColor: const Color(0xFF4F46E5),
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

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => filter = value);
      },
      selectedColor: const Color(0xFF4F46E5).withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? const Color(0xFF4F46E5) : Colors.black),
    );
  }
}
