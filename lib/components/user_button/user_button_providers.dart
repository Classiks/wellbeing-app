import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/user_button/login_result.dart';

final StateProvider<String?> emailProvider = StateProvider((ref) => null);
final StateProvider<bool> emailValidProvider = StateProvider((ref) => true);
final StateProvider<bool> passwordValidProvider = StateProvider((ref) => true);
final StateProvider<bool> passwordsMatchingProvider = StateProvider((ref) => true);
final StateProvider<LoginResult> loginResultProvider = StateProvider((ref) => LoginResult.success);
