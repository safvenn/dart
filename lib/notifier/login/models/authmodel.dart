class AuthState {
  final bool isloading;
  final bool isAuthenticate;
  final String? error;
  final String? userEmail;
  final bool? isAdmin;
  AuthState({
    this.isloading = false,
    this.isAuthenticate = false,
    this.error,
    this.userEmail,
    this.isAdmin = false
  });
  AuthState copyWith({
    bool? isloading,
    bool? isAuthenticate,
    String? error,
    String? userEmail,
    bool? isAdmin
  }) {
    return AuthState(
      isloading: isloading ?? this.isloading,
      isAuthenticate: isAuthenticate ?? this.isAuthenticate,
      error: error,
      userEmail: userEmail ?? this.userEmail,
      isAdmin: isAdmin ?? this.isAdmin
    );
  }
}
