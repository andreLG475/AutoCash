import 'package:flutter/material.dart';

class ViewExpensePage extends StatelessWidget {
  const ViewExpensePage({super.key});

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
                const Text('Visualizar Gasto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _buildInfoBlock('Item / Manutenção:', 'Pneu Novo'),
                const SizedBox(height: 14),
                _buildInfoBlock('Valor Total:', 'R\$ 150,00'),
                const SizedBox(height: 14),
                _buildInfoBlock('Data Registrada:', '10/06/2026'),
                const SizedBox(height: 14),
                _buildInfoBlock('KM do Veículo na data:', '140500 Km'),
                const SizedBox(height: 14),
                _buildInfoBlock('Descrição detalhada:', 'Substituição do pneu dianteiro esquerdo que furou na rodovia.', maxLines: 3),
                const SizedBox(height: 20),
                const Text('Nota Fiscal / Foto:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text('comprovante_nota_fiscal.pdf', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Abrir Arquivo', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), maxLines: maxLines),
        ),
      ],
    );
  }
}