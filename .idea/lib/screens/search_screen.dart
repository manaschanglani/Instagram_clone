import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: mobileBackgroundColor,
        //   title: TextFormField(
        //     controller: _searchController,
        //     decoration: InputDecoration(
        //       labelText: 'Search for a user',
        //     ),
        //     onFieldSubmitted: (String _) {
        //       setState(() {
        //         isShowUsers = true;
        //       });
        //     },
        //   ),
        // ),
        body: SafeArea(
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(children: [
          SizedBox(
            width: 5,
          ),
          Icon(Icons.search),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              padding: EdgeInsets.only(
                bottom: 16,
                top: 5,
              ),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for a user',
                ),
                onSubmitted: (String _) {
                  setState(() {
                    isShowUsers = true;
                  });
                },
              ),
            ),
          ),
        ]),
        SizedBox(
          height: 10,
        ),
        isShowUsers
            ? Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('username',
                          isGreaterThanOrEqualTo: _searchController.text)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
              
                    return ListView.builder(
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                        uid: (snapshot.data! as dynamic)
                                            .docs[index]['uid']))),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    (snapshot.data! as dynamic).docs[index]
                                        ['photoUrl']),
                              ),
                              title: Text((snapshot.data! as dynamic).docs[index]
                                  ['username']),
                            ),
                          );
                        });
                  },
                ),
            )
            : FutureBuilder(
                future: FirebaseFirestore.instance.collection('posts').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return Container(
                          height: 50,
                          child: Image(
                            image: NetworkImage(snap['postUrl']),
                            fit: BoxFit.cover,
                          ),
                        );
                      });

                  // return StaggeredGrid.count(
                  //   crossAxisCount: 5,
                  //   mainAxisSpacing: 2,
                  //   crossAxisSpacing: 2,
                  //   children: [
                  //     StaggeredGridTile.count(
                  //       crossAxisCellCount: 2,
                  //       mainAxisCellCount: 2,
                  //       child: Image.network(
                  //           (snapshot.data! as dynamic).docs[0]['postUrl']),
                  //     ),
                  //     StaggeredGridTile.count(
                  //       crossAxisCellCount: 2,
                  //       mainAxisCellCount: 1,
                  //       child: Image.network(
                  //           (snapshot.data! as dynamic).docs[1]['postUrl']),
                  //     ),
                  //   ],
                  // );
                },
              ),
      ]),
    ));
  }
}
