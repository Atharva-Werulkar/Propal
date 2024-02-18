import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            size: 30,
          ),
          onPressed: () {},
        ),
        automaticallyImplyLeading: true,
        actions: [
          //profile picture
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFB3AAF2),
              child: IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        color: ThemeData.dark().scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(child: ListView()),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: const Color(0xFFB3AAF2),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: ThemeData.dark().primaryColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(100),
                          )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFD7D1F1),
                    radius: 32,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFB3AAF2),
                      child: IconButton(
                        icon: Icon(Icons.send,
                            size: 30, color: ThemeData.dark().primaryColor),
                        onPressed: () {},
                      ),
                    ),
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
