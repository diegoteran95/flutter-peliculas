import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_peliculas/models/models.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier {
  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '614ac3fd9eb46196aecfff6d582ad08e';
  String _language = 'es-ES';
  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  int _popularPage = 0;

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

  Future<String> _getJsonData(String path, [int page = 1]) async {
    var url = Uri.https(_baseUrl, path,
        {'api_key': _apiKey, 'language': _language, 'page': '${page}'});

    final response = await http.get(url);

    return response.body;
  }
}
