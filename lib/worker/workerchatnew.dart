import 'package:amaliya/helper/chat.dart';
import 'package:amaliya/helper/const.dart';
import 'package:amaliya/helper/searchService.dart';
import 'package:amaliya/worker/model/users.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:amaliya/worker/workermessage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerChat extends StatefulWidget {
  @override
  State createState() => WorkerChatState();
}

class WorkerChatState extends State<WorkerChat>
    with SingleTickerProviderStateMixin {
  WorkerChatState({Key key, @required this.currentUserId});
  TabController _tabController;
  var queryResultSet = [];
  var tempSearchStore = [];
  Stream<QuerySnapshot> chatStream;
  Stream<QuerySnapshot> userStream;
  String currentUserId;
  bool isLoading = false;
  String groupChatId = '';
  final _contollerTextEditing = TextEditingController();
  List<Users> _users = [];
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    Future.delayed(const Duration(seconds: 1), () {
      fetchData();
    });
    getCurrent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //test fetching data
  Future<void> fetchData() async {
    final result = await Firestore.instance.collection('users').getDocuments();

    List<Users> users = [];
    result.documents.forEach((doc) async {
      Users user = new Users();
      String id = doc.data['uid'];

      if (id.hashCode <= currentUserId.hashCode) {
        groupChatId = '$id-$currentUserId';
        print('lempar 1 : $id');
        await setList(groupChatId, doc);
      } else {
        print('lempar 2 : $id');
        groupChatId = '$currentUserId-$id';
        await setList(groupChatId, doc);
      }
    });
  }

  Future<void> setList(String groupid, var doc) async {
    Users user = new Users();
    user.email = doc.data['email'];
    user.imageUrl = doc.data['imageUrl'];
    final m = await Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .getDocuments();

    if (m.documents.length > 0) {
      print('ada : $groupChatId');
      if (m.documents.first.data['idTo'] == currentUserId) {
        user.uid = m.documents.first.data['idFrom'];
      } else {
        user.uid = m.documents.first.data['idTo'];
      }

      setState(() {
        _users.add(user);
      });
    }
  }

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toLowerCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByEmail(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['email'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  getCurrent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = preferences.getString("uuid");
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;
    final double itemWidth = size.width / 2;

    return new Scaffold(
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            child: TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 45),
              indicatorColor: Colors.grey,
              unselectedLabelColor: Colors.white,
              labelColor: Colors.grey,
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.person),
                  text: "Pencarian Kontak",
                ),
                Tab(
                  icon: Icon(Icons.message),
                  text: "Manajemen Pesan",
                )
              ],
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                  Color.fromRGBO(0, 4, 40, 1),
                  Color.fromRGBO(0, 78, 146, 1),
                ])),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            ListView(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) {
                    initiateSearch(val);
                  },
                  decoration: InputDecoration(
                      
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.white,),
                        iconSize: 20.0,
                      ),
                      contentPadding: EdgeInsets.only(left: 25.0),
                      hintText: 'Pencarian Berdasarkan Email',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(4.0))),
                ),
              ),
              SizedBox(height: 10.0),
              GridView.count(
                  padding: EdgeInsets.only(left: 2.0, right: 10.0),
                  crossAxisCount: 2,
                  childAspectRatio: (itemWidth / itemHeight),
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  primary: false,
                  shrinkWrap: true,
                  children: tempSearchStore.map((element) {
                    return buildResultCard(element);
                  }).toList())
            ]),
            buildMessage()
          ],
        ));
  }

  Widget buildMessage() {
    return Container(
        child: ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, i) {
        return Container(
          child: FlatButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: imgPP != null
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: Image.asset(
                                'assets/images/default-profile.jpg'),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                          imageUrl: _users[i].imageUrl,
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: greyColor,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Email: ${_users[i].email}',
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20.0),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            peerId: _users[i].uid,
                            peerAvatar: _users[i].imageUrl,
                          )));
            },
            color: greyColor2,
            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        );
      },
    ));
  }

  Widget buildResultCard(data) {
    if (data['uid'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Column(
            children: <Widget>[
              Material(
                child: imgPP != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child:
                              Image.asset('assets/images/default-profile.jpg'),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: data['imageUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          data['email'],
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        //margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 2.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          peerId: data['uid'],
                          peerAvatar: data['imageUrl'],
                        )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Material(
              child: imgPP != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: Image.asset('assets/images/default-profile.jpg'),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      ),
                      imageUrl: document['imageUrl'],
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.account_circle,
                      size: 50.0,
                      color: greyColor,
                    ),
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Email: ${document['email']}',
                        style: TextStyle(color: primaryColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        peerId: document.documentID,
                        peerAvatar: document['imageUrl'],
                      )));
        },
        color: greyColor2,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
