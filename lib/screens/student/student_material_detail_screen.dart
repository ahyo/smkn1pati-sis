import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/data_provider.dart';
import '../../widgets/role_scaffold.dart';

class StudentMaterialDetailScreen extends StatelessWidget {
  const StudentMaterialDetailScreen({super.key, required this.materialId});
  final String materialId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final material =
        data.materials.where((m) => m.id == materialId).firstOrNull;
    if (material == null) {
      return const RoleScaffold(
          title: 'Materi', body: Center(child: Text('Materi tidak ditemukan')));
    }
    final subject = data.subjectById(material.subjectId);
    final teacher = data.userById(material.teacherId);
    final df = DateFormat('dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: material.title,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(material.title,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
              '${subject?.name ?? '-'} • ${teacher?.name ?? '-'} • ${df.format(material.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall),
          const Divider(height: 32),
          Text(material.content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
