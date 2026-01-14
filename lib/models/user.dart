class User {
  final String? userId;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool? emailVerified;
  final DateTime? createdAt;
  final String? token;
  final String? otp;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  User({
      this.userId,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.email,
      this.emailVerified,
      this.createdAt,
    this.token,
    this.otp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      token: json['token'],
      otp: json['otp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'email_verified': emailVerified,
      'created_at': createdAt!.toIso8601String(),
      'token': token,
      'otp': otp,
    };
  }
}