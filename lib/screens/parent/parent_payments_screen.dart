import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/payment_bill.dart';
import '../../models/payment_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class ParentPaymentsScreen extends StatelessWidget {
  const ParentPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parent = context.read<AuthProvider>().user;
    final dp = context.watch<DataProvider>();
    final childrenIds = parent?.childrenIds ?? [];

    if (childrenIds.isEmpty) {
      return RoleScaffold(
        title: 'Pembayaran Anak',
        body: const EmptyState(
          icon: Icons.child_care,
          title: 'Tidak ada data anak',
          message: 'Hubungi admin untuk menautkan akun anak Anda.',
        ),
      );
    }

    return RoleScaffold(
      title: 'Pembayaran Anak',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: 'Pembayaran Anak'),
          Expanded(
            child: childrenIds.length == 1
                ? _ChildPaymentView(studentId: childrenIds.first)
                : DefaultTabController(
                    length: childrenIds.length,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: childrenIds.map((id) {
                            final name =
                                dp.userById(id)?.name ?? id;
                            return Tab(text: name);
                          }).toList(),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: childrenIds
                                .map((id) =>
                                    _ChildPaymentView(studentId: id))
                                .toList(),
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

class _ChildPaymentView extends StatelessWidget {
  const _ChildPaymentView({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final bills = dp.billsForStudent(studentId);
    final txs = dp.transactionsForStudent(studentId);

    final totalTagihan = bills.fold<int>(0, (s, b) => s + b.amount);
    final totalTerbayar = bills.fold<int>(0, (s, b) => s + b.paidAmount);
    final sisaTagihan = totalTagihan - totalTerbayar;

    return Column(
      children: [
        // Summary
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _chip('Total Tagihan', 'Rp ${_fmt(totalTagihan)}',
                  Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              _chip('Terbayar', 'Rp ${_fmt(totalTerbayar)}',
                  Colors.green.shade700),
              const SizedBox(width: 8),
              _chip(
                'Sisa',
                'Rp ${_fmt(sisaTagihan)}',
                sisaTagihan > 0
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
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
                      _BillsList(bills: bills),
                      _HistoryList(txs: txs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value, Color color) => Expanded(
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
              Text(label, style: TextStyle(fontSize: 11, color: color)),
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

class _BillsList extends StatelessWidget {
  const _BillsList({required this.bills});
  final List<PaymentBill> bills;

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
        message: 'Belum ada tagihan untuk anak Anda.',
      );
    }
    final dp = context.watch<DataProvider>();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, i) {
        final bill = bills[i];
        final category = dp.paymentCategoryById(bill.categoryId);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  _statusColor(bill.status).withValues(alpha: 0.1),
              child: Icon(
                bill.status == BillStatus.paid
                    ? Icons.check
                    : Icons.receipt_long,
                color: _statusColor(bill.status),
                size: 20,
              ),
            ),
            title: Text(bill.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600)),
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
                    color: _statusColor(bill.status)
                        .withValues(alpha: 0.12),
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
                if (bill.remainingAmount > 0 &&
                    bill.status != BillStatus.paid)
                  Text(
                    'Sisa Rp ${_fmt(bill.remainingAmount)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
        message: 'Riwayat pembayaran anak Anda akan muncul di sini.',
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

String _fmt(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
