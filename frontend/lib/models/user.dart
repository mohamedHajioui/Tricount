class User{
  final int id;
  final String email;
  final String fullName;
  final String? token;
  
  
  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.token,
});

  factory User.fromJson(Map<String,dynamic> j) => User(
    id:        j['id'] as int,
    email:     j['email'] as String,
    fullName:  j['full_name'] as String,
    token:     j['token'] as String,   
  );




  Map<String, dynamic> toJson() => {
    'id' : id,
    'email' : email,
    'token' : token,
  };


}