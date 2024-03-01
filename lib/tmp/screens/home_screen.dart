import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:pickerv2/tmp/models/choice.dart';
import 'package:pickerv2/tmp/models/choices_operation.dart';
import 'package:pickerv2/tmp/screens/picker_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/Saved_Choices.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool ontapselect = false;
  final Low_Choices = SnackBar(
    content: Text(
      'Please add more choices',
      style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
  );
  final Home_Screen_Help = SnackBar(
    content: Text(
      '''Add choices Screen -Help
      
to delete choices tap and hold to select and then use the delete icon on the top right

Swipe down to dismiss
      ''',
      style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.grey,
    duration: Duration(seconds: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
  );
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider.of<ChoicesOperation>(context, listen: false).CreateDB();
    print('object created');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Floating_Button(context),
      appBar: Provider.of<ChoicesOperation>(context, listen: false)
                  .SelectedExist(
                      Provider.of<ChoicesOperation>(context, listen: false)
                          .getChoices) ==
              true
          ? SelectedAppBar(context)
          : NormalAppBar(),
      body: Column(
        children: <Widget>[
          InputChoice(),
          Expanded(
            child: Consumer<ChoicesOperation>(
                //child: InputChoice(),
                builder: (context, ChoicesOperation data, child) {
              return ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: data.getChoices.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (context, index) {
                    return Choice_Card(context, index, data);
                  });
            }),
          ),
        ],
      ),
    );
  }

  FloatingActionButton Floating_Button(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (Provider.of<ChoicesOperation>(context, listen: false)
                .getChoices
                .length <
            2) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(Low_Choices);
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Provider.of<ChoicesOperation>(context, listen: false).Save_Choices();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Roulette(
                      Provider.of<ChoicesOperation>(context, listen: false)
                          .ToLabels())));
        }
      },
      child: Icon(
        Icons.arrow_right,
        size: 50,
      ),
    );
  }

  PreferredSize NormalAppBar() {
    if (Provider.of<ChoicesOperation>(context, listen: false).NumSelected(
            Provider.of<ChoicesOperation>(context, listen: false).getChoices) ==
        0) {
      ontapselect = false;
    }
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(
            Icons.help,
            size: 40,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(Home_Screen_Help);
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
              icon: Icon(
                Icons.star,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .Save_Choices();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Saved_Choices_Screen()));
                });
              })
        ],
      ),
    );
  }

  PreferredSize SelectedAppBar(BuildContext context) {
    int selected = Provider.of<ChoicesOperation>(context, listen: false)
        .NumSelected(
            Provider.of<ChoicesOperation>(context, listen: false).getChoices);
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        leading: IconButton(
          icon: Icon(Icons.select_all),
          onPressed: () => setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).Select_All(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getChoices);
          }),
        ),
        title: Text("Selected :" + selected.toString()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .DeleteSelected(
                          Provider.of<ChoicesOperation>(context, listen: false)
                              .getChoices);
                  ontapselect = false;
                });
              })
        ],
      ),
    );
  }

  Material Choice_Card(BuildContext context, int index, ChoicesOperation data) {
    return Material(
      elevation: 10,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.blue,
        highlightColor: Colors.red,
        onTap: () {
          if (ontapselect == true) {
            setState(() {
              Provider.of<ChoicesOperation>(context, listen: false).Selected(
                  Provider.of<ChoicesOperation>(context, listen: false)
                      .getChoices,
                  index);
            });
          }
        },
        onLongPress: () {
          setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).Selected(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getChoices,
                index);
            ontapselect = true;
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

  ChoicesCard(this.choice);

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: choice.Selected == 0
              ? Theme.of(context).colorScheme.background
              : Colors.redAccent,
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            choice.description,
            style: GoogleFonts.roboto(
              fontSize: 24,
              color: choice.Selected == 0
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
  @override
  _InputChoiceState createState() => _InputChoiceState();
}

class _InputChoiceState extends State<InputChoice> {
  String DescriptionText = "";
  TextEditingController txt = new TextEditingController();
  final validate =
      ValidationBuilder().minLength(1, 'Length < 1 😟').maxLength(1500).build();

  GlobalKey<FormState> _form = GlobalKey();

  void done() {
    if (_form.currentState!.validate()) {
      Provider.of<ChoicesOperation>(context, listen: false)
          .addNewChoice(DescriptionText);
      txt.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          boxShadow: [
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
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
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
                  DescriptionText = value;
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
