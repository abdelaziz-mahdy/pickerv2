import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:pickerv2/models/Choice.dart';
import 'package:pickerv2/models/Choicesoperation.dart';
import 'package:pickerv2/screens/Edit_Screen.dart';
import 'package:pickerv2/screens/Picker_Screen.dart';
import 'package:pickerv2/screens/add_screen.dart';
import 'package:provider/provider.dart';
 class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    bool ontapselect=false;
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
       floatingActionButton: FloatingActionButton(
         onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>  Roulette(Provider.of<ChoicesOperation>(context,listen: false).ToLabels())));
         },
         child: Icon(
           Icons.arrow_right,
           size:40,
           color: Colors.blue[900],
         ),
         backgroundColor: Theme.of(context).backgroundColor,
       ),

       appBar: Provider.of<ChoicesOperation>(context,listen: false).SelectedExist()==true?SelectedAppBar(context):NormalAppBar(),

      body: Column(
        children: <Widget>[
        InputChoice(),

          Expanded(
            child: Consumer<ChoicesOperation>(
                //child: InputChoice(),
                builder: (context,ChoicesOperation data,child){
                return ListView.builder(
                  itemCount: data.getChoices.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap:  (){
                        ontapselect==true?setState(() {
                          Provider.of<ChoicesOperation>(context,listen: false).Selected(index);
                        }):{};
                      },
                      onLongPress: (){
                      setState(() {
                        Provider.of<ChoicesOperation>(context,listen: false).Selected(index);
                        ontapselect=true;
                      });
                    },
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.stretch,
                          children: [
                            //index==0?InputChoice():Container(),
                            ChoicesCard(data.getChoices[index]),
                          ],
                        ),

                    );

                  }

                );

              }
            ),
          ),
        ],
      ),
     );
   }

   PreferredSize NormalAppBar() {
     if(Provider.of<ChoicesOperation>(context,listen: false).NumSelected()==0){ontapselect=false;}
     return PreferredSize(
       preferredSize: const Size(double.infinity, kToolbarHeight),
       child: AppBar(
         title: Text("Choice Picker" ),
         centerTitle: true,
         elevation: 0,
         backgroundColor: Colors.transparent,
       ),
     );
   }

   PreferredSize SelectedAppBar(BuildContext context) {
     int selected=Provider.of<ChoicesOperation>(context,listen: false).NumSelected();
     return PreferredSize(
       preferredSize: const Size(double.infinity, kToolbarHeight),
       child: AppBar(
         title: Text("Selected :"+selected.toString()),
         centerTitle: true,
         elevation: 0,
         backgroundColor: Colors.red,
         actions: [
           IconButton(icon:Icon(Icons.delete),
                onPressed: (){
                  setState(() {
                    Provider.of<ChoicesOperation>(context, listen: false)
                        .DeleteSelected();
                    ontapselect=false;
                  });
                })
         ],
       ),

     );
   }
}

class ChoicesCard extends StatelessWidget {
    final Choice choice;


    ChoicesCard(this.choice);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      height: 100,
      decoration: BoxDecoration(
        boxShadow: [
        BoxShadow(
        color: Colors.black,
        offset: Offset(0.0, 0.0), //(x,y)
        blurRadius: 6.0,
      ),
      ],
        color: choice.Selected==0?Theme.of(context).backgroundColor:Colors.redAccent,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Text(
            choice.description,
            style:TextStyle(fontSize: 24,
            color:choice.Selected==0?Colors.blueAccent:Colors.black,
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
  String DescriptionText;
  TextEditingController txt =new TextEditingController();
  final validate = ValidationBuilder().minLength(1, 'Length < 1 😟').maxLength(1500).build();

  GlobalKey<FormState> _form = GlobalKey();

  void done(){
    if(_form.currentState.validate()) {
      Provider.of<ChoicesOperation>(context, listen: false)
          .addNewChoice(DescriptionText);
      txt.text="";
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
              blurRadius: 6.0,
            ),
          ],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
      Form(
        key: _form,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            onEditingComplete: (){done();},
            validator: validate,
            controller: txt,
            decoration: InputDecoration(
              errorStyle: TextStyle(
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
              hintStyle:TextStyle(   fontSize: 24,
                  color: Colors.blueAccent
              ),
              labelText: 'Choice',labelStyle:TextStyle(fontSize: 18,
              color: Colors.blueAccent,
            ),

            ),
            style:TextStyle(   fontSize: 24,
                color: Colors.blueAccent
            ),

            onChanged: (value){
              DescriptionText=value;
            },
          ),
        ),
      ),

          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              onPressed: (){
                done();},
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Text('Add Choice',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),),
            ),
          )

        ],
      ),
    );
  }
}
