class AnimeServerInfo {
  final String serverName;
  final String serverId;
  final String dataId;
  final String type;

  AnimeServerInfo({
    required this.serverName,
    required this.serverId,
    required this.dataId,
    required this.type,
  });

  factory AnimeServerInfo.fromJson(Map<String, dynamic> json) {
    return AnimeServerInfo(
      serverName: json['serverName']?.toString() ?? '',
      serverId: json['server_id']?.toString() ?? '',
      dataId: json['data_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class AnimeServersEntity {
  final List<AnimeServerInfo> sub;
  final List<AnimeServerInfo> dub;

  AnimeServersEntity({
    required this.sub,
    required this.dub,
  });
}
