import 'package:flutter/material.dart';

Widget buildHeaderText(int index, int length) {
  return RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      children: [
        const TextSpan(
          text: 'Question ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextSpan(
          text: index
              .toString()
              .padLeft(2, '0'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        TextSpan(
          text: '/$length',
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}
