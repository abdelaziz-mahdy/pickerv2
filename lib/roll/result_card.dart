import 'package:flutter/material.dart';

/// The pick, shown once the wheel or reel has stopped: the choice in large
/// type, then "Spin again" and, when there are enough choices left,
/// "Remove & spin" (take this one out of this roll and spin the rest).
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.choice,
    required this.color,
    required this.onSpinAgain,
    this.onRemoveAndSpin,
  });

  final String choice;

  /// The winning choice's colour, used as an accent stripe.
  final Color color;
  final VoidCallback onSpinAgain;

  /// Null when removing would leave fewer than two choices.
  final VoidCallback? onRemoveAndSpin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      liveRegion: true,
      label: 'Picked $choice',
      child: Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text('The pick',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                choice,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onSpinAgain,
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Spin again'),
                  ),
                  if (onRemoveAndSpin != null)
                    OutlinedButton.icon(
                      onPressed: onRemoveAndSpin,
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Remove & spin'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
