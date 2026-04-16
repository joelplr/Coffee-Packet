import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class RecipesScreen extends StatefulWidget {
  RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    '${provider.recipes.length} recipes configured',
                    style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 13),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showRecipeDialog(context, provider, null),
                    icon: Icon(Icons.add_rounded, size: 18),
                    label: Text('New Recipe'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: provider.recipes.length,
                  itemBuilder: (ctx, i) => _RecipeCard(
                    recipe: provider.recipes[i],
                    provider: provider,
                    onEdit: () => _showRecipeDialog(context, provider, provider.recipes[i]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecipeDialog(BuildContext context, AppProvider provider, Recipe? existing) {
    final isNew = existing == null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final coffeeCtrl = TextEditingController(text: existing?.coffeeRatio.toString() ?? '40');
    final sugarCtrl = TextEditingController(text: existing?.sugarRatio.toString() ?? '35');
    final milkCtrl = TextEditingController(text: existing?.milkRatio.toString() ?? '25');
    final weightCtrl = TextEditingController(text: existing?.totalWeight.toString() ?? '20');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: context.theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.theme.border)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isNew ? 'Create Recipe' : 'Edit Recipe',
                    style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 20),
                _field('Recipe Name', nameCtrl),
                SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Coffee (%)', coffeeCtrl, hint: 'e.g. 40')),
                  SizedBox(width: 12),
                  Expanded(child: _field('Sugar (%)', sugarCtrl, hint: 'e.g. 35')),
                ]),
                SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Milk Powder (%)', milkCtrl, hint: 'e.g. 25')),
                  SizedBox(width: 12),
                  Expanded(child: _field('Total Weight (g)', weightCtrl, hint: 'e.g. 20')),
                ]),
                SizedBox(height: 24),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: GoogleFonts.inter(color: context.theme.textSecondary)),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        final recipe = Recipe(
                          id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim().isEmpty ? 'Unnamed Recipe' : nameCtrl.text.trim(),
                          coffeeRatio: double.tryParse(coffeeCtrl.text) ?? 40,
                          sugarRatio: double.tryParse(sugarCtrl.text) ?? 35,
                          milkRatio: double.tryParse(milkCtrl.text) ?? 25,
                          totalWeight: double.tryParse(weightCtrl.text) ?? 20,
                          isDefault: existing?.isDefault ?? false,
                        );
                        if (isNew) provider.addRecipe(recipe);
                        else provider.updateRecipe(recipe);
                        Navigator.pop(ctx);
                      },
                      child: Text(isNew ? 'Create' : 'Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      keyboardType: label.contains('%') || label.contains('g)') ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final AppProvider provider;
  final VoidCallback onEdit;
  const _RecipeCard({required this.recipe, required this.provider, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isActive = provider.activeRecipe?.id == recipe.id;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? context.theme.accent : context.theme.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: context.theme.accent.withOpacity(0.1), blurRadius: 12, spreadRadius: 2)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.science_rounded, color: context.theme.accent, size: 18),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name,
                        style: GoogleFonts.inter(color: context.theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    Text('${recipe.totalWeight.toInt()}g per sachet',
                        style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              if (recipe.isDefault)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.theme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('DEFAULT', style: GoogleFonts.inter(color: context.theme.accent, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          SizedBox(height: 16),
          // Ratio bars
          _ratioBars(context),
          Spacer(),
          Row(
            children: [
              InkWell(
                onTap: () => provider.setActiveRecipe(recipe),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? context.theme.accent.withOpacity(0.15) : context.theme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isActive ? context.theme.accent.withOpacity(0.4) : context.theme.border),
                  ),
                  child: Text(
                    isActive ? '✓ Active' : 'Set Active',
                    style: GoogleFonts.inter(color: isActive ? context.theme.accent : context.theme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(width: 6),
              InkWell(
                onTap: () => provider.setDefaultRecipe(recipe.id),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: context.theme.surfaceLight, borderRadius: BorderRadius.circular(6), border: Border.all(color: context.theme.border)),
                  child: Text('Default', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 11)),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_rounded, size: 16, color: context.theme.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => provider.deleteRecipe(recipe.id),
                icon: Icon(Icons.delete_rounded, size: 16, color: context.theme.error),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratioBars(BuildContext context) {
    final total = recipe.coffeeRatio + recipe.sugarRatio + recipe.milkRatio;
    return Column(
      children: [
        _ratioRow(context, '☕ Coffee', recipe.coffeeRatio, total, AppTheme.accentDark),
        SizedBox(height: 4),
        _ratioRow(context, '🍬 Sugar', recipe.sugarRatio, total, AppTheme.info),
        SizedBox(height: 4),
        _ratioRow(context, '🥛 Milk', recipe.milkRatio, total, context.theme.textSecondary),
      ],
    );
  }

  Widget _ratioRow(BuildContext context, String label, double value, double total, Color color) {
    final pct = total > 0 ? value / total : 0.0;
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: context.theme.surfaceLighter,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ),
        SizedBox(width: 6),
        SizedBox(width: 30, child: Text('${value.toInt()}%', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10))),
      ],
    );
  }
}