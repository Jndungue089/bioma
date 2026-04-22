import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'high_risk_screen.dart';
import '../services/api_service.dart';
import 'dart:math';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  double _progress = 0.0;
  bool _isFinished = false;
  
  String _tempEsq = '--';
  String _tempDir = '--';
  String _bpm = '--';
  String _spo2 = '--';
  String _assimetria = '--';
  double _assimetriaValue = 0.0;

  @override
  void initState() {
    super.initState();
    _startCollection();
  }

  void _startCollection() async {
    // Clear any stale sensor data
    await ApiService.clearSensor();

    bool dataReceived = false;
    Map<String, dynamic> payload = {};

    while (!dataReceived && mounted) {
      final sensorData = await ApiService.pollSensorData();
      if (sensorData != null) {
        setState(() {
          if (sensorData['esq'] != null) _tempEsq = sensorData['esq'].toString();
          if (sensorData['dir'] != null) _tempDir = sensorData['dir'].toString();
          
          if (sensorData['esq'] != null && sensorData['dir'] != null) {
            double esq = (sensorData['esq'] is int) ? (sensorData['esq'] as int).toDouble() : sensorData['esq'];
            double dir = (sensorData['dir'] is int) ? (sensorData['dir'] as int).toDouble() : sensorData['dir'];
            _assimetriaValue = (esq - dir).abs();
            _assimetria = _assimetriaValue.toStringAsFixed(1);
          }
        });
        
        if (sensorData['valida'] == true) {
          // Agora o backend pega os dados do sensor, passamos apenas valores padrão opcionais ou payload vazio
          payload = {};
          dataReceived = true;
          setState(() {
            _progress = 1.0;
            _isFinished = true;
          });
        } else {
          // Incrementa um progresso animado
          setState(() {
             _progress += 0.05;
             if (_progress > 0.85) _progress = 0.1;
          });
          await Future.delayed(const Duration(seconds: 1));
        }
      } else {
        // Incrementa um progresso "falso" animado até o sensor enviar
        setState(() {
           _progress += 0.05;
           if (_progress > 0.85) _progress = 0.1; // Loop de loading
        });
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    if (!mounted) return;

    final createdData = await ApiService.addTriagem(payload);
    // Se não retornou dados (ex: erro), usa o próprio payload do sensorData (somente visual)
    final dataPassed = createdData ?? {'classificacao_risco': 'Erro'};
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    String risco = dataPassed['classificacao_risco'] ?? 'Normal';
    
    if (risco == 'Alto Risco') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HighRiskScreen(resultData: dataPassed)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(resultData: dataPassed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC75B8B); // Rosa
    final bool isAlmostDone = _progress > 0.75;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIOMA'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Leitura em curso',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Ao vivo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAlmostDone ? 'A recolher dados... 75% concluído' : 'Aguarde enquanto os sensores recolhem dados...',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              color: primaryColor,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildValueCard(context, 'Temp. Mama Esq.', _tempEsq == '--' ? '--' : '$_tempEsq°C', 'normal', Icons.thermostat, Colors.amber)),
                const SizedBox(width: 16),
                Expanded(child: _buildValueCard(context, 'Temp. Mama Dir.', _tempDir == '--' ? '--' : '$_tempDir°C', _assimetria == '--' ? '' : '+$_assimetria°C', Icons.thermostat, Colors.amber, isWarn: _assimetriaValue >= 1.0)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildValueCard(context, 'Freq. Cardíaca', _bpm == '--' ? '--' : '$_bpm bpm', 'normal', Icons.favorite, Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildValueCard(context, 'SpO2', _spo2 == '--' ? '--' : '$_spo2%', 'normal', Icons.water_drop, Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            _buildAsymmetryCard(primaryColor),
            const SizedBox(height: 24),
            _buildActivityLayerCard(primaryColor),
            const SizedBox(height: 48),
            if(!_isFinished)
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancelar Leitura', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(BuildContext context, String title, String value, String subValue, IconData icon, Color iconColor, {bool isWarn = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isWarn ? Colors.orange.shade700 : Colors.black)),
          const SizedBox(height: 4),
          Text(subValue, style: TextStyle(fontSize: 12, color: isWarn ? Colors.orange.shade700 : Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildAsymmetryCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assimetria Térmica', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _assimetriaValue / 2.0, // Exemplo
                  backgroundColor: Colors.grey[200],
                  color: _assimetriaValue >= 2.0 ? Colors.red : (_assimetriaValue >= 1.0 ? Colors.amber : Colors.green),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 16),
              Text(_assimetria == '--' ? '--' : '$_assimetria°C', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _assimetriaValue >= 2.0 ? Colors.red : (_assimetriaValue >= 1.0 ? Colors.amber : Colors.green))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Limite recomendado: < 0.5°C', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildActivityLayerCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nível de Actividade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
               Expanded(child: _buildActivityButton('Em repouso', true, primaryColor)),
               const SizedBox(width: 4),
               Expanded(child: _buildActivityButton('Baixo', false, primaryColor)),
               const SizedBox(width: 4),
               Expanded(child: _buildActivityButton('Médio', false, primaryColor)),
               const SizedBox(width: 4),
               Expanded(child: _buildActivityButton('Alto', false, primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton(String label, bool isSelected, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
