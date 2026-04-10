import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/ui_elements.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ).then((_) => provider.notifyListeners()),
            child: const Text('Edit', style: TextStyle(color: Color(0xFF4F8EF7), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const AppBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAvatarSection(provider),
                const SizedBox(height: 28),
                _buildPersonalInfoCard(provider),
                const SizedBox(height: 28),
                _buildCardSection(context, provider),
                const SizedBox(height: 28),
                _buildSettingsCard(context, provider),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(FinanceProvider provider) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF4F8EF7), Color(0xFF2D5BA3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            provider.userFirstName.isNotEmpty 
              ? provider.userFirstName[0].toUpperCase() 
              : '?',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(FinanceProvider provider) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _infoRow(LucideIcons.user, 'Name', provider.userDisplayName),
          _divider(),
          _infoRow(LucideIcons.mail, 'Email', provider.userEmail.isEmpty ? '—' : provider.userEmail),
          _divider(),
          _infoRow(LucideIcons.phone, 'Phone', provider.userPhone.isEmpty ? '—' : provider.userPhone),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4F8EF7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4F8EF7), size: 16),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context, FinanceProvider provider) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (provider.cardGenerated) ...[
            _infoRow(LucideIcons.creditCard, 'Card', '•••• •••• •••• ${provider.cardLast4}'),
            _divider(),
            ListTile(
              onTap: () => _confirmDestroyCard(context, provider),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
              ),
              title: const Text('Destroy Card', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ] else
            ListTile(
              onTap: () => provider.generateCard(),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F8EF7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.sparkles, color: Color(0xFF4F8EF7), size: 16),
              ),
              title: const Text('Generate Card', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, FinanceProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appearance', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildAppearancePicker(provider),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statPill('Transactions', '${provider.transactions.length}'),
              _dividerVertical(),
              _statPill('Balance', provider.formatCurrency(provider.monthlySnapshot.balance)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearancePicker(FinanceProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _appearanceButton(provider, 'System', ThemeMode.system),
          _appearanceButton(provider, 'Light', ThemeMode.light),
          _appearanceButton(provider, 'Dark', ThemeMode.dark),
        ],
      ),
    );
  }

  Widget _appearanceButton(FinanceProvider provider, String label, ThemeMode mode) {
    bool isSelected = provider.appearance == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setAppearance(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _divider() => Divider(color: Colors.white.withOpacity(0.1), indent: 52);
  Widget _dividerVertical() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.15));

  void _confirmDestroyCard(BuildContext context, FinanceProvider provider) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Destroy Card?', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently delete your virtual tracking card data.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.destroyCard();
              Navigator.pop(context);
            }, 
            child: const Text('Destroy', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}
