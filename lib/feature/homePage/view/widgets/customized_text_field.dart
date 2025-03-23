import 'package:flutter/material.dart';
import 'package:uber_app/feature/homePage/model/google_map_model.dart';

class CustomizedTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;
  final Function(String) onChanged;
  final Function(Prediction) onSuggestionSelected;
  final List<Prediction> suggestions;

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
              child: Material(
                // Wrap with Material
                elevation: 4.0, // Add elevation for shadow
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final prediction = suggestions[index];
                    return ListTile(
                      title: Text(prediction.description),
                      onTap: () => onSuggestionSelected(prediction),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
