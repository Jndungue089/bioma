import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart'; // Para acessar MainScreen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _idadeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _pinController = TextEditingController();
  
  bool _isLoading = false;

  void _register() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final idade = int.tryParse(_idadeController.text.trim()) ?? 0;
    final telefone = _telefoneController.text.trim();
    final localizacao = _localizacaoController.text.trim();
    final pin = _pinController.text.trim();

    if (nome.isEmpty || email.isEmpty || pin.isEmpty || idade == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios (Nome, Email, Idade, PIN).')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dados = {
      'nome': nome,
      'email': email,
      'idade': idade,
      'telefone': telefone,
      'localizacao': localizacao,
      'pin': pin,
    };

    final result = await ApiService.register(dados);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registar. Email pode já existir.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC75B8B);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Registo')),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const Text(
                'Crie a sua conta BIOMA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idadeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Idade', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _localizacaoController,
                decoration: const InputDecoration(labelText: 'Localização', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number, // NumPad
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'PIN (4 dígitos)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registar', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Já tenho conta. Fazer login', style: TextStyle(color: primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}