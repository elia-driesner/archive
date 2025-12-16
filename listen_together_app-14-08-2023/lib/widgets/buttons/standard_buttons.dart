import 'package:flutter/material.dart';

class WhiteButton extends StatelessWidget {
  const WhiteButton(this.size, this.text, this.function, {super.key});
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
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: function,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(text,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark)),
                ),
                Icon(Icons.arrow_forward,
                    color: Theme.of(context).primaryColorDark)
              ],
            )),
      ),
    );
  }
}

class AccentButton extends StatelessWidget {
  const AccentButton(this.size, this.text, this.function, {super.key});
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
              backgroundColor: Theme.of(context).focusColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: function,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColorDark)),
                ),
              ],
            )),
      ),
    );
  }
}

class DarkButton extends StatelessWidget {
  const DarkButton(this.size, this.text, this.function, {super.key});
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
              backgroundColor: Theme.of(context).primaryColorDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: function,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(text,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                ),
                Icon(Icons.arrow_forward,
                    color: Theme.of(context).primaryColorLight)
              ],
            )),
      ),
    );
  }
}

class TransparentButton extends StatelessWidget {
  const TransparentButton(this.size, this.text, this.function, {super.key});
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColorLight)),
                ),
              ],
            )),
      ),
    );
  }
}
