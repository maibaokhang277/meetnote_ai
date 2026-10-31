import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'meeting_detail_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String meetingId;
  const ProcessingScreen({super.key, required this.meetingId});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

enum ProcessState { loading, error, success }

class _ProcessingScreenState extends State<ProcessingScreen> {
  final ApiService _apiService = ApiService();
  int currentStep = 0;
  ProcessState _state = ProcessState.loading;

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  void _startProcess() async {
    if (!mounted) return;
    setState(() {
      _state = ProcessState.loading;
      currentStep = 0;
    });

    try {
      // Step 0: Đã tải tệp lên
      await Future.delayed(const Duration(seconds: 1));
      if (_state == ProcessState.error) return; // if user clicked error debug
      setState(() => currentStep = 1);

      // Step 1: Đang chuyển giọng nói
      await Future.delayed(const Duration(seconds: 2));
      if (_state == ProcessState.error) return;
      setState(() => currentStep = 2);

      // Step 2: Đang tóm tắt & Action Items
      await _apiService.analyzeMeeting(widget.meetingId); // Takes 3s
      if (_state == ProcessState.error) return;
      setState(() => currentStep = 3);

      // Step 3: Hoàn tất
      await Future.delayed(const Duration(milliseconds: 500));
      if (_state == ProcessState.error) return;
      setState(() => _state = ProcessState.success);

      if (mounted && _state == ProcessState.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MeetingDetailScreen(meetingId: widget.meetingId)),
        );
      }
    } catch (e) {
      setState(() {
        _state = ProcessState.error;
      });
    }
  }

  Widget _buildStep(int stepIndex, String title, String subtitle) {
    bool isCompleted = currentStep > stepIndex;
    bool isActive = currentStep == stepIndex;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF10B981) : (isActive ? const Color(0xFF4F46E5) : Colors.grey[300]),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : (isActive
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const SizedBox()),
            ),
            if (stepIndex < 3)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? const Color(0xFF10B981) : Colors.grey[300],
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFF4F46E5) : (isCompleted ? Colors.black : Colors.grey),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Đang xử lý AI'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Debug State Bar
          PopupMenuButton<ProcessState>(
            icon: const Icon(Icons.bug_report, color: Colors.grey),
            tooltip: 'Debug State Bar',
            onSelected: (state) {
              setState(() {
                _state = state;
                if (state == ProcessState.loading) {
                  _startProcess();
                }
              });
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: ProcessState.loading, child: Text('Loading State')),
              const PopupMenuItem(value: ProcessState.error, child: Text('Error State')),
            ],
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _state == ProcessState.error
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 80),
                    const SizedBox(height: 16),
                    const Text('Mất kết nối mạng hoặc lỗi máy chủ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Dữ liệu của bạn đã được lưu nháp. Vui lòng thử lại.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        _startProcess();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại (Retry)'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                    )
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStep(0, 'Đã tải tệp lên', 'Tệp âm thanh đã sẵn sàng'),
                    _buildStep(1, 'Đang chuyển giọng nói thành văn bản', 'AI đang nghe và nhận diện văn bản...'),
                    _buildStep(2, 'Đang tóm tắt & bóc tách', 'Phân tích Action Items và ý chính...'),
                    _buildStep(3, 'Hoàn tất', 'Chuyển hướng đến chi tiết...'),
                  ],
                ),
        ),
      ),
    );
  }
}
