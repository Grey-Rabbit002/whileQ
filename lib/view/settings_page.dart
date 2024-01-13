import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:while_app/resources/components/text_button.dart';

import '../repository/firebase_repository.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const ListTile(
                      leading: Icon(Icons.people_outline),
                      title: Text("Follow and invite friends")),
                  const ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text("Notifications")),
                  const ListTile(
                      leading: Icon(Icons.lock), title: Text("Privacy")),
                  const ListTile(
                      leading: Icon(Icons.people), title: Text("Supervision")),
                  const ListTile(
                      leading: Icon(Icons.security), title: Text("Security")),
                  const ListTile(
                      leading: Icon(Icons.play_arrow),
                      title: Text("Suggested Content")),
                  const ListTile(
                      leading: Icon(Icons.announcement),
                      title: Text("Announcement")),
                  const ListTile(
                      leading: Icon(Icons.account_box), title: Text("Account")),
                  const ListTile(
                      leading: Icon(Icons.help), title: Text("Help")),
                  const ListTile(
                    leading: Icon(Icons.sunny_snowing),
                    title: Text("Theme"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Textbutton(
                          ontap: () {
                            context
                                .read<FirebaseAuthMethods>()
                                .signout(context);


                            Navigator.of(context).pop();
                          },
                          text: "Logout"))
                ],
              ),
            )
          ]),
        ));
  }
}
