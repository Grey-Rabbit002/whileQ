import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:while_app/repository/firebase_repository.dart';
import 'package:while_app/utils/data_provider.dart';
import 'package:while_app/view_model/current_user_provider.dart';
import 'package:while_app/view_model/firebasedata.dart';
import 'package:while_app/view_model/post_provider.dart';
import 'package:while_app/view_model/profile_controller.dart';
import 'package:while_app/view_model/reel_controller.dart';

final providers = <SingleChildWidget>[
  Provider(create: (_) => PostProvider()),
  Provider<FirebaseAuthMethods>(
    create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
  ),
  Provider<ReelController>(create: (_) => ReelController()),
  StreamProvider(
    create: (context) => context.read<FirebaseAuthMethods>().authState,
    initialData: null,
  ),
  ChangeNotifierProvider(create: (_) => ProfileController()),
  Provider(create: (_) => CurrentUserProvider()),
  Provider(create: (_) => FireBaseDataProvider()),
  ChangeNotifierProvider(create: (context) => DataProvider())
];
