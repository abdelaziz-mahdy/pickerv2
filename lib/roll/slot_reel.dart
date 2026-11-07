import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickerv2/roll/roll_palette.dart';

/// A vertical slot-machine reel: the choices loop past a frame in the middle
/// and settle on the picked one. Text stays horizontal, so long choices read
/// in full. Mirrors the FortuneWheel API used by the roll screen: a stream of
/// target indices plus start/end callbacks.
///
/// The reel is a flat strip laid out by hand rather than a
/// ListWheelScrollView: the 3D drum skewed the outer rows and, after a long
/// spin, left an empty slot above the frame.
class SlotReel extends StatefulWidget {
  const SlotReel({
    super.key,
    required this.labels,
    required this.colors,
    required this.selected,
    this.duration = const Duration(milliseconds: 4200),
    this.onAnimationStart,
    this.onAnimationEnd,
    this.onFling,
  });

  final List<String> labels;

  /// One fill per row; the roll screen fades the non-picks once a result
  /// shows, the same way it does for the wheel.
  final List<Color> colors;
  final Stream<int> selected;
  final Duration duration;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationEnd;
  final VoidCallback? onFling;

  static const double itemExtent = 64;

  @override
  State<SlotReel> createState() => _SlotReelState();
}

class _SlotReelState extends State<SlotReel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(vsync: this)
    ..addListener(_tick);
  final _random = Random();
  StreamSubscription<int>? _sub;

  /// The row in the frame, in rows (fractional while spinning). Unbounded:
  /// row k shows choice k mod n.
  double _position = 0;
  double _from = 0;
  double _to = 0;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.selected.listen(_spinTo);
  }

  @override
  void didUpdateWidget(SlotReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _sub?.cancel();
      _sub = widget.selected.listen(_spinTo);
    }
    // "Remove & spin" shortens the list: keep the reel on a whole row.
    if (oldWidget.labels.length != widget.labels.length && !_spinning) {
      _position = _position.roundToDouble();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animation.dispose();
    super.dispose();
  }

  void _tick() {
    final next =
        _from + (_to - _from) * Curves.easeOutCubic.transform(_animation.value);
    // A click each time a new row reaches the frame.
    if (next.round() != _position.round()) HapticFeedback.selectionClick();
    setState(() => _position = next);
  }

  Future<void> _spinTo(int target) async {
    final n = widget.labels.length;
    if (n == 0 || _spinning) return;
    final current = _position.round();
    // Several full loops, then land exactly on the target row.
    final loops = 4 + _random.nextInt(3);
    final forward = (target - current % n) % n;
    _from = _position;
    _to = (current + loops * n + forward).toDouble();
    _spinning = true;
    widget.onAnimationStart?.call();
    _animation.duration = widget.duration;
    try {
      await _animation.forward(from: 0).orCancel;
    } on TickerCanceled {
      return; // disposed mid-spin
    }
    _spinning = false;
    if (mounted) widget.onAnimationEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = widget.labels.length;
    const extent = SlotReel.itemExtent;
    return GestureDetector(
      // Swiping the reel spins it, like flinging the wheel.
      onVerticalDragEnd: (_) {
        if (!_spinning) widget.onFling?.call();
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final height = constraints.maxHeight;
        final half = height / 2 / extent;
        final first = (_position - half).floor() - 1;
        final last = (_position + half).ceil() + 1;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (n > 0)
              // Rows fade out only at the very edges of the window, where
              // they slide in and out; every whole row stays readable.
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0, 0.12, 0.88, 1],
                ).createShader(rect),
                child: ClipRect(
                  child: Stack(
                    children: [
                      for (var k = first; k <= last; k++)
                        Positioned(
                          // Keyed by row, so a row keeps its element as it
                          // slides and only animates its own fade, never a
                          // blend into the colour of the row after it.
                          key: ValueKey(k),
                          left: 0,
                          right: 0,
                          top: height / 2 + (k - _position - 0.5) * extent,
                          height: extent,
                          child: _ReelRow(
                            label: widget.labels[k % n],
                            color: widget.colors[k % n],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            // The frame marks the row that counts.
            IgnorePointer(
              child: Container(
                height: extent + 8,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.primary, width: 3),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ReelRow extends StatelessWidget {
  const _ReelRow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: labelColorOn(color),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
