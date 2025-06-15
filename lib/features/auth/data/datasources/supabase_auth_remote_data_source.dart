import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_remote_data_source.dart';

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        // raw_user_meta_data에 username을 포함하여 전달
        // 이 데이터는 public.profiles 테이블 생성 트리거 (handle_new_user)에서 사용됩니다.
        data: {'username': username, 'role': 'user'},
      );

      // Supabase signUp 성공 시 User 객체가 반환됩니다.
      // (이메일 확인이 활성화된 경우에도 user 객체는 생성되고 id를 가집니다.)
      final User? user = response.user;

      if (user == null) {
        // 일반적으로 signUp이 성공하면 user 객체가 null이 아니지만,
        // 예외적인 경우를 대비하여 체크합니다.
        // profiles 테이블 생성을 위해 user.id가 필수적이므로, user가 null이면 에러로 간주합니다.
        throw const AuthException(
          // 또는 직접 정의한 ServerException 등
          'Registration was successful, '
          'but user information could not be retrieved. (User is null)',
        );
      }
      return user;
    } on AuthException {
      // Supabase에서 발생한 AuthException을 그대로 다시 throw 하거나 필요에 따라
      // 커스텀 Exception(예: ServerException(message: e.message))으로 변환하여 throw.
      // Repository 계층에서 이 Exception을 Failure로 변환.
      // print('SupabaseAuthRemoteDataSource Error: ${e.message}'); // 디버깅용
      rethrow; // 우선 그대로 다시 던짐.
    } catch (e) {
      // 예상치 못한 다른 종류의 에러 처리
      // print('SupabaseAuthRemoteDataSource Unknown Error: $e'); // 디버깅용
      // 일반적인 AuthException으로 변환하거나 커스텀 Exception 사용
      throw AuthException(
        'An unexpected error occurred while signup.: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      final User? user = response.user;
      if (user == null) {
        // signInWithPassword가 성공하면 user 객체가 null이 아니어야 합니다.
        // 만약 null이라면, 예상치 못한 상황으로 간주합니다.
        throw const AuthException(
          'Sign in was successful, '
          'but user information could not be retrieved. (User is null)',
        );
      }
      // printJwtToken();
      return user;
    } on AuthException {
      // Supabase에서 발생한 AuthException (예: 잘못된 이메일/비밀번호)을
      // 그대로 다시 throw. Repository 계층에서 Failure로 변환.
      rethrow;
    } catch (e) {
      // 기타 예상치 못한 에러 처리
      throw AuthException(
        'An unexpected error occurred while login.: ${e.toString()}',
      );
    }
  }

  void printJwtToken() {
    final session = _supabaseClient.auth.currentSession;

    if (session != null) {
      final jwt = session.accessToken;
      print('JWT Token: $jwt');
    } else {
      print('No active session.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException {
      // signOut에서 발생하는 AuthException 처리 (필요시)
      // 일반적으로 signOut은 로컬 세션만 지우므로 심각한 에러는 드물지만,
      // 만약의 경우를 대비해 로그를 남기거나 특정 Exception으로 변환 가능
      // print('SupabaseAuthRemoteDataSource Logout Error: ${e.message}');
      rethrow; // 또는 특정 DataSourceException throw
    } catch (e) {
      // print('SupabaseAuthRemoteDataSource Unknown Logout Error: $e');
      throw AuthException(
        'An unexpected error occurred while logging out.: ${e.toString()}',
      );
    }
  }
}
