class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String token;
  final String uid;
  final String loginType;
  final int? age;
  final String contactNo;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.token,
    this.uid = '',
    this.loginType = 'dummyjson',
    this.age,
    this.contactNo = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      username: json['username'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      token: json['token'] ?? '',
      uid: json['uid'] ?? '',
      loginType: json['loginType'] ?? 'dummyjson',
      age: json['age'] is int ? json['age'] as int : null,
      contactNo: json['contactNo'] ?? '',
    );
  }

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? token,
    String? uid,
    String? loginType,
    int? age,
    String? contactNo,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      token: token ?? this.token,
      uid: uid ?? this.uid,
      loginType: loginType ?? this.loginType,
      age: age ?? this.age,
      contactNo: contactNo ?? this.contactNo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'token': token,
      'uid': uid,
      'loginType': loginType,
      'age': age,
      'contactNo': contactNo,
    };
  }
}
