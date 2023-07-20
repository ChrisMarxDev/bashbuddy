import 'package:flutter/material.dart';

class BashBuddySearchBar extends StatelessWidget {
  const BashBuddySearchBar({
    super.key,
     this.controller,
    required this.onChanged
  });

  final TextEditingController? controller;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}