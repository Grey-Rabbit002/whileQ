import 'package:flutter/material.dart';
import 'package:while_app/view/profile/creator_profile_widget.dart';
import 'package:while_app/view/profile/profile_data_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // print(APIs.me.email);
    const tabBarIcons = [
      Tab(
        icon: Icon(
          Icons.photo_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.person,
          color: Colors.white,
          size: 30,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.brush,
          color: Colors.white,
          size: 30,
        ),
      ),
    ];

    return //SafeArea(child:
        Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(
                    const [ProfileDataWidget()],
                  ),
                ),
              ];
            },
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Material(
                  color: Colors.black,
                  child: TabBar(
                    padding: EdgeInsets.all(0),
                    indicatorColor: Colors.white,
                    tabs: tabBarIcons,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Center(child: FirebaseImageScreen()),
                      const Center(
                          child: Text(
                        "Become a Mentor",
                        style: TextStyle(color: Colors.white),
                      )),
                      const Center(
                          child: Text(
                        "Become a Freelancer",
                        style: TextStyle(color: Colors.white),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
