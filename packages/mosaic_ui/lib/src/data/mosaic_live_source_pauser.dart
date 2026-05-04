import 'package:flutter/widgets.dart';

import 'mosaic_live_source.dart';

/// Wrapping widget that pauses the supplied [MosaicLiveSource]s when
/// the host app moves to the background and resumes them when it
/// returns to the foreground.
///
/// Use at the root of a surface that holds polling sources (a weather
/// surface, a price ticker, a notifications stream) so it stops
/// hammering the network while the user is in another app.
///
/// This covers the most common off-screen case (app backgrounded). For
/// per-tile off-screen pausing while still in the foreground, call
/// `source.pause()` / `source.resume()` directly from a visibility
/// observer.
class MosaicLiveSourcePauser extends StatefulWidget {
  const MosaicLiveSourcePauser({
    super.key,
    required this.sources,
    required this.child,
    this.pauseOnInactive = false,
  });

  final List<MosaicLiveSource<Object?>> sources;
  final Widget child;

  /// When true, also pauses on [AppLifecycleState.inactive] (e.g. the
  /// task switcher or a phone call overlay). Defaults to false because
  /// inactive flickers when the keyboard appears on some platforms,
  /// which would cause a noisy pause/resume cycle.
  final bool pauseOnInactive;

  @override
  State<MosaicLiveSourcePauser> createState() => _MosaicLiveSourcePauserState();
}

class _MosaicLiveSourcePauserState extends State<MosaicLiveSourcePauser>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldPause = state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        (widget.pauseOnInactive && state == AppLifecycleState.inactive);
    if (shouldPause) {
      for (final s in widget.sources) {
        s.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      for (final s in widget.sources) {
        s.resume();
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
