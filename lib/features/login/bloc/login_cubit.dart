import 'package:bloc/bloc.dart';
import 'package:expense_app/services/auth_service.dart';
import 'package:expense_app/features/login/bloc/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService authService;

  LoginCubit({required this.authService}) : super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());

    final result = await authService.login(email: email, password: password);

    if (result.success) {
      emit(const LoginSuccess());
    } else {
      emit(LoginFailure(result.message));
    }
  }
}
