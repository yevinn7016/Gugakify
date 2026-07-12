import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'project_state.dart';

class ProjectRepository {
  static const _recentProjectsKey = 'gugakify_recent_projects';

  Future<List<RecentProject>> loadRecentProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentProjectsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RecentProject.fromJson)
        .toList();
  }

  Future<void> saveRecentProjects(List<RecentProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      projects.map((project) => project.toJson()).toList(),
    );
    await prefs.setString(_recentProjectsKey, encoded);
  }
}
