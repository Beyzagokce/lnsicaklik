import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // ImageFilter için gerekli
import 'package:audioplayers/audioplayers.dart'; // Ses çalmak için
import 'login_screen.dart'; // Login ekranı
import 'temperature_graph_screen.dart'; // Sıcaklık grafik ekranı
import 'warning_screen.dart'; // Uyarı ekranı

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  String temperature = '...'; // Başlangıç sıcaklık değeri
  final String apiUrl = 'https://api.thingspeak.com/channels/2626920/fields/1/last.json?api_key=374WR0W8MPADP3T9';
  final AudioPlayer _audioPlayer = AudioPlayer(); // Ses çalar

  @override
  void initState() {
    super.initState();
    fetchTemperature(); // Widget oluşturulduğunda sıcaklığı çek
  }

  Future<void> fetchTemperature() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = double.tryParse(data['field1']);
        
        setState(() {
          temperature = '${data['field1']}°C'; // Sıcaklık değerini güncelle
        });
        
        if (temp != null && temp > 20) {
          _playWarningSound(); // Sıcaklık 20°C'yi geçtiyse ses çal
          _showWarningScreen(); // Uyarı ekranını göster
        }
      } else {
        throw Exception('Sıcaklık yüklenemedi');
      }
    } catch (e) {
      setState(() {
        temperature = 'Hata'; // Hata varsa göster
        _playWarningSound(); // Hata durumunda uyarı sesini çal
      });
    }
  }

  void _playWarningSound() async {
    await _audioPlayer.play(AssetSource('assets/glitch-lazer-232465.mp3')); // Ses dosyasını çal
  }

  void _showWarningScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WarningScreen()),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showGraph() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TemperatureGraphScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color lightBlue = Colors.lightBlueAccent; // Daha açık mavi
    final Color darkerBlue = Colors.lightBlue; // Biraz daha koyu mavi

    return Scaffold(
      appBar: AppBar(
        title: Text('Sıcaklık Verisi'),
        backgroundColor: lightBlue,
        // Remove the actions property to get rid of the menu button
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: lightBlue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Grafik'),
              onTap: _showGraph,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Çıkış Yap'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/originals/19/6e/17/196e178a5d70af3ed070249089c7506c.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0), // Blur efektini azaltarak netliği artırdık
              child: Container(
                color: Colors.black.withOpacity(0.2), // Yarı saydam siyah katman
              ),
            ),
          ),
          Positioned(
            top: 50, // Logoyu biraz aşağıya indirdik
            left: 16,
            child: Image.network(
              'https://ln.com.tr/assets/modules/Theme/images/logo-white.png',
              width: 100, // Logo genişliği
              height: 50, // Logo yüksekliği
            ),
          ),
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 16,
              shadowColor: Colors.black38,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thermostat_rounded,
                          color: darkerBlue,
                          size: 36,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sıcaklık Verisi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: darkerBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: Text(
                        'Sıcaklık: $temperature',
                        key: ValueKey<String>(temperature),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: lightBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
