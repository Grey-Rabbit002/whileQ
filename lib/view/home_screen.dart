import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:while_app/view/create_screen.dart';
import 'package:while_app/view/feed_screen.dart';
import 'package:while_app/view/profile/user_profile_screen.dart';
import 'package:while_app/view/reels_screen.dart';
import 'package:while_app/view/social/social_home_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const FeedScreen(),
    const CreateScreen(),
    const ReelsScreen(),
    const SocialScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //clipBehavior: Clip.antiAlias,
        height: 50,
        //shape: const AutomaticNotchedShape(BeveledRectangleBorder()),
        color: Colors.black,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () {
                _onTabTapped(0);
              },
              icon: Icon(
                _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _onTabTapped(1);
              },
              icon: Icon(
                _currentIndex == 1
                    ? Icons.add_circle
                    : Icons.add_circle_outline_sharp,
                size: 30,
                color: Colors.white,
              ),
            ),
            IconButton(
<<<<<<< HEAD
                iconSize: 100,
                onPressed: () {
                  _onTabTapped(2);
                },
                icon: Image.asset(
                  'assets/while.png',
                  fit: BoxFit.cover,
=======
                // iconSize: 25,
                onPressed: () {
                  _onTabTapped(2);
                },
                icon: const Icon(
                  CupertinoIcons.infinite,
                  size: 30,
                  color: Colors.white,
>>>>>>> 31e385512f9d2a432b353d6455bd33fdfda0b9ca
                )),
            IconButton(
              onPressed: () {
                _onTabTapped(3);
              },
              icon: Icon(
                _currentIndex == 3
                    ? CupertinoIcons.text_bubble_fill
                    : CupertinoIcons.text_bubble,
                size: 30,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _onTabTapped(4);
              },
              icon: Icon(
                _currentIndex == 4
                    ? Icons.account_circle
                    : Icons.account_circle_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
