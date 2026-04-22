import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 

  static Future<Map<String, dynamic>?> login(String email, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('paciente_id', data['token']);
        await prefs.setString('paciente_nome', data['paciente']['nome']);
        await prefs.setString('paciente_email', data['paciente']['email']);
        return data;
      }
      return null;
    } catch (e) {
      print('Erro login: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pacientes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return await login(data['email'], data['pin'] ?? userData['pin']);
      }
      return null;
    } catch (e) {
      print('Erro registrar: $e');
      return null;
    }
  }
  
  static Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('paciente_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('paciente_id');
    await prefs.remove('paciente_nome');
    await prefs.remove('paciente_email');
  }

  static Future<List<Map<String, dynamic>>> getTriagens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pId = prefs.getString('paciente_id');
      if (pId == null) return [];

      final response = await http.get(Uri.parse('$baseUrl/pacientes/$pId/triagens'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      print('Erro getTriagens: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getPaciente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pId = prefs.getString('paciente_id');
      if (pId == null) return null;

      final response = await http.get(Uri.parse('$baseUrl/pacientes/$pId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao obter paciente: $e');
      return null;
    }
  }

  static Future<bool> updatePaciente(Map<String, dynamic> dados) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pId = prefs.getString('paciente_id');
      if (pId == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/pacientes/$pId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );
      
      if (response.statusCode == 200) {
        if (dados['nome'] != null) {
           await prefs.setString('paciente_nome', dados['nome']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao atualizar paciente: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> addTriagem(Map<String, dynamic> dados) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pId = prefs.getString('paciente_id');
      if (pId == null) return null;

      dados['paciente_id'] = int.parse(pId);
      final response = await http.post(
        Uri.parse('$baseUrl/triagens'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro upload triagem: $e');
      return null;
    }
  }
}
