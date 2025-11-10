import 'dart:convert';
import 'dart:io';

/// Minimal Tesseract wrapper.
/// - Windows: tries common install paths, then PATH.
/// - macOS/Linux: relies on PATH.
/// Returns the recognized text (UTF-8), or throws with a readable message.
class TesseractOcr {
  /// Language packs: use 'eng' by default. You can pass 'eng+spa' etc.
  static Future<String> recognize({
    required String imagePath,
    String lang = 'eng',
    Duration timeout = const Duration(seconds: 40),
  }) async {
    final exe = await _resolveTesseractExe();
    if (exe == null) {
      throw Exception(
        "Tesseract not found. Install it and restart your shell.\n"
        "Windows (Chocolatey): choco install tesseract -y\n"
        "Windows (winget):     winget install -e --id UB-Mannheim.TesseractOCR\n"
        "macOS:                brew install tesseract\n"
        "Linux:                sudo apt-get install tesseract-ocr\n",
      );
    }

    // Tesseract syntax: tesseract <img> stdout --oem 1 --psm 6 -l eng
    final args = <String>[
      imagePath,
      'stdout',
      '--oem',
      '1',
      '--psm',
      '6',
      '-l',
      lang,
    ];

    final proc = await Process.start(exe, args, runInShell: true);
    final out = utf8.decodeStream(proc.stdout);
    final err = utf8.decodeStream(proc.stderr);
    final result =
        await Future.wait([out, err, proc.exitCode.timeout(timeout)]);

    final exitCode = result[2] as int;
    final stdoutText = result[0] as String;
    final stderrText = result[1] as String;

    if (exitCode != 0) {
      throw Exception("Tesseract failed (exit $exitCode):\n$stderrText");
    }
    // Some builds write warnings to stderr; we ignore if exit==0.
    return stdoutText.trim();
  }

  static Future<String?> _resolveTesseractExe() async {
    // 1) Common Windows locations from Chocolatey / UB-Mannheim installer
    final candidates = <String>[
      r'C:\Program Files\Tesseract-OCR\tesseract.exe',
      r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
      // fallbacks (PATH)
      'tesseract', // let the OS resolve
    ];

    for (final p in candidates) {
      try {
        final ok = await _tryVersion(p);
        if (ok) return p;
      } catch (_) {
        // ignore and keep trying
      }
    }
    return null;
  }

  static Future<bool> _tryVersion(String exe) async {
    try {
      final p = await Process.start(exe, const ['--version'], runInShell: true);
      final code = await p.exitCode.timeout(const Duration(seconds: 10));
      return code == 0;
    } catch (_) {
      return false;
    }
  }
}
