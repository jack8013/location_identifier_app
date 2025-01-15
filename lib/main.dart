import 'package:flutter/services.dart';
import 'package:mountain_app/camera_page.dart';
import 'package:mountain_app/google_map.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  double maxDistance = 25.0;
  late final String fromJava;
  final String CHANNEL = "com.example.mountain_app/focalLength";
  late final MethodChannel _channel = MethodChannel(CHANNEL);

  List<Peak> peaks = [
    //Selangor
    Peak(
        name: "Bukit Rupa",
        lat: 2.9176523767908984,
        lon: 101.7666237160167,
        alt: 0),
    Peak(
        name: "Bukit Badak",
        lat: 2.9050270930863142,
        lon: 101.62116689114977,
        alt: 0),
    Peak(
        name: "Bukit Bisa",
        lat: 2.9673828797036883,
        lon: 101.70669809756858,
        alt: 0),
    Peak(name: "Bukit Tunggul", lat: 2.8732905, lon: 101.7485283, alt: 0),
    Peak(name: "Bukit Broga	", lat: 2.9503566, lon: 101.9029692, alt: 0),
    Peak(name: "Bukit Tabur East", lat: 3.2322805, lon: 101.7569321, alt: 0),
    Peak(name: "Bukit Tabur West", lat: 3.2369716, lon: 101.7387991, alt: 0),
    Peak(name: "Gunung Tok Wan", lat: 2.9687166, lon: 101.9160644, alt: 0),
    Peak(name: "Bukit Kutu", lat: 3.5431596, lon: 101.7199114, alt: 0),
    Peak(name: "Bukit Tadun", lat: 3.2566577, lon: 101.5434135, alt: 0),
    Peak(name: "Saga Hill Station", lat: 3.1097380, lon: 101.7767509, alt: 0),
    Peak(name: "Gunung Bunga Buah", lat: 3.3741383, lon: 101.7396812, alt: 0),
    Peak(name: "Genting Sempah Peak", lat: 3.3501650, lon: 101.7820590, alt: 0),
    Peak(name: "Puncak Seni", lat: 3.1032570, lon: 101.5057440, alt: 0),
    Peak(
        name: "Puncak Denai Tiga Puteri",
        lat: 3.1757770,
        lon: 101.5995537,
        alt: 0),
    Peak(name: "Bukit Wawasan", lat: 3.0151977, lon: 101.6367710, alt: 0),
    Peak(name: "Bukit Tunggul", lat: 3.4608122, lon: 101.7767394, alt: 0),
    Peak(name: "Bukit Kutu South", lat: 3.5352975, lon: 101.7276872, alt: 0),
    Peak(name: "Bukit Unknown", lat: 3.4650852, lon: 101.7242110, alt: 0),
    Peak(name: "Bukit Tamu", lat: 3.4493969, lon: 101.7063131, alt: 0),
    Peak(name: "Gunung Akar", lat: 3.7116767, lon: 101.7103969, alt: 0),
    Peak(name: "Gunung Hulu Kali", lat: 3.4329312, lon: 101.7833734, alt: 0),
    Peak(name: "Bukit Batu Pahat", lat: 3.5593732, lon: 101.6785728, alt: 0),
    Peak(
        name: "Bukit Jugra",
        lat: 2.800621317080301,
        lon: 101.47977062066995,
        alt: 0),
    Peak(
        name: "Bukit Chedding",
        lat: 2.9161485031634777,
        lon: 101.56977175619181,
        alt: 0),
    Peak(name: "Bukit Boyan", lat: 3.3894506, lon: 101.7188593, alt: 0),
    Peak(name: "Pine Tree Hill", lat: 3.7105038, lon: 101.6966417, alt: 0),
    Peak(name: "Gunung Hulu Lenik", lat: 3.6357911, lon: 101.6563663, alt: 0),
    Peak(name: "Bukit Irdom", lat: 3.6881171, lon: 101.6067308, alt: 0),
    Peak(name: "Bukit Chenuang", lat: 3.2378753, lon: 101.8229496, alt: 0),
    Peak(name: "Bukit Batu Kumbang", lat: 3.2293306, lon: 101.8166428, alt: 0),
    Peak(
        name: "Gunung Ulu Semangkok", lat: 3.6814112, lon: 101.7680531, alt: 0),
    Peak(name: "Bukit Chorocho", lat: 3.6623771, lon: 101.7238495, alt: 0),
    Peak(name: "Bukit Hulu Rumput", lat: 3.3148830, lon: 101.7578816, alt: 0),
    Peak(name: "Peak Garden", lat: 3.1284187, lon: 101.4843053, alt: 0),
    Peak(name: "Apek Hill", lat: 3.1028937, lon: 101.7729749, alt: 0),
    Peak(name: "Bukit Kembara", lat: 3.1627534, lon: 101.7769153, alt: 0),
    Peak(name: "Bukit Sapu Tangan", lat: 3.1145919, lon: 101.4983917, alt: 0),
    Peak(name: "Gunung Ulu Tranum", lat: 3.6812988, lon: 101.7638538, alt: 0),
    Peak(name: "Bukit Cherakah", lat: 3.2308048, lon: 101.3938490, alt: 0),
    Peak(name: "Bukit Asa", lat: 3.6802763, lon: 101.5071195, alt: 0),
    Peak(name: "Bukit Hulu Munchong", lat: 3.2772442, lon: 101.5854491, alt: 0),
    Peak(
        name: "Budiman Peak Lookout point",
        lat: 3.1387986,
        lon: 101.4853306,
        alt: 0),
    Peak(name: "Bukit Tampoi", lat: 2.8464586, lon: 101.6723527, alt: 0),
    Peak(name: "Bukit Lanjan", lat: 3.1779752, lon: 101.6121841, alt: 0),
    Peak(name: "Bukit Hulu Sekamat", lat: 3.6743859, lon: 101.5731004, alt: 0),
    Peak(name: "Bukit Kalumpang", lat: 3.6642083, lon: 101.5863746, alt: 0),
    Peak(name: "Bukit Kubah", lat: 3.6430881, lon: 101.6007499, alt: 0),
    Peak(name: "Bukit Rasak", lat: 3.6338746, lon: 101.5265759, alt: 0),
    Peak(name: "Bukit Sebarau", lat: 3.5749214, lon: 101.6388648, alt: 0),
    Peak(name: "Bukit Perian", lat: 3.5954891, lon: 101.6679447, alt: 0),
    Peak(name: "Bukit Ulu Kubu", lat: 3.5940602, lon: 101.6761743, alt: 0),
    Peak(name: "Bukit Menggaru Mati", lat: 3.5787964, lon: 101.6877686, alt: 0),
    Peak(name: "Bukit Bertam", lat: 3.6012897, lon: 101.6397532, alt: 0),
    Peak(
        name: "Peak of Kingsley Hill",
        lat: 3.0057709,
        lon: 101.5765375,
        alt: 0),
    Peak(name: "Bukit Mesian", lat: 3.1142937, lon: 101.4915182, alt: 0),
    Peak(name: "Bukit Batu Chondong", lat: 3.2206636, lon: 101.7871110, alt: 0),
    Peak(name: "Bukit Pau", lat: 3.2352899, lon: 101.7746495, alt: 0),
    Peak(name: "Bukit Lagong", lat: 3.2514511, lon: 101.6096145, alt: 0),
    Peak(name: "Bukit Unyang", lat: 3.3247477, lon: 101.6273010, alt: 0),
    Peak(name: "Bukit Tabur Extra", lat: 3.2276390, lon: 101.7692113, alt: 0),
    Peak(name: "Bukit Serdang", lat: 3.0192425, lon: 101.6893230, alt: 0),
    Peak(name: "Bukit Ketumbar", lat: 3.0983098, lon: 101.7542027, alt: 0),
    Peak(name: "Bukit Beruang", lat: 3.2363156, lon: 101.6165292, alt: 0),
    Peak(name: "Bukit Sentosa", lat: 3.4034567, lon: 101.5803449, alt: 0),
    Peak(name: "Bukit Tabur Extreme", lat: 3.2288387, lon: 101.7658988, alt: 0),
    Peak(name: "Bukit Batu Karpet", lat: 3.2945000, lon: 101.7613551, alt: 0),
    Peak(name: "Bukit Jeram", lat: 3.2510940, lon: 101.3065963, alt: 0),

    //Perak
    Peak(
        name: "Bukit Hulu Sekamat",
        lat: 3.677421236427022,
        lon: 101.58043342909052,
        alt: 871),
    Peak(
        name: "Bukit Kalumpang",
        lat: 3.666722447075143,
        lon: 101.59059730344111,
        alt: 990),
    Peak(
        name: "Bukit Irdom",
        lat: 3.6912043329711013,
        lon: 101.61229332156702,
        alt: 1318),
    Peak(
        name: "Bukit Kubah",
        lat: 3.638785695004066, 
        lon: 101.60308422875976,
        alt: 758),
    Peak(name: 'Bukit Ulu Tengah', lat: 3.6879677952041656, lon: 101.46579038034083, alt: 182),
    Peak(name: 'Cangkat Lembah', lat: 3.7113922656223512,lon: 101.55054349058285, alt: 284),
    //Johor
    Peak(name: 'Bukit Kulai', lat: 1.529428, lon: 103.531994, alt: 584),
    Peak(name: 'Ulu Choh Hill', lat: 1.546077, lon: 103.541352, alt: 451),
    Peak(name: 'Gunung Pulai', lat: 1.6016002, lon: 103.5460556, alt: 654),
    Peak(name: 'Gunung Panti', lat: 1.8259330, lon: 103.8669830, alt: 510),
    Peak(name: 'Gunung Pertawai', lat: 2.5100218, lon: 103.2849931, alt: 840),
    Peak(name: 'Gunung Tiong', lat: 2.4308617, lon: 103.2939649, alt: 0),
    Peak(name: 'Gunuung Bekok', lat: 2.3873161, lon: 103.1809995, alt: 0),
    Peak(name: 'Bukit Arong', lat: 2.5615383, lon: 103.8078605, alt: 0),
    Peak(name: 'Bukit Petai', lat: 2.0610070, lon: 104.0097144, alt: 0),
    Peak(name: 'Bukit Besar', lat: 2.2959010, lon: 103.8332995, alt: 0),
    Peak(name: 'Gunung Lambak', lat: 2.0278449, lon: 103.3575167, alt: 510),
    Peak(
        name: 'Bukit Batu Tongkat', lat: 1.9883851, lon: 103.5117028, alt: 395),
    Peak(name: 'Gunung Chemendong', lat: 2.0829864, lon: 103.5586281, alt: 846),
    Peak(name: 'Bukit Tinggi', lat: 2.2832896, lon: 103.6665929, alt: 0),
    Peak(name: 'Bukit Jengeli West', lat: 1.9478160, lon: 103.6192932, alt: 0),
    Peak(name: 'Bukit Pachat', lat: 1.8988276, lon: 103.7052194, alt: 0),
    Peak(name: 'Bukit Tengkil', lat: 1.8821567, lon: 103.7521132, alt: 0),
    Peak(name: 'Gunung Sumalayang', lat: 1.9631102, lon: 103.7678184, alt: 0),
    Peak(name: 'Gunung Belumut', lat: 2.0425519, lon: 103.5612441, alt: 1010),
    Peak(name: 'Gunung Muntahak', lat: 1.8529553, lon: 103.8110162, alt: 634),
    Peak(name: 'Bukit Banang', lat: 1.8140513, lon: 102.9404674, alt: 427),
    Peak(
        name: 'Gunung Janing Barat',
        lat: 2.5167229,
        lon: 103.3899239,
        alt: 543),
    Peak(name: 'Bukit Maokil', lat: 2.1108664, lon: 102.9041363, alt: 578),
    Peak(name: 'Gunung Sumalayang', lat: 1.9611968, lon: 103.7749927, alt: 615),
    Peak(name: 'Gunung Janing', lat: 2.5145733, lon: 103.4145307, alt: 655),
    Peak(name: 'Bukit Batu Mas', lat: 1.3676615, lon: 104.1194215, alt: 0),
    Peak(
        name: 'Bukit Tanjung Kupang', lat: 1.3765088, lon: 103.6081142, alt: 0),
    Peak(name: 'Bukit Pengerang', lat: 1.3771479, lon: 104.1007468, alt: 0),
    Peak(name: 'Bukit Waju', lat: 1.3808089, lon: 104.2591618, alt: 0),
    Peak(name: 'Bukit Hutan', lat: 1.3886448, lon: 104.1892142, alt: 0),
    Peak(name: 'Bukit Saga', lat: 1.3948153, lon: 104.1892818, alt: 0),
    Peak(name: 'Bukit Santi', lat: 1.4021263, lon: 104.1196743, alt: 0),
    Peak(name: 'Bukit G 253', lat: 1.4367163, lon: 103.6218233, alt: 0),
    Peak(name: 'Bukit Arang', lat: 1.4477874, lon: 104.1021571, alt: 0),
    Peak(name: 'Bukit Buah Kechil', lat: 1.4489868, lon: 104.0794111, alt: 0),
    Peak(name: 'Bukit Tempinis', lat: 1.4673625, lon: 104.0824215, alt: 0),
    Peak(name: 'Bukit Kempas', lat: 1.5350096, lon: 103.7015713, alt: 0),
    Peak(name: 'Bukit Belukar', lat: 1.6749507, lon: 103.8345863, alt: 0),
    Peak(name: 'Bukit Belah', lat: 1.9427987, lon: 102.9681998, alt: 0),
    Peak(name: 'Bukit Kubur Cina', lat: 2.0380005, lon: 102.6623346, alt: 0),
    Peak(name: 'Bukit Nyior Tunggal', lat: 2.0328659, lon: 102.6723822, alt: 0),
    Peak(name: 'Bukit Dinding', lat: 2.0162377, lon: 102.6749439, alt: 0),
    Peak(name: 'Bukit Tanjung', lat: 1.7379819, lon: 102.9932857, alt: 0),
    Peak(name: 'Bukit Belading', lat: 2.3252551, lon: 102.5319832, alt: 0),
    Peak(name: 'Bukit Reban Kambing', lat: 2.3347852, lon: 102.5414729, alt: 0),
    Peak(name: 'Bukit Tukau	', lat: 2.3233148, lon: 102.5425887, alt: 0),
    Peak(name: 'Bukit Leman', lat: 2.2173113, lon: 102.5650227, alt: 0),
    Peak(name: 'Bukit Lipat Kajang', lat: 2.2117874, lon: 102.5682494, alt: 0),
    Peak(name: 'Bukit Segenting', lat: 1.7910494, lon: 102.8892693, alt: 0),
    Peak(name: 'Bukit Sinding', lat: 1.7907851, lon: 102.9023157, alt: 0),
    Peak(name: 'Bukit Kupong', lat: 2.4194486, lon: 102.6395774, alt: 0),
    Peak(name: 'Gunung Ledang', lat: 2.3732115, lon: 102.6078884, alt: 1276),
    Peak(name: 'Bukit Keledang', lat: 2.4617864, lon: 102.6453763, alt: 0),
    Peak(name: 'Bukit Sengkang', lat: 2.4372424, lon: 102.6641545, alt: 0),
    Peak(name: 'Bukit Gempa', lat: 2.4297337, lon: 102.6662278, alt: 0),
    Peak(name: 'Bukit Perah', lat: 1.9751790, lon: 102.6673704, alt: 0),
    Peak(name: 'Bukit Mor', lat: 1.9790712, lon: 102.6767608, alt: 233),
    Peak(name: 'Bukit Pengkalan', lat: 2.1344694, lon: 102.6922345, alt: 0),
    Peak(
        name: 'Bukit Panchor Gemuroh',
        lat: 2.1070974,
        lon: 102.6946592,
        alt: 0),
    Peak(name: 'Bukit Jementah', lat: 2.4498320, lon: 102.7090466, alt: 0),
    Peak(name: 'Bukit Kuala Palong', lat: 2.6770502, lon: 102.7477133, alt: 0),
    Peak(name: 'Bukit Ganjis', lat: 2.6747782, lon: 102.7602607, alt: 0),
    Peak(
        name: 'Bukit Setambun Tulang',
        lat: 2.1405777,
        lon: 102.7845456,
        alt: 0),
    Peak(name: 'Bukit Spang Loi', lat: 2.6444510, lon: 102.7858479, alt: 0),
    Peak(name: 'Bukit Perlah', lat: 2.8036402, lon: 102.7943313, alt: 0),
    Peak(
        name: 'Bukit Gelang Chinchin',
        lat: 2.5911227,
        lon: 102.8196823,
        alt: 0),
    Peak(name: 'Bukit Renchir', lat: 2.6209019, lon: 102.8136957, alt: 0),
    Peak(name: 'Bukit Timah', lat: 2.2056363, lon: 102.8242206, alt: 0),
    Peak(name: 'Bukit Tasek', lat: 2.0289139, lon: 102.8639551, alt: 0),
    Peak(name: 'Bukit Ampar', lat: 2.0052787, lon: 102.8736486, alt: 0),
    Peak(name: 'Bukit Kepong', lat: 2.3606953, lon: 102.8883564, alt: 0),
    Peak(name: 'Bukit Kalong', lat: 1.9911071, lon: 102.8955674, alt: 0),
    Peak(name: 'Bukit Inas', lat: 2.0032555, lon: 102.9067522, alt: 0),
    Peak(name: 'Bukit Chapal', lat: 1.9905871, lon: 102.9236716, alt: 0),
    Peak(name: 'Bukit Payong', lat: 1.9650891, lon: 102.9261795, alt: 0),
    Peak(name: 'Bukit Pauh Manis', lat: 2.6004185, lon: 102.9341416, alt: 0),
    Peak(name: 'Bukit Tempayan', lat: 2.0133586, lon: 102.9437050, alt: 0),
    Peak(name: 'Bukit Batang Jarang', lat: 2.1083948, lon: 102.9544043, alt: 0),
    Peak(name: 'Bukit Soga', lat: 1.8552172, lon: 102.9578429, alt: 0),
    Peak(name: 'Bukit Penggaram', lat: 1.8351915, lon: 102.9678369, alt: 0),
    Peak(name: 'Bukit Bindu', lat: 1.9070629, lon: 102.9983951, alt: 0),
    Peak(name: 'Bukit Melong', lat: 2.5631699, lon: 103.0312684, alt: 0),
    Peak(name: 'Bukit Jeram Belanga', lat: 2.3289280, lon: 103.0611294, alt: 0),
    Peak(name: 'Bukit Tahang Rimau', lat: 2.4392040, lon: 103.0703080, alt: 0),
    Peak(name: 'Bukit Lanjut', lat: 2.4588681, lon: 103.0844647, alt: 0),
    Peak(name: 'Bukit Kerinting', lat: 2.3025297, lon: 103.1085021, alt: 0),
    Peak(name: 'Bukit Jintan', lat: 2.0006661, lon: 103.1474322, alt: 0),
    Peak(name: 'Gunung Besar', lat: 2.5199339, lon: 103.1478828, alt: 0),
    Peak(name: 'Bukit Besi', lat: 1.9407917, lon: 103.1507099, alt: 0),
    Peak(name: 'Bukit Belah', lat: 1.9527796, lon: 102.9641247, alt: 0),
    Peak(name: 'Bukit Keliring', lat: 2.4704978, lon: 103.1844287, alt: 0),
    Peak(name: 'Bukit Semeninjau', lat: 2.5375463, lon: 103.1964271, alt: 0),
    Peak(name: 'Bukit Marong', lat: 2.3747324, lon: 103.1953794, alt: 0),
    Peak(name: 'Bukit Merbak', lat: 2.4364385, lon: 103.1974608, alt: 0),
    Peak(
        name: 'Bukit Tulang Kijang',
        lat: 2.4954997,
        lon: 103.2019293,
        alt: 432),
    Peak(name: 'Bukit Batu', lat: 2.4873642, lon: 103.2149327, alt: 511),
    Peak(
        name: 'Bukit Permatang Serai',
        lat: 2.3625924,
        lon: 103.2073903,
        alt: 0),
    Peak(name: 'Bukit Payong', lat: 2.5166742, lon: 103.2152063, alt: 0),
    Peak(name: 'Bukit Donan', lat: 2.4501375, lon: 103.2163596, alt: 0),
    Peak(name: 'Bukit Lemaroh', lat: 2.4513059, lon: 103.2246959, alt: 0),
    Peak(name: 'Bukit Serigi', lat: 2.4764310, lon: 103.2296634, alt: 0),
    Peak(name: 'Bukit Gaut', lat: 2.4629681, lon: 103.2386434, alt: 0),
    Peak(name: 'Bukit Gemai', lat: 2.3476812, lon: 103.2359558, alt: 0),
    Peak(name: 'Bukit Keleman', lat: 2.4180336, lon: 103.2378709, alt: 0),
    Peak(name: 'Bukit Sabong', lat: 1.9207563, lon: 103.2446623, alt: 0),
    Peak(name: 'Bukit Langkap', lat: 2.5478057, lon: 103.2466578, alt: 0),
    Peak(name: 'Bukit Rambut', lat: 2.4307788, lon: 103.2873952, alt: 0),
    Peak(name: 'Bukit Batu', lat: 2.1725138, lon: 103.2964396, alt: 0),
    Peak(name: 'Bukit Seligi', lat: 2.3035201, lon: 103.3024102, alt: 0),
    Peak(name: 'Bukit Mengkibol', lat: 2.0138973, lon: 103.3156550, alt: 0),
    Peak(name: 'Bukit Sengongong', lat: 2.5081690, lon: 103.3218723, alt: 0),
    Peak(name: 'Bukit Chuchok', lat: 2.3154570, lon: 103.3307826, alt: 0),
    Peak(name: 'Bukit Laki', lat: 2.0897874, lon: 103.3314961, alt: 0),
    Peak(name: 'Bukit Selantai', lat: 2.5090580, lon: 103.8395491, alt: 0),
    Peak(name: 'Bukit Orang Baru', lat: 2.5288202, lon: 103.8234948, alt: 0),
    Peak(name: 'Bukit Melintang', lat: 2.5176945, lon: 103.8205873, alt: 0),
  ];


  Future<void> getCameraIntrinsicParams(String cameraId) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
          'getCameraIntrinsicParams', <String, dynamic>{'cameraId': cameraId});
      List<double> intrinsicParams = result.cast<double>().toList();
      debugPrint('Camera intrinsic parameters: $intrinsicParams');
    } on PlatformException catch (e) {
      print("Failed to call getCameraIntrinsicParams: '${e.message}'.");
    }
  }

  Future<void> getCameraPoseRotation(String cameraId) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
          'getCameraPoseRotation', <String, dynamic>{'cameraId': cameraId});
      List<double> quartenions = result.cast<double>().toList();
      debugPrint('Camera rotation parameters: $quartenions');
    } on PlatformException catch (e) {
      print("Failed to call getCameraPoseRotation: '${e.message}'.");
    }
  }


  Future<List<double>> getOrientedRotationMatrix() async {
    try {
      final List<dynamic> result =
          await _channel.invokeMethod('getOrientedRotationMatrix');
      final List<double> matrix = result.cast<double>();
      debugPrint(matrix.toString());
      return matrix;
    } on PlatformException catch (e) {
      print("Failed to call getOrientedRotationMatrix: '${e.message}'.");
      return <double>[];
    }
  }

  Future<void> sendPeaksData(List<Peak> peaks) async {
    final List<Map<String, dynamic>> peaksData = peaks
        .map((peak) => {
              'name': peak.name,
              'lat': peak.lat,
              'lon': peak.lon,
              'alt': peak.alt,
            })
        .toList();

    try {
      await _channel.invokeMethod('sendPeaksData', peaksData);
    } catch (e) {
      print('Error sending peaks data: $e');
    }
  }

  int currentPage = 0;


showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Help'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Welcome to Mountain Peak Identifier! Here is a quick tutorial to help you get started.\n '),
            Text('1. To start identifying peaks, press the "Open Camera" button. You will be prompted to accept the camera permission and turning on location access.\n '),
            Text('2. At the camera preview screen, you will have your location info presented on the top left and detected mountain information on the bottom right. \n '),
            Text('3. To change the visibility settings, press the "Visibility" button with a settings icon at the location info box.'),
            SizedBox(height: 8),
            
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    sendPeaksData(peaks);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mountain Peak Identifier'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_img.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final matrix = await getOrientedRotationMatrix();
                  await availableCameras().then(
                      (value) => Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) {
                              return CameraPage(
                                cameras: value,
                                matrix: matrix,
                              );
                            },
                          )));
                },
                child: const Text("Open Camera"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GMap(),
                    ),
                  );
                },
                child: const Text("Open Map"),
              ),
              const SizedBox(height: 10),
                          ElevatedButton(
              onPressed: () {
                showHelpDialog(context); 
              },
              child: const Text("Help"),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

// Store mountain peak data
class Peak {
  final String name;
  final double lat;
  final double lon;
  final int alt;

  Peak(
      {required this.name,
      required this.lat,
      required this.lon,
      required this.alt});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lat': lat,
      'long': lon,
      'alt': alt,
    };
  }

  String getName() {
    return name;
  }

  double getLat() {
    return lat;
  }

  double getLon() {
    return lon;
  }

  int getAlt() {
    return alt;
  }
}
