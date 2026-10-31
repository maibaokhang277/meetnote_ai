import 'dart:async';
import '../models/models.dart';

class ApiService {
  // --- MOCK DATA ---
  UserModel? currentUser;

  final List<MeetingModel> mockMeetings = [
    MeetingModel(
      id: 'm1',
      userId: 'u1',
      title: 'Họp triển khai đồ án MeetNote AI',
      language: 'vi',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      durationSeconds: 1200,
    ),
    MeetingModel(
      id: 'm2',
      userId: 'u1',
      title: 'Phỏng vấn ứng viên Mobile Developer',
      language: 'vi',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      durationSeconds: 2400,
    ),
    MeetingModel(
      id: 'm3',
      userId: 'u1',
      title: 'Bài giảng Mạng máy tính',
      language: 'vi',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      durationSeconds: 3600,
    ),
  ];

  final List<TaskItemModel> mockTasks = [
    TaskItemModel(
      id: 't1',
      meetingId: 'm1',
      userId: 'u1',
      title: 'Thiết kế Design System trên Figma',
      assigneeName: 'Lan Anh',
      dueAt: DateTime.now().add(const Duration(days: 2)),
      status: 'todo',
      sourceText: 'Lan Anh nhớ thiết kế xong Design System trên Figma trước thứ 6 nhé.',
    ),
    TaskItemModel(
      id: 't2',
      meetingId: 'm1',
      userId: 'u1',
      title: 'Tạo cấu trúc thư mục Flutter',
      assigneeName: 'Tuấn',
      dueAt: null,
      status: 'unconfirmed',
      sourceText: 'Tuấn lo phần tạo cấu trúc thư mục Flutter.',
    ),
    TaskItemModel(
      id: 't3',
      meetingId: 'm1',
      userId: 'u1',
      title: 'Viết API mock dữ liệu',
      assigneeName: null,
      dueAt: DateTime.now().add(const Duration(days: 1)),
      status: 'unconfirmed',
      sourceText: 'Cần có người viết API mock dữ liệu gấp vào ngày mai.',
    ),
  ];

  final Map<String, SummaryModel> mockSummaries = {
    'm1': SummaryModel(
      id: 's1',
      meetingId: 'm1',
      summaryText: '- Bàn luận về kiến trúc app MeetNote AI\n- Phân công nhiệm vụ cho các thành viên\n- Xác định timeline hoàn thành',
      generatedAt: DateTime.now().subtract(const Duration(hours: 23)),
    ),
  };

  final Map<String, TranscriptModel> mockTranscripts = {
    'm1': TranscriptModel(
      id: 'tr1',
      meetingId: 'm1',
      fullText: 'Chào mọi người. Hôm nay chúng ta họp triển khai đồ án MeetNote AI. Lan Anh nhớ thiết kế xong Design System trên Figma trước thứ 6 nhé. Tuấn lo phần tạo cấu trúc thư mục Flutter. Cần có người viết API mock dữ liệu gấp vào ngày mai.',
      segmentsJson: [
        TranscriptSegment(startTime: 0, endTime: 5, text: 'Chào mọi người. Hôm nay chúng ta họp triển khai đồ án MeetNote AI.', confidence: 0.98),
        TranscriptSegment(startTime: 5, endTime: 12, text: 'Lan Anh nhớ thiết kế xong Design System trên Figma trước thứ 6 nhé.', confidence: 0.95),
        TranscriptSegment(startTime: 12, endTime: 18, text: 'Tuấn lo phần tạo cấu trúc thư mục Flutter.', confidence: 0.92),
        TranscriptSegment(startTime: 18, endTime: 25, text: 'Cần có người viết API mock dữ liệu gấp vào ngày mai.', confidence: 0.89),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 23)),
    )
  };

  // --- API STUBS ---
  
  // TODO: Backend API Integration -> POST /auth/login
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email và mật khẩu không được để trống.');
    }
    currentUser = UserModel(
      id: 'u1',
      email: email,
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
    );
    return currentUser!;
  }

  // TODO: Backend API Integration -> POST /meetings
  Future<MeetingModel> createMeeting(String title, String language) async {
    await Future.delayed(const Duration(seconds: 1));
    final newMeeting = MeetingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser?.id ?? 'u1',
      title: title,
      language: language,
      status: 'uploaded',
      createdAt: DateTime.now(),
      durationSeconds: 0,
    );
    mockMeetings.insert(0, newMeeting);
    return newMeeting;
  }

  // TODO: Backend API Integration -> POST /meetings/{id}/audio
  Future<void> uploadAudio(String meetingId, String audioPath) async {
    await Future.delayed(const Duration(seconds: 2));
    final index = mockMeetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      mockMeetings[index] = mockMeetings[index].copyWith(audioPath: audioPath, status: 'transcribing');
    }
  }

  // TODO: Backend API Integration -> GET /meetings/{id}
  Future<Map<String, dynamic>> getMeetingDetail(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final meeting = mockMeetings.firstWhere((m) => m.id == meetingId, orElse: () => throw Exception('Meeting not found'));
    final summary = mockSummaries[meetingId];
    final transcript = mockTranscripts[meetingId];
    final tasks = mockTasks.where((t) => t.meetingId == meetingId).toList();

    return {
      'meeting': meeting,
      'summary': summary,
      'transcript': transcript,
      'tasks': tasks,
    };
  }

  // TODO: Backend API Integration -> POST /meetings/{id}/analyze
  Future<void> analyzeMeeting(String meetingId) async {
    await Future.delayed(const Duration(seconds: 3));
    final index = mockMeetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      mockMeetings[index] = mockMeetings[index].copyWith(status: 'completed');
    }
  }

  // TODO: Backend API Integration -> GET /tasks
  Future<List<TaskItemModel>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockTasks;
  }

  // TODO: Backend API Integration -> PATCH /tasks/{id}
  Future<void> updateTask(String taskId, TaskItemModel updatedTask) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = mockTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      mockTasks[index] = updatedTask;
    }
  }

  // TODO: Backend API Integration -> DELETE /meetings/{id}
  Future<void> deleteMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    mockMeetings.removeWhere((m) => m.id == meetingId);
    mockTasks.removeWhere((t) => t.meetingId == meetingId);
    mockSummaries.remove(meetingId);
    mockTranscripts.remove(meetingId);
  }
}
