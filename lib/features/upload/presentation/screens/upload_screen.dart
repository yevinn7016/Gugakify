import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gray_input_box.dart';
import '../../../../shared/widgets/gugak_header.dart';
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

  bool get _canNext =>
      _nameController.text.trim().isNotEmpty &&
      _urlController.text.trim().isNotEmpty &&
      _copyrightChecked;

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>();
    _nameController = TextEditingController(text: project.projectName);
    _urlController = TextEditingController(text: project.youtubeUrl);
    _copyrightChecked = project.copyrightConfirmed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: '새 프로젝트 만들기', onBack: () => context.go('/home')),
          const SizedBox(height: 28),
          const Text('프로젝트 명', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GrayInputBox(
            controller: _nameController,
            hintText: '예: APT 국악 변환',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 50),
          const Row(
            children: [
              Text('업로드 방식', style: TextStyle(fontWeight: FontWeight.w800)),
              Expanded(child: SizedBox.shrink()),
              Text(
                '변환할 음원을 업로드 해주세요.',
                style: TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GrayInputBox(
            controller: _urlController,
            hintText: 'YouTube URL',
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 260),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.lightPurple.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _copyrightChecked = !_copyrightChecked),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _copyrightChecked,
                          side: BorderSide(
                            width: 1.2,
                            color: AppColors.lightPurple.withValues(alpha: 0.9),
                          ),
                          activeColor: AppColors.primaryPurple,
                          onChanged: (value) => setState(
                            () => _copyrightChecked = value ?? false,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, top: 2),
                          child: Text(
                            '저작권 및 이용 권한을 확인했습니다.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _showCopyrightSheet(context),
                    child: const Text('확인 내용 보기'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryLavenderButton(
            label: '다음',
            onPressed: _canNext
                ? () {
                    context.read<ProjectProvider>().setUploadInfo(
                      _nameController.text,
                      _urlController.text.trim(),
                      _copyrightChecked,
                    );
                    context.go('/audio/settings');
                  }
                : null,
          ),
        ],
      ),
    );
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
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const _CopyrightBullet('본인이 보유하거나 이용 권한이 있는 음원만 변환할 수 있습니다.'),
              const _CopyrightBullet(
                '타인의 저작물을 무단으로 업로드하거나 변환한 결과물을 배포해서는 안 됩니다.',
              ),
              const _CopyrightBullet(
                'YouTube 링크를 사용하는 경우에도 해당 콘텐츠의 이용 조건과 저작권을 확인해야 합니다.',
              ),
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

class _CopyrightBullet extends StatelessWidget {
  const _CopyrightBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(color: AppColors.primaryPurple)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
