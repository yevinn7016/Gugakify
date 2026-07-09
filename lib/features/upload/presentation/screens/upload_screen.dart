import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
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
      _nameController.text.trim().isNotEmpty && _urlController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>();
    _nameController = TextEditingController(text: project.projectName);
    _urlController = TextEditingController(text: project.youtubeUrl);
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
          const SizedBox(height: 24),
          const Text('프로젝트 명', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GrayInputBox(controller: _nameController, hintText: '예: APT 국악 변환', onChanged: (_) => setState(() {})),
          const SizedBox(height: 20),
          const Text('업로드 방식', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('YouTube URL', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          GrayInputBox(
            controller: _urlController,
            hintText: 'https://youtube.com/watch?v=...',
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => setState(() => _copyrightChecked = !_copyrightChecked),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _copyrightChecked,
                  onChanged: (value) => setState(() => _copyrightChecked = value ?? false),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('저작권 및 이용 권한을 확인했습니다.'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
          PrimaryLavenderButton(
            label: '다음',
            onPressed: _canNext
                ? () {
                    context.read<ProjectProvider>().setUploadInfo(_nameController.text, _urlController.text);
                    context.go('/audio/settings');
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
