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
    this.inputAudioFileName,
    this.inputSourceType = 'file',
    this.youtubeUrl,
    this.outputAudioFileName,
    this.outputVideoFileName,
    this.vocalInstrument,
    this.accompanimentInstrument,
    this.aiJobId,
    this.aiJobStatus,
    this.midiDownloadUrl,
    this.resultUploadUrl,
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
  final String? inputAudioFileName;
  final String inputSourceType;
  final String? youtubeUrl;
  final String? outputAudioFileName;
  final String? outputVideoFileName;
  final String? vocalInstrument;
  final String? accompanimentInstrument;
  final String? aiJobId;
  final String? aiJobStatus;
  final String? midiDownloadUrl;
  final String? resultUploadUrl;

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
    String? inputAudioFileName,
    String? inputSourceType,
    String? youtubeUrl,
    String? outputAudioFileName,
    String? outputVideoFileName,
    String? vocalInstrument,
    String? accompanimentInstrument,
    String? aiJobId,
    String? aiJobStatus,
    String? midiDownloadUrl,
    String? resultUploadUrl,
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
      inputAudioFileName: inputAudioFileName ?? this.inputAudioFileName,
      inputSourceType: inputSourceType ?? this.inputSourceType,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      outputAudioFileName: outputAudioFileName ?? this.outputAudioFileName,
      outputVideoFileName: outputVideoFileName ?? this.outputVideoFileName,
      vocalInstrument: vocalInstrument ?? this.vocalInstrument,
      accompanimentInstrument:
          accompanimentInstrument ?? this.accompanimentInstrument,
      aiJobId: aiJobId ?? this.aiJobId,
      aiJobStatus: aiJobStatus ?? this.aiJobStatus,
      midiDownloadUrl: midiDownloadUrl ?? this.midiDownloadUrl,
      resultUploadUrl: resultUploadUrl ?? this.resultUploadUrl,
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
    'inputAudioFileName': inputAudioFileName,
    'inputSourceType': inputSourceType,
    'youtubeUrl': youtubeUrl,
    'outputAudioFileName': outputAudioFileName,
    'outputVideoFileName': outputVideoFileName,
    'vocalInstrument': vocalInstrument,
    'accompanimentInstrument': accompanimentInstrument,
    'aiJobId': aiJobId,
    'aiJobStatus': aiJobStatus,
    'midiDownloadUrl': midiDownloadUrl,
    'resultUploadUrl': resultUploadUrl,
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
      inputAudioFileName: json['inputAudioFileName'] as String?,
      inputSourceType: json['inputSourceType'] as String? ?? 'file',
      youtubeUrl: json['youtubeUrl'] as String?,
      outputAudioFileName: json['outputAudioFileName'] as String?,
      outputVideoFileName: json['outputVideoFileName'] as String?,
      vocalInstrument: json['vocalInstrument'] as String?,
      accompanimentInstrument: json['accompanimentInstrument'] as String?,
      aiJobId: json['aiJobId'] as String?,
      aiJobStatus: json['aiJobStatus'] as String?,
      midiDownloadUrl: json['midiDownloadUrl'] as String?,
      resultUploadUrl: json['resultUploadUrl'] as String?,
    );
  }
}

class ProjectProvider extends ChangeNotifier {
  ProjectProvider({ProjectRepository? repository})
    : _repository = repository ?? ProjectRepository();

  final ProjectRepository _repository;

  String projectName = '';
  String youtubeUrl = '';
  String inputMode = 'url';
  String? uploadedVideoFileName;
  String inputSourceType = 'url';
  String? inputAudioFileName;
  String? inputAudioFileExtension;
  String? inputAudioFilePath;
  Uint8List? inputAudioFileBytes;
  String? outputAudioFileName;
  String? outputVideoFileName;
  bool copyrightConfirmed = false;
  bool preserveMelody = false;
  bool preserveVocal = false;
  String? preferredJangdan;
  List<String> preferredInstruments = [];
  String? vocalInstrument;
  String? accompanimentInstrument;
  String? aiJobId;
  String? aiJobStatus;
  String? midiDownloadUrl;
  String? resultUploadUrl;
  String? outputAudioUrl;
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

  void setProjectName(String value) {
    projectName = value;
    notifyListeners();
  }

  void setCopyrightConfirmed(bool value) {
    copyrightConfirmed = value;
    notifyListeners();
  }

  void setInputSourceType(String value) {
    if (value != 'url' && value != 'file') return;
    inputSourceType = value;
    inputMode = value;
    notifyListeners();
  }

  void setYoutubeUrl(String value) {
    youtubeUrl = value;
    notifyListeners();
  }

  void setInputAudioFile({
    required String fileName,
    String? extension,
    String? path,
    Uint8List? bytes,
  }) {
    inputAudioFileName = fileName;
    inputAudioFileExtension = extension;
    inputAudioFilePath = path;
    inputAudioFileBytes = bytes;
    // 파일을 세팅하는 시점에 입력 방식도 함께 'file'로 확정한다.
    // (이 호출이 누락되면 inputSourceType이 기본값인 'url'에 머물러
    //  파일을 업로드했는데도 /projects/upload-url 로 요청이 나가는
    //  버그가 발생한다.)
    inputSourceType = 'file';
    inputMode = 'file';
    notifyListeners();
  }

  void resetCurrentProject() {
    projectName = '';
    youtubeUrl = '';
    inputMode = 'url';
    uploadedVideoFileName = null;
    inputSourceType = 'url';
    inputAudioFileName = null;
    inputAudioFileExtension = null;
    inputAudioFilePath = null;
    inputAudioFileBytes = null;
    outputAudioFileName = null;
    outputVideoFileName = null;
    copyrightConfirmed = false;
    preserveMelody = false;
    preserveVocal = false;
    preferredJangdan = null;
    preferredInstruments = [];
    vocalInstrument = null;
    accompanimentInstrument = null;
    aiJobId = null;
    aiJobStatus = null;
    midiDownloadUrl = null;
    resultUploadUrl = null;
    outputAudioUrl = null;
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

  void setUploadInfo(
    String name,
    String url,
    bool confirmed, {
    String mode = 'url',
    String? fileName,
    String? audioFileName,
    String? audioFileExtension,
    String? audioFilePath,
    Uint8List? audioFileBytes,
  }) {
    projectName = name.trim();
    youtubeUrl = url.trim();
    final normalizedMode = mode == 'audio_file' ? 'file' : mode;
    inputMode = normalizedMode;
    uploadedVideoFileName = fileName;
    inputSourceType = normalizedMode;
    inputAudioFileName = audioFileName;
    inputAudioFileExtension = audioFileExtension;
    inputAudioFilePath = audioFilePath;
    inputAudioFileBytes = audioFileBytes;
    outputAudioFileName = buildOutputAudioFileName(projectName);
    outputVideoFileName = null;
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
    String? vocalInstrumentValue,
    String? accompanimentInstrumentValue,
  }) {
    preserveMelody = melody ?? preserveMelody;
    preserveVocal = vocal ?? preserveVocal;
    preferredJangdan = jangdan ?? preferredJangdan;
    preferredInstruments = instruments ?? preferredInstruments;
    targetMood = mood ?? targetMood;
    conversionIntensity = intensity ?? conversionIntensity;
    vocalInstrument = vocalInstrumentValue ?? vocalInstrument;
    accompanimentInstrument =
        accompanimentInstrumentValue ?? accompanimentInstrument;
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
      outputVideoFileName ??= buildOutputVideoFileName(projectName);
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
    outputVideoFileName = buildOutputVideoFileName(projectName);
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
    outputAudioUrl = project.outputAudioUrl;
    outputVideoDurationSeconds = project.outputVideoDurationSeconds;
    inputAudioFileName = project.inputAudioFileName;
    inputSourceType = project.inputSourceType;
    inputMode = project.inputSourceType;
    youtubeUrl = project.youtubeUrl ?? '';
    inputAudioFileExtension = null;
    inputAudioFilePath = null;
    inputAudioFileBytes = null;
    outputAudioFileName =
        project.outputAudioFileName ??
        buildOutputAudioFileName(project.projectName);
    outputVideoFileName =
        project.outputVideoFileName ??
        buildOutputVideoFileName(project.projectName);
    vocalInstrument = project.vocalInstrument;
    accompanimentInstrument = project.accompanimentInstrument;
    aiJobId = project.aiJobId;
    aiJobStatus = project.aiJobStatus;
    midiDownloadUrl = project.midiDownloadUrl;
    resultUploadUrl = project.resultUploadUrl;
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
      inputMode = 'url';
      uploadedVideoFileName = null;
      inputSourceType = 'url';
      inputAudioFileName = null;
      inputAudioFileExtension = null;
      inputAudioFilePath = null;
      inputAudioFileBytes = null;
      outputAudioFileName = null;
      outputVideoFileName = null;
      copyrightConfirmed = false;
      preserveMelody = false;
      preserveVocal = false;
      preferredJangdan = null;
      preferredInstruments = [];
      vocalInstrument = null;
      accompanimentInstrument = null;
      aiJobId = null;
      aiJobStatus = null;
      midiDownloadUrl = null;
      resultUploadUrl = null;
      outputAudioUrl = null;
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
      outputAudioUrl: outputAudioUrl,
      outputAudioDurationSeconds: outputAudioDurationSeconds,
      outputVideoDurationSeconds: outputVideoDurationSeconds,
      inputAudioFileName: inputAudioFileName,
      inputSourceType: inputSourceType,
      youtubeUrl: youtubeUrl,
      outputAudioFileName:
          outputAudioFileName ?? buildOutputAudioFileName(projectName),
      outputVideoFileName:
          outputVideoFileName ?? buildOutputVideoFileName(projectName),
      vocalInstrument: vocalInstrument,
      accompanimentInstrument: accompanimentInstrument,
      aiJobId: aiJobId,
      aiJobStatus: aiJobStatus,
      midiDownloadUrl: midiDownloadUrl,
      resultUploadUrl: resultUploadUrl,
    );
    if (index >= 0) {
      recentProjects[index] = project.copyWith(
        isFavorite: previous!.isFavorite,
        outputAudioUrl: outputAudioUrl ?? previous.outputAudioUrl,
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

  static String buildOutputAudioFileName(String projectName) {
    final baseName = sanitizeFileBaseName(projectName);
    return '${baseName ?? 'gugakify_result'}.wav';
  }

  static String buildOutputVideoFileName(String projectName) {
    final baseName = sanitizeFileBaseName(projectName);
    return '${baseName ?? 'gugakify_mv_result'}.mp4';
  }

  static String? sanitizeFileBaseName(String name) {
    final withoutOutputExtension = name.trim().replaceFirst(
      RegExp(r'\.(?:wav|mp4)$', caseSensitive: false),
      '',
    );
    final sanitized = withoutOutputExtension
        .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.isEmpty) return null;
    return sanitized.length > 80
        ? sanitized.substring(0, 80).trimRight()
        : sanitized;
  }
}