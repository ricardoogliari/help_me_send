import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final List<bool> solarPosition = [
  false, false, false, false
];
final List<String> solarPositionOptions = [
  'Norte', 'Sul', 'Leste', 'Oeste'
];

int getSolarPosition() => solarPosition.indexOf(true);

Widget makeSolarChoices(Function callback) => Wrap(
  spacing: 12,
  children: [
    _makeItemSolarChoice(0, callback),
    _makeItemSolarChoice(1, callback),
    _makeItemSolarChoice(2, callback),
    _makeItemSolarChoice(3, callback),
  ],
);

Widget _makeItemSolarChoice(int index, Function callback) =>
    ChoiceChip(
      label: Text(solarPositionOptions[index]),
      selected: solarPosition[index],
      onSelected: (value) {
        solarPosition.fillRange(0, 4, false);
        solarPosition[index] = true;
        callback.call();
      },
    );
