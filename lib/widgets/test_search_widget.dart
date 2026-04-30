import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/loinc_master.dart';

class TestSearchWidget extends StatefulWidget {
  final Function(LoincMaster) onSelect;
  const TestSearchWidget({super.key, required this.onSelect});

  @override
  State<TestSearchWidget> createState() => _TestSearchWidgetState();
}

class _TestSearchWidgetState extends State<TestSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;

  void _onSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    // API Service se dynamic search
    final data = await ApiService.searchLabTests(query);
    setState(() {
      _results = data;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: "Search Lab Test (e.g. CBC)",
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          _isSearching
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final test = LoincMaster.fromJson(_results[index]);
                      return ListTile(
                        title: Text(test.longCommonName),
                        subtitle: Text(test.loincCode),
                        onTap: () {
                          widget.onSelect(test);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
