import 'package:flutter/material.dart';

class MyBarrier extends StatelessWidget {
  final double size;

  const MyBarrier({this.size});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth / 4,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/brickwall.png'),
          fit: BoxFit.cover,
        ),
        color: Colors.grey,
        border: Border.all(
          width: 4,
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
