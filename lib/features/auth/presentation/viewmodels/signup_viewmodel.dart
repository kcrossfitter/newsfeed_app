import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/signup_usecase.dart';
import '../providers/auth_dependency_providers.dart';

part 'signup_viewmodel.g.dart';

@riverpod
class SignupViewModel extends _$SignupViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    // 1. 현재 상태를 로딩 중으로 설정하여 UI에 알립니다.
    state = const AsyncLoading();

    // 2. SignupUseCaseProvider를 통해 UseCase 인스턴스를 가져옵니다.
    final signupUsecase = ref.read(signupUseCaseProvider);

    // 3. UseCase를 호출하기 위한 파라미터 객체(SignupParams)를 생성합니다.
    final params = SignupParams(
      email: email,
      password: password,
      username: username,
    );

    // 4. UseCase를 실행하고 결과를 받습니다.
    final result = await signupUsecase(params);

    // 5. UseCase 실행 결과(Either<Failure, void>)에 따라 상태를 업데이트합니다.
    result.fold(
      (failure) {
        // 실패 시: AsyncError 상태로 변경하고 Failure 객체를 전달합니다.
        // UI(SignupPage)의 ref.listen에서 이 상태를 감지하여 사용자에게 에러 메시지를 보여줍니다.
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        // 성공 시: AsyncData(null) 상태로 변경합니다.
        // 회원가입 성공 후에는 authStateStreamProvider의 상태가 변경되고,
        // GoRouter의 redirect 로직에 의해 자동으로 뉴스피드 페이지로 이동될 것입니다.
        // 따라서 여기서 별도의 네비게이션 호출은 필요하지 않습니다.
        state = const AsyncData(null);
      },
    );
  }
}
