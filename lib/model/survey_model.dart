class Survey {
  final int? id;
  final String? survey;

  Survey({
    this.id,
    this.survey,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] as int?,
      survey: json['survey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey': survey,
    };
  }
}
