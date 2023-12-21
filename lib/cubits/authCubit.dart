import 'package:injazathr/data/models/user.dart';
import 'package:injazathr/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final String jwtToken;
  final User user;

  Authenticated({required this.jwtToken, required this.user});
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial()) {
    _checkIsAuthenticated();
  }

  void _checkIsAuthenticated() {
    if (authRepository.getIsLogIn()) {
      emit(
        Authenticated(
          user: authRepository.getUserDetails(),
          jwtToken: authRepository.getJwtToken(),
        ),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  void authenticateUser({required String jwtToken, required User user}) {
    //
    authRepository.setJwtToken(jwtToken);
    authRepository.setIsLogIn(true);
    authRepository.setUserDetails(user);

    //emit new state
    emit(Authenticated(
      user: user,
      jwtToken: jwtToken,
    ));
  }

  User getUserDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).user;
    }
    return User.fromJson({});
  }

  void signOut() {
    authRepository.signOutUser();
    emit(Unauthenticated());
  }
}
