import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Token-driven icon. Looks up [name] in a curated registry and
/// renders the glyph with the active token color and the supplied
/// [size].
///
/// Why a registry rather than an enum: it keeps the API stable while
/// the implementation can change later (Unicode glyph today; bundled
/// SVG path data tomorrow). Consumers reference icons by name, the
/// registry resolves them, and we avoid every component shipping its
/// own arbitrary Unicode characters.
///
/// Unknown names render `·` so a typo never produces a Mojibake or
/// throws — the icon is just visibly absent.
class MosaicIcon extends StatelessWidget {
  const MosaicIcon(this.name, {super.key, this.size = 20, this.color});

  final String name;
  final double size;
  final Color? color;

  /// Single source of truth for icon → glyph mapping. Add entries here
  /// rather than typing Unicode characters at call sites.
  static const Map<String, String> _glyphs = <String, String>{
    // navigation / chrome
    'arrow.left': '←',
    'arrow.right': '→',
    'arrow.up': '↑',
    'arrow.down': '↓',
    'arrow.upRight': '↗',
    'arrow.downLeft': '↙',
    'chevron.left': '‹',
    'chevron.right': '›',
    'chevron.up': '⌃',
    'chevron.down': '⌄',
    'close': '×',
    'check': '✓',
    'plus': '+',
    'minus': '−',
    'menu': '≡',
    'more': '⋯',
    // status / feedback
    'info': 'ⓘ',
    'warning': '⚠',
    'error': '!',
    'success': '✓',
    'star': '★',
    'starOutline': '☆',
    'heart': '♥',
    'heartOutline': '♡',
    'circle': '●',
    'circleOutline': '◌',
    // chrome / shell
    'home': '⌂',
    'settings': '⚙',
    'search': '⌕',
    'filter': '◇',
    'refresh': '↻',
    'lock': '⛒',
    // domain
    'calendar': '◫',
    'clock': '◷',
    'location': '⌖',
    'user': '◉',
    'mail': '✉',
    'phone': '☎',
    'message': '✎',
    'folder': '📁',
    'file': '📄',
    'image': '🖼',
    'music': '♫',
    'video': '▶',
    'camera': '📷',
    'mic': '🎤',
    'send': '↗',
    'pay': '◇',
    // weather
    'sun': '☀',
    'moon': '☾',
    'cloud': '☁',
    'rain': '☔',
    'snow': '❄',
    'storm': '⛈',
  };

  static const String _missing = '·';

  /// Read-only view of the registered icon names. Useful for tests and
  /// galleries.
  static Iterable<String> get names => _glyphs.keys;

  String get _glyph => _glyphs[name] ?? _missing;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Text(
      _glyph,
      style: TextStyle(
        fontSize: size,
        height: 1,
        color: color ?? tokens.color.textPrimary,
      ),
    );
  }
}
