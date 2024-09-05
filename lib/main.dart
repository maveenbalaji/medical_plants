import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Identification App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const PlantIdentificationPage(),
    );
  }
}

class PlantIdentificationPage extends StatefulWidget {
  const PlantIdentificationPage({super.key});

  @override
  _PlantIdentificationPageState createState() =>
      _PlantIdentificationPageState();
}

class _PlantIdentificationPageState extends State<PlantIdentificationPage> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  FlashMode _currentFlashMode = FlashMode.off;
  late Interpreter _interpreter;
  String _predictedPlant = '';
  String _plantDescription = '';
  bool _showDescription = false;
  final FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts


  final Map<int, String> classLabels = {
    0: 'Alpinia Galanga (Rasna)',
    1: 'Amaranthus Viridis (Arive-Dantu)',
    2: 'Artocarpus Heterophyllus (Jackfruit)',
    3: 'Mangifera Indica (Mango)',
    4: 'Basella Alba (Basale)',
    5: 'Brassica Juncea (Indian Mustard)',
    6: 'Carissa Carandas (Karanda)',
    7: 'Citrus Limon (Lemon)',
    8: 'Ficus Auriculata (Roxburgh fig)',
    9: 'Ficus Religiosa (Peepal Tree)',
    10: 'Nyctanthes Arbor-tristis (Parijata)',
    11: 'Jasminum (Jasmine)',
    12: 'Murraya Koenigii (Curry)',
    13: 'Mentha (Mint)',
    14: 'Moringa Oleifera (Drumstick)',
    15: 'Muntingia Calabura (Jamaica Cherry-Gasagase)',
    16: 'Azadirachta Indica (Neem)',
    17: 'Nerium Oleander (Oleander)',
    18: 'Hibiscus Rosa-sinensis',
    19: 'Ocimum Tenuiflorum (Tulsi)',
    20: 'Piper Betle (Betel)',
    21: 'Plectranthus Amboinicus (Mexican Mint)',
    22: 'Pongamia Pinnata (Indian Beech)',
    23: 'Psidium Guajava (Guava)',
    24: 'Punica Granatum (Pomegranate)',
    25: 'Santalum Album (Sandalwood)',
    26: 'Syzygium Cumini (Jamun)',
    27: 'Syzygium Jambos (Rose Apple)',
    28: 'Tabernaemontana Divaricata (Crape Jasmine)',
    29: 'Trigonella Foenum-graecum (Fenugreek)',
  };

  final Map<String, String> plantDescriptions = {
    'Alpinia Galanga (Rasna)': 'Description: Alpinia Galanga, commonly known as Rasna, is a herbaceous plant with aromatic rhizomes. It is native to Southeast Asia and is found in various regions of India, especially in the Western Ghats.\n\nMedical Uses:\n- Rasna is used in traditional Ayurvedic medicine for its anti-inflammatory and digestive properties.\n- It is believed to help alleviate joint pain and digestive disorders.\n\nRegional Distribution in India:\n- Rasna is primarily found in the Western Ghats, including states like Kerala and Karnataka.\n- It is also cultivated in other parts of India due to its medicinal value.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin A (15% DV), Vitamin C (9% DV)\n- Minerals: Calcium (4% DV), Iron (3% DV)',

    'Amaranthus Viridis (Arive-Dantu)': 'Description: Amaranthus Viridis, also called Arive-Dantu, is a leafy green vegetable packed with nutrients. It is a popular ingredient in many Indian dishes and is known for its health benefits.\n\nMedical Uses:\n- Arive-Dantu is used in traditional medicine for its digestive and diuretic properties.\n- It is considered beneficial for treating gastrointestinal issues.\n\nRegional Distribution in India:\n- Arive-Dantu is cultivated throughout India, with a significant presence in southern states like Karnataka and Tamil Nadu.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin A (47% DV), Vitamin C (50% DV)\n- Minerals: Iron (42% DV), Calcium (13% DV), Potassium (14% DV)',

    'Artocarpus Heterophyllus (Jackfruit)': 'Description: Artocarpus Heterophyllus, known as Jackfruit, is a tropical tree with the largest fruit of all trees. The fruit is sweet and can be eaten ripe or unripe, and it\'s used in various culinary preparations.\n\nMedical Uses:\n- Jackfruit seeds are used in traditional medicine for their diuretic properties.\n\nRegional Distribution in India:\n- Jackfruit is widely cultivated in southern and coastal regions of India, including Kerala, Karnataka, and Maharashtra.\n\nNutritional Content (per 100g of fruit):\n- Vitamins: Vitamin C (18% DV), Vitamin A (1% DV)\n- Minerals: Potassium (10% DV), Magnesium (6% DV)',

    'Azadirachta Indica (Neem)': 'Description: Azadirachta Indica, commonly referred to as Neem, is a versatile tree widely distributed throughout India, especially in drier regions. Neem has various medicinal uses, including antibacterial, antiviral, and antifungal properties.\n\nMedical Uses:\n- Neem is used in traditional medicine for its antimicrobial properties.\n- It is known for treating skin conditions, dental issues, and as a natural insect repellent.\n\nRegional Distribution in India:\n- Neem trees are found in arid and semi-arid regions of India, including states like Rajasthan and Gujarat.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin C (50% DV)\n- Minerals: Calcium (1% DV), Iron (1% DV)',

    'Basella Alba (Basale)': 'Description: Basella Alba, also known as Basale or Malabar Spinach, thrives in warm and humid regions of India. It is known for its high iron content and is recommended for individuals with anemia. Basale leaves are rich in vitamins A and C.\n\nMedical Uses:\n- Basale is traditionally used to treat iron-deficiency anemia due to its high iron content.\n\nRegional Distribution in India:\n- Basale is cultivated in various parts of India, with a significant presence in southern states like Karnataka and Kerala.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin A (47% DV), Vitamin C (50% DV)\n- Minerals: Iron (42% DV), Calcium (13% DV), Potassium (14% DV)',

    'Brassica Juncea (Indian Mustard)': 'Description: Brassica Juncea, or Indian Mustard, is a cool-season crop grown in various parts of India. Its leaves and seeds are used both in cooking and traditional medicine. Indian Mustard leaves are a good source of vitamins A, C, and K, as well as minerals like calcium and potassium.\n\nMedical Uses:\n- Indian Mustard seeds are used in traditional medicine for various health benefits, including digestive support.\n\nRegional Distribution in India:\n- Indian Mustard is cultivated in different regions of India, with variations in climate.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin A (180% DV), Vitamin C (50% DV), Vitamin K (530% DV)\n- Minerals: Calcium (10% DV), Potassium (13% DV)',

    'Carissa Carandas (Karanda)': 'Description: Carissa Carandas, commonly known as Karanda or Karonda, is a small fruit-bearing shrub found in India, particularly in the northern and western regions. Karanda fruits have medicinal properties and are used in Ayurvedic preparations.\n\nMedical Uses:\n- Karanda fruits are traditionally used to treat digestive disorders and diarrhea.\n\nRegional Distribution in India:\n- Karanda is found in various states of India, including Rajasthan, Gujarat, and Maharashtra.\n\nNutritional Content (per 100g of fruits):\n- Vitamins: Vitamin C (20% DV)\n- Minerals: Calcium (6% DV), Iron (1% DV)',

    'Citrus Limon (Lemon)': 'Description: Citrus Limon, or Lemon, is a widely cultivated citrus fruit in India, especially in hilly and subtropical regions. Lemons are rich in vitamin C and are used for their antioxidant and immune-boosting properties.\n\nMedical Uses:\n- Lemon juice is used in traditional remedies for its digestive and detoxifying properties.\n\nRegional Distribution in India:\n- Lemons are cultivated in various states across India, including Himachal Pradesh, Uttarakhand, and parts of South India.\n\nNutritional Content (per 100g of fruit):\n- Vitamins: Vitamin C (64% DV)\n- Minerals: Potassium (2% DV)',

    'Ficus Auriculata (Roxburgh fig)': 'Description: Ficus Auriculata, also called Roxburgh Fig, produces small edible fruits and is found in various parts of India. Its leaves are used in traditional medicine for various purposes.\n\nMedical Uses:\n- Roxburgh Fig leaves are traditionally used for their potential medicinal properties.\n\nRegional Distribution in India:\n- Roxburgh Fig trees can be found in different regions of India, including the Himalayan foothills and parts of South India.\n\nNutritional Content (per 100g of leaves):\n- Limited nutritional data available.',

    'Ficus Religiosa (Peepal Tree)': 'Description: Ficus Religiosa, known as the Peepal Tree, is a sacred tree in Hinduism and Buddhism. It is known for its heart-shaped leaves and religious significance in India.\n\nMedical Uses:\n- Peepal leaves are traditionally used for various health purposes in Ayurveda.\n\nRegional Distribution in India:\n- Peepal trees are found throughout India, especially in areas with religious significance.\n\nNutritional Content (limited data available).',

    'Hibiscus Rosa-sinensis': 'Description: Hibiscus Rosa-sinensis, also known as the Chinese Hibiscus or Shoeblackplant, is a tropical shrub known for its beautiful flowers. It has various traditional medicinal uses in India.\n\nMedical Uses:\n- Hibiscus flowers and leaves are used in traditional remedies for their potential health benefits.\n\nRegional Distribution in India:\n- Hibiscus plants are cultivated in various parts of India, including South India.\n\nNutritional Content (limited data available).',

    'Jasminum (Jasmine)': 'Description: Jasmine is a fragrant flowering plant found in India. It is known for its aromatic flowers and has several traditional uses, including in perfumery.\n\nMedical Uses:\n- Jasmine flowers and essential oils are used in aromatherapy and traditional remedies.\n\nRegional Distribution in India:\n- Jasmine plants are cultivated in various regions of India for their flowers.\n\nNutritional Content (limited data available).',

    'Mangifera Indica (Mango)': 'Description: Mangifera Indica, the Mango tree, is widely grown in India for its sweet and juicy fruits. Mango leaves are also used in traditional medicine.\n\nMedical Uses:\n- Mango leaves are traditionally used for their potential health benefits.\n\nRegional Distribution in India:\n- Mango trees are cultivated throughout India, with variations in regional preferences for mango varieties.\n\nNutritional Content (limited data available).',

    'Mentha (Mint)': 'Description: Mint, a common herb in India, is known for its refreshing flavor and various medicinal uses. It is used in herbal teas and for digestive purposes.\n\nMedical Uses:\n- Mint leaves are used in traditional remedies for their digestive and soothing properties.\n\nRegional Distribution in India:\n- Mint is cultivated in various parts of India and is commonly found in home gardens.\n\nNutritional Content (limited data available).',

    'Moringa Oleifera (Drumstick)': 'Description: Moringa Oleifera, commonly known as Drumstick, is a nutritional powerhouse. It is rich in vitamins, minerals, and antioxidants, making it a valuable plant in India.\n\nMedical Uses:\n- Various parts of the Moringa tree are used in traditional medicine for their potential health benefits.\n\nRegional Distribution in India:\n- Moringa trees are cultivated in different regions of India, with variations in local names.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin A (763% DV), Vitamin C (156% DV)\n- Minerals: Calcium (19% DV), Iron (31% DV), Potassium (9% DV).',

    'Muntingia Calabura (Jamaica Cherry-Gasagase)': 'Description: Muntingia Calabura, known as Jamaica Cherry or Gasagase, is a small fruit-bearing tree found in India. The fruit has traditional uses and is a source of vitamin C.\n\nMedical Uses:\n- Jamaica Cherry fruits are traditionally used for their potential health benefits.\n\nRegional Distribution in India:\n- Jamaica Cherry trees are found in various states of India, including Kerala and Karnataka.\n\nNutritional Content (per 100g of fruits):\n- Vitamins: Vitamin C (150% DV)\n- Minerals: Limited data available.',

    'Murraya Koenigii (Curry)': 'Description: Murraya Koenigii, or Curry tree, is a spice tree used in Indian cooking. It has traditional medicinal uses and is known for its aromatic leaves.\n\nMedical Uses:\n- Curry leaves are used in traditional remedies for their potential health benefits.\n\nRegional Distribution in India:\n- Curry trees are cultivated in various regions of India, especially in South India.\n\nNutritional Content (limited data available).',

    'Nerium Oleander (Oleander)': 'Description: Nerium Oleander, commonly called Oleander, is an ornamental shrub in India. It has traditional uses but should be handled with caution due to its toxic properties.\n\nMedical Uses:\n- Oleander has limited medicinal uses due to its toxic nature.\n\nRegional Distribution in India:\n- Oleander plants are grown as ornamental shrubs in various parts of India.\n\nNutritional Content (limited data available).',

    'Nyctanthes Arbor-tristis (Parijata)': 'Description: Nyctanthes Arbor-tristis, known as Parijata or Night Jasmine, is a fragrant flowering plant with traditional medicinal uses in India.\n\nMedical Uses:\n- Parijata flowers are used in traditional remedies for their potential health benefits.\n\nRegional Distribution in India:\n- Parijata plants are cultivated in different regions of India, especially in areas with religious significance.\n\nNutritional Content (limited data available).',

    'Ocimum Tenuiflorum (Tulsi)': 'Description: Ocimum Tenuiflorum, or Tulsi, is a sacred herb in India. It has numerous traditional and medicinal uses, including in Ayurveda.\n\nMedical Uses:\n- Tulsi leaves are used in Ayurvedic medicine for their potential health benefits, including as an adaptogen and immunomodulator.\n\nRegional Distribution in India:\n- Tulsi plants are grown in various regions of India, often near homes and temples.\n\nNutritional Content (limited data available).',

    'Piper Betle (Betel)': 'Description: Piper Betle, or Betel leaf, is commonly used in traditional Indian chewing preparations. It has cultural and traditional significance.\n\nMedical Uses:\n- Betel leaves are used in traditional remedies, often in combination with other ingredients.\n\nRegional Distribution in India:\n- Betel leaves are grown in different regions of India and are a key ingredient in betel quid preparations.\n\nNutritional Content (limited data available).',

    'Plectranthus Amboinicus (Mexican Mint)': 'Description: Plectranthus Amboinicus, also known as Mexican Mint, is a medicinal plant used in traditional medicine in India.\n\nMedical Uses:\n- Mexican Mint leaves are traditionally used for their potential health benefits.\n\nRegional Distribution in India:\n- Mexican Mint is grown in various parts of India, often as a household herb.\n\nNutritional Content (limited data available).',

    'Pongamia Pinnata (Indian Beech)': 'Description: Pongamia Pinnata, known as Indian Beech, is a tree with traditional medicinal uses in India.\n\nMedical Uses:\n- Various parts of the Indian Beech tree have been used in traditional remedies for their potential health benefits.\n\nRegional Distribution in India:\n- Indian Beech trees are found in different regions of India, including coastal areas.\n\nNutritional Content (limited data available).',

    'Psidium Guajava (Guava)': 'Description: Psidium Guajava, or Guava, is a tropical fruit tree widely grown in India. It is known for its vitamin C content and various traditional uses.\n\nMedical Uses:\n- Guava fruits and leaves are traditionally used for their potential health benefits, including digestive support.\n\nRegional Distribution in India:\n- Guava trees are cultivated in various states of India, including Uttar Pradesh and Bihar.\n\nNutritional Content (per 100g of fruit):\n- Vitamins: Vitamin C (228% DV)\n- Minerals: Limited data available.',

    'Punica Granatum (Pomegranate)': 'Description: Punica Granatum, or Pomegranate, is a fruit-bearing tree in India known for its antioxidant-rich fruits and traditional medicinal uses.\n\nMedical Uses:\n- Pomegranate fruits and juice are traditionally used for their potential health benefits, including as an antioxidant.\n\nRegional Distribution in India:\n- Pomegranate trees are grown in various states of India, including Maharashtra and Punjab.\n\nNutritional Content (per 100g of fruit):\n- Vitamins: Vitamin C (10% DV)\n- Minerals: Potassium (2% DV).',

    'Santalum Album (Sandalwood)': 'Description: Santalum Album, or Sandalwood, is a fragrant tree in India. It is highly valued for its aromatic wood and traditional uses in perfumery and Ayurveda.\n\nMedical Uses:\n- Sandalwood is used in traditional remedies for its potential health benefits and aromatic properties.\n\nRegional Distribution in India:\n- Sandalwood trees are primarily found in the southern regions of India, including Karnataka.\n\nNutritional Content (limited data available).',

    'Syzygium Cumini (Jamun)': 'Description: Syzygium Cumini, or Jamun, is a fruit-bearing tree in India known for its sweet and tangy fruits. It has traditional uses and is a good source of nutrients.\n\nMedical Uses:\n- Jamun fruits and seeds are traditionally used for their potential health benefits.\n\nRegional Distribution in India:\n- Jamun trees are cultivated in different regions of India, including North India and parts of South India.\n\nNutritional Content (per 100g of fruit):\n- Vitamins: Vitamin C (18% DV)\n- Minerals: Potassium (15% DV).',

    'Syzygium Jambos (Rose Apple)': 'Description: Syzygium Jambos, known as Rose Apple, is a fruit tree with traditional uses in India. It produces sweet and aromatic fruits.\n\nMedical Uses:\n- Rose Apple fruits are traditionally consumed for their potential health benefits.\n\nRegional Distribution in India:\n- Rose Apple trees are grown in various states of India, including Kerala and Karnataka.\n\nNutritional Content (per 100g of fruit):\n- Vitamins: Vitamin C (22% DV)\n- Minerals: Limited data available.',

    'Tabernaemontana Divaricata (Crape Jasmine)': 'Description: Tabernaemontana Divaricata, or Crape Jasmine, is an ornamental plant with traditional medicinal uses in India.\n\nMedical Uses:\n- Crape Jasmine is used in traditional remedies for its potential health benefits.\n\nRegional Distribution in India:\n- Crape Jasmine is cultivated in various regions of India for its attractive flowers.\n\nNutritional Content (limited data available).',

    'Trigonella Foenum-graecum (Fenugreek)': 'Description: Trigonella Foenum-graecum, or Fenugreek, is a spice and herb with various traditional uses in Indian cuisine and Ayurveda.\n\nMedical Uses:\n- Fenugreek seeds and leaves are used in traditional remedies for their potential health benefits.\n\nRegional Distribution in India:\n- Fenugreek is cultivated in different parts of India and is used as a spice and a medicinal herb.\n\nNutritional Content (per 100g of leaves):\n- Vitamins: Vitamin A (220% DV), Vitamin C (13% DV)\n- Minerals: Iron (34% DV), Calcium (40% DV), Potassium (10% DV).',
  };


  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }
  void _speakPlantDescription() async {
    if (_showDescription) {
      await flutterTts.speak(_plantDescription);
    }
  }
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(camera, ResolutionPreset.medium);

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _isCameraReady = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'assets/plant_identification_model1.tflite',
        options: interpreterOptions,
      );
      _interpreter.allocateTensors();
      print("Model loaded successfully.");

      var inputShape = _interpreter.getInputTensor(0).shape;
      if (inputShape[0] != 1 ||
          inputShape[1] != 224 ||
          inputShape[2] != 224 ||
          inputShape[3] != 3) {
        print(
            "Input tensor shape does not match model expectations [1, 224, 224, 3].");
      } else {
        print("Input size matches model expectations.");
      }

      var outputShape = _interpreter.getOutputTensor(0).shape;
      _handleOutputShape(outputShape);
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void _handleOutputShape(List<int> outputShape) {
    if (outputShape.length == 2 && outputShape[0] == 1) {
      final numClasses = outputShape[1];
      print("Output size matches model expectations (numClasses: $numClasses).");
    } else {
      print("Output tensor shape does not match model expectations.");
    }
  }

  Future<void> _predictPlant(XFile image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final Uint8List inputImage = Uint8List.fromList(imageBytes);

      final inputImageData = Uint8List(224 * 224 * 3);
      final Float32List inputImageBuffer = Float32List(224 * 224 * 3);

      // Preprocess the input image
      for (var i = 0; i < inputImage.lengthInBytes; i++) {
        inputImageData[i] = inputImage[i] ~/ 255.0; // Normalize and convert to int
      }

      // Fill the input buffer with the preprocessed image data
      for (var i = 0; i < inputImageData.length; i++) {
        inputImageBuffer[i] = inputImageData[i].toDouble();
      }

      var outputShape = _interpreter.getOutputTensor(0).shape;
      _handleOutputShape(outputShape);

      var outputSize = outputShape.reduce((a, b) => a * b);
      var outputData = Float32List(outputSize);

      // Run inference
      await Future(() {
        _interpreter.run(inputImageBuffer.buffer.asUint8List(), outputData.buffer.asUint8List());
      });

      // Find the class with the highest probability
      var predictedIndex = outputData.indexOf(outputData.reduce((a, b) => a > b ? a : b));

      setState(() {
        _predictedPlant = classLabels[predictedIndex] ?? 'Unknown';
      });
    } catch (e) {
      print("Error during inference: $e");
    }
  }

  void _takePicture() async {
    try {
      final XFile image = await _cameraController!.takePicture();

      await _predictPlant(image);
      // Clear the description when a new picture is taken
      setState(() {
        _showDescription = false;
      });
        } catch (e) {
      print("Error taking picture: $e");
    }
  }

  void _fetchPlantDescription() {
    final constantDescription = plantDescriptions[_predictedPlant];
    if (constantDescription != null) {
      setState(() {
        _plantDescription = constantDescription;
        _showDescription = true; // Show the description
      });
    }
  }

  void _refreshCameraAndPrediction() async {
    try {
      await _initializeCamera();
      setState(() {
        _predictedPlant = '';
        _plantDescription = '';
        _showDescription = false; // Hide the description when refreshing
      });
    } catch (e) {
      print("Error refreshing camera and prediction: $e");
    }
  }

  void _toggleFlash() {
    setState(() {
      _currentFlashMode = _currentFlashMode == FlashMode.off
          ? FlashMode.auto
          : _currentFlashMode == FlashMode.auto
          ? FlashMode.always
          : FlashMode.off;
    });
    _setFlashMode(_currentFlashMode);
  }

  Future<void> _setFlashMode(FlashMode mode) async {
    try {
      await _cameraController!.setFlashMode(mode);
    } catch (e) {
      print("Error setting flash mode: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identification App'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _isCameraReady
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                onPressed: _toggleFlash,
                child: _currentFlashMode == FlashMode.off
                    ? const Icon(Icons.flash_off)
                    : _currentFlashMode == FlashMode.auto
                    ? const Icon(Icons.flash_auto)
                    : const Icon(Icons.flash_on),
              ),
              ElevatedButton(
                onPressed: _refreshCameraAndPrediction,
                child: const Icon(Icons.add),
              ),
              ElevatedButton(
                onPressed: _takePicture,
                child: const Icon(Icons.camera_alt),
              ),
              ElevatedButton(
                onPressed: _fetchPlantDescription,
                child: const Text('Description'),
              ),
              ElevatedButton(
                onPressed: _speakPlantDescription, // Add the "Voice" button
                child: const Text('Voice'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Predicted Plant: $_predictedPlant',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_showDescription)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Plant Description: $_plantDescription',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

}
