import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  GoogleMapController? mapaController;

  static const LatLng ubicacionFloreria = LatLng(19.6890, -99.1280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Ubicación',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),

        child: Column(
          children: [
            // ==========================================
            // MAPA
            // ==========================================
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: ubicacionFloreria,
                      zoom: 16,
                    ),

                    markers: {
                      const Marker(
                        markerId: MarkerId('floreria_ambar'),

                        position: ubicacionFloreria,

                        infoWindow: InfoWindow(
                          title: 'Florería Ámbar 🌸',
                          snippet: 'Flores y arreglos personalizados',
                        ),
                      ),
                    },

                    onMapCreated: (controller) {
                      mapaController = controller;
                    },

                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==========================================
            // INFORMACIÓN
            // ==========================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,

                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(13),
                        ),

                        child: const Icon(
                          Icons.storefront_outlined,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Florería Ámbar',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Nuestra ubicación',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Encuéntranos y visita nuestra tienda.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // BOTÓN
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      icon: const Icon(Icons.navigation_outlined, size: 20),

                      label: const Text(
                        'Cómo llegar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      onPressed: () {
                        mapaController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            const CameraPosition(
                              target: ubicacionFloreria,
                              zoom: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
