import 'package:flutter/material.dart';

class AddCarPage extends StatelessWidget {
  const AddCarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AutoCache')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Cadastro de Veículo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _buildLabelAndField('Marca:', 'EX: Peugeot'),
                const SizedBox(height: 16),
                _buildLabelAndField('Modelo:', 'EX: 206'),
                const SizedBox(height: 16),
                _buildLabelAndField('Ano:', 'EX: 2008'),
                const SizedBox(height: 16),
                _buildLabelAndField('Kilometragem do veículo:', 'EX: 140000'),
                const SizedBox(height: 20),
                const Text('Foto do veículo:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.file_upload, color: Colors.red),
                  label: const Text('Selecionar Imagem', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CADASTRAR VEÍCULO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelAndField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}