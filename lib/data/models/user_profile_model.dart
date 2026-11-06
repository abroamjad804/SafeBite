class UserProfile {
  final String id;
  final String name;
  final String email;
  final int age;
  final String? profileImageBase64;
  final bool isGuest;
  final List<String> allergies;
  final List<String> avoidList;
  final List<String> dietaryNeeds;
  final List<String> nutritionGoals;
  final List<String> dietaryPreferences;
  final Map<String, double>? lipidProfile;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.age = 0,
    this.profileImageBase64,
    this.isGuest = false,
    this.allergies = const [],
    this.avoidList = const [],
    this.dietaryNeeds = const [],
    this.nutritionGoals = const [],
    this.dietaryPreferences = const [],
    this.lipidProfile,
  });

  factory UserProfile.empty() => UserProfile(
        id: '',
        name: '',
        email: '',
      );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? profileImageBase64,
    bool? isGuest,
    List<String>? allergies,
    List<String>? avoidList,
    List<String>? dietaryNeeds,
    List<String>? nutritionGoals,
    List<String>? dietaryPreferences,
    Map<String, double>? lipidProfile,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      isGuest: isGuest ?? this.isGuest,
      allergies: allergies ?? this.allergies,
      avoidList: avoidList ?? this.avoidList,
      dietaryNeeds: dietaryNeeds ?? this.dietaryNeeds,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      lipidProfile: lipidProfile ?? this.lipidProfile,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
        'profileImageBase64': profileImageBase64,
        'isGuest': isGuest,
        'allergies': allergies,
        'avoidList': avoidList,
        'dietaryNeeds': dietaryNeeds,
        'nutritionGoals': nutritionGoals,
        'dietaryPreferences': dietaryPreferences,
        'lipidProfile': lipidProfile,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        age: json['age'] ?? 0,
        profileImageBase64: json['profileImageBase64'],
        isGuest: json['isGuest'] ?? false,
        allergies: List<String>.from(json['allergies'] ?? []),
        avoidList: List<String>.from(json['avoidList'] ?? []),
        dietaryNeeds: List<String>.from(json['dietaryNeeds'] ?? []),
        nutritionGoals: List<String>.from(json['nutritionGoals'] ?? []),
        dietaryPreferences:
            List<String>.from(json['dietaryPreferences'] ?? []),
        lipidProfile: json['lipidProfile'] != null
            ? Map<String, double>.from(json['lipidProfile'])
            : null,
      );
}
