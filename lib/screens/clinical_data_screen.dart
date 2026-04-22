import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClinicalDataScreen extends StatefulWidget {
  const ClinicalDataScreen({super.key});

  @override
  State<ClinicalDataScreen> createState() => _ClinicalDataScreenState();
}

class _ClinicalDataScreenState extends State<ClinicalDataScreen> {
  Map<String, dynamic>? _paciente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final paciente = await ApiService.getPaciente();
      if (mounted) {
        setState(() {
          _paciente = paciente;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados Clínicos Básicos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paciente == null
              ? const Center(child: Text('Não foi possível carregar os dados.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.medical_information, size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Informações Pessoais'),
                      _buildInfoRow('Nome', _paciente!['nome']?.toString() ?? '-'),
                      _buildInfoRow('Idade', '${_paciente!['idade']?.toString() ?? '-'} anos'),
                      _buildInfoRow('Data de Nascimento', _paciente!['data_nascimento']?.toString() ?? '-'),
                      _buildInfoRow('Localização / Morada', _paciente!['localizacao']?.toString() ?? '-'),
                      const SizedBox(height: 24),
                      
                      _buildSectionTitle('Contactos'),
                      _buildInfoRow('Email', _paciente!['email']?.toString() ?? '-'),
                      _buildInfoRow('Telefone', _paciente!['telefone']?.toString() ?? '-'),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Dados do Centro de Saúde'),
                      _buildInfoRow('Centro de Saúde', _paciente!['centro_saude']?.toString() ?? '-'),
                      _buildInfoRow('Agente de Saúde', _paciente!['agente_saude']?.toString() ?? '-'),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 16, color: Colors.black12),
        ],
      ),
    );
  }
}
