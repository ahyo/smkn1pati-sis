import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/payment_bill.dart';
import '../../models/payment_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class StudentPaymentsScreen extends StatelessWidget {
  const StudentPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = context.read<AuthProvider>().user?.id ?? '';
    final dp = context.watch<DataProvider>();
    final bills = dp.billsForStudent(studentId);
    final txs = dp.transactionsForStudent(studentId);

    final totalTagihan = bills.fold<int>(0, (s, b) => s + b.amount);
    final totalTerbayar = bills.fold<int>(0, (s, b) => s + b.paidAmount);
    final sisaTagihan = totalTagihan - totalTerbayar;

    return RoleScaffold(
      title: 'Pembayaran',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: 'Pembayaran'),
          // Summary strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _SummaryChip(
                    label: 'Total Tagihan',
                    value: 'Rp ${_fmt(totalTagihan)}',
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Terbayar',
                    value: 'Rp ${_fmt(totalTerbayar)}',
                    color: Colors.green.shade700),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Sisa',
                    value: 'Rp ${_fmt(sisaTagihan)}',
                    color: sisaTagihan > 0
                        ? Colors.orange.shade700
                        : Colors.green.shade700),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Tagihan'),
                      Tab(text: 'Riwayat'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _BillsList(bills: bills, studentId: studentId),
                        _HistoryList(txs: txs),
                      ],
                    ),
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

// ────────────────────────────────────────────────────────────── Bills list ──

class _BillsList extends StatelessWidget {
  const _BillsList({required this.bills, required this.studentId});
  final List<PaymentBill> bills;
  final String studentId;

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
    if (bills.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'Tidak ada tagihan',
        message: 'Belum ada tagihan yang dikeluarkan untuk kamu.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, i) {
        final bill = bills[i];
        final dp = context.read<DataProvider>();
        final category = dp.paymentCategoryById(bill.categoryId);
        final isPaidFull = bill.status == BillStatus.paid;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor:
                  _statusColor(bill.status).withValues(alpha: 0.1),
              child: Icon(
                isPaidFull ? Icons.check : Icons.receipt_long,
                color: _statusColor(bill.status),
                size: 20,
              ),
            ),
            title: Text(bill.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${category?.name ?? ''} • Jatuh tempo: '
              '${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        _statusColor(bill.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bill.status.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: _statusColor(bill.status),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 2),
                Text('Rp ${_fmt(bill.amount)}',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Nominal', 'Rp ${_fmt(bill.amount)}'),
                    _row('Terbayar', 'Rp ${_fmt(bill.paidAmount)}'),
                    _row('Sisa', 'Rp ${_fmt(bill.remainingAmount)}'),
                    if (bill.notes != null) _row('Catatan', bill.notes!),
                    if (!isPaidFull) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _showPaymentDialog(context, bill),
                          icon: const Icon(Icons.payment, size: 18),
                          label: const Text('Bayar Sekarang'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey)),
            ),
            Expanded(
                child:
                    Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  Future<void> _showPaymentDialog(
      BuildContext context, PaymentBill bill) async {
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    PaymentMethod selectedMethod = PaymentMethod.bankTransfer;
    final proofCtrl = TextEditingController();
    final amountCtrl = TextEditingController(
        text: bill.remainingAmount.toString());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                Text('Sisa: Rp ${_fmt(bill.remainingAmount)}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Dibayar (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Harus angka positif';
                    if (n > bill.remainingAmount) {
                      return 'Melebihi sisa tagihan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PaymentMethod>(
                  value: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    border: OutlineInputBorder(),
                  ),
                  items: PaymentMethod.values
                      .map((m) => DropdownMenuItem(
                          value: m, child: Text(m.label)))
                      .toList(),
                  onChanged: (v) => setDlgState(
                      () => selectedMethod = v ?? selectedMethod),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: proofCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan / Bukti Pembayaran',
                    border: OutlineInputBorder(),
                    hintText: 'mis. sudah transfer ke rek BRI sekolah',
                  ),
                  maxLines: 2,
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
                final amount = int.parse(amountCtrl.text.trim());
                final id = 'tx_${const Uuid().v4()}';
                await dp.upsertPaymentTransaction(PaymentTransaction(
                  id: id,
                  billId: bill.id,
                  studentId: studentId,
                  amount: amount,
                  method: selectedMethod,
                  status: TransactionStatus.pending,
                  createdAt: DateTime.now(),
                  proofNote: proofCtrl.text.trim().isEmpty
                      ? null
                      : proofCtrl.text.trim(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(const SnackBar(
                    content: Text(
                        'Pembayaran dikirim, menunggu konfirmasi admin')));
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── History list ──

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.txs});
  final List<PaymentTransaction> txs;

  Color _statusColor(TransactionStatus s) {
    switch (s) {
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
    if (txs.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Belum ada riwayat',
        message: 'Riwayat pembayaran kamu akan muncul di sini.',
      );
    }
    final dp = context.watch<DataProvider>();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: txs.length,
      itemBuilder: (context, i) {
        final tx = txs[i];
        final bill =
            dp.paymentBills.where((b) => b.id == tx.billId).firstOrNull;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  _statusColor(tx.status).withValues(alpha: 0.1),
              child: Icon(
                tx.status == TransactionStatus.confirmed
                    ? Icons.check
                    : tx.status == TransactionStatus.rejected
                        ? Icons.close
                        : Icons.hourglass_empty,
                color: _statusColor(tx.status),
                size: 20,
              ),
            ),
            title: Text(
              bill?.title ?? tx.billId,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${tx.method.label} • '
              '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${_fmt(tx.amount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  tx.status.label,
                  style: TextStyle(
                      color: _statusColor(tx.status), fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────── Shared ─────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: color)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

String _fmt(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
