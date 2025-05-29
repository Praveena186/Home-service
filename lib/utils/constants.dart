import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const royalBg = Color(0xFFEDE7F6);

final royalTitle = GoogleFonts.poppins(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.deepPurple,
);

final royalButton = ElevatedButton.styleFrom(
  backgroundColor: Colors.deepPurple,
  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
