import 'package:flutter/material.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String descriptionText = "";
  final FocusScopeNode _node = FocusScopeNode();
  final validate =
      ValidationBuilder().minLength(1, 'Length < 1 😟').maxLength(1500).build();
  final GlobalKey<FormState> _form = GlobalKey();
  void done() {
    if (_form.currentState!.validate()) {
      Provider.of<ChoicesOperation>(context, listen: false)
          .addNewChoice(descriptionText);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("AddChoice"),
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
                    onChanged: (value) {
                      descriptionText = value;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    done();
                  },
                  child: const Text(
                    'Add Choice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
