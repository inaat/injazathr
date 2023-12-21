import 'package:injazathr/data/models/user.dart';
import 'package:injazathr/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInInProgress extends SignInState {}

class SignInSuccess extends SignInState {
  final String jwtToken;
  final User user;

  SignInSuccess({required this.jwtToken, required this.user});
}

class SignInFailure extends SignInState {
  final String errorMessage;

  SignInFailure(this.errorMessage);
}

class SignInCubit extends Cubit<SignInState> {
  final AuthRepository _authRepository;

  SignInCubit(this._authRepository) : super(SignInInitial());

  void signInUser({required String mobileNo, required String password}) async {
    emit(SignInInProgress());

    try {
      Map<String, dynamic> result = await _authRepository.signInUser(
          mobileNo: mobileNo, password: password);

      emit(SignInSuccess(
        jwtToken: result['jwtToken'],
        user: result['user'] as User,
      ));
    } catch (e) {
      print(e.toString());
      emit(SignInFailure(e.toString()));
    }
  }
}
