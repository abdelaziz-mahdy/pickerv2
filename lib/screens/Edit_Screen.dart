import 'package:flutter/material.dart';
import 'package:pickerv2/models/Choice.dart';
import 'package:pickerv2/models/Choicesoperation.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';

class EditScreen extends StatelessWidget {
  final Choice choice;
  final int index;
  EditScreen(this.choice, this.index);

  @override
  Widget build(BuildContext context) {
    TextEditingController Description = TextEditingController();
    Description.text = choice.description;
    final FocusScopeNode _node = FocusScopeNode();
    final validate = ValidationBuilder()
        .minLength(1, 'Length < 1 😟')
        .maxLength(1500)
        .build();
    GlobalKey<FormState> _form = GlobalKey();
    void done() {
      if (_form.currentState!.validate()) {
        Provider.of<ChoicesOperation>(context, listen: false)
            .EditChoice(Description.text, index);

        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("EditChoice"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _form,
          child: FocusScope(
            node: _node,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      done();
                    },
                    validator: validate,
                    controller: Description,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: 18,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 5.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 5.0),
                      ),
                      border: InputBorder.none,
                      hintText: 'Enter Choice',
                      hintStyle: TextStyle(fontSize: 24, ),
                      labelText: 'Choice',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        
                      ),
                    ),
                    style: TextStyle(fontSize: 24, ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        done();
                      },
                      child: Text(
                        'Save Choice',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<ChoicesOperation>(context, listen: false)
                            .deleteChoice(choice.description);

                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete Choice',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
