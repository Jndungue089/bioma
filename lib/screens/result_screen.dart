import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.resultData['classificacao_risco'] == 'Atenção') {
        _showAttentionModal(context);
      }
    });
  }

  void _showAttentionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
              const SizedBox(height: 8),
              const Text('Atenção', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange, fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              const Text('Detectámos uma assimetria térmica ligeiramente elevada.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50], // Fundo amarelado suave
                  border: Border.all(color: Colors.amber[200]!, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.content_paste, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text('O que deve fazer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber[800], fontStyle: FontStyle.italic)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Não entre em pânico – isto é apenas um aviso preventivo.', style: TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic)),
                    const Text('2. Marque uma consulta no prazo de 2 semanas.', style: TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic)),
                    const Text('3. Evite actividade física intensa nas próximas 48h.', style: TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC75B8B).withOpacity(0.05),
                  border: Border.all(color: const Color(0xFFC75B8B).withOpacity(0.2), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_hospital, color: Color(0xFFC75B8B), size: 20),
                        SizedBox(width: 8),
                        Text('Hospital mais próximo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC75B8B), fontStyle: FontStyle.italic)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Hospital Américo Boavida', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const Text('Av. Hoji-ya-Henda · 3.2 km', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC75B8B),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Ver rota', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('OK, Entendi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultData = widget.resultData;
    final riskLevel = resultData['classificacao_risco'] ?? 'Normal';
    final dateStr = resultData['data_hora'] ?? DateTime.now().toIso8601String();
    final DateTime dateTime = DateTime.parse(dateStr);
    final String formattedDate = DateFormat("dd MMMM yyyy • HH:mm").format(dateTime);
    
    final tempEsq = resultData['temp_mama_esq'];
    final tempDir = resultData['temp_mama_dir'];
    final double diff = (tempEsq - tempDir).abs();
    
    // Normal configuration
    Color statusColor = const Color(0xFF4CB370); // vibrant green matching design
    String description = 'Os teus valores estão dentro do esperado. Continue a monitorizar regularmente.';
    bool showRecommendation = false;

    if (riskLevel == 'Atenção') {
      statusColor = Colors.amber;
      description = 'Foi detectada uma pequena assimetria térmica. Mantenha atenção.';
      showRecommendation = true;
    } else if (riskLevel == 'Alto Risco') {
      statusColor = const Color(0xFFE55A5A); // red matching design
      description = 'Alto Risco Detectado';
      showRecommendation = true;
    }

    final isHighRisk = (riskLevel == 'Alto Risco' || riskLevel == 'Atenção');
    final isVeryHighRisk = riskLevel == 'Alto Risco';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BIOMA', style: TextStyle(fontFamily: 'Caveat', fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: isVeryHighRisk ? statusColor : const Color(0xFFC75B8B),
        foregroundColor: Colors.white,
        elevation: 0,

        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isVeryHighRisk)
              Container(
                width: double.infinity,
                color: statusColor,
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: const Column(
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.yellowAccent),
                    SizedBox(height: 8),
                    Text('Alto Risco Detectado', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    SizedBox(height: 4),
                    Text('Por favor, consulte um médico brevemente.', style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8),
                child: Column(
                  children: [
                    const Text('Resultado da Triagem', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text(formattedDate, style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            const SizedBox(height: 32),
            
            // Gauge Chart Custom Painter
            SizedBox(
              width: 180,
              height: 100,
              child: CustomPaint(
                painter: GaugePainter(riskLevel: riskLevel),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              riskLevel,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: statusColor,
              ),
            ),
            if (!isVeryHighRisk) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Summary Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Resumo dos dados', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ),
                    const Divider(height: 1),
                    _buildRowItem('Temp. Mama Esq.', '${tempEsq}ºC', statusColor),
                    const Divider(height: 1),
                    _buildRowItem('Temp. Mama Dir.', '${tempDir}ºC', statusColor),
                    const Divider(height: 1),
                    _buildRowItem('Assimetria Térmica', '${diff.toStringAsFixed(1)}ºC', isHighRisk ? Colors.redAccent : statusColor, isWarning: isHighRisk),
                    const Divider(height: 1),
                    _buildRowItem('Freq. Cardíaca', '${resultData['bpm']} bpm', Colors.black87),
                    const Divider(height: 1),
                    _buildRowItem('SpO2', '${resultData['spo2']}%', Colors.black87),
                  ],
                ),
              ),
            ),

            if (showRecommendation) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Recomendação',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Dirija-se ao Hospital do Prenda o mais breve possível. Mostre este relatório ao médico.',
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD65858),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Ver no mapa →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                    if (!isHighRisk) ...[
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check, color: Colors.white, size: 18),
                        label: const Text('Concluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC75B8B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (isHighRisk)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Concluir e Voltar', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String title, String value, Color valColor, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
          Row(
            children: [
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valColor, fontStyle: FontStyle.italic)),
              if (isWarning) ...[
                const SizedBox(width: 4),
                const Icon(Icons.warning, color: Colors.amber, size: 16),
              ]
            ],
          )
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final String riskLevel;
  
  GaugePainter({required this.riskLevel});

  @override
  void paint(Canvas canvas, Size size) {
    Paint greenPaint = Paint()
      ..color = const Color(0xFF5DBB7D)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    Paint yellowPaint = Paint()
      ..color = const Color(0xFFE9C56A)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    Paint redPaint = Paint()
      ..color = const Color(0xFFE26161)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: size.width / 2);
    
    // Draw slices overlapping so they form a continuous arc covering Pi
    canvas.drawArc(rect, math.pi, math.pi * 0.45, false, greenPaint); // green section
    canvas.drawArc(rect, math.pi + math.pi * 0.45, math.pi * 0.25, false, yellowPaint); // yellow section
    canvas.drawArc(rect, math.pi + math.pi * 0.70, math.pi * 0.30, false, redPaint); // red section

    // Pointer logic
    double angleMultiplier;
    if (riskLevel == 'Normal') {
      angleMultiplier = 0.22; // 20% point
    } else if (riskLevel == 'Atenção') {
      angleMultiplier = 0.58; // 60% point
    } else {
      angleMultiplier = 0.85; // 85% point
    }
    
    double angle = math.pi + (math.pi * angleMultiplier);
    
    Paint pointerBasePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
      
    Paint pointerLinePaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Center dot
    canvas.drawCircle(Offset(size.width / 2, size.height), 8, pointerBasePaint);
    
    // Line calculation
    Offset endVal = Offset(
       size.width / 2 + (size.width / 2 - 28) * math.cos(angle),
       size.height + (size.width / 2 - 28) * math.sin(angle),
    );
    canvas.drawLine(Offset(size.width / 2, size.height), endVal, pointerLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
