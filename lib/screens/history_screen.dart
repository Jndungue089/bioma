import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'Todas';
  List<dynamic> allTriagens = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final triagens = await ApiService.getTriagens();
    if (mounted) {
      setState(() {
        allTriagens = triagens;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC75B8B);
    
    final filteredList = allTriagens.where((item) {
      if (selectedFilter == 'Todas') return true;
      return item['classificacao_risco'] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('BIOMA', style: TextStyle(fontFamily: 'Caveat', fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
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
        automaticallyImplyLeading: false,
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(color: primaryColor))
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Histórico', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Text('Todas as triagens', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('Normal'),
                const SizedBox(width: 8),
                _buildFilterChip('Atenção'),
                const SizedBox(width: 8),
                _buildFilterChip('Alto Risco'),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                
                final String dateStr = item['data_hora'] ?? DateTime.now().toIso8601String();
                final DateTime dt = DateTime.parse(dateStr);
                final String dayStr = DateFormat("dd MMM yyyy").format(dt);
                
                final String risco = item['classificacao_risco'] ?? 'Normal';
                Color bgColor = Colors.green[400]!;
                if (risco == 'Atenção') bgColor = Colors.orange[400]!;
                else if (risco == 'Alto Risco') bgColor = Colors.red[400]!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 6),
                          const Text('C.S. Rangel', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                              const SizedBox(width: 4),
                              Text('${item['bpm']} bpm', style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                              const SizedBox(width: 12),
                              const Icon(Icons.thermostat, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text('${item['temp_mama_esq']}°C', style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(risco, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;
    final primaryColor = const Color(0xFFC75B8B);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!, width: 1.5),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
