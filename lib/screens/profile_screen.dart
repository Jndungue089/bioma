import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'clinical_data_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'A Carregar...';
  String _ageLocation = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final paciente = await ApiService.getPaciente();
    if (mounted && paciente != null) {
      setState(() {
        _userName = paciente['nome'] ?? 'Sem nome';
        final idade = paciente['idade'] != null ? '${paciente['idade']} anos' : '';
        final localizacao = paciente['localizacao'] ?? '';
        
        if (idade.isNotEmpty && localizacao.isNotEmpty) {
          _ageLocation = '$idade • $localizacao';
        } else if (idade.isNotEmpty) {
          _ageLocation = idade;
        } else {
          _ageLocation = localizacao;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (_ageLocation.isNotEmpty)
              Text(
                _ageLocation,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 32),
            _buildProfileOption(
              icon: Icons.medical_information,
              title: 'Dados Clínicos Básicos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClinicalDataScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await ApiService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Sair do Aplicativo', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
