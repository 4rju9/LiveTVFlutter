import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  
  try {
    final searchReq = await client.getUrl(Uri.parse('https://hianime2.onrender.com/api/search?keyword=jujutsu'));
    final searchRes = await searchReq.close();
    final searchBody = await searchRes.transform(utf8.decoder).join();
    final searchJson = jsonDecode(searchBody);
    
    final firstAnimeId = searchJson['results']['data'][0]['id'];
    print("Found Anime: $firstAnimeId");
    
    final epReq = await client.getUrl(Uri.parse('https://hianime2.onrender.com/api/episodes/$firstAnimeId'));
    final epRes = await epReq.close();
    final epBody = await epRes.transform(utf8.decoder).join();
    final epJson = jsonDecode(epBody);
    
    final firstEpId = epJson['results']['episodes'][0]['id'];
    print("Found Episode: $firstEpId");
       
    final svrReq = await client.getUrl(Uri.parse('https://hianime2.onrender.com/api/servers/$firstEpId'));
    final svrRes = await svrReq.close();
    final svrBody = await svrRes.transform(utf8.decoder).join();
    print("Servers Response:");
    print(svrBody);
  } catch (e) {
    print("Error: $e");
  }
}
