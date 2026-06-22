import 'package:flutter/material.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({super.key});

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
                const Text('Cadastro de Gasto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _buildLabelAndField('Manutenção / Item:', 'EX: Pneu novo'),
                const SizedBox(height: 16),
                _buildLabelAndField('Valor gasto:', 'EX: 150.00'),
                const SizedBox(height: 16),
                _buildLabelAndField('Data:', 'DD/MM/AAAA'),
                const SizedBox(height: 16),
                _buildLabelAndField('Kilometragem na manutenção:', 'EX: 140500'),
                const SizedBox(height: 16),
                _buildLabelAndField('Descrição:', 'Opcional', maxLines: 3),
                const SizedBox(height: 20),
                const Text('Comprovante / Nota Fiscal:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, color: Colors.red),
                  label: const Text('Anexar Imagem ou PDF', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('CADASTRAR GASTO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelAndField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          maxLines: maxLines,
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