import 'package:flutter/material.dart';

class CustomizedTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;
  final Function(String) onChanged; // ✅ New: Trigger API call when typing
  final Function(String) onSuggestionSelected; // ✅ New: Handle selection
  final List<String> suggestions; // ✅ New: Pass fetched predictions

  const CustomizedTextField({
    super.key,
    required this.text,
    required this.controller,
    required this.padding,
    required this.onChanged,
    required this.onSuggestionSelected,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: text,
              fillColor: Colors.white,
              filled: true,
              suffixIcon: const Icon(Icons.search),
            ),
            onChanged: onChanged, 
          ),
          if (suggestions.isNotEmpty) 
            Container(
              color: Colors.white,
              child: Column(
                children: suggestions
                    .map(
                      (suggestion) => ListTile(
                        title: Text(suggestion),
                        onTap: () => onSuggestionSelected(suggestion),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
