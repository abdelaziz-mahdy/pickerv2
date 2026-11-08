import 'package:flutter/material.dart';
import 'package:pickerv2/roll/roll_palette.dart';
import 'package:pickerv2/roll/roll_settings.dart';

/// Bottom sheet where the user picks how the roll looks: the roll style
/// (wheel or slot reel) and the colours, each with a small live preview.
/// Changes apply immediately through [onChanged].
Future<void> showRollStyleSheet(
  BuildContext context, {
  required RollSettings settings,
  required ValueChanged<RollSettings> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) =>
        _RollStyleSheet(initial: settings, onChanged: onChanged),
  );
}

class _RollStyleSheet extends StatefulWidget {
  const _RollStyleSheet({required this.initial, required this.onChanged});

  final RollSettings initial;
  final ValueChanged<RollSettings> onChanged;

  @override
  State<_RollStyleSheet> createState() => _RollStyleSheetState();
}

class _RollStyleSheetState extends State<_RollStyleSheet> {
  late RollSettings _settings = widget.initial;

  void _set(RollSettings s) {
    setState(() => _settings = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roll style', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<RollStyle>(
              segments: const [
                ButtonSegment(
                    value: RollStyle.wheel,
                    icon: Icon(Icons.donut_large),
                    label: Text('Wheel')),
                ButtonSegment(
                    value: RollStyle.reel,
                    icon: Icon(Icons.view_day_outlined),
                    label: Text('Slot reel')),
              ],
              selected: {_settings.style},
              onSelectionChanged: (s) =>
                  _set(_settings.copyWith(style: s.first)),
            ),
            const SizedBox(height: 24),
            Text('Colours', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            // One row of four, so no look wraps onto a line of its own.
            Row(
              children: [
                for (final (i, look) in RollLook.values.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _LookOption(
                      look: look,
                      selected: _settings.look == look,
                      onTap: () => _set(_settings.copyWith(look: look)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LookOption extends StatelessWidget {
  const _LookOption(
      {required this.look, required this.selected, required this.onTap});

  final RollLook look;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final swatches = rollPalette(look, 6, scheme);
    return Semantics(
      button: true,
      selected: selected,
      label: '${look.label} colours',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A live mini preview: the look's first six slice colours.
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    for (final c in swatches)
                      Expanded(child: Container(height: 28, color: c)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(look.label),
            ],
          ),
        ),
      ),
    );
  }
}
