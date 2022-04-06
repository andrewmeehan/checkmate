import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_location/user_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../location.dart';
import '../../tournament.dart';

class MapPage extends StatelessWidget {
  final String uid;

  MapPage({Key? key, required this.uid}) : super(key: key);

  MapController mapController = MapController();
  final List<Marker> _markers = [];
  Location location = Location();
  late UserLocationOptions userLocationOptions;
  String location_id = 'X722uMAdIefDkVj3nqam';
  Tournament tour = Tournament();

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: _markers,
    );

    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection("tournaments").snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 23, 29, 43))));
        }
        if (snapshot.hasData) {
          List<Marker> curMarkers = [];
          snapshot.data!.docs.forEach((result) {
            curMarkers.add(Marker(
                point: LatLng(result['lat'], result['lon']),
                builder: (ctx) => const Icon(Icons.emoji_events_outlined,
                    color: Color.fromARGB(255, 255, 199, 46), size: 30)));
          });

          return FlutterMap(
            options: MapOptions(
                center: LatLng(0, 0),
                zoom: 15.0,
                plugins: [
                  UserLocationPlugin(),
                ],
                onLongPress: (latLng) {
                  tour
                      .isUserTournamentExistHere(
                          this.uid, latLng.latitude, latLng.longitude)
                      .then((value) => tour.onLongPressFunc(context, this.uid,
                          latLng.latitude, latLng.longitude, value));
                  print('${latLng.latitude}, ${latLng.longitude}');
                },
                onTap: (latLng) {}),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
                additionalOptions: {
                  // Paste the access token from the token.txt
                  'accessToken':
                      'pk.eyJ1IjoibmRray0wIiwiYSI6ImNremloa204cDFld3Uyd24yMjdxcTJlZjUifQ.3Di7cDFkBf-oKovlkYO_Tw',
                  'id': 'mapbox/streets-v11',
                },
              ),
              MarkerLayerOptions(markers: curMarkers),
              userLocationOptions,
            ],
            mapController: mapController,
          );
        }
        return Container();
      },
    ));
  }
}
