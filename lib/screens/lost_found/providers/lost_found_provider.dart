import 'package:flutter/foundation.dart';
import '../models/lost_found_item.dart';
import '../repositories/lost_found_repository.dart';

class LostFoundProvider extends ChangeNotifier {
  final LostFoundRepository _repository = LostFoundRepository();

  // --- State ---
  List<LostFoundItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedType = 'lost'; // 'lost' or 'found'
  String _searchQuery = '';
  String _sortBy = 'latest'; // 'latest', 'oldest', 'alphabetical'

  // --- Getters ---
  List<LostFoundItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  // --- Actions ---

  void setSelectedType(String type) {
    if (_selectedType == type) return;
    _selectedType = type;
    notifyListeners();
    loadItems();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadItems();
  }

  void setSortBy(String sort) {
    if (_sortBy == sort) return;
    _sortBy = sort;
    notifyListeners();
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.fetchItems(
        type: _selectedType,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load items: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem(LostFoundItem item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addItem(item);
      // Reload items after adding
      await loadItems();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add item: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String docId, String currentUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deleted = await _repository.deleteItem(docId, currentUserId);
      if (!deleted) {
        _errorMessage = 'You can only delete your own posts.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await loadItems();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
