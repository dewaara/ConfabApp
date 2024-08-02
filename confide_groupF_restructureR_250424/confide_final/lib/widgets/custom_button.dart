import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xffe2e7ef)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xff0c2c63)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/google.png", // Replace with your image path
            width: 40, // Adjust the image size as needed
            height: 40,
          ),
          const SizedBox(width: 8), // Adjust the spacing between image and text
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
