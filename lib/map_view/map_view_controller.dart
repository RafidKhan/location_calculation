import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

const markerIcon = MarkerIcon(
  icon: Icon(
    Icons.place,
    color: Colors.red,
    size: 15,
  ),
);

class MapViewController extends GetxController {
  RxBool isLoading = true.obs;
  RxString distance = "".obs;
  RxString time = "".obs;

  Rx<RoadType> selectedRoadType = Rx<RoadType>(RoadType.car);

  final List<RoadType> roadTypes = [
    RoadType.car,
    RoadType.bike,
    RoadType.foot,
  ];

  void selectRoadType(RoadType roadType) {
    selectedRoadType.value = roadType;
  }

  late final MapController mapController;

  final List<GeoPoint> positions = [];

  GeoPoint? myCurrentPoint;
  GeoPoint? destinationPoint;

  final Location location = Location();

  @override
  onInit() {
    super.onInit();
    setMapController();
  }

  Future<void> addNewLocation(GeoPoint start) async {
    myCurrentPoint = start;
    positions.add(myCurrentPoint!);

    await mapController.removeLastRoad();
    await mapController.removeMarkers(positions);
    await mapController.addMarker(
      destinationPoint!,
      markerIcon: markerIcon,
    );
    await mapController.addMarker(
      start,
      markerIcon: markerIcon,
    );

    final RoadInfo roadInfo = await mapController.drawRoad(
      myCurrentPoint!,
      destinationPoint!,
      roadType: selectedRoadType.value,
      roadOption: const RoadOption(
        roadColor: Colors.orangeAccent,
        roadBorderWidth: 10,
        roadBorderColor: Colors.deepOrange,
        roadWidth: 20,
      ),
    );

    final double distanceInMiles = (roadInfo.distance ?? 0) * 1000;
    distance.value = "${distanceInMiles.round()} Meters";

    final durationInSeconds = (roadInfo.duration ?? 0).round();
    final durationInMinutes = (durationInSeconds / 60).round();

    time.value = durationInSeconds <= 60
        ? "$durationInSeconds Sec"
        : "$durationInMinutes Min";
  }

  Future<void> checkPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future listenToPosition() async {
    checkPermission().then((value) {
      location.onLocationChanged.listen((LocationData currentLocation) {
        addNewLocation(
          GeoPoint(
            latitude: currentLocation.latitude ?? 0,
            longitude: currentLocation.longitude ?? 0,
          ),
        );
      });
    });
  }

  setMapController() {
    isLoading.value = true;
    checkPermission().then((value) async {
      final position = await location.getLocation();
      myCurrentPoint = GeoPoint(
        latitude: position.latitude ?? 0,
        longitude: position.longitude ?? 0,
      );

      mapController = MapController(
        initPosition: myCurrentPoint,
      );

      isLoading.value = false;
    });
  }

  pickLocation(BuildContext context) async {
    await showSimplePickerLocation(
      context: context,
      isDismissible: true,
      title: "Pick Location",
      textConfirmPicker: "pick",
      zoomOption: const ZoomOption(initZoom: 40),
      initCurrentUserPosition: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: true,
      ),
    ).then((position) async {
      if (position != null) {
        await mapController.goToLocation(position);
        destinationPoint = position;
        listenToPosition();
      }
    });
  }
}
