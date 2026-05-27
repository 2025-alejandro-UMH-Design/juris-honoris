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
