import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/login_usecase.dart';
import '../providers/auth_dependency_providers.dart';

part 'login_viewmodel.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> login({required String email, required String password}) async {
    // 1. 로딩 상태로 변경하여 UI에 알립니다.
    state = const AsyncLoading();

    // 2. LoginUseCaseProvider를 통해 UseCase 인스턴스를 가져옵니다.
    final loginUseCase = ref.read(loginUseCaseProvider);

    // 3. UseCase를 호출하기 위한 파라미터 객체(LoginParams)를 생성합니다.
    final params = LoginParams(email: email, password: password);

    // 4. UseCase를 실행하고 결과를 받습니다.
    final result = await loginUseCase(params);

    // 5. UseCase 실행 결과(Either<Failure, void>)에 따라 상태를 업데이트합니다.
    result.fold(
      (failure) {
        // 실패 시: AsyncError 상태로 변경하고 Failure 객체를 전달합니다.
        // UI(LoginPage)의 ref.listen에서 이 상태를 감지하여 사용자에게 에러 메시지를 보여줍니다.
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        // 성공 시: AsyncData(null) 상태로 변경합니다.
        // 로그인 성공 후에는 authStateStreamProvider의 상태가 변경되고,
        // GoRouter의 redirect 로직에 의해 자동으로 뉴스피드 페이지로 이동될 것입니다.
        state = const AsyncData(null);
      },
    );
  }
}
