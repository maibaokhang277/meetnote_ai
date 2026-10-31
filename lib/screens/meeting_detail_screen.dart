import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class MeetingDetailScreen extends StatefulWidget {
  final String meetingId;
  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  bool isLoading = true;
  MeetingModel? meeting;
  SummaryModel? summary;
  TranscriptModel? transcript;
  List<TaskItemModel> tasks = [];
  bool isPlaying = false;
  double audioProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getMeetingDetail(widget.meetingId);
      setState(() {
        meeting = data['meeting'];
        summary = data['summary'];
        transcript = data['transcript'];
        tasks = data['tasks'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _editTitle() {
    TextEditingController ctrl = TextEditingController(text: meeting!.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa tiêu đề'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              setState(() {
                meeting = meeting!.copyWith(title: ctrl.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteMeeting() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () async {
              Navigator.pop(ctx);
              await _apiService.deleteMeeting(widget.meetingId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _editSummary() {
    TextEditingController ctrl = TextEditingController(text: summary?.summaryText ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Tóm tắt'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              setState(() {
                summary = summary!.copyWith(summaryText: ctrl.text, editedAt: DateTime.now());
              });
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _editTranscript(int index) {
    TextEditingController ctrl = TextEditingController(text: transcript!.segmentsJson[index].text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa bản dịch'),
        content: TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              setState(() {
                transcript!.segmentsJson[index] = transcript!.segmentsJson[index].copyWith(text: ctrl.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmTask(TaskItemModel task) {
    TextEditingController assigneeCtrl = TextEditingController(text: task.assigneeName);
    DateTime? selectedDate = task.dueAt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Xác nhận Công việc'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Trích đoạn: "${task.sourceText ?? ""}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                TextField(
                  controller: assigneeCtrl,
                  decoration: const InputDecoration(labelText: 'Người phụ trách', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    DateTime? d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) {
                      setDialogState(() => selectedDate = d);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'Chọn Hạn chót (Bắt buộc)'),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              FilledButton(
                onPressed: () async {
                  if (assigneeCtrl.text.isEmpty || selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin!')));
                    return;
                  }
                  final updatedTask = task.copyWith(
                    assigneeName: assigneeCtrl.text,
                    dueAt: selectedDate,
                    status: 'todo',
                  );
                  await _apiService.updateTask(task.id, updatedTask);
                  setState(() {
                    int idx = tasks.indexWhere((t) => t.id == task.id);
                    tasks[idx] = updatedTask;
                  });
                  if (mounted) Navigator.pop(ctx);
                },
                child: const Text('Xác nhận lưu vào To-Do'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(meeting!.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: _editTitle),
          IconButton(
            icon: const Icon(Icons.autorenew_rounded),
            tooltip: 'Phân tích lại bằng AI',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang phân tích lại...')));
            },
          ),
          IconButton(icon: const Icon(Icons.delete_rounded, color: Color(0xFFE11D48)), onPressed: _deleteMeeting),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
          tabs: const [
            Tab(text: 'Tóm tắt AI'),
            Tab(text: 'Bản chép lời'),
            Tab(text: 'Công việc'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Audio Player
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: const Color(0xFF4F46E5), size: 36),
                  onPressed: () => setState(() => isPlaying = !isPlaying),
                ),
                Expanded(
                  child: Slider(
                    value: audioProgress,
                    onChanged: (val) => setState(() => audioProgress = val),
                    activeColor: const Color(0xFF4F46E5),
                  ),
                ),
                const Text('1.0x', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Summary
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nội dung chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: _editSummary,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Chỉnh sửa'),
                              )
                            ],
                          ),
                          const Divider(),
                          Text(summary?.summaryText ?? 'Không có dữ liệu', style: const TextStyle(height: 1.5)),
                          if (summary?.editedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text('Chỉnh sửa lần cuối: ${summary!.editedAt!.hour}:${summary!.editedAt!.minute}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                            )
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab 2: Transcript
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transcript?.segmentsJson.length ?? 0,
                  itemBuilder: (ctx, i) {
                    final seg = transcript!.segmentsJson[i];
                    return InkWell(
                      onTap: () => _editTranscript(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${seg.startTime.toInt()}s',
                              style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(seg.text, style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('Độ tin cậy: ${(seg.confidence * 100).toInt()}%', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Tab 3: Action Items
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (ctx, i) {
                    final task = tasks[i];
                    bool needsManual = task.assigneeName == null || task.dueAt == null;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: needsManual ? const Color(0xFFF59E0B) : Colors.transparent)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                                if (needsManual)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Cần nhập thủ công', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Người phụ trách: ${task.assigneeName ?? "[Chưa rõ]"}', style: const TextStyle(fontSize: 13)),
                            Text('Hạn chót: ${task.dueAt != null ? "${task.dueAt!.day}/${task.dueAt!.month}/${task.dueAt!.year}" : "[Chưa rõ]"}', style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                              child: Text('"${task.sourceText ?? ""}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                            ),
                            if (needsManual)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _confirmTask(task),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
                                    child: const Text('Bổ sung & Xác nhận'),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
