import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class RoutesMapScreen extends StatefulWidget {
  const RoutesMapScreen({super.key});

  @override
  State<RoutesMapScreen> createState() => _RoutesMapScreenState();
}

class _RoutesMapScreenState extends State<RoutesMapScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  DateFormat.Hm().format(DateTime.now()),
                  style: GoogleFonts.roboto(fontSize: 20),
                ),
                Text(
                  DateFormat.MEd().format(DateTime.now()),
                  style: GoogleFonts.roboto(fontSize: 20),
                ),
              ],
            ),
            TabBar(
              tabs: [
                Text('Mon'),
                Text('Tue'),
                Text('Wed'),
                Text('Thu'),
                Text('Fri'),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.amber, width: 2.0),
                ),
                child: TabBarView(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.amber, width: 2.0),
                      ),
                      child: FlutterMap(
                        mapController: MapController(),
                        options: MapOptions(
                          initialCenter: LatLng(46.7687548, -92.1222135),
                          initialZoom: 10,
                          maxZoom: 21,
                          minZoom: 9,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.all &
                                ~InteractiveFlag
                                    .rotate, // "bitwise AND with NOT rotate" Disables rotation, but allows everything else (drag, pinch zoom, double-tap zoom, everything)
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.northern_buttons', // Required by OpenStreetMap's tile usage policy. You can find this in your android/app/build.gradle.kts file as applicationId and in your ios/Runner/Info.plist as CFBundleIdentifier. It should match the package name you used when creating the Flutter project.
                            // tileBounds: LatLngBounds(corner1, corner2),
                            // + many other options
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(46.805513, -92.091801),
                                child: Icon(
                                  Icons.location_on,
                                  size: 15,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 1, 150, 3),
                          width: 4.0,
                        ),
                      ),
                      child: Text(
                        'Tue',
                        style: GoogleFonts.roboto(fontSize: 26),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 152, 1, 1),
                          width: 4.0,
                        ),
                      ),
                      child: Text(
                        'Wed',
                        style: GoogleFonts.roboto(fontSize: 26),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 152, 1, 1),
                          width: 4.0,
                        ),
                      ),
                      child: Text(
                        'Thu',
                        style: GoogleFonts.roboto(fontSize: 26),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 152, 1, 1),
                          width: 4.0,
                        ),
                      ),
                      child: Text(
                        'Fri',
                        style: GoogleFonts.roboto(fontSize: 26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
