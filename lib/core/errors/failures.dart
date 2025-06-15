import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

// 일반적인 서버 오류 (API 오류, 예기치 않은 응답 등)
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// 네트워크 연결 오류
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'Please check your network connection. If the problem persists, please contact your administrator.',
  });
}

// 인증 관련 오류 (예: 잘못된 자격 증명 - Supabase의 AuthException을 변환)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message});
}

// 권한 없음 오류 (예: RLS 위반 - Supabase의 PostgrestException 특정 코드를 변환)
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission for the request.',
  });
}

// 유효하지 않은 입력 값에 대한 오류 (클라이언트 측에서 잡지 못한 경우 또는 서버 측 유효성 검사 실패)
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({required super.message});
}

// 예상치 못한, 분류되지 않은 기타 오류
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = "An unknown error has occurred. Please try again later.",
  });
}
