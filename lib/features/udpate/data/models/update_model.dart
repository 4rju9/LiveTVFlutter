class UpdateModel {
  final String latestVersion;
  final int latestVersionCode;
  final String url;
  final List<String> releaseNotes;

  UpdateModel({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.url,
    required this.releaseNotes,
  });

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      latestVersion: json['latestVersion'],
      latestVersionCode: json['latestVersionCode'],
      url: json['url'],
      releaseNotes: List<String>.from(json['releaseNotes']),
    );
  }
}
