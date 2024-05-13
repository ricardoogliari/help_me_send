import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiController {

  Future<String> doMagic(BuildContext context, String fullText, List<XFile> _selectedFiles) async {
    const String API_KEY = String.fromEnvironment('API_KEY', defaultValue: 'https://default-api.example.com');
    final _visionModel = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: API_KEY,
    );
    final content = [
      Content.multi([
        TextPart(fullText),
        if (_selectedFiles.isNotEmpty) DataPart('image/jpeg', File(_selectedFiles[0].path).readAsBytesSync()),
        if (_selectedFiles.length > 1) DataPart('image/jpeg', File(_selectedFiles[1].path).readAsBytesSync()),
        if (_selectedFiles.length > 2) DataPart('image/jpeg', File(_selectedFiles[2].path).readAsBytesSync()),
        if (_selectedFiles.length > 3) DataPart('image/jpeg', File(_selectedFiles[3].path).readAsBytesSync()),
        if (_selectedFiles.length > 4) DataPart('image/jpeg', File(_selectedFiles[4].path).readAsBytesSync()),
        if (_selectedFiles.length > 4) DataPart('image/jpeg', File(_selectedFiles[5].path).readAsBytesSync())
      ])
    ];

    var response = await _visionModel.generateContent(content);
    return response.text ?? "";
  }
}