import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:while_app/resources/components/message/apis.dart';
import 'package:while_app/view/profile/user_profile_follower_screen.dart';
import 'package:while_app/view/profile/user_profile_following_screen.dart';
import '../../main.dart';
import '../../resources/components/bottom_options_sheet.dart';

class ProfileDataWidget extends StatefulWidget {
  const ProfileDataWidget({super.key});
  @override
  State<ProfileDataWidget> createState() => _ProfileDataWidgetState();
}

class _ProfileDataWidgetState extends State<ProfileDataWidget> {
  String? _image;
  Future<void>? _dataFetching;

  @override
  void initState() {
    _dataFetching = getData();
    super.initState();
  }

  Future<void> getData() async {
    // print("getting info");
    await APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    // print(APIs.me.about);
    var nh = MediaQuery.of(context).viewPadding.top;
    return FutureBuilder(
        future: _dataFetching,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    height: mq.height / 3,
                  ),
                  Positioned(
                    top: nh,
                    child: InkWell(
                        child: ClipRRect(
                      // borderRadius: BorderRadius.circular(mq.height * .13),
                      child: CachedNetworkImage(
                        width: mq.height,
                        fit: BoxFit.cover,
                        height: mq.height * .13,
                        imageUrl: APIs.me.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    )),
                  ),
                  Positioned(
                    top: nh + mq.height / 7 - mq.width / 8,
                    left: mq.width / 12,
                    //profile picture
                    child: _image != null
                        ?
                        //local image
                        ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(File(_image!),
                                width: mq.height * .1,
                                height: mq.height * .1,
                                fit: BoxFit.cover))
                        :
                        //image from server
                        ClipRRect(
                            borderRadius:
                                BorderRadius.circular(mq.height * .75),
                            child: CachedNetworkImage(
                              width: mq.height * .15,
                              height: mq.height * .15,
                              filterQuality: FilterQuality.low,
                              fit: BoxFit.fill,
                              imageUrl: APIs.me.image,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                      child: Icon(CupertinoIcons.person)),
                            ),
                          ),
                  ),
                  Positioned(
                      top: nh + mq.height / 7.5,
                      left: mq.width / 2.25,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => (UserProfileFollowerScreen(
                                        chatUser: APIs.me,
                                      ))));
                        },
                        child: Text(
                          'Followers  ${APIs.me.follower}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  Positioned(
                      top: nh + mq.height / 6,
                      left: mq.width / 2.25,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => (UserProfileFollowingScreen(
                                        chatUser: APIs.me,
                                      ))));
                        },
                        child: Text(
                          'Following  ${APIs.me.following}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  Positioned(
                      top: nh + mq.height / 7.5,
                      left: mq.width / 1.15,
                      child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return const MoreOptions();
                                });
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ))),
                  Positioned(
                    top: nh + mq.height / 6 + mq.width / 8,
                    child: Container(
                      width: mq.width / 1.1,
                      padding: const EdgeInsets.only(
                        left: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //name
                          Text(
                            APIs.me.name,
                            softWrap: true,
                            maxLines: 2,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(APIs.me.about,
                              softWrap: true,
                              maxLines: 4,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          else {
          // Data is still being fetched, you can show a loading indicator
          return const Center(child: CircularProgressIndicator());
        }
        });
  }
}
