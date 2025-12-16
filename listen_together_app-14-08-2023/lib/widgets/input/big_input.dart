import 'package:flutter/material.dart';

class BigInput extends StatelessWidget {
  BigInput({
    Key? key,
    required this.size,
    required this.text,
    required this.controller,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
  }) : super(key: key);
  late List<double> size;
  late String text;
  late var controller;
  bool obscureText = false;
  late var textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: size[0],
        height: size[1],
        child: TextField(
          textAlign: textAlign,
          obscureText: obscureText,
          autocorrect: false,
          controller: controller,
          autofocus: true,
          cursorColor: Theme.of(context).primaryColorLight,
          cursorHeight: size[1] / 2,
          style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontSize: size[1] / 2.4),
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(width: 2, color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(width: 2, color: Colors.transparent)),
            fillColor: Theme.of(context).primaryColorLight,
            hintText: text,
            hintStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: size[1] / 2.4),
          ),
        ),
      ),
    );
  }
}
