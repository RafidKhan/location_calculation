import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:map_tracker/map_view/map_view_controller.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapViewController());
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: controller.isLoading.isFalse
            ? FloatingActionButton(
                onPressed: () {
                  controller.pickLocation(context);
                },
                child: const Icon(Icons.location_on_outlined),
              )
            : null,
        body: controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  OSMFlutter(
                      controller: controller.mapController,
                      osmOption: OSMOption(
                        userTrackingOption: const UserTrackingOption(
                          enableTracking: true,
                          unFollowUser: true,
                        ),
                        zoomOption: const ZoomOption(
                          initZoom: 30,
                          minZoomLevel: 3,
                          maxZoomLevel: 19,
                          stepZoom: 1.0,
                        ),
                        userLocationMarker: UserLocationMaker(
                          personMarker: const MarkerIcon(
                            icon: Icon(
                              Icons.location_history_rounded,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                          directionArrowMarker: const MarkerIcon(
                            icon: Icon(
                              Icons.double_arrow,
                              size: 48,
                            ),
                          ),
                        ),
                        roadConfiguration: const RoadOption(
                          roadColor: Colors.orange,
                        ),
                        markerOption: MarkerOption(
                            defaultMarker: const MarkerIcon(
                          icon: Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 56,
                          ),
                        )),
                      )),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.all(10),
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.distance.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            controller.time.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(controller.roadTypes.length, (index) {
                          late final IconData icon;

                          if (index == 0) {
                            icon = Icons.car_rental;
                          } else if (index == 1) {
                            icon = Icons.directions_bike;
                          } else if (index == 2) {
                            icon = Icons.directions_walk;
                          }
                          final type = controller.roadTypes[index];

                          return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: InkWell(
                              onTap: () {
                                controller.selectRoadType(type);
                              },
                              child: Icon(
                                icon,
                                color: type == controller.selectedRoadType.value
                                    ? Colors.blue
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
