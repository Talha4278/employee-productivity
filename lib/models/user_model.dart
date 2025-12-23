import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { employee, customer }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserType userType;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime createdAt;
    final createdAtValue = map['createdAt'];
    if (createdAtValue != null) {
      if (createdAtValue is Timestamp) {
        createdAt = createdAtValue.toDate();
      } else if (createdAtValue is DateTime) {
        createdAt = createdAtValue;
      } else {
        // Fallback: try to convert if it has a toDate method
        try {
          createdAt = (createdAtValue as dynamic).toDate();
        } catch (e) {
          createdAt = DateTime.now();
        }
      }
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      userType: map['userType']?.toString() == 'employee' 
          ? UserType.employee 
          : UserType.customer,
      phoneNumber: map['phoneNumber']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': userType == UserType.employee ? 'employee' : 'customer',
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
    };
  }
}

