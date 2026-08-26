class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.token,
  });

  // LAB ACTIVITY 4 - ENHANCEMENT 3:
  // This model represents the user data returned by the DummyJSON API and
  // supports JSON conversion for profile rendering and persistence.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      token: json['token'] ?? '',
    );
  }

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

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
    };
  }
}
