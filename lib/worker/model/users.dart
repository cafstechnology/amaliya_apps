class Users {
  String uid;
  String pushToken;
  String imageUrl;
  String email;
  String chattingWith;
  
  Users({
    this.uid,
    this.pushToken,
    this.imageUrl,
    this.email,
    this.chattingWith,
  });

  Users.map(dynamic obj) {
    this.uid = obj["uid"];
    this.pushToken = obj["pushToken"];
    this.imageUrl = obj["imageUrl"];
    this.email = obj["email"];
    this.chattingWith = obj["chattingWith"];
  }
}