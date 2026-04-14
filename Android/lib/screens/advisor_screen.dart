import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../widgets/ui_elements.dart';

class AdvisorScreen extends StatelessWidget {
  const AdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final snapshot = provider.monthlySnapshot;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Advisor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAIPredictionCard(context, provider),
          const SizedBox(height: 24),
          Text(
            'Smart Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            context,
            icon: LucideIcons.trendingDown,
            title: 'Spending Pattern',
            description: 'You\'ve spent 15% less on Food & Dining compared to last week. Keep it up!',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            context,
            icon: LucideIcons.alertTriangle,
            title: 'Budget Alert',
            description: 'Your Shopping expenses are 80% of your monthly average. You might cross it in 3 days.',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            context,
            icon: LucideIcons.sparkles,
            title: 'Saving Opportunity',
            description: 'Switching your unused "Premium Subscription" could save you ₹499/month.',
            color: const Color(0xFF09637E),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPredictionCard(BuildContext context, FinanceProvider provider) {
    return MaterialCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.brainCircuit, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Monthly Forecast',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '₹42,500',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            'Predicted spend by end of month',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 10),
          Text(
            'You are on track to save ₹7,500 more than last month!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, {required IconData icon, required String title, required String description, required Color color}) {
    return MaterialCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
