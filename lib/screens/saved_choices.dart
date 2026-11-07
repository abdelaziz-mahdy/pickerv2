import 'package:flutter/material.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:provider/provider.dart';

class SavedChoicesScreen extends StatefulWidget {
  const SavedChoicesScreen({super.key});

  @override
  SavedChoicesScreenState createState() => SavedChoicesScreenState();
}

class SavedChoicesScreenState extends State<SavedChoicesScreen> {
  bool onTapSelect = false;
  final savedScreenHelp = SnackBar(
    content: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Saved lists\n',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '• Tap a list to load its choices on the home screen.\n• To delete lists, press and hold one to select it, then tap the trash icon.',
            style: TextStyle(fontSize: 17, height: 1.4),
          ),
        ],
      ),
    ),
    action: SnackBarAction(label: 'Got it', onPressed: () {}),
    persist: false,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 20),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    Provider.of<ChoicesOperation>(context, listen: false).readDB();
  }

  @override
  Widget build(BuildContext context) {
    final operation = Provider.of<ChoicesOperation>(context, listen: false);
    final selecting = operation.selectedExist(operation.getDBChoices);
    // While choices are selected, Back clears the selection instead of
    // leaving the screen.
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) clearSelection();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: selecting ? selectedAppBar(context) : normalAppBar(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Consumer<ChoicesOperation>(
                  //child: InputChoice(),
                  builder: (context, ChoicesOperation data, child) {
                if (data.getDBChoices.isEmpty) return addSavedChoices();
                return ListView.separated(
                    // Keep the last card clear of the gesture bar
                    // (edge-to-edge).
                    padding: EdgeInsets.fromLTRB(
                        15, 15, 15, 15 + MediaQuery.paddingOf(context).bottom),
                    itemCount: data.getDBChoices.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return choiceCard(context, index, data);
                    });
              }),
            ),
          ],
        ),
      ),
    );
  }

  void clearSelection() {
    setState(() {
      final operation = Provider.of<ChoicesOperation>(context, listen: false);
      operation.clearSelection(operation.getDBChoices);
      onTapSelect = false;
    });
  }

  Material choiceCard(BuildContext context, int index, ChoicesOperation data) {
    return Material(
      elevation: 20,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.blue,
        highlightColor: Colors.red,
        onTap: () {
          if (onTapSelect == true) {
            setState(() {
              Provider.of<ChoicesOperation>(context, listen: false).selected(
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .getDBChoices,
                  index);
            });
          } else {
            Provider.of<ChoicesOperation>(context, listen: false)
                .setNewChoices(data.getDBChoices[index].description);
            Navigator.pop(context);
          }
        },
        onLongPress: () {
          setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).selected(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getDBChoices,
                index);
            onTapSelect = true;
          });
        },
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: data.getDBChoices[index].selected == 0
                ? Theme.of(context).colorScheme.surface
                : Colors.redAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: savedListContent(
            context,
            ChoicesOperation.decodeChoices(
                data.getDBChoices[index].description),
            selected: data.getDBChoices[index].selected == 1,
          ),
        ),
      ),
    );
  }

  /// A saved list shown as its choices, one pill each, instead of the raw
  /// comma-joined string it is stored as.
  Widget savedListContent(BuildContext context, List<String> choices,
      {required bool selected}) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = selected ? Colors.black : scheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          choices.length == 1 ? '1 choice' : '${choices.length} choices',
          style: TextStyle(fontSize: 14, color: textColor),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in choices)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.35)
                      : scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  choice,
                  style: TextStyle(
                    fontSize: 18,
                    color:
                        selected ? Colors.black : scheme.onSecondaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget addSavedChoices() {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No saved lists yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lists you roll, or save with the star, show up here so you '
              'can load them again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSize normalAppBar() {
    if (Provider.of<ChoicesOperation>(context, listen: false).numSelected(
            Provider.of<ChoicesOperation>(context, listen: false)
                .getDBChoices) ==
        0) {
      onTapSelect = false;
    }
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Saved Choices",
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.secondary
                : Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(savedScreenHelp);
            },
          ),
        ],
      ),
    );
  }

  PreferredSize selectedAppBar(BuildContext context) {
    int selected = Provider.of<ChoicesOperation>(context, listen: false)
        .numSelected(
            Provider.of<ChoicesOperation>(context, listen: false).getDBChoices);
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: 'Select all',
          onPressed: () => setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).selectAll(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getDBChoices);
          }),
        ),
        title: Text("$selected selected"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected',
              onPressed: () {
                setState(() {
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .deleteSelectedSaved();
                  onTapSelect = false;
                });
              })
        ],
      ),
    );
  }
}
