class GymUser {
  final String uid;
  final String email;
  final String? name;
  final int? age;
  final String? fitnessLevel;
  final String? photoUrl;

  GymUser({
    required this.uid,
    required this.email,
    this.name,
    this.age,
    this.fitnessLevel,
    this.photoUrl,
  });

  factory GymUser.fromMap(Map<String, dynamic> map) {
    return GymUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      age: map['age'],
      fitnessLevel: map['fitnessLevel'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'fitnessLevel': fitnessLevel,
      'photoUrl': photoUrl,
    };
  }
}
