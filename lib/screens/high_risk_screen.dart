import 'package:flutter/material.dart';

class HighRiskScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const HighRiskScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE55A5A);
    final tempEsq = resultData['temp_mama_esq'] ?? 36.4;
    final tempDir = resultData['temp_mama_dir'] ?? 38.1;
    final diff = (tempEsq - tempDir).abs().toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('BIOMA', style: TextStyle(fontFamily: 'Caveat', fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: redColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                 Icon(Icons.signal_cellular_alt, color: Colors.orange),
                 SizedBox(width: 4),
                 Icon(Icons.battery_full, color: Colors.lightGreenAccent),
              ],
            )
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: redColor,
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Alto Risco', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                const Text('Consulta urgente recomendada', style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: redColor.withOpacity(0.5), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('O que isto significa', style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),
                        Text(
                          'O BIOMA detectou uma diferença de temperatura significativa entre as duas mamas ($diffºC). Isto pode indicar inflamação ou alteração que requer avaliação médica.',
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.psychology, color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Este resultado não é um diagnóstico. Apenas um médico pode confirmar.',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_hospital, color: Colors.blueGrey, size: 20),
                            SizedBox(width: 8),
                            Text('Onde ir agora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildHospitalItem('Hospital do Prenda', '1.8 km', '222 323 000'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(),
                        ),
                        _buildHospitalItem('Hospital Américo Boavida', '3.2 km', '222 370 991'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Abrir no mapa', style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_android, color: Colors.black87, size: 18),
                          label: const Text('Partilhar', style: TextStyle(color: Colors.black87)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.black87),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Pop Until Home
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Guardar alerta', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalItem(String name, String distance, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontStyle: FontStyle.italic)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 14),
            const SizedBox(width: 4),
            Text(distance, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic)),
            const SizedBox(width: 16),
            const Icon(Icons.phone, color: Colors.grey, size: 14),
            const SizedBox(width: 4),
            Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        )
      ],
    );
  }
}
