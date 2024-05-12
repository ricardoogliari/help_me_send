
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _responseText = "";
  bool _running = false;

  late Placemark placemark;

  final TextEditingController _environmentsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _parkingsController = TextEditingController();
  final TextEditingController _utilAreaController = TextEditingController();
  final TextEditingController _totalAreaController = TextEditingController();

  final List<XFile> _selectedFiles = [];
  final List<bool> _solarPosition = [
    false, false, false, false
  ];
  final List<String> _solarPositionOptions = [
    'Norte', 'Sul', 'Leste', 'Oeste'
  ];
  final List<bool> _floor = [
    false, false, false
  ];
  final List<String> _floorOptions = [
    'Andar Baixo', 'Andar Médio', 'Andar Alto'
  ];
  final List<bool> _others = [
    false, false, false, false
  ];
  final List<String> _othersOptions = [
    'Elevador', 'Novo', 'Mobiliado', 'Semimobiliado'
  ];

  void _selectPhotos(bool newPhoto) async {
    final ImagePicker _picker = ImagePicker();
    XFile? photo;
    late List<XFile> images;

    if (newPhoto){
      photo = await _picker.pickImage(source: ImageSource.camera);
    } else {
      images = await _picker.pickMultiImage();
    }

    setState(() {
      if (photo?.path != null){
        _selectedFiles.add(photo!);
      } else if (images.isNotEmpty){
        _selectedFiles.addAll(images);
      }
    });

  }

  void _share() {
    Share.share(_responseText);
  }

  void _doMagic(BuildContext context) {
    final gemini = Gemini.instance;

    String environments = _environmentsController.text.isNotEmpty ? " ${_environmentsController.text} ambientes no total. " : "";
    String bathrooms = _bathroomsController.text.isNotEmpty ? "${_bathroomsController.text} banheiros. " : "";
    String bedrooms = _bedroomsController.text.isNotEmpty ? "${_bedroomsController.text} dormitórios. " : "";
    String parkins = _parkingsController.text.isNotEmpty ? "${_parkingsController.text} vagas de estacionamento. " : "";
    String utilArea = _utilAreaController.text.isNotEmpty ? "Área Ùtil de ${_utilAreaController.text} M². " : "";
    String totalArea = _totalAreaController.text.isNotEmpty ? "Área Total de ${_totalAreaController.text} M². " : "";
    int solarPosition = _solarPosition.indexOf(true);
    String solarPositionText = solarPosition >= 0 ? "${_solarPositionOptions[solarPosition]}. " : "";
    int floorPosition = _floor.indexOf(true);
    String floorText = floorPosition >= 0 ? "${_floorOptions[floorPosition]}. " : "";
    String elevator = _others[0] ? "Tem elevador. " : "";
    String newBuilding = _others[1] ? "Imóvel novo. " : "";
    String furnished = _others[2] ? "Imóvel mobiliado. " : "";
    String semiFurnished = _others[3] ? "Imóvel semi-mobiliado. " : "";

    String fullText = "Você é um corretor. "
        "Analise as imagens e os dados de detalhe do imóvel para criar um texto de dois parágrafos, que serão usados como propaganda do imóvel. "
        "O endereço do imóvel é ${placemark.thoroughfare}, ${placemark.subThoroughfare}, ${placemark.subLocality}, ${placemark.subAdministrativeArea}. "
        "Detalhes do imóvel: $environments$bathrooms$bedrooms$parkins$utilArea$totalArea$solarPositionText$floorText$elevator$newBuilding$furnished$semiFurnished."
        "Não invente carasterísticas do imóvel que não foram passadas para você, como dependência de empregada, área de serviço.";

    gemini.streamGenerateContent(
        fullText,
        images: _selectedFiles.map((file) => File(file.path).readAsBytesSync()).toList(),
        generationConfig: GenerationConfig(
          maxOutputTokens: 8192,
          temperature: 0.25,
          topP: 0.95,
          topK: 0
        ),
        safetySettings: [
          SafetySetting(
              category: SafetyCategory.harassment,
              threshold: SafetyThreshold.blockMediumAndAbove),
          SafetySetting(
              category: SafetyCategory.dangerous,
              threshold: SafetyThreshold.blockMediumAndAbove),
          SafetySetting(
              category: SafetyCategory.hateSpeech,
              threshold: SafetyThreshold.blockMediumAndAbove),
          SafetySetting(
              category: SafetyCategory.sexuallyExplicit,
              threshold: SafetyThreshold.blockMediumAndAbove)]
    ).listen((value) {
      setState(() {
        _responseText = (_responseText + (value.output ?? "")).trim();
      });
    }).onError((e) {

    });

  }

  void _determinePosition(BuildContext context) async {
    setState(() {
      _responseText = "";
      _running = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    placemark = placemarks[0];
    _doMagic(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Ajude me a vender!"),
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                primary: false,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: 2,
                                children: <Widget>[
                                  _selectedFiles.isNotEmpty ? _makeContainerWithPhoto(0) : _makeContainerWithoutPhoto(),
                                  _selectedFiles.length > 1 ? _makeContainerWithPhoto(1) : _makeContainerWithoutPhoto(),
                                  _selectedFiles.length > 2 ? _makeContainerWithPhoto(2) : _makeContainerWithoutPhoto(),
                                  _selectedFiles.length > 3 ? _makeContainerWithPhoto(3) : _makeContainerWithoutPhoto(),
                                  _selectedFiles.length > 4 ? _makeContainerWithPhoto(4) : _makeContainerWithoutPhoto(),
                                  _selectedFiles.length > 5 ? _makeContainerWithPhoto(5) : _makeContainerWithoutPhoto()
                                ],
                              ),
                              const SizedBox(height: 16,),
                              OutlinedButton(
                                child: const Text("+ Foto da Câmera"),
                                onPressed: () => _selectPhotos(true),
                              ),
                              OutlinedButton(
                                child: const Text("+ Fotos da Galeria"),
                                onPressed: () => _selectPhotos(false),
                              ),
                            ],
                          )
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      controller: _environmentsController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Ambientes Totais',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12,),
                                  Expanded(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      controller: _bathroomsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Banheiros',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16,),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      controller: _bedroomsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Dormitórios',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12,),
                                  Expanded(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      controller: _parkingsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Vagas Estacionamento',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16,),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      controller: _utilAreaController,
                                      decoration: const InputDecoration(
                                        labelText: 'Área Útil',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12,),
                                  Expanded(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      controller: _totalAreaController,
                                      decoration: const InputDecoration(
                                        labelText: 'Área Total',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16,),
                              const Text("Posição Solar"),
                              _makeSolarChoices(),
                              const SizedBox(height: 16,),
                              const Divider(height: 1,),
                              const SizedBox(height: 16,),
                              _makeFloorChoices(),
                              const SizedBox(height: 16,),
                              const Divider(height: 1,),
                              const SizedBox(height: 16,),
                              const Text("Outros"),
                              _makeOtherChoices(),
                              const SizedBox(height: 16,),
                              ElevatedButton(
                                  onPressed: () => _determinePosition(context),
                                  child: const Text("Receber Sugestão"))
                            ],
                          )
                      ),
                    ),
                  ),
                ),
                if (_running)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: _responseText.isNotEmpty ?
                            Column(
                              children: [
                                Text(_responseText),
                                OutlinedButton(
                                    onPressed: _share,
                                    child: const Text('Compartilhar'))
                              ],
                            ) :
                            const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _makeSolarChoices() => Wrap(
    spacing: 12,
    children: [
      _makeItemSolarChoice(0),
      _makeItemSolarChoice(1),
      _makeItemSolarChoice(2),
      _makeItemSolarChoice(3),
    ],
  );

  Widget _makeItemSolarChoice(int index) =>
      ChoiceChip(
        label: Text(_solarPositionOptions[index]),
        selected: _solarPosition[index],
        onSelected: (value) {
          setState(() {
            _solarPosition.fillRange(0, 4, false);
            _solarPosition[index] = true;
          });
        },
      );

  Widget _makeFloorChoices() => Wrap(
    spacing: 12,
    children: [
      _makeItemFloorChoice(0),
      _makeItemFloorChoice(1),
      _makeItemFloorChoice(2),
    ],
  );

  Widget _makeItemFloorChoice(int index) =>
      ChoiceChip(
        label: Text(_floorOptions[index]),
        selected: _floor[index],
        onSelected: (value) {
          setState(() {
            _floor.fillRange(0, 3, false);
            _floor[index] = true;
          });
        },
      );

  Widget _makeOtherChoices() => Wrap(
    spacing: 12,
    children: [
      _makeItemOtherChoice(0),
      _makeItemOtherChoice(1),
      _makeItemOtherChoice(2),
      _makeItemOtherChoice(3),
    ],
  );

  Widget _makeItemOtherChoice(int index) =>
      ChoiceChip(
        label: Text(_othersOptions[index]),
        selected: _others[index],
        onSelected: (value) {
          if (index == 2 && value){
            _others[3] = false;
          } else if (index == 3 && value){
            _others[2] = false;
          }

          setState(() {
            _others[index] = value;
          });
        },
      );

  Widget _makeContainerWithPhoto(int index) => InkWell(
      child: Image.file(File(
          _selectedFiles[index].path),
        fit: BoxFit.cover,),
      onLongPress: () => setState(() {
        _selectedFiles.removeAt(index);
      })
  );

  Widget _makeContainerWithoutPhoto() => Container(
    padding: const EdgeInsets.all(8),
    color: Colors.teal[100],
    child: const Text("Faça seu melhor"),
  );

}