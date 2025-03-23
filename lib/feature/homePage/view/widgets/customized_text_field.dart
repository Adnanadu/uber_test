import 'package:flutter/material.dart';
import 'package:uber_app/feature/homePage/model/google_map_model.dart';

class CustomizedTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;
  final Function(String) onChanged;
  final Function(Prediction) onSuggestionSelected; // ✅ Accepts `Prediction`
  final List<Prediction> suggestions; // ✅ Stores `Prediction` objects

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
                children:
                    suggestions
                        .map(
                          (prediction) => ListTile(
                            title: Text(
                              prediction.description,
                            ), // ✅ Show place name
                            onTap:
                                () => onSuggestionSelected(
                                  prediction,
                                ), // ✅ Ensure correct type
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
