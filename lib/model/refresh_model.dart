class RefreshModel {
  final String accessToken;
  final String refreshToken;

  RefreshModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RefreshModel(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}