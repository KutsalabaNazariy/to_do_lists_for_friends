import 'package:flutter/material.dart';
import 'package:hands_on_layouts/favor.dart';
import 'package:hands_on_layouts/friend.dart';
import 'package:hands_on_layouts/mock_values.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // home: RequestFavorPage( // uncomment this and comment 'home' below to change the visible page for now
      //   friends: mockFriends,
      // ),
      home: FavorsPage(
        pendingAnswerFavors: mockPendingFavors,
        completedFavors: mockCompletedFavors,
        refusedFavors: mockRefusedFavors,
        acceptedFavors: mockDoingFavors,
        key: null,
      ),
    );
  }
}

class FavorsPage extends StatelessWidget {
  // using mock values from mock_favors dart file for now
  final List<Favor> pendingAnswerFavors;
  final List<Favor> acceptedFavors;
  final List<Favor> completedFavors;
  final List<Favor> refusedFavors;

  const FavorsPage({
    required Key? key,
    required this.pendingAnswerFavors,
    required this.acceptedFavors,
    required this.completedFavors,
    required this.refusedFavors,
  }) : super(key: key);

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
            _favorsList("Pending Requests", pendingAnswerFavors),
            _favorsList("Doing", acceptedFavors),
            _favorsList("Completed", completedFavors),
            _favorsList("Refused", refusedFavors),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
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

  Widget _favorsList(String title, List<Favor> favors) {
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
              return Card(
                key: ValueKey(favor.uuid),
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: Padding(
                  child: Column(
                    children: <Widget>[
                      _itemHeader(favor),
                      Text(favor.description),
                      _itemFooter(favor)
                    ],
                  ),
                  padding: const EdgeInsets.all(8.0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _itemFooter(Favor favor) {
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
            onPressed: () {},
          ),
          TextButton(
            child: const Text("Do"),
            onPressed: () {},
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

  Row _itemHeader(Favor favor) {
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

class RequestFavorPage extends StatelessWidget {
  final List<Friend> friends;

  const RequestFavorPage({required Key key, required this.friends}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requesting a favor"),
        leading: const CloseButton(),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
              child: const Text("SAVE"),
                onPressed: () {}
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Request a favor to:"),
            DropdownButtonFormField(
              items: friends
                  .map(
                    (f) => DropdownMenuItem(
                  child: Text(f.name),
                ),
              ).toList(), onChanged: null,
            ),
            Container(
              height: 16.0,
            ),
            const Text("Favor description:"),
            TextFormField(
              maxLines: 5,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
            ),
            Container(
              height: 16.0,
            ),
            const Text("Due Date:"),
            DateTimeField(
              //inputType: InputType.both,
              format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Date/Time', hintText: 'Hint Text',
                errorText: 'Error Text',
                border: OutlineInputBorder(),
              ),
              onChanged: (dt) {},
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30))
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

