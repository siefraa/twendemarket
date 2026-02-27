import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AppProvider>().login(
        _isLogin ? 'User' : _nameCtrl.text,
        _emailCtrl.text,
        _phoneCtrl.text.isEmpty ? '+255700000000' : _phoneCtrl.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.storefront, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 16),
              Text('TwendeMarket', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
              Text('Local market in your pocket', style: TextStyle(color: AppTheme.textLight)),
              const SizedBox(height: 40),

              // Toggle
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  _tab('Sign In', _isLogin, () => setState(() => _isLogin = true)),
                  _tab('Sign Up', !_isLogin, () => setState(() => _isLogin = false)),
                ]),
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(children: [
                  if (!_isLogin) ...[
                    TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)), validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure))), obscureText: _obscure, validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 16)))),
                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                  ],
                ]),
              ),

              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                child: Text('Browse as Guest', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : AppTheme.textLight, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
