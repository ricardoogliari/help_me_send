import 'dart:io';

import 'package:flutter/material.dart';
import 'package:help_me_send/controllers/address_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:help_me_send/controllers/gemini_controller.dart';
import 'package:help_me_send/widgets/containers_photo.dart';
import 'package:help_me_send/widgets/floor_choice.dart';
import 'package:help_me_send/widgets/other_choice.dart';
import 'package:help_me_send/widgets/solar_choice.dart';
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

  final AddressController _addressController = AddressController();
  final GeminiController _geminiController = GeminiController();

  final TextEditingController _environmentsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _parkingsController = TextEditingController();
  final TextEditingController _utilAreaController = TextEditingController();
  final TextEditingController _totalAreaController = TextEditingController();

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
                                  _makeContainer(0),
                                  _makeContainer(1),
                                  _makeContainer(2),
                                  _makeContainer(3),
                                  _makeContainer(4),
                                  _makeContainer(5)
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
                              makeSolarChoices((){ setState(() {}); }),
                              const SizedBox(height: 16,),
                              const Divider(height: 1,),
                              const SizedBox(height: 16,),
                              makeFloorChoices((){ setState(() {}); }),
                              const SizedBox(height: 16,),
                              const Divider(height: 1,),
                              const SizedBox(height: 16,),
                              const Text("Outros"),
                              makeOtherChoices(() { setState(() { }); }),
                              const SizedBox(height: 16,),
                              ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _responseText = "";
                                      _running = true;
                                    });
                                    Placemark placemark = await _addressController.determinePosition();
                                    _doMagic(context, placemark);
                                  },
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
  
  Widget _makeContainer(int index) => selectedFiles.length > index ? makeContainerWithPhoto(index, (){
      setState(() {
        selectedFiles.removeAt(index);
      });
    }) : makeContainerWithoutPhoto();

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
        selectedFiles.add(photo!);
      } else if (images.isNotEmpty){
        selectedFiles.addAll(images);
      }
    });

  }

  void _share() {
    Share.share(_responseText);
  }

  void _doMagic(BuildContext context, Placemark placemark) async {
    String environments = _environmentsController.text.isNotEmpty ? " ${_environmentsController.text} ambientes no total. " : "";
    String bathrooms = _bathroomsController.text.isNotEmpty ? "${_bathroomsController.text} banheiros. " : "";
    String bedrooms = _bedroomsController.text.isNotEmpty ? "${_bedroomsController.text} dormitórios. " : "";
    String parkins = _parkingsController.text.isNotEmpty ? "${_parkingsController.text} vagas de estacionamento. " : "";
    String utilArea = _utilAreaController.text.isNotEmpty ? "Área Ùtil de ${_utilAreaController.text} M². " : "";
    String totalArea = _totalAreaController.text.isNotEmpty ? "Área Total de ${_totalAreaController.text} M². " : "";
    int solarPosition = getSolarPosition();
    String solarPositionText = solarPosition >= 0 ? "${solarPositionOptions[solarPosition]}. " : "";
    int floorPosition = getFloorPosition();
    String floorText = floorPosition >= 0 ? "${floorOptions[floorPosition]}. " : "";
    String elevator = others[0] ? "Tem elevador. " : "";
    String newBuilding = others[1] ? "Imóvel novo. " : "";
    String furnished = others[2] ? "Imóvel mobiliado. " : "";
    String semiFurnished = others[3] ? "Imóvel semi-mobiliado. " : "";

    String fullText = "Você é um corretor. "
        "Analise as imagens e os dados de detalhe do imóvel para criar um texto de um parágrafo, que será usados como propaganda do imóvel. "
        "O endereço do imóvel é ${placemark.thoroughfare}, ${placemark.subThoroughfare}, ${placemark.subLocality}, ${placemark.subAdministrativeArea}. "
        "Detalhes do imóvel: $environments$bathrooms$bedrooms$parkins$utilArea$totalArea$solarPositionText$floorText$elevator$newBuilding$furnished$semiFurnished."
        "Não fale sobre características do imóvel que não existam nas fotos enviadas.";

    String response = await _geminiController.doMagic(context, fullText, selectedFiles);
    setState(() {
      _responseText = response;
    });
  }
}