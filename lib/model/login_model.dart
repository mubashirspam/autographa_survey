class LoginModel {
  String? accessToken;
  String? refreshToken;
  String? name;
  String? email;
  int? personId;

  LoginModel({
     this.accessToken,
     this.refreshToken,
     this.name,
     this.email,
     this.personId,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginModel(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      personId: data['personId'] ,
    );
  }

  
}
