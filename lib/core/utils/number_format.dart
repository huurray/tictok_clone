/// 숏폼 앱처럼 큰 수를 축약해 표기한다: 1234 -> "1.2K",
/// 1_200_000 -> "1.2M". 끝의 ".0"은 생략한다 (2000 -> "2K").
String formatCount(int count) {
  if (count < 0) return '0';
  if (count < 1000) return '$count';
  if (count < 1000000) return '${_trimOne(count / 1000)}K';
  if (count < 1000000000) return '${_trimOne(count / 1000000)}M';
  return '${_trimOne(count / 1000000000)}B';
}

String _trimOne(double value) {
  final text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
