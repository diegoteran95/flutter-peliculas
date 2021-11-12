import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_peliculas/helpers/debouncer.dart';
import 'package:flutter_peliculas/models/models.dart';
import 'package:flutter_peliculas/models/search_response.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier {
  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '614ac3fd9eb46196aecfff6d582ad08e';
  String _language = 'es-ES';
  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionsStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      this._suggestionsStreamController.stream;

  MoviesProvider() {
    print('Movies provider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  getOnDisplayMovies() async {
    final response = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(response);

    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final response = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(response);
    print(popularResponse);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    print("pidiendo info de actores");
    final response = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(response);
    print(response);
    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': '${query}'});
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await this.searchMovies(searchTerm);
      this._suggestionsStreamController.add(results);
    };
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }

  Future<String> _getJsonData(String path, [int page = 1]) async {
    final url = Uri.https(_baseUrl, path,
        {'api_key': _apiKey, 'language': _language, 'page': '${page}'});

    final response = await http.get(url);

    return response.body;
  }
}
