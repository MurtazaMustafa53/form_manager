import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_manager/Controller/local_storage_controller.dart';
import 'package:form_manager/Controller/provider_controller.dart';
import 'package:form_manager/Views/dashboard_view.dart';
import 'package:form_manager/Views/login_view.dart';
import 'package:form_manager/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalStorageController.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // if (provider.isAuthLoading) {
        //   return const MaterialApp(
        //     home: Scaffold(body: Center(child: CircularProgressIndicator())),
        //   );
        // }
        return MaterialApp(
          title: 'IBM SOLAR SURVEY',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: provider.isLoggedIn ? DashboardView() : LoginView(),
        );
      },
    );
  }
}
