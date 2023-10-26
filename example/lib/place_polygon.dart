// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vietmap_iee_map/vietmap_flutter_gl.dart';

import 'constant.dart';
import 'page.dart';

class PlacePolygonPage extends ExamplePage {
  PlacePolygonPage() : super(const Icon(Icons.check_circle), 'Place polygon');

  @override
  Widget build(BuildContext context) {
    return const PlacePolygonBody();
  }
}

class PlacePolygonBody extends StatefulWidget {
  const PlacePolygonBody();

  @override
  State<StatefulWidget> createState() => PlacePolygonBodyState();
}

class PlacePolygonBodyState extends State<PlacePolygonBody> {
  PlacePolygonBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);
  final String _polygonPatternImage = "assets/fill/cat_silhouette_pattern.png";

  final List<List<LatLng>> _defaultGeometry = [
    [
      LatLng(-33.719, 151.150),
      LatLng(-33.858, 151.150),
      LatLng(-33.866, 151.401),
      LatLng(-33.747, 151.328),
      LatLng(-33.719, 151.150),
    ],
    [
      LatLng(-33.762, 151.250),
      LatLng(-33.827, 151.250),
      LatLng(-33.833, 151.347),
      LatLng(-33.762, 151.250),
    ]
  ];

  VietmapController? controller;
  int _polygonCount = 0;
  Polygon? _selectedPolygon;
  bool isSelected = false;

  void _onMapCreated(VietmapController controller) {
    this.controller = controller;
    controller.onPolygonTapped.add(_onPolygonTapped);
    this.controller!.onFeatureDrag.add(_onFeatureDrag);
  }

  void _onFeatureDrag(id,
      {required current,
      required delta,
      required origin,
      required point,
      required eventType}) {
    DragEventType type = eventType;
    switch (type) {
      case DragEventType.start:
        // TODO: Handle this case.
        break;
      case DragEventType.drag:
        // TODO: Handle this case.
        break;
      case DragEventType.end:
        // TODO: Handle this case.
        break;
    }
  }

  void _onStyleLoaded() {
    addImageFromAsset("assetImage", _polygonPatternImage);
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller!.addImage(name, list);
  }

  @override
  void dispose() {
    controller?.onPolygonTapped.remove(_onPolygonTapped);
    super.dispose();
  }

  void _onPolygonTapped(Polygon polygon) {
    setState(() {
      _selectedPolygon = polygon;

      isSelected = true;
    });
    print('Polygon selected');
  }

  void _updateSelectedPolygon(PolygonOptions changes) {
    controller!.updatePolygon(_selectedPolygon!, changes);
  }

  void _add() {
    controller!.addPolygon(PolygonOptions(
      geometry: _defaultGeometry,
      polygonColor: Color(0xFFFF0000),
      polygonOutlineColor: Color(0xFFFF0000),
    ));
    setState(() {
      _polygonCount += 1;
    });
  }

  void _remove() {
    controller!.removePolygon(_selectedPolygon!);
    setState(() {
      _selectedPolygon = null;
      _polygonCount -= 1;
    });
  }

  void _changePosition() {
    List<List<LatLng>>? geometry = _selectedPolygon!.options.geometry;

    if (geometry == null) {
      geometry = _defaultGeometry;
    }

    _updateSelectedPolygon(PolygonOptions(
        geometry: geometry
            .map((list) => list
                .map(
                    // Move to right with 0.1 degree on longitude
                    (latLng) => LatLng(latLng.latitude, latLng.longitude + 0.1))
                .toList())
            .toList()));
  }

  void _changeDraggable() {
    bool? draggable = _selectedPolygon!.options.draggable;
    if (draggable == null) {
      // default value
      draggable = false;
    }
    _updateSelectedPolygon(
      PolygonOptions(draggable: !draggable),
    );
  }

  Future<void> _changePolygonOpacity() async {
    double? current = _selectedPolygon!.options.polygonOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedPolygon(
      PolygonOptions(polygonOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changePolygonColor() async {
    Color? current = _selectedPolygon!.options.polygonColor;
    if (current == null) {
      // default value
      current = Color(0xFFFF0000);
    }

    _updateSelectedPolygon(
      PolygonOptions(polygonColor: Color(0xFFFF0000)),
    );
  }

  Future<void> _changePolygonOutlineColor() async {
    Color? current = _selectedPolygon!.options.polygonOutlineColor;
    if (current == null) {
      // default value
      current = Color(0xFFFF0000);
    }

    _updateSelectedPolygon(
      PolygonOptions(polygonOutlineColor: Color(0xFFFFFF00)),
    );
  }

  Future<void> _changePolygonPattern() async {
    String? current =
        _selectedPolygon!.options.polygonPattern == null ? "assetImage" : null;
    _updateSelectedPolygon(
      PolygonOptions(polygonPattern: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: VietmapGL(
              styleString: YOUR_STYLE_URL_HERE,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 7.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        ElevatedButton(
                          child: const Text('add'),
                          onPressed: (_polygonCount == 12) ? null : _add,
                        ),
                        ElevatedButton(
                          child: const Text('remove'),
                          onPressed:
                              (_selectedPolygon == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        ElevatedButton(
                          child: const Text('change polygon-opacity'),
                          onPressed: (_selectedPolygon == null)
                              ? null
                              : _changePolygonOpacity,
                        ),
                        ElevatedButton(
                          child: const Text('change polygon-color'),
                          onPressed: (_selectedPolygon == null)
                              ? null
                              : _changePolygonColor,
                        ),
                        ElevatedButton(
                          child: const Text('change polygon-outline-color'),
                          onPressed: (_selectedPolygon == null)
                              ? null
                              : _changePolygonOutlineColor,
                        ),
                        ElevatedButton(
                          child: const Text('change polygon-pattern'),
                          onPressed: (_selectedPolygon == null)
                              ? null
                              : _changePolygonPattern,
                        ),
                        ElevatedButton(
                          child: const Text('change position'),
                          onPressed: (_selectedPolygon == null)
                              ? null
                              : _changePosition,
                        ),
                        ElevatedButton(
                          child: const Text('toggle draggable'),
                          onPressed: (_selectedPolygon == null)
                              ? null
                              : _changeDraggable,
                        ),
                        Text(isSelected
                            ? "You selected a polygon"
                            : "No polygon has been selected")
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
