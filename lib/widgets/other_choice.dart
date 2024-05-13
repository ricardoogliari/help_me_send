import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final List<bool> others = [
  false, false, false, false
];
final List<String> othersOptions = [
  'Elevador', 'Novo', 'Mobiliado', 'Semimobiliado'
];

Widget makeOtherChoices(Function callback) => Wrap(
  spacing: 12,
  children: [
    _makeItemOtherChoice(0, callback),
    _makeItemOtherChoice(1, callback),
    _makeItemOtherChoice(2, callback),
    _makeItemOtherChoice(3, callback),
  ],
);

Widget _makeItemOtherChoice(int index, Function callback) =>
    ChoiceChip(
      label: Text(othersOptions[index]),
      selected: others[index],
      onSelected: (value) {
        if (index == 2 && value){
          others[3] = false;
        } else if (index == 3 && value){
          others[2] = false;
        }

        others[index] = value;
        callback.call();
      },
    );
