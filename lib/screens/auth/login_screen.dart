import 'package:projek_akhir_mobile/screens/pages/navigasi_screen.dart'; 
import 'package:projek_akhir_mobile/services/user_save.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../components/button_primary.dart';
import '../../components/form_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Color _primaryColor = const Color(0xFF044C9C);
  bool _simpanUsername = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        usernameController.text = savedUsername;
        _simpanUsername = true;
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final success = await UserSave().login(
      usernameController.text,
      passwordController.text,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', 'logged_in'); 
      await prefs.setString('username', usernameController.text);
      await prefs.setString('token', 'exists'); 

      if (_simpanUsername) {
        await prefs.setString('saved_username', usernameController.text);
      } else {
        await prefs.remove('saved_username');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigasiScreen()),
        );
      }
    } else {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Gagal'),
            content: const Text('Username atau Password salah'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, Colors.blue.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Selamat Datang!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masuk ke akun Anda untuk melanjutkan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.white70
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          FormInput(
                            hint: "Username",
                            icon: Icons.person_outline,
                            controller: usernameController,
                          ),
                          const SizedBox(height: 16),
                          FormInput(
                            hint: "Password",
                            icon: Icons.lock_outline,
                            controller: passwordController,
                            obscureText: true, 
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _simpanUsername,
                                onChanged: (value) {
                                  setState(() {
                                    _simpanUsername = value ?? false;
                                  });
                                },
                                activeColor: _primaryColor,
                              ),
                              const Text("Simpan Username"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _isLoading 
                              ? Center(child: CircularProgressIndicator(color: _primaryColor))
                              : ButtonPrimary(
                                  text: "Masuk",
                                  onPressed: _login, 
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Kamu belum punya akun? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Daftar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
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
}