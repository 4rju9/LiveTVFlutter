import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  
  // 1. Search Anime
  final searchReq = await client.getUrl(Uri.parse('https://hianime2.onrender.com/api/search?keyword=jujutsu'));
  final searchRes = await searchReq.close();
  final searchBody = await utf8.decodeStream(searchRes);
  final searchJson = jsonDecode(searchBody);
  
  if (searchJson['success'] == true) {
    final firstAnimeId = searchJson['results'][0]['id'];
    print("Found Anime: $firstAnimeId");
    
    // 2. Fetch Episodes
    final epReq = await client.getUrl(Uri.parse('https://hianime2.onrender.com/api/episodes/$firstAnimeId'));
    final epRes = await epReq.close();
    final epBody = await utf8.decodeStream(epRes);
    final epJson = jsonDecode(epBody);
    
    if (epJson['success'] == true && epJson['results'].isNotEmpty) {
       final firstEpId = epJson['results']['episodes'][0]['id'];
       print("Found Episode: $firstEpId");
       
       // 3. Fetch Servers
       final svrReq = await client.getUrl(Uri.parse('https://hianime2.onrender.com/api/servers/$firstEpId'));
       final svrRes = await svrReq.close();
       final svrBody = await utf8.decodeStream(svrRes);
       print("Servers Response:");
       print(svrBody);
       
    }
  }
}
