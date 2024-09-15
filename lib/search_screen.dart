import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typesense_demo/product.dart';
import 'package:typesense_demo/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        elevation: 0,
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          _SearchBar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _FacetFilters()),
                Expanded(flex: 3, child: _SearchResults()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.yellow,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => searchProvider.search(query: value),
      ),
    );
  }
}

class _FacetFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    return Container(
      color: Colors.grey[100],
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFacetSection('Category', searchProvider),
          _buildFacetSection('Brand', searchProvider),
          _buildSortBySection(searchProvider),
        ],
      ),
    );
  }
}

Widget _buildFacetSection(String facet, SearchProvider searchProvider) {
  return ExpansionTile(
    title: Text(facet, style: const TextStyle(fontWeight: FontWeight.bold)),
    children: (searchProvider.facets[facet.toLowerCase()] ?? []).map((value) {
      final isSelected =
          searchProvider.selectedFacets[facet.toLowerCase()]?.contains(value) ??
              false;
      return CheckboxListTile(
        title: Text(value),
        value: isSelected,
        onChanged: (bool? newValue) {
          searchProvider.updateFacetFilter(
              facet.toLowerCase(), value, newValue ?? false);
        },
        dense: true,
      );
    }).toList(),
  );
}

Widget _buildSortBySection(SearchProvider searchProvider) {
  return ExpansionTile(
    title: const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
    children: [
      RadioListTile(
        title: const Text('Rating (High to Low)'),
        value: 'rating:desc',
        groupValue: searchProvider.sortBy,
        onChanged: (value) => searchProvider.updateSortBy(value.toString()),
        dense: true,
      ),
      RadioListTile(
        title: const Text('Price (Low to High)'),
        value: 'price:asc',
        groupValue: searchProvider.sortBy,
        onChanged: (value) => searchProvider.updateSortBy(value.toString()),
        dense: true,
      ),
    ],
  );
}

class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    return searchProvider.products.isEmpty
        ? const Center(child: Text('No products found'))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: searchProvider.products.length,
            itemBuilder: (context, index) {
              final product = searchProvider.products[index];
              return _ProductCard(product: product);
            },
          );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl:
                    'https://img.freepik.com/free-vector/illustration-gallery-icon_53876-27002.jpg', // Assuming you have an imageUrl in your Product model
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.brand,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${product.rating.toStringAsFixed(1)}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
