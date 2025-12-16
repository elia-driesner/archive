import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton(this.size, this.text, this.function, {super.key});
  final List<double> size;
  final String text;
  final VoidCallback function;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: size[0],
        height: size[1],
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: function,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColorLight)),
                ),
                const Spacer(),
                Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      size: 26,
                      color: Theme.of(context).primaryColorLight,
                    )),
              ],
            )),
      ),
    );
  }
}
