import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../models/finance_models.dart';

class ATMCardView extends StatefulWidget {
  final MonthlySnapshot snapshot;
  const ATMCardView({super.key, required this.snapshot});

  @override
  State<ATMCardView> createState() => _ATMCardViewState();
}

class _ATMCardViewState extends State<ATMCardView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    if (!provider.cardGenerated) return;

    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final width = MediaQuery.of(context).size.width - 40;

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleFlip,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * pi;
              final isFront = angle < pi / 2;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: isFront
                    ? _buildFront(provider, width)
                    : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildBack(provider, width),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.hand, size: 12, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 5),
            Text(
              provider.cardGenerated 
                  ? 'Tap to ${_isFlipped ? 'see card' : 'see balance'}'
                  : 'Generate your card in Profile',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFront(FinanceProvider provider, double width) {
    if (!provider.cardGenerated) {
      return _buildPlaceholder(provider, width);
    }

    return Container(
      width: width,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Expense\nDairy',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00FF00),
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _maskCardNumber(provider.cardNumber),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    provider.userDisplayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'VALID THRU',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    provider.cardExpiry,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(LucideIcons.wifi, size: 20, color: Colors.white54),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack(FinanceProvider provider, double width) {
    return Container(
      width: width,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF16213E), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 38,
              color: Colors.black.withOpacity(0.85),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AVAILABLE BALANCE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 1.4,
                          ),
                        ),
                        Text(
                          provider.formatCurrency(widget.snapshot.balance),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.snapshot.balance >= 0 ? const Color(0xFF2EC4B6) : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Divider(color: Colors.white.withOpacity(0.15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('INCOME', provider.formatCurrency(widget.snapshot.income), const Color(0xFF2EC4B6)),
                    Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                    _buildStat('EXPENSES', provider.formatCurrency(widget.snapshot.expenses), const Color(0xFFFF6B6B), alignEnd: true),
                  ],
                ),
                Divider(color: Colors.white.withOpacity(0.15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '•••• •••• •••• ${provider.cardLast4}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.55),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Icon(LucideIcons.wifi, size: 14, color: Colors.white24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(FinanceProvider provider, double width) {
    return Container(
      width: width,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  provider.formatCurrency(widget.snapshot.balance),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Divider(color: Colors.white.withOpacity(0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('INCOME', provider.formatCurrency(widget.snapshot.income), const Color(0xFF2EC4B6)),
                    Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                    _buildStat('EXPENSES', provider.formatCurrency(widget.snapshot.expenses), const Color(0xFFFF6B6B), alignEnd: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _maskCardNumber(String number) {
    final parts = number.split(' ');
    if (parts.length == 4) {
      return '${parts[0]} ${parts[1]} •••• ${parts[3]}';
    }
    return '•••• •••• •••• ••••';
  }
}
