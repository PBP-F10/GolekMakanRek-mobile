
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../authentication/login.dart';
import '../models/userprofile.dart';
import '../widgets/form_modal_dialog.dart';
import '../widgets/profile_section.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _dateOfBirthController = TextEditingController();
  String _username = "";
  String _description = "";
  String _firstName = "";
  String _lastName = "";
  DateTime _dateOfBirth = DateTime.now();
  String _gender = "";
  String _location = "";
  String _phoneNumber = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current date
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<UserProfile> fetchUserProfile(CookieRequest request) async {
    final response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/userprofile/userprofile/get');

    var data = response;

    // Create UserProfile object with data from the response
    UserProfile newUserProfile = UserProfile(
      profile: Profile(
        username: data['profile']['username'] ?? '',
        description: data['profile']['description'] ?? '',
        firstName: data['profile']['first_name'] ?? '',
        lastName: data['profile']['last_name'] ?? '',
        dateOfBirth: data['profile']['date_of_birth'] != null
          ? DateTime.parse(data['profile']['date_of_birth'])
          : DateTime.now(),
        gender: data['profile']['gender'] ?? '',
        location: data['profile']['location'] ?? '',
        phoneNumber: data['profile']['phone_number'] ?? '',
        email: data['profile']['email'] ?? '',
      ),
      created: data['created'] ?? '',
    );

    // Update your local variables with the profile data
    _username = data['profile']['username'] ?? '';
    _description = data['profile']['description'] ?? '';
    _firstName = data['profile']['first_name'] ?? '';
    _lastName = data['profile']['last_name'] ?? '';
    _dateOfBirth = data['profile']['date_of_birth'] != null
        ? DateTime.parse(data['profile']['date_of_birth'])
        : DateTime.now();
    _gender = data['profile']['gender'] ?? '';
    _location = data['profile']['location'] ?? '';
    _phoneNumber = data['profile']['phone_number'] ?? '';
    _email = data['profile']['email'] ?? '';

     // Check if any profile field is empty and trigger a dialog if so
    bool isProfileIncomplete = data['profile']['username'] == null ||
                              data['profile']['username'] == '' ||
                              data['profile']['first_name'] == null ||
                              data['profile']['first_name'] == '' ||
                              data['profile']['last_name'] == null ||
                              data['profile']['last_name'] == '' ||
                              data['profile']['date_of_birth'] == null ||
                              data['profile']['gender'] == null ||
                              data['profile']['location'] == null ||
                              data['profile']['phone_number'] == null ||
                              data['profile']['email'] == null ||
                              data['profile']['email'] == '';

    if (isProfileIncomplete) {
      // Trigger the dialog to allow the user to complete their profile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill this form"),
      ));
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return FormModalDialog(
            isFiiled: false,
            formKey: _formKey, 
            dateOfBirthController: _dateOfBirthController, 
            description: _description, 
            firstName: _firstName, 
            lastName: _lastName, 
            dateOfBirth: _dateOfBirth, 
            gender: _gender, 
            location: _location, 
            phoneNumber: _phoneNumber, 
            email: _email
          );
        }
      );
    }


    return newUserProfile;
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: FutureBuilder(
        future: fetchUserProfile(request), 
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if ((!snapshot.hasData)) {
              return const Column(
                children: [
                  Text(
                    'Tidak berhasil mendapatkan data',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              UserProfile userProfile = snapshot.data!;
              return buildProfile(userProfile, context, request);
            }
          }
        }
      ),
    );
  }

  ListView buildProfile(
    UserProfile userProfile, BuildContext context, CookieRequest request
  ) {
    return ListView(
      children: [
        Container(
          height: 275,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_web.png'),
              fit: BoxFit.fitWidth
            )
          ),
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        return FormModalDialog(
                          formKey: _formKey, 
                          dateOfBirthController: _dateOfBirthController, 
                          description: _description, 
                          firstName: _firstName, 
                          lastName: _lastName, 
                          dateOfBirth: _dateOfBirth, 
                          gender: _gender, 
                          location: _location, 
                          phoneNumber: _phoneNumber, 
                          email: _email
                        );
                      }
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 20,),
                        SizedBox(width: 5,),
                        Text(
                          "Edit Profile", 
                          style: TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, 120),
                  child: Transform.scale(
                    scale: 0.6,
                    child: Container(
                      width: 80, 
                      height: 80, 
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: Colors.orange.shade800,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/user_avatar.png'),
                          fit: BoxFit.fitHeight, 
                          colorFilter: ColorFilter.mode(
                            Colors.orange, BlendMode.color)
                        ),
                      ),
                    )
                  ),
                ),
              ),
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50,),
              ProfileSection(
                header: "First Name", 
                value: userProfile.profile!.firstName.toString()
              ),
              const SizedBox(height: 10,),
               ProfileSection(
                header: "Last Name", 
                value: userProfile.profile!.lastName.toString()
              ),
              const SizedBox(height: 10,),
               ProfileSection(
                header: "Date of Birth", 
                value: userProfile.profile!.dateOfBirth!.toIso8601String().split('T').first
              ),
              const SizedBox(height: 10,),
               ProfileSection(
                header: "Gender", 
                value: userProfile.profile!.gender.toString()
              ),
              const SizedBox(height: 10,),
               ProfileSection(
                header: "Location", 
                value: userProfile.profile!.location.toString()
              ),
              const SizedBox(height: 10,),
               ProfileSection(
                header: "Phone Number", 
                value: userProfile.profile!.phoneNumber.toString()
              ),
              const SizedBox(height: 10,),
               ProfileSection(
                header: "Email", 
                value: userProfile.profile!.email.toString()
              ),
              
              const SizedBox(height: 50,),
              ElevatedButton(
                onPressed: () async {
                  final response = await request.logout(
                    "http://127.0.0.1:8000/logout-external/");
                    String message = response["message"];
                    if (context.mounted) {
                        if (response['status']) {
                            String uname = response["username"];
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("$message Sampai jumpa, $uname."),
                            ));
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                        } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(message),
                                ),
                            );
                        }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  // minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.orange.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(10)))),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      (Icons.logout),
                      size: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Log Out", style: TextStyle(fontSize: 18))
                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
        ),
      ],
    );
  }
}