import 'package:flutter/material.dart';
import 'package:pickerv2/models/choice.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:pickerv2/screens/picker_screen.dart';
import 'package:pickerv2/screens/saved_choices.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
      style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.red,
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
            style:
                GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '• Type a choice and tap Add Choice. Add at least two.\n• Tap Roll to spin the wheel. Lists you roll are kept under the star.\n• To delete choices, press and hold one to select it, then tap the trash icon.',
            style: GoogleFonts.roboto(fontSize: 17, height: 1.4),
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
      icon: const Icon(
        Icons.arrow_right,
        size: 40,
      ),
      label: Text(
        'Roll',
        style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
      ),
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
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: const Icon(
            Icons.help,
            size: 40,
          ),
          tooltip: 'Help',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(homeScreenHelp);
          },
        ),
        title: Text(
          "Choice Picker",
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
              icon: const Icon(
                Icons.star,
                size: 40,
              ),
              tooltip: 'Saved lists',
              onPressed: () {
                setState(() {
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .saveChoices();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SavedChoicesScreen()));
                });
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
        leading: IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: 'Select all',
          onPressed: () => setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).selectAll(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getChoices);
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
      elevation: 10,
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
              : Colors.redAccent,
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Text(
            choice.description,
            style: GoogleFonts.roboto(
              fontSize: 24,
              color: choice.selected == 0
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Colors.black,
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
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0.0, 0.0), //(x,y)
              blurRadius: 2.0,
            ),
          ],
          color: Theme.of(context).cardColor,
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
                  errorStyle: GoogleFonts.roboto(
                    fontSize: 15,
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter Choice',
                  // Hint keeps the theme's hint colour so it does not read
                  // as text that was already typed.
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Theme.of(context).hintColor,
                  ),
                  labelText: 'Choice',
                  labelStyle: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                style: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                done();
              },
              child: Text(
                'Add Choice',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
