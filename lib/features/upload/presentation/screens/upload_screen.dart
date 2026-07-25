import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  bool _copyrightChecked = false;
  String? _selectedFileName;
  String? _selectedFileExtension;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>();
    _nameController = TextEditingController(text: project.projectName);
    _urlController = TextEditingController(text: project.youtubeUrl);
    _copyrightChecked = project.copyrightConfirmed;
    _selectedFileName = project.inputAudioFileName;
    _selectedFileExtension = project.inputAudioFileExtension;
    _selectedFilePath = project.inputAudioFilePath;
    _selectedFileBytes = project.inputAudioFileBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final hasInput = project.inputSourceType == 'url'
        ? project.youtubeUrl.trim().isNotEmpty
        : project.inputAudioFileName?.trim().isNotEmpty == true;
    final canNext =
        project.projectName.trim().isNotEmpty &&
        hasInput &&
        project.copyrightConfirmed;

    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _UploadAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UploadHeader(onBack: () => context.go('/home')),
              const SizedBox(height: 18),
              _UploadCard(
                nameController: _nameController,
                urlController: _urlController,
                inputSourceType: project.inputSourceType,
                copyrightChecked: _copyrightChecked,
                selectedFileName: _selectedFileName,
                onSelectFile: _pickAudioFile,
                onSourceChanged: project.setInputSourceType,
                onUrlChanged: project.setYoutubeUrl,
                onNameChanged: (value) {
                  project.setProjectName(value);
                  setState(() {});
                },
                onCopyrightChanged: (value) {
                  project.setCopyrightConfirmed(value);
                  setState(() => _copyrightChecked = value);
                },
                onShowCopyright: () => _showCopyrightSheet(context),
              ),
              const SizedBox(height: 22),
              PrimaryLavenderButton(
                label: '다음',
                onPressed: canNext
                    ? () {
                        context.read<ProjectProvider>().setUploadInfo(
                          _nameController.text,
                          _urlController.text,
                          _copyrightChecked,
                          mode: project.inputSourceType,
                          audioFileName: _selectedFileName,
                          audioFileExtension: _selectedFileExtension,
                          audioFilePath: _selectedFilePath,
                          audioFileBytes: _selectedFileBytes,
                        );
                        context.go('/audio/settings');
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'wav', 'm4a'],
        allowMultiple: false,
        withData: kIsWeb,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('파일 선택 창을 열지 못했습니다: $error')));
      return;
    }
    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    context.read<ProjectProvider>().setInputAudioFile(
      fileName: file.name,
      extension: file.extension?.toLowerCase(),
      path: file.path,
      bytes: file.bytes,
    );
    setState(() {
      _selectedFileName = file.name;
      _selectedFileExtension = file.extension?.toLowerCase();
      _selectedFilePath = file.path;
      _selectedFileBytes = file.bytes;
    });

    // TODO: 실제 서비스에서는 선택한 audio 파일을 백엔드로 업로드한다.
    // TODO: 백엔드가 AI 서버 POST /jobs를 호출한다.
    // TODO: AI_API_KEY는 Flutter 코드에 포함하지 않는다.
  }

  void _showCopyrightSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 34,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '저작권 및 이용 권한 확인',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '아래 내용을 확인한 뒤 변환을 진행해주세요.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const _CopyrightBullet('본인이 보유하거나 이용 권한이 있는 음원만 변환할 수 있습니다.'),
              const _CopyrightBullet(
                '타인의 저작물을 무단으로 업로드하거나 변환한 결과물을 배포해서는 안 됩니다.',
              ),
              const _CopyrightBullet('업로드하는 원곡 음원의 이용 조건과 저작권을 반드시 확인해야 합니다.'),
              const _CopyrightBullet(
                '생성된 결과물은 대회 시연 및 개인 학습 목적의 mock 결과로 사용됩니다.',
              ),
              const _CopyrightBullet(
                '실제 서비스 배포 시에는 저작권 정책 및 이용 약관에 따라 사용이 제한될 수 있습니다.',
              ),
              const SizedBox(height: 20),
              PrimaryLavenderButton(
                label: '확인했어요',
                onPressed: () {
                  context.read<ProjectProvider>().setCopyrightConfirmed(true);
                  setState(() => _copyrightChecked = true);
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadAtmosphere extends StatelessWidget {
  const _UploadAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.07,
              child: Image.asset(
                'assets/images/intro_hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.91),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: -34,
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: -52,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightPurple.withValues(alpha: 0.34),
                  width: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadHeader extends StatelessWidget {
  const _UploadHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleIconButton(
                tooltip: '홈으로 돌아가기',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              const SizedBox(width: 12),
              const Text(
                '새 프로젝트 만들기',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/icons/gugakify_wordmark.png',
            width: 84,
            errorBuilder: (_, error, stackTrace) => const Text(
              'Gugakify',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          color: AppColors.primaryPurple,
          icon: Icon(icon, size: 18),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.nameController,
    required this.urlController,
    required this.inputSourceType,
    required this.copyrightChecked,
    required this.selectedFileName,
    required this.onSelectFile,
    required this.onSourceChanged,
    required this.onUrlChanged,
    required this.onNameChanged,
    required this.onCopyrightChanged,
    required this.onShowCopyright,
  });

  final TextEditingController nameController;
  final TextEditingController urlController;
  final String inputSourceType;
  final bool copyrightChecked;
  final String? selectedFileName;
  final VoidCallback onSelectFile;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onUrlChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<bool> onCopyrightChanged;
  final VoidCallback onShowCopyright;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.065),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _UploadInkWash()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepPill(),
              const SizedBox(height: 16),
              const Text(
                '변환할 음악 정보를 입력해주세요',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.26,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'URL을 입력하거나 음원 파일을 업로드해 변환을 시작할 수 있어요.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _InputSourceToggle(
                value: inputSourceType,
                onChanged: onSourceChanged,
              ),
              const SizedBox(height: 20),
              _ProjectInputField(
                label: '프로젝트 이름',
                hintText: '예: APT 국악 버전',
                controller: nameController,
                onChanged: onNameChanged,
                icon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 18),
              if (inputSourceType == 'url')
                _UrlInputBox(controller: urlController, onChanged: onUrlChanged)
              else
                _FileUploadBox(
                  fileName: selectedFileName,
                  onSelect: onSelectFile,
                ),
              const SizedBox(height: 20),
              _CopyrightConfirmBox(
                checked: copyrightChecked,
                onChanged: onCopyrightChanged,
                onShowDetails: onShowCopyright,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightPurple),
      ),
      child: const Text(
        'STEP 1',
        style: TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProjectInputField extends StatelessWidget {
  const _ProjectInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    required this.icon,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 20),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.white.withValues(alpha: 0.74),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: AppColors.borderSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: AppColors.borderSoft.withValues(alpha: 0.9),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputSourceToggle extends StatelessWidget {
  const _InputSourceToggle({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          _InputSourceButton(
            label: 'URL 입력',
            icon: Icons.link_rounded,
            selected: value == 'url',
            onTap: () => onChanged('url'),
          ),
          _InputSourceButton(
            label: '파일 업로드',
            icon: Icons.upload_file_rounded,
            selected: value == 'file',
            onTap: () => onChanged('file'),
          ),
        ],
      ),
    );
  }
}

class _InputSourceButton extends StatelessWidget {
  const _InputSourceButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.softPurple
                : AppColors.backgroundAlt.withValues(alpha: .7),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? AppColors.lightPurple : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.deepInkPurple),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.deepInkPurple,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrlInputBox extends StatelessWidget {
  const _UrlInputBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: .32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'URL로 원곡 불러오기',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '변환할 음원의 URL을 입력해주세요.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _ProjectInputField(
            label: '음원 또는 영상 URL',
            hintText: 'https://youtube.com/…',
            controller: controller,
            onChanged: onChanged,
            icon: Icons.link_rounded,
          ),
          const SizedBox(height: 10),
          const Text(
            '일부 URL은 접근 제한으로 처리되지 않을 수 있어요. 이 경우 파일 업로드를 이용해주세요.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileUploadBox extends StatelessWidget {
  const _FileUploadBox({required this.fileName, required this.onSelect});

  final String? fileName;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName?.trim().isNotEmpty == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasFile
            ? AppColors.paleLavender.withValues(alpha: .62)
            : AppColors.paleLavender.withValues(alpha: .32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1D9E8)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.upload_file_rounded,
            color: AppColors.primaryPurple,
            size: 36,
          ),
          const SizedBox(height: 9),
          const Text(
            '원곡 음원 업로드',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '국악기 음색으로 변환할 원곡 음원을 업로드해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            hasFile ? '선택한 파일' : '아직 선택된 파일이 없어요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.deepInkPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          if (!hasFile)
            const Text(
              'MP3, WAV, M4A 파일을 선택해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          if (hasFile) ...[
            const SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryPurple,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    fileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('파일 선택하기'),
          ),
        ],
      ),
    );
  }
}

class _CopyrightConfirmBox extends StatelessWidget {
  const _CopyrightConfirmBox({
    required this.checked,
    required this.onChanged,
    required this.onShowDetails,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightPurple.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderSoft.withValues(alpha: 0.8),
                  ),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const SizedBox(
                width: 224,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '저작권 및 이용 권한 확인',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '본인이 보유하거나 이용 권한이 있는 음원만 변환할 수 있어요.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => onChanged(!checked),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 7, 10, 7),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: checked,
                      checkColor: AppColors.white,
                      side: BorderSide(
                        width: 1.2,
                        color: AppColors.lightPurple.withValues(alpha: 0.95),
                      ),
                      activeColor: AppColors.primaryPurple,
                      onChanged: (value) => onChanged(value ?? false),
                    ),
                  ),
                  const SizedBox(width: 9),
                  const SizedBox(
                    width: 220,
                    child: Text(
                      '저작권 및 이용 권한을 확인했습니다.',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onShowDetails,
            icon: const Icon(Icons.info_outline_rounded, size: 16),
            label: const Text('확인 내용 보기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primaryPurple,
              backgroundColor: AppColors.backgroundAlt.withValues(alpha: 0.64),
              side: BorderSide(
                color: AppColors.lightPurple.withValues(alpha: 0.9),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadInkWash extends StatelessWidget {
  const _UploadInkWash();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: CustomPaint(
        painter: _UploadInkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _UploadInkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final moonPaint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(size.width - 36, 42), 28, moonPaint);

    final linePaint = Paint()
      ..color = AppColors.deepInkPurple.withValues(alpha: 0.1)
      ..strokeWidth = 2.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.48, 78)
      ..cubicTo(
        size.width * 0.64,
        54,
        size.width * 0.74,
        94,
        size.width * 0.92,
        72,
      )
      ..cubicTo(size.width, 62, size.width + 12, 76, size.width + 24, 82);
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < 3; i++) {
      final y = size.height - 24 + i * 10;
      final wave = Path()
        ..moveTo(size.width * 0.35, y)
        ..cubicTo(
          size.width * 0.52,
          y - 18,
          size.width * 0.72,
          y + 16,
          size.width,
          y - 4,
        );
      canvas.drawPath(wave, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _UploadInkPainter oldDelegate) => false;
}

class _CopyrightBullet extends StatelessWidget {
  const _CopyrightBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: AppColors.cardLight.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderSoft.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 7),
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 262,
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
