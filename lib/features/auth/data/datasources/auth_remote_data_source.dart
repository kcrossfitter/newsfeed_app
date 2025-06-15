import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<User> signup({
    required String email,
    required String password,
    required String username, // raw_user_meta_data에 전달될 사용자 이름
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();
}
