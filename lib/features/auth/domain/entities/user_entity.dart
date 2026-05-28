import 'package:equatable/equatable.dart';

enum UserRole { client, lawyer, admin }

enum UserPlan { free, premium }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? dni;
  final UserRole role;
  final UserPlan plan;
  final bool isVerified;
  final int solicitationsThisMonth;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.dni,
    required this.role,
    required this.plan,
    required this.isVerified,
    required this.solicitationsThisMonth,
    required this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id:                      json['id'] as String,
      email:                   json['email'] as String,
      name:                    json['full_name'] as String?,
      phone:                   json['phone'] as String?,
      dni:                     json['dni'] as String?,
      role:                    _roleFromString(json['role'] as String? ?? 'client'),
      plan:                    (json['plan'] as String?) == 'premium' ? UserPlan.premium : UserPlan.free,
      isVerified:              json['is_verified'] as bool? ?? false,
      solicitationsThisMonth:  json['solicitations_this_month'] as int? ?? 0,
      createdAt:               DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static UserRole _roleFromString(String role) {
    switch (role) {
      case 'admin':  return UserRole.admin;
      case 'lawyer': return UserRole.lawyer;
      default:       return UserRole.client;
    }
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? dni,
    UserRole? role,
    UserPlan? plan,
    bool? isVerified,
    int? solicitationsThisMonth,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dni: dni ?? this.dni,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      isVerified: isVerified ?? this.isVerified,
      solicitationsThisMonth:
          solicitationsThisMonth ?? this.solicitationsThisMonth,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        dni,
        role,
        plan,
        isVerified,
        solicitationsThisMonth,
        createdAt,
      ];
}
