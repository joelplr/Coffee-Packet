import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: context.theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.theme.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: context.theme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.theme.accent.withOpacity(0.3)),
                  ),
                  labelColor: context.theme.accent,
                  unselectedLabelColor: context.theme.textSecondary,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'Weekly Production'),
                    Tab(text: 'Ingredient Usage'),
                    Tab(text: 'Efficiency'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _WeeklyProductionTab(provider: provider),
                    _IngredientUsageTab(provider: provider),
                    _EfficiencyTab(provider: provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyProductionTab extends StatelessWidget {
  final AppProvider provider;
  const _WeeklyProductionTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.weeklyProduction.fold(0.0, (a, b) => a + b).toInt();
    final avg = (total / 7).toInt();
    final maxVal = provider.weeklyProduction.fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        Row(
          children: [
            _summaryBox(context, 'Total This Week', '$total', 'sachets', context.theme.accent),
            SizedBox(width: 16),
            _summaryBox(context, 'Daily Average', '$avg', 'sachets/day', context.theme.info),
            SizedBox(width: 16),
            _summaryBox(context, 'Best Day', '${maxVal.toInt()}', 'sachets', context.theme.success),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Production (7 Days)', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: context.theme.border, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) => Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(provider.weekDays[val.toInt()],
                                  style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 11)),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (val, _) => Text(
                              val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}K' : val.toInt().toString(),
                              style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10),
                            ),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: provider.weeklyProduction.asMap().entries.map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [BarChartRodData(
                          toY: e.value,
                          gradient: LinearGradient(
                            colors: [context.theme.accentLight, context.theme.accentDark],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 32,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                        )],
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryBox(BuildContext context, String title, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.theme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 11)),
            SizedBox(height: 6),
            Text(value, style: GoogleFonts.inter(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
            Text(sub, style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _IngredientUsageTab extends StatelessWidget {
  final AppProvider provider;
  const _IngredientUsageTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final sections = [
      PieChartSectionData(value: 40, title: 'Coffee\n40%', color: context.theme.accentDark, radius: 80,
          titleStyle: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      PieChartSectionData(value: 35, title: 'Sugar\n35%', color: context.theme.info, radius: 80,
          titleStyle: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      PieChartSectionData(value: 25, title: 'Milk\n25%', color: context.theme.textSecondary, radius: 80,
          titleStyle: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ];

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredient Ratio (Default Recipe)', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Expanded(
                  child: PieChart(PieChartData(
                    sections: sections,
                    centerSpaceRadius: 50,
                    sectionsSpace: 3,
                  )),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Stock Levels', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                ...provider.inventory.map((item) {
                  final color = item.isEmpty ? context.theme.error : item.isLow ? context.theme.warning : context.theme.success;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(item.name, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13)),
                          Spacer(),
                          Text('${(item.percentFull * 100).toInt()}%', style: GoogleFonts.inter(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                        SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: item.percentFull,
                            backgroundColor: context.theme.surfaceLighter,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('${item.quantity.toStringAsFixed(1)} / ${item.maxCapacity} ${item.unit}',
                            style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EfficiencyTab extends StatelessWidget {
  final AppProvider provider;
  const _EfficiencyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalProduced = provider.totalSachetsProduced;
    final efficiency = totalProduced > 0 ? 87 : 0; // simulated

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Machine Efficiency', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(PieChartData(
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(value: efficiency.toDouble(), color: context.theme.success, radius: 20, title: ''),
                            PieChartSectionData(value: (100 - efficiency).toDouble(), color: context.theme.surfaceLighter, radius: 20, title: ''),
                          ],
                          centerSpaceRadius: 70,
                          sectionsSpace: 2,
                        )),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$efficiency%', style: GoogleFonts.inter(color: context.theme.success, fontSize: 36, fontWeight: FontWeight.w700)),
                            Text('Efficiency', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _effRow(context, 'Total Sachets Produced', '$totalProduced'),
                _effRow(context, 'Avg Daily Output', '${(provider.weeklyProduction.fold(0.0, (a, b) => a + b) / 7).toInt()}'),
                _effRow(context, 'Machine Uptime', '87%'),
                _effRow(context, 'Error Rate', '0.3%'),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Most Used Recipes', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                ...provider.recipes.asMap().entries.map((e) {
                  final usage = [42, 28, 18, 12][e.key % 4];
                  final colors = [context.theme.accent, context.theme.info, context.theme.success, context.theme.accentLight];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(e.value.name, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13)),
                          Spacer(),
                          Text('$usage%', style: GoogleFonts.inter(color: colors[e.key % 4], fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                        SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: usage / 100,
                            backgroundColor: context.theme.surfaceLighter,
                            valueColor: AlwaysStoppedAnimation<Color>(colors[e.key % 4]),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _effRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
          Spacer(),
          Text(value, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}