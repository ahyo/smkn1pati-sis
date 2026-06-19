import 'package:flutter/material.dart';

import '../../widgets/role_scaffold.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      title: 'Pengaturan',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.school),
              title: Text('Nama Sekolah'),
              subtitle: Text('SMK Negeri 1 Pati'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Tahun Ajaran'),
              subtitle: Text('2026/2027'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.security),
              title: Text('Kebijakan Privasi'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Tentang Aplikasi'),
              subtitle: Text('Versi 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
