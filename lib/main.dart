import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (const Text('lista zakupów')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseFirestore.instance.collection('categories').add(
            {
              'title': controller.text,
            },
          );
          controller.clear();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('categories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Wystąpił nieoczekiwany problem');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Proszę czekać, trwa ładowanie danych');
            }

            final documents = snapshot.data!.docs;

            return ListView(
              children: [
                for (final document in documents) ...[
                  Dismissible(
                    key: ValueKey(document.id),
                    onDismissed: (_) {
                      FirebaseFirestore.instance
                          .collection('categories')
                          .doc(document.id)
                          .delete();
                    },
                    child: CategoryWidget(
                      document['title'],
                    ),
                  ),
                ],
                TextField(
                  controller: controller,
                ),
              ],
            );
          }),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.all(10),
      child: Text(title),
    );
  }
}
