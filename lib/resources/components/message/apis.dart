import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
// import 'package:while_app/data/model/message.dart';
import 'package:while_app/resources/components/message/models/chat_user.dart';
import 'package:while_app/resources/components/message/models/classroom_user.dart';
import 'models/community_message.dart';
import 'models/community_user.dart';
import 'models/message.dart';

String userImage = '';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static ChatUser me = ChatUser(
    id: user.uid,
    name: user.displayName.toString(),
    email: user.email.toString(),
    about: "Hey, I'm using While",
    image: userImage,
    createdAt: '',
    isOnline: false,
    lastActive: '',
    pushToken: '',
    dateOfBirth: '',
    gender: '',
    phoneNumber: '',
    place: '',
    profession: '',
    designation: 'Member',
    follower: 0,
    following: 0,
  );

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        // log('Push Token: $t');
        // print('Push Token: $t');
      }
    });

    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAsNkZIGs:APA91bGeaCnMuqtGmil4H3ZKYVQ_9aaWIZlqd1hvrBzJlaKIUYl-w2XCycnvx8l5Iis61lezhZzdjphO4kYG0ahxTZUiz0fMdcaiKyZ3SjQxlt_y57i4sc3npUM4jjgoA7kUSawYYTDt'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUserdailog(String id) async {
    final data =
        await firestore.collection('users').where('email', isEqualTo: id).get();
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(data.docs.first.id)
        .set({'timeStamp': FieldValue.serverTimestamp()});
    following(data.docs.first.id);
    follower(data.docs.first.id);
    return true;
  }

  static Future<bool> addChatUser(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(id)
        .set({'timeStamp': FieldValue.serverTimestamp()});
    following(id);
    follower(id);
    //  firestore
    //   .collection('users')
    //   .doc(id)
    //   .collection('following')
    //   .doc(user.uid)
    //   .set({})
    //   .then((value) => firestore
    //       .collection('users')
    //       .doc(user.uid)
    //       .update({'followers': APIs.me.following + 1}))
    //   .then((value) => APIs.getSelfInfo());

    return true;
  }

  static Future<bool> following(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(id)
        .set({})
        .then((value) => firestore
            .collection('users')
            .doc(user.uid)
            .update({'following': APIs.me.following + 1}))
        .then((value) => APIs.getSelfInfo());
    // firestore
    //     .collection('users')
    //     .doc(id)
    //     .update({'follower': APIs.me.follower + 1});
    return true;
  }

  static Future<bool> follower(String id) async {
    firestore
        .collection('users')
        .doc(id)
        .collection('follower')
        .doc(user.uid)
        .set({});
    await firestore.collection('users').doc(id).get().then((user) async {
      if (user.exists) {
        final data = ChatUser.fromJson(user.data()!);
        firestore
            .collection('users')
            .doc(id)
            .update({'follower': data.follower + 1});
        // log('My Data: ${user.data()}');
      }
    });

    return true;
  }

  static Future<bool> addUserToCommunity(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_communities')
        .doc(id)
        .set({
      'id': id,
    });
    firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .doc(user.uid)
        .set(me.toJson());
    return true;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user through new method
  static Future<void> createNewUser(ChatUser newUser) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: newUser.name.toString(),
      email: newUser.email.toString(),
      about: newUser.about,
      image:
          'https://firebasestorage.googleapis.com/v0/b/while-2.appspot.com/o/profile_pictures%2FKIHEXrUQrzcWT7aw15E2ho6BNhc2.jpg?alt=media&token=1316edc6-b215-4655-ae0d-20df15555e34',
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
      dateOfBirth: '',
      gender: '',
      phoneNumber: '',
      place: '',
      profession: '',
      designation: 'Member',
      follower: 0,
      following: 0,
    );
    log(' users given id is ///// : ${newUser.name}');
    await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
      dateOfBirth: '',
      gender: '',
      phoneNumber: '',
      place: '',
      designation: 'Member',
      profession: '',
      follower: 0,
      following: 0,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .orderBy(
          'timeStamp',
          descending: true,
        )
        .snapshots();
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsUsersId(
      ChatUser users) {
    return firestore
        .collection('users')
        .doc(users.id)
        .collection('following')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    print('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCommunities(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('communities')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for updating user information
  static Future<void> updateUserInfo(ChatUser usersDetail) async {
    await firestore.collection('users').doc(user.uid).update({
      'name': usersDetail.name,
      'about': usersDetail.about,
      'email': usersDetail.email,
      'gender': usersDetail.gender,
      'place': usersDetail.place,
      'phoneNumber': usersDetail.phoneNumber,
      'profession': usersDetail.profession,
      'dateOfBirth': usersDetail.dateOfBirth,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    //updating image in firestore database
    userImage = await ref.getDownloadURL();
    me.image = userImage;

    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': userImage});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getSelfData() {
    return firestore
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(chatUser.id)
        .update({'timeStamp': FieldValue.serverTimestamp()});
    firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .update({'timeStamp': FieldValue.serverTimestamp()});
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  //communities chat messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> communityChatMessages(
      String id) {
    return FirebaseFirestore.instance
        .collection('communities')
        .doc(id)
        .collection('chat')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  //communities add chat messages
  static communityAddMessage(String id, String enteredMessage) async {
    final userData = await firestore.collection('users').doc(user.uid).get();
    firestore.collection('communities').doc(id).collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['name'],
      'userImage': userData.data()!['image'],
    });
  }

  // for getting id's of joined community from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCommunityId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_communities')
        .snapshots();
  }

  // get only last message of a specific communtiy
  static getLastMessageCommunity(String id) async {
    var data = await FirebaseFirestore.instance
        .collection('communities')
        .doc(id)
        .collection('chat')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(1)
        .get();

    await FirebaseFirestore.instance
        .collection('communities')
        .doc(id)
        .update({'lastMessage': data.docs[0].get('text')});
  }

  //getting information of community
  static getCommunityDetail(String id) {
    return FirebaseFirestore.instance.collection('communities').doc(id).get();
  }

  // for getting all user communities from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserCommunities(
      List<String> communityIds) {
    log('\nCommunityIds: $communityIds');

    return firestore
        .collection('communities')
        .where('id',
            whereIn: communityIds.isEmpty
                ? ['']
                : communityIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //get only last message of a specific community chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastCommunityMessage(
      CommunityUser user) {
    return firestore
        .collection('communities')
        .doc(user.id)
        .collection('chat')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for getting all messages of a specific conversation of community from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCommunityMessages(
      CommunityUser user) {
    return firestore
        .collection('communities')
        .doc(user.id)
        .collection('chat')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendCommunityMessage(
      CommunityUser chatUser, String msg, Types type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final CommunityMessage message = CommunityMessage(
      toId: chatUser.id,
      msg: msg,
      read: '',
      types: type,
      fromId: user.uid,
      sent: time,
      senderName: me.name,
    );
    log(me.name);

    final ref =
        firestore.collection('communities').doc(chatUser.id).collection('chat');
    await ref.doc(time).set(message.toJson()).then((value) {
      try {
        log(message.toJson().toString());
      } catch (error) {
        log(error.toString());
      }
    });
  }

  ///////////////
  static Future<void> addCommunities(CommunityUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    chatUser.image = imageUrl;
    final refe = FirebaseFirestore.instance.collection('communities');
    await refe.doc(chatUser.id).set(chatUser.toJson()).then((value) {
      addUserToCommunity(chatUser.id);
    });
  }

  static Future<void> communitySendChatImage(
      CommunityUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendCommunityMessage(chatUser, imageUrl, Types.image);
  }

  // update profile picture of community
  static Future<void> updateProfilePictureCommunity(
      File file, String id) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/$id.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    var image = await ref.getDownloadURL();
    await firestore.collection('communities').doc(id).update({'image': image});
  }

  ///// update community info
  static Future<void> updateCommunityInfo(CommunityUser community) async {
    await firestore.collection('communities').doc(community.id).update({
      'name': community.name,
      'about': community.about,
      'email': community.email,
      'domain': community.domain,
    });
  }

  //comunity participants info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCommunityInfo(
      CommunityUser community) {
    return firestore
        .collection('communities')
        .where('id', isEqualTo: community.id)
        .snapshots();
  }

  //comunity participants info
  static getCommunityInfos(CommunityUser community) async {
    // ignore: unused_local_variable
    CommunityUser ds;
    firestore
        .collection('communities')
        .doc(community.id)
        .snapshots()
        .map((event) {
      return ds = CommunityUser(
          image: event.data()!['image'],
          about: event.data()!['about'],
          name: event.data()!['name'],
          createdAt: event.data()!['createdAt'],
          id: event.data()!['id'],
          email: event.data()!['email'],
          type: event.data()!['type'],
          noOfUsers: event.data()!['noOfUsers'],
          domain: event.data()!['domain'],
          timeStamp: event.data()!['timeStamp'],
          admin: event.data()!['admin']);
    });
  }

  //comunity participants info
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      getCommunityParticipantsInfo(String id) {
    return firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .snapshots();
  }

  ////////////// classroom
  static Future<void> addClassroom(Class chatUser) async {
    final refe = FirebaseFirestore.instance.collection('classroom');
    await refe.doc(chatUser.id).set(chatUser.toJson()).then((value) {
      addUserToClassroom(chatUser.id);
      log('sa');
    });
  }

  // for getting id's of joined classroom from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getClassroomId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_class')
        .snapshots();
  }

  static Future<bool> addUserToClassroom(String id) async {
    firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_class')
        .doc(id)
        .set({
      'id': id,
    });
    firestore
        .collection('classroom')
        .doc(id)
        .collection('participants')
        .doc(user.uid)
        .set(me.toJson());
    // firestore
    //     .collection('communities')
    //     .doc(id)
    //     .collection('participants')
    //     .doc(user.uid)
    //     .update({'designation': 'user'});
    return true;
  }

  // for getting all user communities from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserClass(
      List<String> communityIds) {
    log('\nCommunityIds: $communityIds');

    return firestore
        .collection('classroom')
        .where('id',
            whereIn: communityIds.isEmpty
                ? ['']
                : communityIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for getting all messages of a specific conversation of class from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllClassMessages(
      Class clas) {
    return firestore
        .collection('classroom')
        .doc(clas.id)
        .collection('chat')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //class participants info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getClassParticipantsInfo(
      String id) {
    return firestore
        .collection('communities')
        .doc(id)
        .collection('participants')
        .snapshots();
  }

  ///// update class info
  static Future<void> updateClassInfo(Class clas) async {
    await firestore.collection('classroom').doc(clas.id).update({
      'name': clas.name,
      'about': clas.about,
      'email': clas.email,
      'domain': clas.about,
    });
  }
}
