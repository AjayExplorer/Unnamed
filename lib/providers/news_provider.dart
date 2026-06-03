import 'package:flutter/foundation.dart';
import '../models/news_feed.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NewsPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNewsPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _newsService.getAllNewsPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load news: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addNewsPost(NewsPost post) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _newsService.addNewsPost(post);
      await loadNewsPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add news: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNewsPost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _newsService.deleteNewsPost(postId);
      await loadNewsPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete news: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
