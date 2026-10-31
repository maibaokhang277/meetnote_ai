import 'dart:async';
import 'package:flutter/material.dart';
import 'processing_screen.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class RecordImportScreen extends StatefulWidget {
  final bool isImport;
  const RecordImportScreen({super.key, this.isImport = false});

  @override
  State<RecordImportScreen> createState() => _RecordImportScreenState();
}

class _RecordImportScreenState extends State<RecordImportScreen> {
  final ApiService _apiService = ApiService();
  bool isRecording = false;
  bool isPaused = false;
  bool isFinished = false;
  int recordDuration = 0;
  Timer? _timer;
  
  String meetingTitle = 'Bản ghi âm mới';
  String selectedLanguage = 'vi';
  
  @override
  void initState() {
    super.initState();
    if (widget.isImport) {
      // Mock importing flow
      _showImportDialog();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordDuration++;
      });
    });
  }

  void _toggleRecord() {
    if (isRecording && !isPaused) {
      // Pause
      _timer?.cancel();
      setState(() {
        isPaused = true;
      });
    } else if (isRecording && isPaused) {
      // Resume
      _startTimer();
      setState(() {
        isPaused = false;
      });
    } else {
      // Start
      _startTimer();
      setState(() {
        isRecording = true;
        isFinished = false;
        recordDuration = 0;
      });
    }
  }

  void _stopRecord() {
    _timer?.cancel();
    setState(() {
      isRecording = false;
      isPaused = false;
      isFinished = true;
    });
  }

  void _showImportDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nhập tệp âm thanh'),
          content: const Text('Chọn tệp .mp3, .wav, .m4a (tối đa 50MB)'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  isFinished = true;
                  meetingTitle = 'Tệp âm thanh đã nhập';
                  recordDuration = 120; // 2 phút giả lập
                });
              },
              child: const Text('Chọn tệp'),
            )
          ],
        ),
      );
    });
  }

  Future<void> _submitToAI() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      MeetingModel newMeeting = await _apiService.createMeeting(meetingTitle, selectedLanguage);
      await _apiService.uploadAudio(newMeeting.id, 'path/to/mock_audio.mp3');
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProcessingScreen(meetingId: newMeeting.id)),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  String _formatDuration(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.isImport ? 'Nhập tệp âm thanh' : 'Ghi âm mới'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bảo mật dữ liệu: Âm thanh sẽ được tải lên dịch vụ AI để bóc tách an toàn.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tiêu đề cuộc họp',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => meetingTitle = val.isEmpty ? 'Bản ghi âm mới' : val,
              controller: TextEditingController(text: meetingTitle),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Ngôn ngữ nói',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedLanguage = val;
                  });
                }
              },
            ),
            const Spacer(),
            if (isRecording || isFinished) ...[
              Text(
                _formatDuration(recordDuration),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(height: 24),
              // Waveform giả lập
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(15, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: isRecording && !isPaused ? (index % 3 == 0 ? 40 : 20) : 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],
            if (!isFinished && !widget.isImport) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRecording)
                    IconButton(
                      iconSize: 64,
                      color: const Color(0xFFF59E0B),
                      icon: Icon(isPaused ? Icons.play_circle_fill_rounded : Icons.pause_circle_filled_rounded),
                      onPressed: _toggleRecord,
                    ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 80,
                    color: isRecording ? const Color(0xFFE11D48) : const Color(0xFF4F46E5),
                    icon: Icon(isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded),
                    onPressed: isRecording ? _stopRecord : _toggleRecord,
                  ),
                ],
              ),
            ],
            if (isFinished) ...[
              ElevatedButton.icon(
                onPressed: () {
                  // Giả lập phát lại
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang phát lại...')));
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Nghe lại bản ghi'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submitToAI,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: const Text('Tải lên & Phân tích AI', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    isFinished = false;
                    recordDuration = 0;
                  });
                },
                child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFFE11D48))),
              )
            ]
          ],
        ),
      ),
    );
  }
}
