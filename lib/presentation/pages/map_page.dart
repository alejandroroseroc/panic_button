import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../controllers/alert_log_controller.dart';
import '../../models/alert_log_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _alertCtrl = Get.find<AlertLogController>();
  final Location _locService = Location();

  LatLng? _current;
  LatLng? _lastAlert;

  @override
  void initState() {
    super.initState();
    _initLocations();
  }

  Future<void> _initLocations() async {
    final perm = await _locService.requestPermission();
    if (perm == PermissionStatus.granted) {
      final locData = await _locService.getLocation();
      setState(() {
        _current = LatLng(locData.latitude!, locData.longitude!);
      });
    }
    final AlertLogModel? last = await _alertCtrl.getLast();
    if (last != null) {
      setState(() {
        _lastAlert = LatLng(last.latitude, last.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null && _lastAlert == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa de Alertas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final center = _current ?? _lastAlert!;

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Alertas')),
      body: FlutterMap(
        options: MapOptions(center: center, zoom: 13.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          if (_current != null)
            MarkerLayer(markers: [
              Marker(
                width: 40, height: 40,
                point: _current!,
                builder: (_) => const Icon(Icons.my_location, color: Colors.blue, size: 30),
              ),
            ]),
          if (_lastAlert != null)
            MarkerLayer(markers: [
              Marker(
                width: 40, height: 40,
                point: _lastAlert!,
                builder: (_) => const Icon(Icons.flag, color: Colors.red, size: 30),
              ),
            ]),
        ],
      ),
    );
  }
}
