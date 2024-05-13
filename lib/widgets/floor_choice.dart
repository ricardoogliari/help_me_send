import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final List<bool> floor = [
  false, false, false
];
final List<String> floorOptions = [
  'Andar Baixo', 'Andar Médio', 'Andar Alto'
];

int getFloorPosition() => floor.indexOf(true);

Widget makeFloorChoices(Function callback) => Wrap(
  spacing: 12,
  children: [
    _makeItemFloorChoice(0, callback),
    _makeItemFloorChoice(1, callback),
    _makeItemFloorChoice(2, callback),
  ],
);

Widget _makeItemFloorChoice(int index, Function callback) =>
    ChoiceChip(
      label: Text(floorOptions[index]),
      selected: floor[index],
      onSelected: (value) {
        floor.fillRange(0, 3, false);
        floor[index] = true;
        callback.call();
      },
    );
