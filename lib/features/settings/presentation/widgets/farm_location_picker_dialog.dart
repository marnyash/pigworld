import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmLocationSelection {
  const FarmLocationSelection({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

class FarmLocationPickerDialog extends StatefulWidget {
  const FarmLocationPickerDialog({
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    super.key,
  });

  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<FarmLocationPickerDialog> createState() =>
      _FarmLocationPickerDialogState();
}

class _FarmLocationPickerDialogState extends State<FarmLocationPickerDialog> {
  static const _defaultPosition = LatLng(-1.286389, 36.817223);

  late LatLng _selected;
  late final GoogleMapController _controller;
  late final TextEditingController _searchController;
  String _address = '';
  bool _resolvingAddress = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLatitude != null && widget.initialLongitude != null
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _defaultPosition;
    _address = widget.initialAddress ?? '';
    _searchController = TextEditingController(text: _address);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Set farm location'),
    content: SizedBox(
      width: 620,
      height: MediaQuery.sizeOf(context).height * .62,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchAddress(),
                  decoration: InputDecoration(
                    hintText: 'Search address or place',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Search map',
                      onPressed: _searching ? null : _searchAddress,
                      icon: _searching
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Use current location',
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _selected, zoom: 14),
                onMapCreated: (controller) => _controller = controller,
                onTap: _selectPoint,
                markers: {
                  Marker(
                    markerId: const MarkerId('farm-location'),
                    position: _selected,
                    draggable: true,
                    onDragEnd: _selectPoint,
                  ),
                },
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _resolvingAddress
                      ? 'Finding address…'
                      : _address.isEmpty
                      ? 'Tap the map to choose the farm location'
                      : _address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _address.trim().isEmpty ? null : _save,
        icon: const Icon(Icons.check),
        label: const Text('Save location'),
      ),
    ],
  );

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searching = true);
    try {
      final matches = await locationFromAddress(query);
      if (matches.isEmpty) throw const FormatException('No location found.');
      final match = matches.first;
      await _select(LatLng(match.latitude, match.longitude));
    } catch (_) {
      if (mounted) _message('Could not find that place. Try a more specific address.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Enable location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is needed to use your current location.');
      }
      final position = await Geolocator.getCurrentPosition();
      await _select(LatLng(position.latitude, position.longitude));
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _selectPoint(LatLng point) => _select(point);

  Future<void> _select(LatLng point) async {
    setState(() {
      _selected = point;
      _resolvingAddress = true;
    });
    await _controller.animateCamera(CameraUpdate.newLatLngZoom(point, 15));
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((part) => part?.trim().isNotEmpty == true).join(', ');
        if (address.isNotEmpty) _searchController.text = address;
        if (mounted) setState(() => _address = address);
      }
    } catch (_) {
      // The selected coordinates are still usable when reverse geocoding fails.
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  void _save() => Navigator.pop(
    context,
    FarmLocationSelection(
      address: _address.trim(),
      latitude: _selected.latitude,
      longitude: _selected.longitude,
    ),
  );

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
