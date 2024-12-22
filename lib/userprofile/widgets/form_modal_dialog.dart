import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../screens/user_profile_page.dart';

class FormModalDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController dateOfBirthController;
  final String description;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String location;
  final String phoneNumber;
  final String email;
  final bool isFiiled;

  const FormModalDialog({
    super.key,
    required this.formKey,
    required this.dateOfBirthController,
    required this.description,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.phoneNumber,
    required this.email,
    this.isFiiled = true,
  });

  @override
  State<FormModalDialog> createState() => _FormModalDialogState();
}

class _FormModalDialogState extends State<FormModalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateOfBirthController = TextEditingController();
  String _description = "";
  String _firstName = "";
  String _lastName = "";
  DateTime _dateOfBirth = DateTime.now();
  String _gender = "";
  String _location = "";
  String _phoneNumber = "";
  String _email = "";
  bool _isFiiled = true;

  @override
  void initState() {
    super.initState();

    _description = widget.description;
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _dateOfBirth = widget.dateOfBirth;
    _gender = widget.gender;
    _location = widget.location;
    _phoneNumber = widget.phoneNumber;
    _email = widget.email;
    _isFiiled = widget.isFiiled;

    _dateOfBirthController.text = _dateOfBirth.toLocal().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void showCustomDialog(String titleText, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          titleText,
          style: const TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        content: Text(value),
        actions: [
          TextButton(
            style: ButtonStyle(
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
                )
              )
            ),
            child: const Text(
              'OK', 
              style: TextStyle(
                color: Colors.white
                ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 27.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _firstName,
                    onChanged: (String? value) {
                      setState(() {
                        _firstName = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "First name must be filled";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    initialValue: _lastName,
                    onChanged: (String? value) {
                      setState(() {
                        _lastName = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Last name must be filled";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    initialValue: _description,
                    onChanged: (String? value) {
                      setState(() {
                        _description = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Description must be filled";
                      }
                      return null;
                    },
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    controller: _dateOfBirthController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dateOfBirth,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != _dateOfBirth) {
                        setState(() {
                          _dateOfBirth = pickedDate;
                          // Update the controller with the new date
                          _dateOfBirthController.text = _dateOfBirth.toIso8601String().split('T').first;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Birth of Date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  DropdownButtonFormField<String>(
                    value: _gender.isEmpty ? null : _gender, // set the initial value
                    onChanged: (String? newValue) {
                      setState(() {
                        _gender = newValue!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Gender must be filled";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    items: <String>['Female', 'Male', 'Others']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    initialValue: _location,
                    onChanged: (String? value) {
                      setState(() {
                        _location = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Location must be filled";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: _phoneNumber,
                    onChanged: (String? value) {
                      setState(() {
                        _phoneNumber = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number must be filled";
                      }
                      if (int.tryParse(value) == null) {
                      return "Phone number must be integer numbers!";
                    }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    initialValue: _email,
                    onChanged: (String? value) {
                      setState(() {
                        _email = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Email must be filled!";
                      }
                      if (!value.contains('@')) {
                        return "It must be a valid email!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey.shade900, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton( 
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                      print(_dateOfBirthController.text);
                                      final response = await request.postJson(
                                        "https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/userprofile/userprofile/update-external",
                                        jsonEncode(<String, dynamic>{
                                          'description': _description,
                                          'first_name': _firstName,
                                          'last_name': _lastName,
                                          'date_of_birth': "${_dateOfBirth.year.toString().padLeft(4, '0')}-${_dateOfBirth.month.toString().padLeft(2, '0')}-${_dateOfBirth.day.toString().padLeft(2, '0')}", // Format as YYYY-MM-DD,
                                          'gender': _gender,
                                          'location': _location,
                                          'phone_number': _phoneNumber,
                                          'email': _email,
                                        }),
                                      );
                                      if (context.mounted) {
                                          if (response['message'] == 'Profile updated successfully!') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                              content: Text("Profile updated successfully!"),
                                              ));
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfilePage()));
                                          } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                  content:
                                                      Text("Profile updated failed!"),
                                              ));
                                              print(response);
                                          }
                                      }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 40),
                                  backgroundColor: Colors.green.shade500,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)))),
                                child: const Text("Save"),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: ElevatedButton( 
                                onPressed: () {
                                  if (_isFiiled) {
                                    Navigator.pop(context);
                                  }
                                  else {
                                    showCustomDialog("Form harus diisi", "Data profil anda kosong, maka form harus diisi");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 40),
                                  backgroundColor: Colors.red,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  )
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}