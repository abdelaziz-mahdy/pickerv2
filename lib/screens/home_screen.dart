import 'package:flutter/material.dart';
import 'package:pickerv2/models/choice.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:pickerv2/screens/picker_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool onTapSelect = false;
  final lowChoices = SnackBar(
    content: Text(
      'Add at least two choices to roll',
    ),
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
  );
  final homeScreenHelp = SnackBar(
    content: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'How to use Picker\n',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '• Type a choice and tap Add Choice. Add at least two.\n• Tap Roll to spin the wheel. Lists you roll or save with the bookmark appear in the Saved tab.\n• To delete choices, press and hold one to select it, then tap the trash icon.',
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider.of<ChoicesOperation>(context, listen: false).createDB();
  }

  @override
  Widget build(BuildContext context) {
    final operation = Provider.of<ChoicesOperation>(context, listen: false);
    final selecting = operation.selectedExist(operation.getChoices);
    // While choices are selected, Back clears the selection instead of
    // leaving the screen.
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) clearSelection();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: floatingButton(context),
        appBar: selecting ? selectedAppBar(context) : normalAppBar(),
        body: Column(
          children: <Widget>[
            const InputChoice(),
            Expanded(
              child: Consumer<ChoicesOperation>(
                  //child: InputChoice(),
                  builder: (context, ChoicesOperation data, child) {
                return ListView.separated(
                    // Room at the end so the last card can scroll clear of
                    // the Roll button and the gesture bar (edge-to-edge).
                    padding: EdgeInsets.fromLTRB(
                        15, 15, 15, 96 + MediaQuery.paddingOf(context).bottom),
                    itemCount: data.getChoices.length,
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
      operation.clearSelection(operation.getChoices);
      onTapSelect = false;
    });
  }

  FloatingActionButton floatingButton(BuildContext context) {
    return FloatingActionButton.extended(
      tooltip: 'Spin the wheel with these choices',
      onPressed: () {
        if (Provider.of<ChoicesOperation>(context, listen: false)
                .getChoices
                .length <
            2) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(lowChoices);
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Provider.of<ChoicesOperation>(context, listen: false).saveChoices();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Roulette(
                      Provider.of<ChoicesOperation>(context, listen: false)
                          .ToLabels())));
        }
      },
      icon: const Icon(Icons.casino_outlined),
      label: const Text('Roll'),
    );
  }

  PreferredSize normalAppBar() {
    if (Provider.of<ChoicesOperation>(context, listen: false).numSelected(
            Provider.of<ChoicesOperation>(context, listen: false).getChoices) ==
        0) {
      onTapSelect = false;
    }
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        // The list scrolls below the choice card, not under the app bar, so
        // the app bar keeps its flat colour when the list is scrolled.
        notificationPredicate: (_) => false,
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Help',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(homeScreenHelp);
          },
        ),
        title: const Text("Choice Picker"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: 'Save list',
              onPressed: () {
                final operation =
                    Provider.of<ChoicesOperation>(context, listen: false);
                final messenger = ScaffoldMessenger.of(context);
                messenger.removeCurrentSnackBar();
                if (operation.getChoices.isEmpty) {
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Add some choices first'),
                    behavior: SnackBarBehavior.floating,
                  ));
                  return;
                }
                operation.saveChoices();
                messenger.showSnackBar(const SnackBar(
                  content: Text('List saved. Find it in the Saved tab.'),
                  behavior: SnackBarBehavior.floating,
                ));
              })
        ],
      ),
    );
  }

  PreferredSize selectedAppBar(BuildContext context) {
    int selected = Provider.of<ChoicesOperation>(context, listen: false)
        .numSelected(
            Provider.of<ChoicesOperation>(context, listen: false).getChoices);
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        // The list scrolls below the choice card, not under the app bar, so
        // the app bar keeps its flat colour when the list is scrolled.
        notificationPredicate: (_) => false,
        // X leaves selection mode, the same as Back.
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Clear selection',
          onPressed: clearSelection,
        ),
        title: Text("$selected selected"),
        centerTitle: true,
        elevation: 0,
        // Theme colours, not red: selecting isn't destructive; Delete is.
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: 'Select all',
            onPressed: () => setState(() {
              Provider.of<ChoicesOperation>(context, listen: false).selectAll(
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .getChoices);
            }),
          ),
          IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected',
              onPressed: () {
                setState(() {
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .deleteSelectedChoices();
                  onTapSelect = false;
                });
              })
        ],
      ),
    );
  }

  Material choiceCard(BuildContext context, int index, ChoicesOperation data) {
    return Material(
      elevation: 1,
      color: Colors.transparent,
      // The shadow follows this shape; without it a square shadow showed
      // behind the rounded card corners.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (onTapSelect == true) {
            setState(() {
              Provider.of<ChoicesOperation>(context, listen: false).selected(
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .getChoices,
                  index);
            });
          }
        },
        onLongPress: () {
          setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).selected(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getChoices,
                index);
            onTapSelect = true;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //index==0?InputChoice():Container(),
            ChoicesCard(data.getChoices[index]),
          ],
        ),
      ),
    );
  }
}

class ChoicesCard extends StatelessWidget {
  final Choice choice;

  const ChoicesCard(this.choice, {super.key});

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: choice.selected == 0
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.secondaryContainer,
          // An outline marks selected cards at a glance.
          border: choice.selected == 0
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Text(
            choice.description,
            style: TextStyle(
              fontSize: 20,
              color: choice.selected == 0
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          )
        ],
      ),
    );
  }
}

class InputChoice extends StatefulWidget {
  const InputChoice({super.key});

  @override
  InputChoiceState createState() => InputChoiceState();
}

class InputChoiceState extends State<InputChoice> {
  TextEditingController txt = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey();

  void done() {
    if (_form.currentState!.validate()) {
      Provider.of<ChoicesOperation>(context, listen: false)
          .addNewChoice(txt.text.trim());
      txt.text = "";
    }
  }

  @override
  void dispose() {
    txt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          // A theme outline instead of a black shadow.
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Form(
            key: _form,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  done();
                },
                validator: ChoicesOperation.validateChoice,
                controller: txt,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 15,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error, width: 2.0),
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter Choice',
                  // Hint keeps the theme's hint colour so it does not read
                  // as text that was already typed.
                  hintStyle: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).hintColor,
                  ),
                  labelText: 'Choice',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: () {
                done();
              },
              child: const Text('Add Choice'),
            ),
          )
        ],
      ),
    );
  }
}
