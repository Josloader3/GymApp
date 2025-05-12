import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_app/features/auth/services/auth_service.dart';
import 'package:gym_app/features/user_data/models/user_model.dart';
import 'package:gym_app/features/user_data/repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepository;
  final AuthService _authService = AuthService();

  AuthBloc(this._userRepository) : super(const AuthState()) {
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final userCredential = await _authService.signUp(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        final newUser = GymUser(
          uid: userCredential.user!.uid,
          email: event.email,
          name: event.name,
        );

        await _userRepository.saveUserData(newUser);

        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: userCredential.user,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          error: e.message ?? 'Error en el registro',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, error: e.toString()),
      );
    }
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final userCredential = await _authService.signIn(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: userCredential.user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          error: e.message ?? 'Error en el login',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, error: e.toString()),
      );
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.unknown));
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: _auth.currentUser,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, error: e.toString()),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.unknown));
    await Future.delayed(const Duration(milliseconds: 500));
    final user = _auth.currentUser;
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }
}
