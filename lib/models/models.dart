import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MeetingModel {
  final String id;
  final String userId;
  final String title;
  final String language;
  final String? audioPath;
  final String status;
  final DateTime createdAt;
  final int durationSeconds;

  MeetingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.language,
    this.audioPath,
    required this.status,
    required this.createdAt,
    required this.durationSeconds,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      language: json['language'],
      audioPath: json['audioPath'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      durationSeconds: json['durationSeconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'language': language,
      'audioPath': audioPath,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  MeetingModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? language,
    String? audioPath,
    String? status,
    DateTime? createdAt,
    int? durationSeconds,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      language: language ?? this.language,
      audioPath: audioPath ?? this.audioPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

class TranscriptSegment {
  final double startTime;
  final double endTime;
  final String text;
  final double confidence;

  TranscriptSegment({
    required this.startTime,
    required this.endTime,
    required this.text,
    required this.confidence,
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      startTime: json['startTime']?.toDouble() ?? 0.0,
      endTime: json['endTime']?.toDouble() ?? 0.0,
      text: json['text'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
      'confidence': confidence,
    };
  }

  TranscriptSegment copyWith({
    double? startTime,
    double? endTime,
    String? text,
    double? confidence,
  }) {
    return TranscriptSegment(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
    );
  }
}

class TranscriptModel {
  final String id;
  final String meetingId;
  final String fullText;
  final List<TranscriptSegment> segmentsJson;
  final DateTime createdAt;

  TranscriptModel({
    required this.id,
    required this.meetingId,
    required this.fullText,
    required this.segmentsJson,
    required this.createdAt,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    var list = json['segmentsJson'] as List;
    List<TranscriptSegment> segmentsList = list.map((i) => TranscriptSegment.fromJson(i)).toList();
    return TranscriptModel(
      id: json['id'],
      meetingId: json['meetingId'],
      fullText: json['fullText'],
      segmentsJson: segmentsList,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'fullText': fullText,
      'segmentsJson': segmentsJson.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TranscriptModel copyWith({
    String? id,
    String? meetingId,
    String? fullText,
    List<TranscriptSegment>? segmentsJson,
    DateTime? createdAt,
  }) {
    return TranscriptModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      fullText: fullText ?? this.fullText,
      segmentsJson: segmentsJson ?? this.segmentsJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SummaryModel {
  final String id;
  final String meetingId;
  final String summaryText;
  final DateTime generatedAt;
  final DateTime? editedAt;

  SummaryModel({
    required this.id,
    required this.meetingId,
    required this.summaryText,
    required this.generatedAt,
    this.editedAt,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'],
      meetingId: json['meetingId'],
      summaryText: json['summaryText'],
      generatedAt: DateTime.parse(json['generatedAt']),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'summaryText': summaryText,
      'generatedAt': generatedAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  SummaryModel copyWith({
    String? id,
    String? meetingId,
    String? summaryText,
    DateTime? generatedAt,
    DateTime? editedAt,
  }) {
    return SummaryModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      summaryText: summaryText ?? this.summaryText,
      generatedAt: generatedAt ?? this.generatedAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

class TaskItemModel {
  final String id;
  final String meetingId;
  final String userId;
  final String title;
  final String? assigneeName;
  final DateTime? dueAt;
  final String status;
  final String? sourceText;

  TaskItemModel({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.title,
    this.assigneeName,
    this.dueAt,
    required this.status,
    this.sourceText,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) {
    return TaskItemModel(
      id: json['id'],
      meetingId: json['meetingId'],
      userId: json['userId'],
      title: json['title'],
      assigneeName: json['assigneeName'],
      dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt']) : null,
      status: json['status'],
      sourceText: json['sourceText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'userId': userId,
      'title': title,
      'assigneeName': assigneeName,
      'dueAt': dueAt?.toIso8601String(),
      'status': status,
      'sourceText': sourceText,
    };
  }

  TaskItemModel copyWith({
    String? id,
    String? meetingId,
    String? userId,
    String? title,
    String? assigneeName,
    DateTime? dueAt,
    String? status,
    String? sourceText,
  }) {
    return TaskItemModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      assigneeName: assigneeName ?? this.assigneeName,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      sourceText: sourceText ?? this.sourceText,
    );
  }
}

class ReminderPreferenceModel {
  final String id;
  final String taskId;
  final DateTime remindAt;
  final bool enabled;

  ReminderPreferenceModel({
    required this.id,
    required this.taskId,
    required this.remindAt,
    required this.enabled,
  });

  factory ReminderPreferenceModel.fromJson(Map<String, dynamic> json) {
    return ReminderPreferenceModel(
      id: json['id'],
      taskId: json['taskId'],
      remindAt: DateTime.parse(json['remindAt']),
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'remindAt': remindAt.toIso8601String(),
      'enabled': enabled,
    };
  }

  ReminderPreferenceModel copyWith({
    String? id,
    String? taskId,
    DateTime? remindAt,
    bool? enabled,
  }) {
    return ReminderPreferenceModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      remindAt: remindAt ?? this.remindAt,
      enabled: enabled ?? this.enabled,
    );
  }
}
