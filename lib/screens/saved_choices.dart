import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    content: Text(
      '''Saved choices Screen -Help

to use the choices you saved just click on them

to delete choices tap and hold to select (Same as add choices screen) and then use the delete icon on the top right

Swipe down to dismiss
      ''',
      style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.grey,
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
                return ListView.separated(
                    padding: const EdgeInsets.all(15),
                    itemCount: data.getDBChoices.isEmpty
                        ? 1
                        : data.getDBChoices.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return data.getDBChoices.isEmpty
                          ? addSavedChoices()
                          : choiceCard(context, index, data);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                data.getDBChoices[index].description,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: data.getDBChoices[index].selected == 0
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Material addSavedChoices() {
    return Material(
      elevation: 20,
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.blue,
        highlightColor: Colors.red,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                "roll some choices to have them saved here so you can use them later",
                style: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              )
            ],
          ),
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
          style: GoogleFonts.roboto(
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
            icon: Icon(Icons.help,
                size: 40, color: Theme.of(context).iconTheme.color),
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
