import 'dart:convert';
import 'package:http/http.dart' as http;

class AzureOpenAIService {
  final String apiKey;
  final String endpoint;
  final String deploymentName;

  AzureOpenAIService({
    required this.apiKey,
    required this.endpoint,
    required this.deploymentName,
  });

  Future<String> getAiResponse(String userPrompt, {String? firebaseData}) async {
  try {
    // 1. Endpoint temizliği: Başta kalabilecek '=' işaretini ve boşlukları temizle
    String cleanEndpoint = endpoint.trim();
    if (cleanEndpoint.startsWith('=')) {
      cleanEndpoint = cleanEndpoint.substring(1).trim();
    }
    
    // Fazlalık /openai veya /v1 kısımlarını buda
    cleanEndpoint = cleanEndpoint.split('/openai')[0];
    
    if (cleanEndpoint.endsWith('/')) {
      cleanEndpoint = cleanEndpoint.substring(0, cleanEndpoint.length - 1);
    }

    // 2. Deployment ismini temizle (gpt-4o)
    String cleanDeployment = deploymentName.trim();
    if (cleanDeployment.startsWith('=')) {
      cleanDeployment = cleanDeployment.substring(1).trim();
    }
    cleanDeployment = cleanDeployment.split(' ')[0];

    // 3. URL Kurulumu
    final url = Uri.parse(
        '$cleanEndpoint/openai/deployments/$cleanDeployment/chat/completions?api-version=2024-02-15-preview');

    print("--- DOĞRULANMIŞ URL ---");
    print(url.toString()); 
    // Burada artık başında '=' görmemelisin!

      final headers = {
        'Content-Type': 'application/json',
        'api-key': apiKey,
      };

      String finalPrompt = "Kullanıcı Sağlık Verileri:\n${firebaseData ?? 'Veri yok'}\n\nSoru: $userPrompt";

      final body = jsonEncode({
        'messages': [
          {
            "role": "system",
            "content": """INSULA Nihai Asistan Kuralları:

1. Kimlik ve Karakter:
Sen INSULA uygulamasının sağlık, beslenme ve yaşam tarzı asistanısın. Tonlama: Her zaman çok kibar, anlayışlı, empatik ve profesyonel bir dil kullan. Kullanıcıya her mesajında değerli olduğunu hissettir.

2. Kritik Güvenlik ve İlaç Kuralları (Kırmızı Çizgiler):
İlaç Yasağı: Kesinlikle hiçbir ilaç ismi (aspirin, insülin vb.) verme ve dozaj önerme. Kullanıcı sorarsa: "İlaç yönetimi ve dozajı konusunda sadece doktorunuz yetkilidir, lütfen hekiminize danışın" şeklinde cevap ver.
Riskli Durumlar: Göğüs ağrısı, nefes darlığı veya baygınlık hissi gibi durumlarda doğrudan: "Lütfen en yakın sağlık kuruluşuna başvurun" de.
Kritik Hassas Konular: İntihar, ölüm, uyuşturucu veya kendine zarar verme ifadelerinde sakin ve şefkatli ol. Şunu de: "Bu konuda size cevap verme yetkim bulunmuyor ancak çok değerli olduğunuzu hatırlatmak isterim. Lütfen hemen bir yakınınızla iletişime geçin veya bir uzmandan destek alın."

3. Şeker (Diyabet) Yönetimi Acil Durumlar:
Şeker Düşüşü (Hipoglisemi): Belirtiler varsa; 2-3 adet küp şeker veya meyve suyu gibi hızlı şeker kaynakları tüketmesini ve mutlaka bir yakınına haber vermesini öner.
Şeker Yükselişi (Hiperglisemi): Bol su içmesini, (doktoru onayladıysa) hafif yürüyüş yapmasını ve değerler düşmüyorsa doktoruna ulaşmasını söyle.

4. Program Hazırlama ve Veri Analizi:
Hedef Odaklılık: Kullanıcının kilo alma, kilo verme veya kas kütlesi artırma hedefine göre kalori ve makro dengesine uygun beslenme ve egzersiz programları hazırla.
Veri Yorumlama: Kullanıcının paylaştığı haftalık kan şekeri, su, adım ve öğün grafiklerini/raporlarını analiz et. Trendleri (eğilimleri) belirle.

5. Yasal Sorumluluk ve Rutinler:
Yasal Uyarı: Sağlıkla ilgili her tavsiyenin başına veya sonuna şu notu mutlaka ekle: "Bu bir yapay zeka tavsiyesidir, tıbbi teşhis veya tedavi yerine geçmez."
Teşvik: Kullanıcıyı her zaman su içmeye, aktif kalmaya ve haftalık raporlarını takip etmeye teşvik et.
"""
          },
          {"role": "user", "content": finalPrompt}
        ],
        'max_tokens': 800,
        'temperature': 0.7,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim() ?? "Cevap üretilemedi.";
      } else {
        print("Azure Hata Detayı: ${response.body}"); // 404'ün sebebini burada yazar
        return "Servis hatası (Kod: ${response.statusCode})";
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return "Bağlantı kurulamadı.";
    }
  }
}