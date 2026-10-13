import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'i18n/lang.dart';
import 'i18n/strings.dart';
import 'theme/tokens.dart';

const _kDownloadUrl = 'https://jugaadi.vercel.app/download';
const _kCardSize = 1080.0;

/// Renders a branded "open position" card for this job (logo, title, skill, pay, location,
/// a download CTA) with dart:ui directly — no widget needs to be mounted on screen for this,
/// unlike the usual RepaintBoundary screenshot approach.
Future<Uint8List> _renderJobCard(Map<String, dynamic> job, Lang lang) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _kCardSize, _kCardSize));
  const c = AppColors.dark;

  canvas.drawRect(const Rect.fromLTWH(0, 0, _kCardSize, _kCardSize), Paint()..color = c.bg);

  final gradientPaint = Paint()
    ..shader = LinearGradient(colors: [c.accent, c.accentDeep], begin: Alignment.topLeft, end: Alignment.bottomRight)
        .createShader(const Rect.fromLTWH(0, 0, _kCardSize, 260));
  canvas.drawRect(const Rect.fromLTWH(0, 0, _kCardSize, 260), gradientPaint);

  final logoBytes = await rootBundle.load('assets/icon/icon.png');
  final logoCodec = await ui.instantiateImageCodec(logoBytes.buffer.asUint8List(), targetWidth: 140, targetHeight: 140);
  final logo = (await logoCodec.getNextFrame()).image;
  final logoRect = const Rect.fromLTWH(60, 60, 140, 140);
  canvas.save();
  canvas.clipPath(Path()..addOval(logoRect));
  canvas.drawImageRect(
    logo,
    Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
    logoRect,
    Paint(),
  );
  canvas.restore();

  void text(String value, {required double x, required double y, required double size, Color? color, FontWeight weight = FontWeight.w500, double maxWidth = _kCardSize - 120}) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: TextStyle(color: color ?? c.textPrimary, fontSize: size, fontWeight: weight, height: 1.25)),
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, Offset(x, y));
  }

  text(tr(lang, 'share_open_position_badge').toUpperCase(), x: 220, y: 95, size: 28, color: c.onAccent, weight: FontWeight.w700);
  text('Jugaadi', x: 220, y: 135, size: 34, color: c.onAccent, weight: FontWeight.w800);

  double y = 320;
  text(job['title'] as String? ?? '', x: 60, y: y, size: 56, weight: FontWeight.w800, maxWidth: _kCardSize - 120);
  y += 140;

  text('${tr(lang, 'share_skill_label')}: ${job['skill_needed'] ?? '-'}', x: 60, y: y, size: 34, color: c.textSecondary);
  y += 56;

  final address = (job['address_text'] as String?) ?? '';
  if (address.isNotEmpty) {
    text('${tr(lang, 'share_location_label')}: $address', x: 60, y: y, size: 34, color: c.textSecondary);
    y += 56;
  }

  if (job['daily_wage'] != null) {
    text('${tr(lang, 'share_wage_label')}: ₹${job['daily_wage']}/${tr(lang, 'share_per_day')}', x: 60, y: y, size: 34, color: c.textSecondary);
    y += 56;
  }

  text('${job['start_date']} → ${job['end_date']}', x: 60, y: y, size: 34, color: c.textSecondary);

  // Footer CTA band
  canvas.drawRect(const Rect.fromLTWH(0, _kCardSize - 160, _kCardSize, 160), Paint()..color = c.surfaceHigh);
  text(tr(lang, 'share_cta_line'), x: 60, y: _kCardSize - 128, size: 30, weight: FontWeight.w700);
  text(_kDownloadUrl, x: 60, y: _kCardSize - 84, size: 30, color: c.accent, weight: FontWeight.w700);

  final picture = recorder.endRecording();
  final image = await picture.toImage(_kCardSize.toInt(), _kCardSize.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

String _shareText(Map<String, dynamic> job, Lang lang) {
  final wage = job['daily_wage'] != null ? ' · ₹${job['daily_wage']}/${tr(lang, 'share_per_day')}' : '';
  return '${tr(lang, 'share_open_position_badge')}: ${job['title']}\n'
      '${tr(lang, 'share_skill_label')}: ${job['skill_needed']}$wage\n\n'
      '${tr(lang, 'share_cta_line')}\n'
      '$_kDownloadUrl';
}

Future<void> shareJob(Map<String, dynamic> job, Lang lang) async {
  final bytes = await _renderJobCard(job, lang);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/jugaadi_job_${job['id']}.png');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(
    ShareParams(text: _shareText(job, lang), files: [XFile(file.path)]),
  );
}
