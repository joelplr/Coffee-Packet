import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/inventory_item.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final lowItems = provider.inventory.where((i) => i.isLow).length;
        return Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lowItems > 0)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.theme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.theme.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: context.theme.warning, size: 18),
                      SizedBox(width: 10),
                      Text(
                        '$lowItems ingredient${lowItems > 1 ? 's are' : ' is'} running low. Please restock soon.',
                        style: GoogleFonts.inter(color: context.theme.warning, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  children: provider.inventory.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _InventoryCard(item: item, provider: provider),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final AppProvider provider;
  const _InventoryCard({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = item.isEmpty ? context.theme.error : item.isLow ? context.theme.warning : context.theme.success;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                item.name == 'Coffee Powder' ? '☕' : item.name == 'Sugar' ? '🍬' : '🥛',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          SizedBox(width: 20),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.name, style: GoogleFonts.inter(color: context.theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    SizedBox(width: 10),
                    _StatusBadge(item: item, color: color),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: item.percentFull,
                    backgroundColor: context.theme.surfaceLighter,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${item.quantity.toStringAsFixed(1)} ${item.unit} remaining',
                      style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12),
                    ),
                    Spacer(),
                    Text(
                      'Capacity: ${item.maxCapacity.toInt()} ${item.unit}  |  Low at: ${item.lowThreshold.toInt()} ${item.unit}',
                      style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          // Restock
          Column(
            children: [
              Text('${(item.percentFull * 100).toInt()}%',
                  style: GoogleFonts.inter(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _showRestockDialog(context, item),
                icon: Icon(Icons.add_rounded, size: 16),
                label: Text('Restock'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(BuildContext context, InventoryItem item) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: context.theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: context.theme.border)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Restock ${item.name}', style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Current: ${item.quantity.toStringAsFixed(1)} ${item.unit}  |  Max: ${item.maxCapacity} ${item.unit}',
                  style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
              SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 14),
                decoration: InputDecoration(labelText: 'Amount to add (${item.unit})', hintText: 'e.g. 25'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: context.theme.textSecondary))),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(ctrl.text) ?? 0;
                      if (amount > 0) provider.restockInventory(item.name, amount);
                      Navigator.pop(ctx);
                    },
                    child: Text('Confirm Restock'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final InventoryItem item;
  final Color color;
  const _StatusBadge({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = item.isEmpty ? 'OUT OF STOCK' : item.isLow ? 'LOW STOCK' : 'IN STOCK';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: GoogleFonts.inter(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
