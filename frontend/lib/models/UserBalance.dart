import 'package:prbd_2425_a07/models/user.dart';

class UserBalance {
  final int userId;
  final double paid;
  final double due;
  final double balance;
  

  UserBalance({
    required this.userId,
    required this.paid,
    required this.due,
    required this.balance,
    
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) => UserBalance(
    userId: json['user'],
    paid: (json['paid'] as num).toDouble(),
    due: (json['due'] as num).toDouble(),
    balance: (json['balance'] as num).toDouble()
  );
}
