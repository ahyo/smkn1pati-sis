import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/payment_bill.dart';
import '../../models/payment_category.dart';
import '../../models/payment_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      title: 'Manajemen Pembayaran',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: 'Manajemen Pembayaran'),
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Tagihan'),
              Tab(text: 'Konfirmasi'),
              Tab(text: 'Kategori'),
              Tab(text: 'Laporan'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _BillsTab(),
                _TransactionsTab(),
                _CategoriesTab(),
                _ReportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Tab: Tagihan ───

class _BillsTab extends StatefulWidget {
  const _BillsTab();

  @override
  State<_BillsTab> createState() => _BillsTabState();
}

class _BillsTabState extends State<_BillsTab> {
  BillStatus? _statusFilter;
  String? _classFilter;

  Color _statusColor(BillStatus s) {
    switch (s) {
      case BillStatus.unpaid:
        return Colors.grey.shade600;
      case BillStatus.partiallyPaid:
        return Colors.orange.shade700;
      case BillStatus.paid:
        return Colors.green.shade700;
      case BillStatus.overdue:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final classes = dp.classes;

    var bills = dp.paymentBills.toList();
    if (_statusFilter != null) {
      bills = bills.where((b) => b.status == _statusFilter).toList();
    }
    if (_classFilter != null) {
      bills = bills.where((b) => b.classId == _classFilter).toList();
    }
    bills.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<BillStatus?>(
                  value: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Semua Status')),
                    ...BillStatus.values.map(
                      (s) => DropdownMenuItem(
                          value: s, child: Text(s.label)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String?>(
                  value: _classFilter,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Semua Kelas')),
                    ...classes.map(
                      (c) => DropdownMenuItem(
                          value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _classFilter = v),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showGenerateSppDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Generate SPP'),
              ),
            ],
          ),
        ),
        if (bills.isEmpty)
          const Expanded(
            child: EmptyState(
              icon: Icons.receipt_long,
              title: 'Tidak ada tagihan',
              message: 'Belum ada tagihan yang sesuai filter.',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: bills.length,
              itemBuilder: (context, i) {
                final bill = bills[i];
                final student = dp.userById(bill.studentId);
                final category = dp.paymentCategoryById(bill.categoryId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(bill.title,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${student?.name ?? bill.studentId} • ${category?.name ?? ''}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(bill.status)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bill.status.label,
                            style: TextStyle(
                                color: _statusColor(bill.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${_fmt(bill.amount)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    onTap: () => _showBillDetail(context, bill),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showBillDetail(BuildContext context, PaymentBill bill) {
    final dp = context.read<DataProvider>();
    final student = dp.userById(bill.studentId);
    final category = dp.paymentCategoryById(bill.categoryId);
    final txs = dp.transactionsForBill(bill.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Text(bill.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _detailRow('Siswa', student?.name ?? bill.studentId),
            _detailRow('Kategori', category?.name ?? bill.categoryId),
            _detailRow('Jumlah', 'Rp ${_fmt(bill.amount)}'),
            _detailRow('Terbayar', 'Rp ${_fmt(bill.paidAmount)}'),
            _detailRow('Sisa', 'Rp ${_fmt(bill.remainingAmount)}'),
            _detailRow(
              'Jatuh Tempo',
              '${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
            ),
            _detailRow('Status', bill.status.label),
            if (bill.notes != null) _detailRow('Catatan', bill.notes!),
            const Divider(height: 24),
            const Text('Riwayat Transaksi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (txs.isEmpty)
              const Text('Belum ada transaksi',
                  style: TextStyle(color: Colors.grey))
            else
              ...txs.map((tx) => _TxTile(tx: tx)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13)),
            ),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  Future<void> _showGenerateSppDialog(BuildContext context) async {
    final dp = context.read<DataProvider>();
    final auth = context.read<AuthProvider>();
    final classes = dp.classes;
    if (classes.isEmpty) return;

    String? selectedClassId = classes.first.id;
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;
    final sppCategories =
        dp.paymentCategories.where((c) => c.isRecurringMonthly).toList();
    String? selectedCategoryId = sppCategories.firstOrNull?.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Generate Tagihan SPP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedClassId,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: classes
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) =>
                    setDlgState(() => selectedClassId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: selectedCategoryId,
                decoration:
                    const InputDecoration(labelText: 'Kategori SPP'),
                items: sppCategories
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) =>
                    setDlgState(() => selectedCategoryId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration:
                          const InputDecoration(labelText: 'Bulan'),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(_monthName(i + 1))),
                      ),
                      onChanged: (v) => setDlgState(
                          () => selectedMonth = v ?? selectedMonth),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration:
                          const InputDecoration(labelText: 'Tahun'),
                      items: [2025, 2026, 2027]
                          .map((y) => DropdownMenuItem(
                              value: y, child: Text(y.toString())))
                          .toList(),
                      onChanged: (v) => setDlgState(
                          () => selectedYear = v ?? selectedYear),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Generate')),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    if (selectedClassId == null || selectedCategoryId == null) return;

    final cls = dp.classById(selectedClassId!);
    if (cls == null) return;
    final category = dp.paymentCategoryById(selectedCategoryId!);
    if (category == null) return;
    final adminId = auth.user?.id;

    final messenger = ScaffoldMessenger.of(context);
    int created = 0;
    for (final studentId in cls.studentIds) {
      final alreadyExists = dp.paymentBills.any((b) =>
          b.studentId == studentId &&
          b.categoryId == selectedCategoryId &&
          b.month == selectedMonth &&
          b.year == selectedYear);
      if (alreadyExists) continue;

      final id = 'bill_${const Uuid().v4()}';
      await dp.upsertPaymentBill(PaymentBill(
        id: id,
        studentId: studentId,
        classId: selectedClassId,
        categoryId: selectedCategoryId!,
        title: 'SPP ${_monthName(selectedMonth)} $selectedYear',
        amount: category.defaultAmount,
        dueDate: DateTime(selectedYear, selectedMonth, 10),
        status: BillStatus.unpaid,
        month: selectedMonth,
        year: selectedYear,
        createdAt: DateTime.now(),
        createdByAdminId: adminId,
      ));
      created++;
    }
    messenger.showSnackBar(
        SnackBar(content: Text('$created tagihan SPP berhasil dibuat')));
  }
}

// ─────────────────────────────────────────────── Tab: Konfirmasi Transaksi ──

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final pending = dp.pendingTransactions;

    if (pending.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'Semua transaksi selesai',
        message: 'Tidak ada transaksi yang menunggu konfirmasi.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, i) => _PendingTxCard(tx: pending[i]),
    );
  }
}

class _PendingTxCard extends StatelessWidget {
  const _PendingTxCard({required this.tx});
  final PaymentTransaction tx;

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final student = dp.userById(tx.studentId);
    final bill =
        dp.paymentBills.where((b) => b.id == tx.billId).firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student?.name ?? tx.studentId,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        bill?.title ?? tx.billId,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rp ${_fmt(tx.amount)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payment,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(tx.method.label,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.access_time,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year} '
                  '${tx.createdAt.hour.toString().padLeft(2, '0')}:'
                  '${tx.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            if (tx.proofNote != null) ...[
              const SizedBox(height: 6),
              Text('Catatan: ${tx.proofNote}',
                  style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _reject(context, tx, bill),
                  icon: const Icon(Icons.close,
                      size: 16, color: Colors.red),
                  label: const Text('Tolak',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _confirm(context, tx, bill),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Konfirmasi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, PaymentTransaction tx,
      PaymentBill? bill) async {
    final dp = context.read<DataProvider>();
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final adminId = auth.user?.id ?? '';
    final now = DateTime.now();

    await dp.upsertPaymentTransaction(tx.copyWith(
      status: TransactionStatus.confirmed,
      confirmedAt: now,
      confirmedByAdminId: adminId,
      receiptNumber:
          'RCP-${now.year}-${now.millisecondsSinceEpoch % 100000}',
    ));

    if (bill != null) {
      final newPaid = bill.paidAmount + tx.amount;
      final newStatus = newPaid >= bill.amount
          ? BillStatus.paid
          : BillStatus.partiallyPaid;
      await dp.upsertPaymentBill(
          bill.copyWith(paidAmount: newPaid, status: newStatus));
    }

    messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi dikonfirmasi')));
  }

  Future<void> _reject(BuildContext context, PaymentTransaction tx,
      PaymentBill? bill) async {
    final reasonCtrl = TextEditingController();
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Transaksi'),
        content: TextField(
          controller: reasonCtrl,
          decoration:
              const InputDecoration(labelText: 'Alasan penolakan'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tolak')),
        ],
      ),
    );

    if (confirmed != true) return;
    await dp.upsertPaymentTransaction(tx.copyWith(
      status: TransactionStatus.rejected,
      rejectionReason: reasonCtrl.text.trim().isEmpty
          ? null
          : reasonCtrl.text.trim(),
    ));
    messenger
        .showSnackBar(const SnackBar(content: Text('Transaksi ditolak')));
  }
}

// ──────────────────────────────────────────────────────── Tab: Kategori ─────

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<DataProvider>().paymentCategories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _showCategoryEditor(context, null),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Kategori'),
            ),
          ),
        ),
        if (categories.isEmpty)
          const Expanded(
            child: EmptyState(
              icon: Icons.category_outlined,
              title: 'Belum ada kategori',
              message: 'Tambahkan kategori pembayaran seperti SPP, Buku, dll.',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.isRecurringMonthly
                          ? Colors.blue.shade50
                          : Colors.purple.shade50,
                      child: Icon(
                        cat.isRecurringMonthly
                            ? Icons.repeat
                            : Icons.receipt_long,
                        color: cat.isRecurringMonthly
                            ? Colors.blue.shade700
                            : Colors.purple.shade700,
                        size: 20,
                      ),
                    ),
                    title: Text(cat.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Rp ${_fmt(cat.defaultAmount)}'
                      '${cat.isRecurringMonthly ? ' / bulan' : ''}'
                      '${cat.description != null ? ' • ${cat.description}' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showCategoryEditor(context, cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          tooltip: 'Hapus',
                          onPressed: () =>
                              _deleteCategory(context, cat),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _showCategoryEditor(
      BuildContext context, PaymentCategory? existing) async {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final amountCtrl = TextEditingController(
        text: existing != null ? existing.defaultAmount.toString() : '');
    bool isRecurring = existing?.isRecurringMonthly ?? false;
    final formKey = GlobalKey<FormState>();

    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(
              existing == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Kategori'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Wajib diisi'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi (opsional)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nominal Default (Rp)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Harus angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tagihan Bulanan (SPP)'),
                  value: isRecurring,
                  onChanged: (v) =>
                      setDlgState(() => isRecurring = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final id = existing?.id ?? 'pc_${const Uuid().v4()}';
                await dp.upsertPaymentCategory(PaymentCategory(
                  id: id,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  defaultAmount: int.parse(amountCtrl.text.trim()),
                  isRecurringMonthly: isRecurring,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(
                    content: Text(existing == null
                        ? 'Kategori ditambahkan'
                        : 'Kategori diperbarui')));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(
      BuildContext context, PaymentCategory cat) async {
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus kategori "${cat.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    await dp.deletePaymentCategory(cat.id);
    messenger
        .showSnackBar(const SnackBar(content: Text('Kategori dihapus')));
  }
}

// ────────────────────────────────────────────────────────── Tab: Laporan ────

class _ReportTab extends StatefulWidget {
  const _ReportTab();

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final scheme = Theme.of(context).colorScheme;

    final billsThisYear = dp.paymentBills
        .where((b) => b.year == _year || b.dueDate.year == _year);
    final totalBilled =
        billsThisYear.fold<int>(0, (s, b) => s + b.amount);
    final totalPaid =
        billsThisYear.fold<int>(0, (s, b) => s + b.paidAmount);
    final totalPending = dp.pendingTransactions.length;

    final byMonth = <int, (int, int)>{};
    for (final b in billsThisYear) {
      final m = b.month ?? b.dueDate.month;
      final cur = byMonth[m] ?? (0, 0);
      byMonth[m] = (cur.$1 + b.amount, cur.$2 + b.paidAmount);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Laporan Keuangan',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _year,
              items: [2025, 2026, 2027]
                  .map((y) => DropdownMenuItem(
                      value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _year = v ?? _year),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SummaryCard(
              label: 'Total Tagihan',
              value: 'Rp ${_fmt(totalBilled)}',
              icon: Icons.receipt_long,
              color: scheme.primary,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Total Terbayar',
              value: 'Rp ${_fmt(totalPaid)}',
              icon: Icons.check_circle_outline,
              color: Colors.green.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SummaryCard(
              label: 'Belum Lunas',
              value: 'Rp ${_fmt(totalBilled - totalPaid)}',
              icon: Icons.pending_outlined,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Menunggu Konfirmasi',
              value: '$totalPending transaksi',
              icon: Icons.hourglass_empty,
              color: Colors.blue.shade700,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Rekap Per Bulan',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...List.generate(12, (i) {
          final m = i + 1;
          final data = byMonth[m];
          if (data == null) return const SizedBox.shrink();
          final (billed, paid) = data;
          final pct = billed > 0 ? paid / billed : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_monthName(m),
                        style: const TextStyle(fontSize: 13)),
                    Text(
                      'Rp ${_fmt(paid)} / Rp ${_fmt(billed)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: pct >= 1.0
                        ? Colors.green.shade600
                        : Colors.blue.shade500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Shared widgets ─────

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});
  final PaymentTransaction tx;

  Color _statusColor() {
    switch (tx.status) {
      case TransactionStatus.confirmed:
        return Colors.green.shade700;
      case TransactionStatus.rejected:
        return Colors.red.shade700;
      case TransactionStatus.pending:
        return Colors.orange.shade700;
      case TransactionStatus.expired:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: _statusColor()),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rp ${_fmt(tx.amount)} • ${tx.method.label}',
                    style: const TextStyle(fontSize: 13)),
                Text(
                  '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}'
                  ' • ${tx.status.label}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (tx.receiptNumber != null)
            Text(tx.receiptNumber!,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Helpers ────────

String _fmt(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _monthName(int m) => const [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ][m];
