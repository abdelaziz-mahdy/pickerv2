import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:pickerv2/models/choice.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:pickerv2/screens/picker_screen.dart';
import 'package:pickerv2/screens/saved_choices.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool onTapSelect = false;
  final lowChoices = SnackBar(
    content: Text(
      'Please add more choices',
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
    content: Text(
      '''Add choices Screen -Help
      
to delete choices tap and hold to select and then use the delete icon on the top right

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider.of<ChoicesOperation>(context, listen: false).createDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: floatingButton(context),
      appBar: Provider.of<ChoicesOperation>(context, listen: false)
                  .selectedExist(
                      Provider.of<ChoicesOperation>(context, listen: false)
                          .getChoices) ==
              true
          ? selectedAppBar(context)
          : normalAppBar(),
      body: Column(
        children: <Widget>[
          const InputChoice(),
          Expanded(
            child: Consumer<ChoicesOperation>(
                //child: InputChoice(),
                builder: (context, ChoicesOperation data, child) {
              return ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: data.getChoices.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (context, index) {
                    return choiceCard(context, index, data);
                  });
            }),
          ),
        ],
      ),
    );
  }

  FloatingActionButton floatingButton(BuildContext context) {
    return FloatingActionButton(
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
      child: const Icon(
        Icons.arrow_right,
        size: 50,
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
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              icon: const Icon(
                Icons.star,
                size: 40,
              ),
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
          onPressed: () => setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).selectAll(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getChoices);
          }),
        ),
        title: Text("Selected :$selected"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .deleteSelected(
                          Provider.of<ChoicesOperation>(context, listen: false)
                              .getChoices);
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
              ? Theme.of(context).colorScheme.background
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
  _InputChoiceState createState() => _InputChoiceState();
}

class _InputChoiceState extends State<InputChoice> {
  String descriptionText = "";
  TextEditingController txt = TextEditingController();
  final validate =
      ValidationBuilder().minLength(1, 'Length < 1 😟').maxLength(1500).build();

  final GlobalKey<FormState> _form = GlobalKey();

  void done() {
    if (_form.currentState!.validate()) {
      Provider.of<ChoicesOperation>(context, listen: false)
          .addNewChoice(descriptionText);
      txt.text = "";
    }
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
                validator: validate,
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
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                onChanged: (value) {
                  descriptionText = value;
                },
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
