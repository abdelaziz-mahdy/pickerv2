import 'package:flutter/material.dart';
import 'package:pickerv2/models/choice.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';

class EditScreen extends StatelessWidget {
  final Choice choice;
  final int index;
  const EditScreen(this.choice, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController Description = TextEditingController();
    Description.text = choice.description;
    final FocusScopeNode node = FocusScopeNode();
    final validate = ValidationBuilder()
        .minLength(1, 'Length < 1 😟')
        .maxLength(1500)
        .build();
    GlobalKey<FormState> form = GlobalKey();
    void done() {
      if (form.currentState!.validate()) {
        Provider.of<ChoicesOperation>(context, listen: false)
            .EditChoice(Description.text, index);

        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("EditChoice"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: form,
          child: FocusScope(
            node: node,
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
                    decoration: const InputDecoration(
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
                      hintStyle: TextStyle(
                        fontSize: 24,
                      ),
                      labelText: 'Choice',
                      labelStyle: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        done();
                      },
                      child: const Text(
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
                      child: const Text(
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
