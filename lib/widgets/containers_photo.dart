import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final List<XFile> selectedFiles = [];

Widget makeContainerWithPhoto(int index, Function callback) => InkWell(
    child: Image.file(
      File(selectedFiles[index].path),
      fit: BoxFit.cover,),
    onLongPress: () => callback.call()
);

Widget makeContainerWithoutPhoto() => Container(
  padding: const EdgeInsets.all(8),
  color: Colors.teal[100],
  child: const Text("Faça seu melhor"),
);