import 'package:flutter/material.dart';
import 'text.dart';

class HeaderWithSearch extends StatefulWidget {
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const HeaderWithSearch({
    super.key,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  HeaderWithSearchState createState() => HeaderWithSearchState();
}

class HeaderWithSearchState extends State<HeaderWithSearch> {
  late String searchQuery;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery;
    searchController = widget.searchController;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                widget.onSearchChanged(value);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                hintStyle: style1(18, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: style(18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
