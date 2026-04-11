import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/ui_elements.dart';
import '../widgets/home_components.dart' hide GlassCard;
import '../widgets/atm_card_view.dart';
import 'add_transaction_screen.dart';

enum OnboardingPhase { intro, setup }
enum SetupStep { name, contact, firstTransaction, cardSetup }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingPhase _phase = OnboardingPhase.intro;
  SetupStep _setupStep = SetupStep.name;
  int _introPageIndex = 0;
  final PageController _pageController = PageController();

  // Setup state
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _showValidation = false;

  final List<OnboardingIntroData> _introPages = [
    OnboardingIntroData(
      image: 'assets/images/onboarding_home.png',
      gradientColors: [const Color(0xFF09637E), const Color(0xFF2D5BA3)],
      title: 'Know Where Your Money Goes',
      subtitle: 'Track every rupee with smart categories. See exactly what you spend on food, travel, bills, and more — all in one clean dashboard.',
    ),
    OnboardingIntroData(
      image: 'assets/images/onboarding_add.png',
      gradientColors: [const Color(0xFF6E44C8), const Color(0xFF9B59B6)],
      title: 'Log Income & Expenses Instantly',
      subtitle: 'Add transactions in seconds. Whether it\'s a salary deposit or a coffee run, every entry builds a clearer picture of your finances.',
    ),
    OnboardingIntroData(
      image: 'assets/images/onboarding_insights.png',
      gradientColors: [const Color(0xFF2EC4B6), const Color(0xFF1A8F85)],
      title: 'Insights That Actually Help',
      subtitle: 'Monthly summaries, spending rings, and category charts so you always know if this month is healthy — before it ends.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const AppBackdrop(),
          if (_phase == OnboardingPhase.intro)
            _buildIntroView()
          else
            _buildSetupView(),
        ],
      ),
    );
  }

  // MARK: - Intro View

  Widget _buildIntroView() {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Row(
              children: [
                ...List.generate(_introPages.length, (i) => _buildPageIndicator(i)),
                const Spacer(),
                if (_introPageIndex < _introPages.length - 1)
                  GestureDetector(
                    onTap: () => setState(() => _introPageIndex = _introPages.length - 1),
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _introPageIndex = i),
            itemCount: _introPages.length,
            itemBuilder: (context, i) => _buildIntroPage(_introPages[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: PrimaryButton(
            title: _introPageIndex < _introPages.length - 1 ? 'Next' : 'Get Started',
            action: () {
              if (_introPageIndex < _introPages.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutQuart);
              } else {
                setState(() => _phase = OnboardingPhase.setup);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int index) {
    final isSelected = _introPageIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF09637E) : Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildIntroPage(OnboardingIntroData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: data.gradientColors.map((c) => c.withOpacity(0.22)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Image.asset(data.image, width: 200, height: 200, fit: BoxFit.contain),
          ],
        ),
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 14),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Setup View

  Widget _buildSetupView() {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
            child: Row(
              children: List.generate(4, (i) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getStepIndex() >= i ? const Color(0xFF09637E) : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(Tween(begin: const Offset(0.1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut))),
                  child: child,
                ),
              );
            },
            child: _buildSetupStep(),
          ),
        ),
      ],
    );
  }

  int _getStepIndex() {
    switch (_setupStep) {
      case SetupStep.name: return 0;
      case SetupStep.contact: return 1;
      case SetupStep.firstTransaction: return 2;
      case SetupStep.cardSetup: return 3;
    }
  }

  Widget _buildSetupStep() {
    switch (_setupStep) {
      case SetupStep.name:
        return _SetupStepWrapper(
          key: const ValueKey('name'),
          icon: LucideIcons.user,
          iconColors: const [Color(0xFF09637E), Color(0xFF2D5BA3)],
          title: "What's your name?",
          subtitle: "Personalise your experience — your greeting and profile will use this.",
          fields: Column(
            children: [
              _SetupTextField(controller: _firstNameController, placeholder: 'First Name', icon: LucideIcons.user),
              const SizedBox(height: 14),
              _SetupTextField(controller: _lastNameController, placeholder: 'Last Name (optional)', icon: LucideIcons.userPlus),
              if (_showValidation && _firstNameController.text.trim().isEmpty)
                _buildValidation("Please enter your first name."),
            ],
          ),
          onNext: () {
            if (_firstNameController.text.trim().isEmpty) {
              setState(() => _showValidation = true);
            } else {
              setState(() {
                _showValidation = false;
                _setupStep = SetupStep.contact;
              });
              context.read<FinanceProvider>().saveUserName(_firstNameController.text.trim(), _lastNameController.text.trim());
            }
          },
        );
      case SetupStep.contact:
        return _SetupStepWrapper(
          key: const ValueKey('contact'),
          icon: LucideIcons.mail,
          iconColors: const [Color(0xFF6E44C8), Color(0xFF9B59B6)],
          title: "Contact info",
          subtitle: "Completely optional — used only to personalise your profile within the app.",
          fields: Column(
            children: [
              _SetupTextField(controller: _emailController, placeholder: 'Email (optional)', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _SetupTextField(controller: _phoneController, placeholder: 'Phone (optional)', icon: LucideIcons.phone, keyboardType: TextInputType.phone),
            ],
          ),
          onNext: () {
            context.read<FinanceProvider>().saveContactInfo(_emailController.text.trim(), _phoneController.text.trim());
            setState(() => _setupStep = SetupStep.firstTransaction);
          },
        );
      case SetupStep.firstTransaction:
        return _SetupStepWrapper(
          key: const ValueKey('first'),
          icon: LucideIcons.plusCircle,
          iconColors: const [Color(0xFF2EC4B6), Color(0xFF1A8F85)],
          title: "Add your first transaction",
          subtitle: "Log one income or expense now to see your dashboard come alive.",
          nextLabel: 'Skip for now',
          fields: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your dashboard waits for real data.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Tap below to log your first income or expense. You can also skip and add it from the home screen later.", 
                     style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                const SizedBox(height: 18),
                PrimaryButton(
                  title: 'Add first transaction', 
                  action: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(
                      kind: 'expense',
                      onSave: () => setState(() => _setupStep = SetupStep.cardSetup),
                    )));
                  }
                ),
              ],
            ),
          ),
          onNext: () => setState(() => _setupStep = SetupStep.cardSetup),
        );
      case SetupStep.cardSetup:
        return _CardSetupStep(onFinish: () {
          context.read<FinanceProvider>().completeOnboarding();
        });
    }
  }

  Widget _buildValidation(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: Colors.red, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SetupStepWrapper extends StatelessWidget {
  final IconData icon;
  final List<Color> iconColors;
  final String title;
  final String subtitle;
  final Widget fields;
  final VoidCallback onNext;
  final String nextLabel;

  const _SetupStepWrapper({
    super.key,
    required this.icon,
    required this.iconColors,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onNext,
    this.nextLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(colors: iconColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: iconColors.first.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 28),
                Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                const SizedBox(height: 28),
                fields,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          child: PrimaryButton(title: nextLabel, action: onNext),
        ),
      ],
    );
  }
}

class _SetupTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final TextInputType keyboardType;

  const _SetupTextField({required this.controller, required this.placeholder, required this.icon, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSetupStep extends StatefulWidget {
  final VoidCallback onFinish;
  const _CardSetupStep({required this.onFinish});

  @override
  State<_CardSetupStep> createState() => _CardSetupStepState();
}

class _CardSetupStepState extends State<_CardSetupStep> {
  bool _generated = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final isGenerated = provider.cardGenerated;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF09637E).withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                const Text('Your ExpenseTracker Card', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 10),
                const Text('A virtual card that lives inside the app — representing your financial identity here, not in any bank.', 
                     style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                const SizedBox(height: 28),
                
                ATMCardView(snapshot: provider.monthlySnapshot),
                
                const SizedBox(height: 28),
                _buildBullet(LucideIcons.userCheck, const Color(0xFF09637E), 'Your financial identity', 'Your name, card number, and expiry date are generated uniquely for your account.'),
                const SizedBox(height: 14),
                _buildBullet(LucideIcons.barChart, const Color(0xFF2EC4B6), 'Live balance on the back', 'Flip the card anytime to see your current month\'s available balance, income, and expenses.'),
                const SizedBox(height: 14),
                _buildBullet(LucideIcons.shieldCheck, const Color(0xFF6E44C8), 'Private & local', 'Everything stays on your device. No network calls, no third parties.'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          child: PrimaryButton(
            title: isGenerated ? 'Continue to Home' : 'Generate My Card', 
            action: () {
              if (isGenerated) {
                widget.onFinish();
              } else {
                provider.generateCard();
                setState(() => _generated = true);
              }
            }
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(IconData icon, Color color, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingIntroData {
  final String image;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  OnboardingIntroData({required this.image, required this.gradientColors, required this.title, required this.subtitle});
}
