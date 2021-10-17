import 'package:flutter/material.dart';
import 'package:flutter_peliculas/widgets/movie_slider.dart';
import 'package:flutter_peliculas/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Películas en cines'),
        elevation: 0.0,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tarjetas principales
            CardSwipper(),

            // Slider ede peliculas
            MovieSlider()
            // Listado hotizontal de peliculas
          ],
        ),
      ),
    );
  }
}
