import 'package:flutter/material.dart';
import 'package:typesense_demo/product.dart';

import 'typesense_client.dart';

class SearchProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  Map<String, List<String>> _facets = {};
  Map<String, List<String>> get facets => _facets;

  String _query = '';
  String get query => _query;

  Map<String, List<String>> _selectedFacets = {};
  Map<String, List<String>> get selectedFacets => _selectedFacets;

  String _sortBy = 'rating:desc';
  String get sortBy => _sortBy;

  Future<void> search({
    String? query,
    Map<String, List<String>>? facetFilters,
    String? sortBy,
  }) async {
    _query = query ?? _query;
    _selectedFacets = facetFilters ?? _selectedFacets;
    _sortBy = sortBy ?? _sortBy;

    final searchParameters = {
      'q': _query,
      'query_by': 'name,description,category,brand',
      'facet_by': 'category,brand,rating',
      'sort_by': _sortBy,
      'per_page': '20',
    };

    if (_selectedFacets.isNotEmpty) {
      searchParameters['filter_by'] = _selectedFacets.entries
          .map((e) => '${e.key}:[${e.value.join(',')}]')
          .join(' && ');
    }

    try {
      final searchResult = await TypesenseClient.instance
          .collection('products')
          .documents
          .search(searchParameters);

      _products = (searchResult['hits'] as List)
          .map((hit) => Product.fromJson(hit['document']))
          .toList();

      _facets = {};
      for (var facet in (searchResult['facet_counts'] as List)) {
        _facets[facet['field_name']] = (facet['counts'] as List)
            .map((c) => c['value'].toString())
            .toList();
      }

      notifyListeners();
    } catch (e) {
      print('Error searching products: $e');
    }
  }

  void updateFacetFilter(String facet, String value, bool isSelected) {
    if (isSelected) {
      _selectedFacets[facet] = [...(_selectedFacets[facet] ?? []), value];
    } else {
      _selectedFacets[facet]?.remove(value);
      if (_selectedFacets[facet]?.isEmpty ?? false) {
        _selectedFacets.remove(facet);
      }
    }
    search();
  }

  void updateSortBy(String newSortBy) {
    _sortBy = newSortBy;
    search();
  }
}
