import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hands_on_layouts/favor.dart';
import 'package:hands_on_layouts/friend.dart';
import 'package:hands_on_layouts/mock_values.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


import 'dart:developer';
import 'package:pretty_json/pretty_json.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      // home: RequestFavorPage( // uncomment this and comment 'home' below to change the visible page for now
      //   friends: mockFriends,
      // ),
      home: FavorsPage(),
    );
  }
}

class FavorsPage extends StatefulWidget {
  const FavorsPage({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => FavorsPageState();
}

class FavorsPageState extends State<FavorsPage> {
  // using mock values from mock_favors dart file for now
  late final List<Favor>? pendingAnswerFavors;
  late final List<Favor>? acceptedFavors;
  late final List<Favor>? completedFavors;
  late final List<Favor>? refusedFavors;

  @override
  void initState() {
    super.initState();
    pendingAnswerFavors = [];
    acceptedFavors = [];
    completedFavors = [];
    refusedFavors = [];
    loadFavors();
  }

  void loadFavors() {
    pendingAnswerFavors!.addAll(mockPendingFavors);
    acceptedFavors!.addAll(mockDoingFavors);
    completedFavors!.addAll(mockCompletedFavors);
    refusedFavors!.addAll(mockRefusedFavors);
  }

  static FavorsPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<FavorsPageState>();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your favors"),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              _buildCategoryTab("Requests"),
              _buildCategoryTab("Doing"),
              _buildCategoryTab("Completed"),
              _buildCategoryTab("Refused"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FavorsList(title: "Pending Requests", favors: pendingAnswerFavors!),
            FavorsList(title: "Doing", favors: acceptedFavors!),
            FavorsList(title: "Completed", favors: completedFavors!),
            FavorsList(title: "Refused", favors: refusedFavors!),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestFavorPage(
                  friends: mockFriends,
                ),
              ),
            );
          },
          tooltip: 'Ask a favor',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String title) {
    return Tab(
      child: Text(title),
    );
  }

  void refuseToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors!.remove(favor);

      refusedFavors!.add(favor.copyWith(accepted: false));
    });
  }

  void acceptToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors!.remove(favor);

      acceptedFavors!.add(favor.copyWith(accepted: true));
    });
  }

  void giveUp(Favor favor) {
    setState(() {
      acceptedFavors!.remove(favor);

      refusedFavors!.add(favor.copyWith(
        accepted: false,
      ));
    });
  }

  void complete(Favor favor) {
    setState(() {
      acceptedFavors!.remove(favor);

      completedFavors!.add(favor.copyWith(
        completed: DateTime.now(),
      ));
    });
  }
}

class FavorsList extends StatelessWidget {
  final String title;
  final List<Favor> favors;

  const FavorsList({Key? key, required this.title, required this.favors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          child: Text(title),
          padding: const EdgeInsets.only(top: 16.0),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: favors.length,
            itemBuilder: (BuildContext context, int index) {
              final favor = favors[index];
              return FavorCardItem(favor: favor);
            },
          ),
        ),
      ],
    );
  }
}

class FavorCardItem extends StatelessWidget {
  final Favor favor;

  const FavorCardItem({Key? key, required this.favor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(favor.uuid),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Padding(
        child: Column(
          children: <Widget>[
            _itemHeader(favor),
            Text(favor.description),
            _itemFooter(context, favor)
          ],
        ),
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }

  Widget _itemFooter(BuildContext context, Favor favor) {
    if (favor.isCompleted) {
      final format = DateFormat();
      return Container(
        margin: const EdgeInsets.only(top: 8.0),
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Completed at: ${format.format(favor.completed)}"),
        ),
      );
    }
    if (favor.isRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            child: const Text("Refuse"),
            onPressed: () {
              FavorsPageState.of(context)!.refuseToDo(favor);
            },
          ),
          TextButton(
            child: const Text("Do"),
            onPressed: () {
              FavorsPageState.of(context)!.acceptToDo(favor);
            },
          )
        ],
      );
    }
    if (favor.isDoing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            child: const Text("give up"),
            onPressed: () {},
          ),
          TextButton(
            child: const Text("complete"),
            onPressed: () {},
          )
        ],
      );
    }

    return Container();
  }

  Widget _itemHeader(Favor favor) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(
            favor.friend.photoURL,
          ),
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("${favor.friend.name} asked you to... ")),
        )
      ],
    );
  }
}

class RequestFavorPage extends StatefulWidget {
  final List<Friend> friends;

  const RequestFavorPage({Key? key, required this.friends}) : super(key: key);

  @override
  RequestFavorPageState createState() {
    return RequestFavorPageState();
  }
}

class RequestFavorPageState extends State<RequestFavorPage> {
  final _formKey = GlobalKey<FormState>();
  late Friend _selectedFriend;

  static RequestFavorPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<RequestFavorPageState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requesting a favor"),
        leading: const CloseButton(),
        actions: <Widget>[
          Builder(
            builder: (context) => TextButton(
              child: const Text("SAVE", style: TextStyle(color: Colors.white)),
              onPressed: () {
                RequestFavorPageState.of(context)!.save();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<Friend>(
                value: _selectedFriend,
                onChanged: (friend) {
                  setState(() {
                    _selectedFriend = friend!;
                  });
                },
                items: widget.friends
                    .map(
                      (f) => DropdownMenuItem<Friend>(
                        value: f,
                        child: Text(f.name),
                      ),
                    )
                    .toList(),
                validator: (friend) {
                  if (friend == null) {
                    return "You must select a friend to ask the favor";
                  }
                  return null;
                },
              ),
              Container(
                height: 16.0,
              ),
              const Text("Favor description:"),
              TextFormField(
                maxLines: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validator: (value) {
                  if (value!.isEmpty) {
                    return "You must detail the favor";
                  }
                  return null;
                },
              ),
              Container(
                height: 16.0,
              ),
              const Text("Due Date:"),
              DateTimeField(
                format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                enabled: false,
                decoration: const InputDecoration(
                    labelText: 'Date/Time',
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (dateTime) {
                  if (dateTime == null) {
                    return "You must select a due date time for the favor";
                  }
                  return null;
                },
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void save() {
    if (_formKey.currentState!.validate()) {
      // store the favor request on firebase
      Navigator.pop(context);
    }
  }
}
