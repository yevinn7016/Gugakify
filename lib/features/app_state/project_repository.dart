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
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return [];
    }
    if (decoded is! List) return [];

    final projects = <RecentProject>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      try {
        projects.add(RecentProject.fromJson(item));
      } on Object {
        // Ignore a malformed legacy entry without preventing the app from
        // loading the remaining recent projects.
      }
    }
    return projects;
  }

  Future<void> saveRecentProjects(List<RecentProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      projects.map((project) => project.toJson()).toList(),
    );
    await prefs.setString(_recentProjectsKey, encoded);
  }
}
