import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.black87,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunitoSans(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}
