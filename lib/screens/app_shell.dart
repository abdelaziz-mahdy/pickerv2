import 'package:flutter/material.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:pickerv2/screens/home_screen.dart';
import 'package:pickerv2/screens/saved_choices.dart';
import 'package:provider/provider.dart';

/// The two top-level places in the app, switched with a bottom bar:
/// the current choices and the saved lists.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int index = 0;

  void select(int i) {
    // Saved lists can change on the Choices tab (Roll and Save list both
    // add one), so reload them whenever the Saved tab is opened.
    if (i == 1) {
      Provider.of<ChoicesOperation>(context, listen: false).readDB();
    }
    setState(() => index = i);
  }

  @override
  Widget build(BuildContext context) {
    // Back on the Saved tab returns to Choices before leaving the app.
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) select(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            const HomeScreen(),
            SavedChoicesScreen(onListLoaded: () => select(0)),
          ],
        ),
        // Roll needs two choices; below that the button could only say so,
        // and the empty state already explains it.
        floatingActionButton: index == 0 &&
                context.select<ChoicesOperation, bool>(
                    (o) => o.getChoices.length >= 2)
            ? const RollButton()
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Choices',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmarks_outlined),
              selectedIcon: Icon(Icons.bookmarks),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}
