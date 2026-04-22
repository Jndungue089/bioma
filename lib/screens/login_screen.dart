import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import '../main.dart'; // Para acessar MainScreen
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _savedEmail;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedEmail = prefs.getString('paciente_email');
    });
  }

  void _login() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    if (_savedEmail == null) {
      // Se não tem email, deve ir pro registro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.login(_savedEmail!, pin);

    setState(() => _isLoading = false);

    if (success != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('PIN incorreto.'))
         );
         _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC75B8B);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.medical_services, size: 80, color: primaryColor),
              const SizedBox(height: 24),
              const Text(
                'BIOMA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 2
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rastreio Termográfico',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 48),
              Text(
                _savedEmail != null ? 'Bem-vindo de volta\n($_savedEmail)' : 'Acesso BIOMA',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'PIN (4 dígitos)',
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  )
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Entrar com PIN',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Sou novo por aqui. Criar uma conta', style: TextStyle(color: primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
