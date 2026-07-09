import 'package:flutter/foundation.dart';

import 'project_repository.dart';

class RecentProject {
  const RecentProject({
    required this.id,
    required this.projectName,
    required this.status,
    required this.progress,
    required this.currentStep,
    this.visualStyle,
    this.aspectRatio,
    this.isFavorite = false,
    this.isCompleted = false,
    this.outputAudioUrl,
    this.outputVideoUrl,
  });

  final String id;
  final String projectName;
  final String status;
  final double progress;
  final String currentStep;
  final String? visualStyle;
  final String? aspectRatio;
  final bool isFavorite;
  final bool isCompleted;
  final String? outputAudioUrl;
  final String? outputVideoUrl;

  RecentProject copyWith({
    String? id,
    String? projectName,
    String? status,
    double? progress,
    String? currentStep,
    String? visualStyle,
    String? aspectRatio,
    bool? isFavorite,
    bool? isCompleted,
    String? outputAudioUrl,
    String? outputVideoUrl,
  }) {
    return RecentProject(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      visualStyle: visualStyle ?? this.visualStyle,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      outputAudioUrl: outputAudioUrl ?? this.outputAudioUrl,
      outputVideoUrl: outputVideoUrl ?? this.outputVideoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectName': projectName,
        'status': status,
        'progress': progress,
        'currentStep': currentStep,
        'visualStyle': visualStyle,
        'aspectRatio': aspectRatio,
        'isFavorite': isFavorite,
        'isCompleted': isCompleted,
        'outputAudioUrl': outputAudioUrl,
        'outputVideoUrl': outputVideoUrl,
      };

  factory RecentProject.fromJson(Map<String, dynamic> json) {
    return RecentProject(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: json['projectName'] as String? ?? 'Untitled',
      status: json['status'] as String? ?? 'preparing',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      currentStep: json['currentStep'] as String? ?? '준비',
      visualStyle: json['visualStyle'] as String?,
      aspectRatio: json['aspectRatio'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      outputAudioUrl: json['outputAudioUrl'] as String?,
      outputVideoUrl: json['outputVideoUrl'] as String?,
    );
  }
}

class ProjectProvider extends ChangeNotifier {
  ProjectProvider({ProjectRepository? repository})
      : _repository = repository ?? ProjectRepository();

  final ProjectRepository _repository;

  String projectName = '';
  String youtubeUrl = '';
  bool preserveMelody = false;
  bool preserveVocal = false;
  String? preferredJangdan;
  List<String> preferredInstruments = [];
  String? targetMood;
  String? conversionIntensity;
  int? mvLength;
  String? visualStyle;
  String? effectMode;
  String? aspectRatio;
  String currentStatus = 'preparing';
  double progress = 0;
  String? currentProjectId;

  List<RecentProject> recentProjects = [];

  Future<void> loadRecentProjects() async {
    recentProjects = await _repository.loadRecentProjects();
    notifyListeners();
  }

  void resetCurrentProject() {
    projectName = '';
    youtubeUrl = '';
    preserveMelody = false;
    preserveVocal = false;
    preferredJangdan = null;
    preferredInstruments = [];
    targetMood = null;
    conversionIntensity = null;
    mvLength = null;
    visualStyle = null;
    effectMode = null;
    aspectRatio = null;
    currentStatus = 'preparing';
    progress = 0;
    currentProjectId = null;
    notifyListeners();
  }

  void setUploadInfo(String name, String url) {
    projectName = name.trim();
    youtubeUrl = url.trim();
    currentStatus = 'audio_setting';
    progress = 0.1;
    _upsertRecent(status: currentStatus, progress: progress, currentStep: '준비');
    notifyListeners();
  }

  void setAudioSettings({
    bool? melody,
    bool? vocal,
    String? jangdan,
    List<String>? instruments,
    String? mood,
    String? intensity,
  }) {
    preserveMelody = melody ?? preserveMelody;
    preserveVocal = vocal ?? preserveVocal;
    preferredJangdan = jangdan ?? preferredJangdan;
    preferredInstruments = instruments ?? preferredInstruments;
    targetMood = mood ?? targetMood;
    conversionIntensity = intensity ?? conversionIntensity;
    notifyListeners();
  }

  void setMvSettings({
    int? length,
    String? style,
    String? effect,
    String? ratio,
  }) {
    mvLength = length ?? mvLength;
    visualStyle = style ?? visualStyle;
    effectMode = effect ?? effectMode;
    aspectRatio = ratio ?? aspectRatio;
    notifyListeners();
  }

  void updateStatus(String status, {double? newProgress}) {
    currentStatus = status;
    progress = newProgress ?? progress;
    _upsertRecent(
      status: currentStatus,
      progress: progress,
      currentStep: _stepLabel(status),
      completed: status == 'completed',
    );
    notifyListeners();
  }

  void updateProgress(double value) {
    progress = value.clamp(0, 1);
    _upsertRecent(
      status: currentStatus,
      progress: progress,
      currentStep: _stepLabel(currentStatus),
      completed: currentStatus == 'completed',
    );
    notifyListeners();
  }

  void completeProject() {
    currentStatus = 'completed';
    progress = 1;
    _upsertRecent(
      status: 'completed',
      progress: 1,
      currentStep: '완료',
      completed: true,
    );
    notifyListeners();
  }

  void selectRecentProject(RecentProject project) {
    currentProjectId = project.id;
    projectName = project.projectName;
    currentStatus = project.status;
    progress = project.progress;
    visualStyle = project.visualStyle;
    aspectRatio = project.aspectRatio;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    recentProjects = recentProjects
        .map((project) => project.id == id
            ? project.copyWith(isFavorite: !project.isFavorite)
            : project)
        .toList();
    _persist();
    notifyListeners();
  }

  void deleteProject(String id) {
    recentProjects = recentProjects.where((project) => project.id != id).toList();
    if (currentProjectId == id) {
      projectName = '';
      youtubeUrl = '';
      preserveMelody = false;
      preserveVocal = false;
      preferredJangdan = null;
      preferredInstruments = [];
      targetMood = null;
      conversionIntensity = null;
      mvLength = null;
      visualStyle = null;
      effectMode = null;
      aspectRatio = null;
      currentStatus = 'preparing';
      progress = 0;
      currentProjectId = null;
    }
    _persist();
    notifyListeners();
  }

  void _upsertRecent({
    required String status,
    required double progress,
    required String currentStep,
    bool completed = false,
  }) {
    if (projectName.isEmpty) {
      return;
    }
    currentProjectId ??= DateTime.now().millisecondsSinceEpoch.toString();
    final project = RecentProject(
      id: currentProjectId!,
      projectName: projectName,
      status: status,
      progress: progress,
      currentStep: currentStep,
      visualStyle: visualStyle,
      aspectRatio: aspectRatio,
      isCompleted: completed,
    );
    final index = recentProjects.indexWhere((item) => item.id == project.id);
    if (index >= 0) {
      final previous = recentProjects[index];
      recentProjects[index] = project.copyWith(
        isFavorite: previous.isFavorite,
        outputAudioUrl: previous.outputAudioUrl,
        outputVideoUrl: previous.outputVideoUrl,
      );
    } else {
      recentProjects = [project, ...recentProjects];
    }
    _persist();
  }

  void _persist() {
    _repository.saveRecentProjects(recentProjects);
  }

  String _stepLabel(String status) {
    switch (status) {
      case 'audio_processing':
        return '음원 생성';
      case 'audio_completed':
        return '음원 완료';
      case 'mv_setting':
        return 'MV 설정';
      case 'mv_processing':
        return 'MV 생성';
      case 'completed':
        return '완료';
      case 'audio_setting':
      case 'preparing':
      default:
        return '준비';
    }
  }
}
