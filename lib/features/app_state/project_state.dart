import 'package:flutter/foundation.dart';

import 'project_repository.dart';

class RecentProject {
  const RecentProject({
    required this.id,
    required this.projectName,
    required this.createdAt,
    required this.status,
    required this.progress,
    required this.currentStep,
    this.resultType,
    this.hasAudio = false,
    this.hasMv = false,
    this.visualStyle,
    this.aspectRatio,
    this.isFavorite = false,
    this.isCompleted = false,
    this.outputAudioUrl,
    this.outputVideoUrl,
    this.thumbnailUrl,
    this.outputAudioDurationSeconds,
    this.outputVideoDurationSeconds,
  });

  final String id;
  final String projectName;
  final DateTime createdAt;
  final String status;
  final double progress;
  final String currentStep;
  final String? resultType;
  final bool hasAudio;
  final bool hasMv;
  final String? visualStyle;
  final String? aspectRatio;
  final bool isFavorite;
  final bool isCompleted;
  final String? outputAudioUrl;
  final String? outputVideoUrl;
  final String? thumbnailUrl;
  final int? outputAudioDurationSeconds;
  final int? outputVideoDurationSeconds;

  RecentProject copyWith({
    String? id,
    String? projectName,
    DateTime? createdAt,
    String? status,
    double? progress,
    String? currentStep,
    String? resultType,
    bool? hasAudio,
    bool? hasMv,
    String? visualStyle,
    String? aspectRatio,
    bool? isFavorite,
    bool? isCompleted,
    String? outputAudioUrl,
    String? outputVideoUrl,
    String? thumbnailUrl,
    int? outputAudioDurationSeconds,
    int? outputVideoDurationSeconds,
  }) {
    return RecentProject(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      resultType: resultType ?? this.resultType,
      hasAudio: hasAudio ?? this.hasAudio,
      hasMv: hasMv ?? this.hasMv,
      visualStyle: visualStyle ?? this.visualStyle,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      outputAudioUrl: outputAudioUrl ?? this.outputAudioUrl,
      outputVideoUrl: outputVideoUrl ?? this.outputVideoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      outputAudioDurationSeconds:
          outputAudioDurationSeconds ?? this.outputAudioDurationSeconds,
      outputVideoDurationSeconds:
          outputVideoDurationSeconds ?? this.outputVideoDurationSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectName': projectName,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
    'progress': progress,
    'currentStep': currentStep,
    'resultType': resultType,
    'hasAudio': hasAudio,
    'hasMv': hasMv,
    'visualStyle': visualStyle,
    'aspectRatio': aspectRatio,
    'isFavorite': isFavorite,
    'isCompleted': isCompleted,
    'outputAudioUrl': outputAudioUrl,
    'outputVideoUrl': outputVideoUrl,
    'thumbnailUrl': thumbnailUrl,
    'outputAudioDurationSeconds': outputAudioDurationSeconds,
    'outputVideoDurationSeconds': outputVideoDurationSeconds,
  };

  factory RecentProject.fromJson(Map<String, dynamic> json) {
    return RecentProject(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: json['projectName'] as String? ?? 'Untitled',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'preparing',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      currentStep: json['currentStep'] as String? ?? '준비',
      resultType: json['resultType'] as String?,
      hasAudio: json['hasAudio'] as bool? ?? false,
      hasMv: json['hasMv'] as bool? ?? false,
      visualStyle: json['visualStyle'] as String?,
      aspectRatio: json['aspectRatio'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      outputAudioUrl: json['outputAudioUrl'] as String?,
      outputVideoUrl: json['outputVideoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      outputAudioDurationSeconds: (json['outputAudioDurationSeconds'] as num?)
          ?.toInt(),
      outputVideoDurationSeconds: (json['outputVideoDurationSeconds'] as num?)
          ?.toInt(),
    );
  }
}

class ProjectProvider extends ChangeNotifier {
  ProjectProvider({ProjectRepository? repository})
    : _repository = repository ?? ProjectRepository();

  final ProjectRepository _repository;

  String projectName = '';
  String youtubeUrl = '';
  bool copyrightConfirmed = false;
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
  bool pendingAudioResult = false;
  int? outputAudioDurationSeconds;
  int? outputVideoDurationSeconds;

  List<RecentProject> recentProjects = [];

  Future<void> loadRecentProjects() async {
    recentProjects = await _repository.loadRecentProjects();
    notifyListeners();
  }

  void resetCurrentProject() {
    projectName = '';
    youtubeUrl = '';
    copyrightConfirmed = false;
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
    pendingAudioResult = false;
    outputAudioDurationSeconds = null;
    outputVideoDurationSeconds = null;
    notifyListeners();
  }

  void setUploadInfo(String name, String url, bool confirmed) {
    projectName = name.trim();
    youtubeUrl = url.trim();
    copyrightConfirmed = confirmed;
    currentStatus = 'audio_setting';
    progress = 0.1;
    currentProjectId ??= DateTime.now().millisecondsSinceEpoch.toString();
    pendingAudioResult = false;
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
    if (status == 'audio_completed') {
      pendingAudioResult = true;
      outputAudioDurationSeconds ??= 192;
      outputVideoDurationSeconds = null;
    } else if (status == 'mv_processing') {
      pendingAudioResult = false;
      outputAudioDurationSeconds ??= 192;
      _upsertRecent(
        status: currentStatus,
        progress: progress,
        currentStep: _stepLabel(status),
        resultType: null,
        hasAudio: true,
      );
    } else if (status == 'completed') {
      pendingAudioResult = false;
      _upsertRecent(
        status: currentStatus,
        progress: progress,
        currentStep: _stepLabel(status),
        completed: status == 'completed',
        resultType: 'audioWithMv',
        hasAudio: true,
        hasMv: true,
      );
    }
    notifyListeners();
  }

  void updateProgress(double value) {
    progress = value.clamp(0, 1);
    notifyListeners();
  }

  void completeProject({bool saveToArchive = true}) {
    currentStatus = 'completed';
    progress = 1;
    pendingAudioResult = false;
    outputAudioDurationSeconds ??= 192;
    outputVideoDurationSeconds = outputAudioDurationSeconds;
    if (saveToArchive) {
      _upsertRecent(
        status: 'completed',
        progress: 1,
        currentStep: 'MV 생성 완료',
        completed: true,
        resultType: 'audioWithMv',
        hasAudio: true,
        hasMv: true,
      );
    }
    notifyListeners();
  }

  void confirmAudioOnlyResult({bool saveToArchive = true}) {
    currentStatus = 'audio_completed';
    progress = 1;
    pendingAudioResult = false;
    outputAudioDurationSeconds ??= 192;
    outputVideoDurationSeconds = null;
    if (saveToArchive) {
      _upsertRecent(
        status: 'audio_completed',
        progress: 1,
        currentStep: '국악 음원 완료',
        completed: true,
        resultType: 'audioOnly',
        hasAudio: true,
      );
    }
    notifyListeners();
  }

  void confirmAudioBeforeMv({bool saveToArchive = true}) {
    currentStatus = 'mv_setting';
    progress = 0.55;
    pendingAudioResult = false;
    outputAudioDurationSeconds ??= 192;
    if (saveToArchive) {
      _upsertRecent(
        status: 'mv_setting',
        progress: progress,
        currentStep: 'MV 설정',
        resultType: 'audioOnly',
        hasAudio: true,
      );
    }
    notifyListeners();
  }

  void discardPendingAudioResult() {
    pendingAudioResult = false;
    currentStatus = 'audio_setting';
    progress = 0.1;
    notifyListeners();
  }

  void selectRecentProject(RecentProject project) {
    currentProjectId = project.id;
    projectName = project.projectName;
    currentStatus = project.status;
    progress = project.progress;
    visualStyle = project.visualStyle;
    aspectRatio = project.aspectRatio;
    outputAudioDurationSeconds = project.outputAudioDurationSeconds;
    outputVideoDurationSeconds = project.outputVideoDurationSeconds;
    pendingAudioResult = false;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    recentProjects = recentProjects
        .map(
          (project) => project.id == id
              ? project.copyWith(isFavorite: !project.isFavorite)
              : project,
        )
        .toList();
    _persist();
    notifyListeners();
  }

  void deleteProject(String id) {
    recentProjects = recentProjects
        .where((project) => project.id != id)
        .toList();
    if (currentProjectId == id) {
      projectName = '';
      youtubeUrl = '';
      copyrightConfirmed = false;
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
      pendingAudioResult = false;
      outputAudioDurationSeconds = null;
      outputVideoDurationSeconds = null;
    }
    _persist();
    notifyListeners();
  }

  void _upsertRecent({
    required String status,
    required double progress,
    required String currentStep,
    bool completed = false,
    String? resultType,
    bool hasAudio = false,
    bool hasMv = false,
  }) {
    if (projectName.isEmpty) {
      return;
    }
    currentProjectId ??= DateTime.now().millisecondsSinceEpoch.toString();
    final index = recentProjects.indexWhere(
      (item) => item.id == currentProjectId,
    );
    final previous = index >= 0 ? recentProjects[index] : null;
    final project = RecentProject(
      id: currentProjectId!,
      projectName: projectName,
      createdAt: previous?.createdAt ?? DateTime.now(),
      status: status,
      progress: progress,
      currentStep: currentStep,
      resultType: resultType,
      hasAudio: hasAudio,
      hasMv: hasMv,
      visualStyle: visualStyle,
      aspectRatio: aspectRatio,
      isCompleted: completed,
      outputAudioDurationSeconds: outputAudioDurationSeconds,
      outputVideoDurationSeconds: outputVideoDurationSeconds,
    );
    if (index >= 0) {
      recentProjects[index] = project.copyWith(
        isFavorite: previous!.isFavorite,
        outputAudioUrl: previous.outputAudioUrl,
        outputVideoUrl: previous.outputVideoUrl,
        thumbnailUrl: previous.thumbnailUrl,
        outputAudioDurationSeconds: previous.outputAudioDurationSeconds,
        outputVideoDurationSeconds: previous.outputVideoDurationSeconds,
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
