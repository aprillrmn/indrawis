import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsView extends StatelessWidget {
  final LatLng currentPosition;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback onRefreshPressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onDirectionsPressed;

  const MapsView({
    Key? key,
    required this.currentPosition,
    required this.onMapCreated,
    required this.onRefreshPressed,
    required this.onBookmarkPressed,
    required this.onDirectionsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentPosition,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('current'),
              position: currentPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: const InfoWindow(title: 'Lokasi Saya'),
            ),
          },
          onMapCreated: onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          bottom: 250,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'refresh_fab',
                onPressed: onRefreshPressed,
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'bookmark_fab',
                onPressed: onBookmarkPressed,
                child: const Icon(Icons.bookmark),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'directions_fab',
                onPressed: onDirectionsPressed,
                child: const Icon(Icons.directions),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
