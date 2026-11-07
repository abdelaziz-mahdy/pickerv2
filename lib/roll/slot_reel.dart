import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickerv2/roll/roll_palette.dart';

/// A vertical slot-machine reel: the choices loop past a frame in the middle
/// and settle on the picked one. Text stays horizontal, so long choices read
/// in full. Mirrors the FortuneWheel API used by the roll screen: a stream of
/// target indices plus start/end callbacks.
class SlotReel extends StatefulWidget {
  const SlotReel({
    super.key,
    required this.labels,
    required this.colors,
    required this.selected,
    this.duration = const Duration(milliseconds: 4200),
    this.dimExcept,
    this.onAnimationStart,
    this.onAnimationEnd,
    this.onFling,
  });

  final List<String> labels;
  final List<Color> colors;
  final Stream<int> selected;
  final Duration duration;

  /// When set, every row except this index is dimmed (the result is shown).
  final int? dimExcept;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationEnd;
  final VoidCallback? onFling;

  static const double itemExtent = 64;

  @override
  State<SlotReel> createState() => _SlotReelState();
}

class _SlotReelState extends State<SlotReel> {
  final _controller = FixedExtentScrollController();
  final _random = Random();
  StreamSubscription<int>? _sub;
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
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spinTo(int target) async {
    final n = widget.labels.length;
    if (n == 0 || !_controller.hasClients) return;
    final current = _controller.selectedItem;
    // Several full loops, then land exactly on the target row.
    final loops = 4 + _random.nextInt(3);
    final forward = (target - current % n) % n;
    final destination = current + loops * n + forward;
    _spinning = true;
    widget.onAnimationStart?.call();
    await _controller.animateToItem(destination,
        duration: widget.duration, curve: Curves.easeOutCubic);
    _spinning = false;
    if (mounted) widget.onAnimationEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = widget.labels.length;
    return GestureDetector(
      // Swiping the reel spins it, like flinging the wheel.
      onVerticalDragEnd: (_) {
        if (!_spinning) widget.onFling?.call();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: SlotReel.itemExtent,
            diameterRatio: 1.8,
            perspective: 0.004,
            physics: const NeverScrollableScrollPhysics(),
            onSelectedItemChanged: (_) {
              if (_spinning) HapticFeedback.selectionClick();
            },
            childDelegate: ListWheelChildLoopingListDelegate(
              children: [
                for (var i = 0; i < n; i++)
                  _ReelRow(
                    label: widget.labels[i],
                    color: widget.colors[i],
                    dimmed: widget.dimExcept != null && widget.dimExcept != i,
                  ),
              ],
            ),
          ),
          // The frame marks the row that counts.
          IgnorePointer(
            child: Container(
              height: SlotReel.itemExtent + 8,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.primary, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelRow extends StatelessWidget {
  const _ReelRow(
      {required this.label, required this.color, required this.dimmed});

  final String label;
  final Color color;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.35 : 1,
      duration: const Duration(milliseconds: 250),
      child: Container(
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
      ),
    );
  }
}
