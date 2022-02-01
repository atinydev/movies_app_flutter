import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app_flutter/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  static const _apiKey = 'ec43a22728c6531c11a5f81fb6806031';
  static const _baseURl = 'api.themoviedb.org';
  static const _language = 'en-US';

  var onDisplayMovies = <Movie>[];
  var popularMovies = <Movie>[];
  var _popularPage = 0;
  final moviesCast = <int, List<Cast>>{};

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String unencodedPath, [int page = 1]) async {
    final url = Uri.https(_baseURl, unencodedPath, {
      'api_key': _apiKey,
      'language': _language,
      'page': page.toString(),
    });
    final response = await http.get(url);
    return response.body;
  }

  Future<void> getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  Future<void> getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) {
      return moviesCast[movieId]!;
    }
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }
}
