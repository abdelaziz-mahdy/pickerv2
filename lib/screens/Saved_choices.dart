import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:provider/provider.dart';

class Saved_Choices_Screen extends StatefulWidget {
  @override
  _Saved_Choices_ScreenState createState() => _Saved_Choices_ScreenState();
}

class _Saved_Choices_ScreenState extends State<Saved_Choices_Screen> {
  bool ontapselect = false;
  final Saved_Screen_Help = SnackBar(
    content: Text(
      '''Saved choices Screen -Help

to use the choices you saved just click on them

to delete choices tap and hold to select (Same as add choices screen) and then use the delete icon on the top right

Swipe down to dismiss
      ''',
      style: GoogleFonts.roboto(
          fontSize: 20, fontWeight: FontWeight.bold),
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
  final _scaffoldKey_Saved = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Provider.of<ChoicesOperation>(context, listen: false).ReadDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey_Saved,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: Provider.of<ChoicesOperation>(context, listen: false)
                  .SelectedExist(
                      Provider.of<ChoicesOperation>(context, listen: false)
                          .getDBChoices) ==
              true
          ? SelectedAppBar(context)
          : NormalAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<ChoicesOperation>(
                //child: InputChoice(),
                builder: (context, ChoicesOperation data, child) {
              return ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: data.getDBChoices.length == 0
                      ? 1
                      : data.getDBChoices.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (context, index) {
                    return data.getDBChoices.length == 0
                        ? Add_Saved_Choices()
                        : Choice_Card(context, index, data);
                  });
            }),
          ),
        ],
      ),
    );
  }

  Material Choice_Card(BuildContext context, int index, ChoicesOperation data) {
    return Material(
      elevation: 20,
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
                      .getDBChoices,
                  index);
            });
          } else {
            Provider.of<ChoicesOperation>(context, listen: false)
                .SetNewChoices(data.getDBChoices[index].description);
            Navigator.pop(context);
          }
        },
        onLongPress: () {
          setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).Selected(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getDBChoices,
                index);
            ontapselect = true;
          });
        },
        child: Ink(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: data.getDBChoices[index].Selected == 0
                ? Theme.of(context).colorScheme.background
                : Colors.redAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5,
              ),
              Text(
                data.getDBChoices[index].description,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: data.getDBChoices[index].Selected == 0
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

  Material Add_Saved_Choices() {
    return Material(
      elevation: 20,
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.blue,
        highlightColor: Colors.red,
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
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

  PreferredSize NormalAppBar() {
    if (Provider.of<ChoicesOperation>(context, listen: false).NumSelected(
            Provider.of<ChoicesOperation>(context, listen: false)
                .getDBChoices) ==
        0) {
      ontapselect = false;
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
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.help,
                size: 40, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(Saved_Screen_Help);
            },
          ),
        ],
      ),
    );
  }

  PreferredSize SelectedAppBar(BuildContext context) {
    int selected = Provider.of<ChoicesOperation>(context, listen: false)
        .NumSelected(
            Provider.of<ChoicesOperation>(context, listen: false).getDBChoices);
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        leading: IconButton(
          icon: Icon(Icons.select_all),
          onPressed: () => setState(() {
            Provider.of<ChoicesOperation>(context, listen: false).Select_All(
                Provider.of<ChoicesOperation>(context, listen: false)
                    .getDBChoices);
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
                              .getDBChoices);
                  ontapselect = false;
                });
              })
        ],
      ),
    );
  }
}
