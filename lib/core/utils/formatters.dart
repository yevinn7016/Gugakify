String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

double aspectRatioValue(String? value) {
  switch (value) {
    case '9:16':
      return 9 / 16;
    case '1:1':
      return 1;
    case '16:9':
    default:
      return 16 / 9;
  }
}
