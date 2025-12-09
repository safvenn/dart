class AuthState {
  final bool isloading;
  final bool isAuthenticate;
  final String? error;
  final String? userEmail;
  AuthState({
    this.isloading = false,
    this.isAuthenticate = false,
    this.error,
    this.userEmail,
  });
  AuthState copyWith({
    bool? isloading,
    bool? isAuthenticate,
    String? error,
    String? userEmail,
  }) {
    return AuthState(
      isloading: isloading ?? this.isloading,
      isAuthenticate: isloading ?? this.isAuthenticate,
      error: error,
      userEmail: userEmail ?? this.userEmail 
    );
  }
}
