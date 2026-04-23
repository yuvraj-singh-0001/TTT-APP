import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../app_branding.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  String? _selectedClass;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  int _step = 1; // 1 = form, 2 = payment

  String _regType = 'registration_only';
  String _appliedCoupon = '';
  double _discountPct = 0;
  String _discountMsg = '';
  bool _couponApplied = false;

  late AnimationController _animCtrl;
  Timer? _offerTimer;
  int _timeLeft = 20 * 60 + 15;

  final double _regPrice = 99;
  final double _regOrig = 799;
  final double _bookPrice = 199;
  final double _bookOrig = 1299;
  final double _gst = 0.18;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _startOfferEffects() {
    if (_animCtrl.isAnimating || _timeLeft <= 0) {
      return;
    }
    _animCtrl.repeat();
    _offerTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _timeLeft <= 0) {
        _stopOfferEffects();
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _stopOfferEffects() {
    _offerTimer?.cancel();
    _offerTimer = null;
    if (_animCtrl.isAnimating) {
      _animCtrl.stop();
    }
  }

  String get _timeStr {
    final m = _timeLeft ~/ 60;
    final s = _timeLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _base => _regType == 'registration_only' ? _regPrice : _bookPrice;
  double get _discounted =>
      _couponApplied ? _base * (1 - _discountPct / 100) : _base;
  double get _gstAmt => _discounted * _gst;
  double get _total => _discounted + _gstAmt;

  void _applyCoupon() {
    final c = _couponCtrl.text.trim().toUpperCase();
    final Map<String, double> coupons = {
      'SAVE80': 80,
      'WELCOME50': 50,
      'FLAT100': 30,
    };
    if (_couponApplied) {
      _snack('Coupon already applied!');
    } else if (coupons.containsKey(c)) {
      setState(() {
        _appliedCoupon = c;
        _discountPct = coupons[c]!;
        _discountMsg = 'Coupon applied! ${_discountPct.toInt()}% OFF';
        _couponApplied = true;
      });
    } else {
      _snack('Invalid coupon code');
    }
  }

  void _removeCoupon() => setState(() {
    _appliedCoupon = '';
    _discountPct = 0;
    _discountMsg = '';
    _couponApplied = false;
    _couponCtrl.clear();
  });

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _goToStep2() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null) {
      _snack('Please select your class');
      return;
    }
    if (!_agreeToTerms) {
      _snack('Please agree to Terms & Conditions');
      return;
    }
    setState(() => _step = 2);
    _startOfferEffects();
  }

  Future<void> _pay() async {
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    _stopOfferEffects();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationPage(
          userName: _nameCtrl.text,
          userClass: _selectedClass!,
          whatsappNumber: _waCtrl.text,
          registrationType: _regType,
          totalPayable: _total,
          couponApplied: _appliedCoupon,
          discountPercentage: _discountPct,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _nameCtrl.dispose();
    _waCtrl.dispose();
    _couponCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // â”€â”€â”€ INPUT DECORATION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: kBrandGold),
    filled: true,
    fillColor: Colors.white.withAlpha(15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kBrandGold.withAlpha(50)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kBrandGold.withAlpha(50)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kBrandGold, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );

  // â”€â”€â”€ BUILD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A0A),
              Color(0xFF0D0D05),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
              child: _step == 1 ? _buildStep1() : _buildStep2(),
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ STEP 1 â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildStep1() {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      key: const ValueKey('step1'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        children: [
          const SizedBox(height: 6),
          // Logo
          Image.asset('assets/logo-image.png', height: 90, fit: BoxFit.contain),
          const SizedBox(height: 16),
          // Welcome text
          const Text(
            'Welcome to The True Toppers',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kBrandGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Register now & unlock your potential!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Form card
          Card(
            elevation: 10,
            color: Colors.black.withAlpha(200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: kBrandGold.withAlpha(100)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepDot(1, true),
                        const SizedBox(width: 8),
                        Container(
                          height: 2,
                          width: 40,
                          color: kBrandGold.withAlpha(80),
                        ),
                        const SizedBox(width: 8),
                        _stepDot(2, false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Personal Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _deco('Full Name', Icons.person_outline),
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    // Class dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedClass,
                      decoration: _deco('Class', Icons.school_outlined),
                      dropdownColor: const Color(0xFF1A1A0A),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: kBrandGold,
                      ),
                      items:
                          ['6th', '7th', '8th', '9th', '10th', '11th', '12th']
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedClass = v),
                      validator: (v) =>
                          v == null ? 'Please select your class' : null,
                    ),
                    const SizedBox(height: 14),
                    // WhatsApp
                    TextFormField(
                      controller: _waCtrl,
                      decoration: _deco('WhatsApp Number', Icons.phone_android),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter WhatsApp number';
                        }
                        if (v.length < 10) {
                          return 'Enter valid 10-digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Terms
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (v) =>
                              setState(() => _agreeToTerms = v ?? false),
                          activeColor: kBrandGold,
                          checkColor: Colors.black,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _agreeToTerms = !_agreeToTerms),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: kBrandGold,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Register & Pay button
                    ElevatedButton(
                      onPressed: _goToStep2,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Register & Pay',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: kBrandGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(int n, bool active) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? kBrandGold : Colors.white12,
      border: Border.all(color: active ? kBrandGold : Colors.white24),
    ),
    child: Center(
      child: Text(
        '$n',
        style: TextStyle(
          color: active ? Colors.black : Colors.white54,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    ),
  );

  // â”€â”€â”€ STEP 2 â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildStep2() {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      key: const ValueKey('step2'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        children: [
          const SizedBox(height: 6),
          _buildOfferTimer(),
          const SizedBox(height: 14),
          Card(
            elevation: 10,
            color: Colors.black.withAlpha(200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: kBrandGold.withAlpha(130), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stepDot(1, false),
                      const SizedBox(width: 8),
                      Container(height: 2, width: 40, color: kBrandGold),
                      const SizedBox(width: 8),
                      _stepDot(2, true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Registration Type',
                        style: TextStyle(
                          color: kBrandGold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Best value plans',
                        style: TextStyle(
                          color: Colors.white.withAlpha(140),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _radioCard(
                    'registration_only',
                    'Registration Only',
                    '₹${_regPrice.toInt()}',
                    '₹${_regOrig.toInt()}',
                  ),
                  const SizedBox(height: 8),
                  _radioCard(
                    'with_book',
                    'With Book Material',
                    '₹${_bookPrice.toInt()}',
                    '₹${_bookOrig.toInt()}',
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  _buildCoupon(),
                  const Divider(color: Colors.white24, height: 24),
                  _buildPriceBreakdown(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Proceed to Pay  ₹${_total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildOfferTimer() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        final glow = 70 + (70 * _animCtrl.value).toInt();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, color: kBrandGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Offer ends in',
                style: TextStyle(
                  color: Colors.white.withAlpha(210),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: kBrandGold.withAlpha(glow),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  _timeStr,
                  style: const TextStyle(
                    color: kBrandGold,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _radioCard(String val, String title, String offer, String orig) {
    final sel = _regType == val;
    return GestureDetector(
      onTap: () => setState(() {
        _regType = val;
        _removeCoupon();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? kBrandGold : Colors.white24,
            width: sel ? 2 : 1,
          ),
          color: sel ? kBrandGold.withAlpha(25) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? kBrandGold : Colors.white54,
                  width: 2,
                ),
              ),
              child: sel
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kBrandGold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        orig,
                        style: const TextStyle(
                          color: Colors.white38,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '80% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  offer,
                  style: TextStyle(
                    color: sel ? kBrandGold : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  val == 'with_book' ? 'Books included' : 'Exam access',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupon() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Have a coupon?',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Spacer(),
            Text(
              'Optional',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponCtrl,
                enabled: !_couponApplied,
                decoration: InputDecoration(
                  hintText: 'e.g. SAVE80',
                  hintStyle: const TextStyle(color: Colors.white30),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kBrandGold.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kBrandGold.withAlpha(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBrandGold),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _couponApplied ? _removeCoupon : _applyCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: _couponApplied ? Colors.red : kBrandGold,
                foregroundColor: _couponApplied ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_couponApplied ? 'Remove' : 'Apply'),
            ),
          ],
        ),
        if (_discountMsg.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _discountMsg,
              style: TextStyle(color: Colors.green.shade400, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Price Breakdown',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              'Final summary',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _priceRow('Base Price:', 'Rs ${_base.toStringAsFixed(0)}', false),
              if (_couponApplied)
                _priceRow(
                  'Discount (${_discountPct.toInt()}%):',
                  '- Rs ${(_base - _discounted).toStringAsFixed(0)}',
                  false,
                  color: Colors.green.shade400,
                ),
              _priceRow('GST (18%):', 'Rs ${_gstAmt.toStringAsFixed(0)}', false),
              const Divider(color: Colors.white24, height: 16),
              _priceRow(
                'Total Payable:',
                'Rs ${_total.toStringAsFixed(0)}',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String val, bool bold, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? kBrandGold : Colors.white70,
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              color: color ?? (bold ? kBrandGold : Colors.white),
              fontSize: bold ? 17 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ PAYMENT CONFIRMATION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class PaymentConfirmationPage extends StatelessWidget {
  final String userName,
      userClass,
      whatsappNumber,
      registrationType,
      couponApplied;
  final double totalPayable, discountPercentage;

  const PaymentConfirmationPage({
    super.key,
    required this.userName,
    required this.userClass,
    required this.whatsappNumber,
    required this.registrationType,
    required this.totalPayable,
    required this.couponApplied,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
        backgroundColor: Colors.transparent,
        foregroundColor: kBrandGold,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A0A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.black.withAlpha(200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: kBrandGold.withAlpha(100)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Registration Successful! ðŸŽ‰',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Details sent to $whatsappNumber',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 20),
                        _row('Name:', userName),
                        _row('Class:', userClass),
                        _row(
                          'Type:',
                          registrationType == 'registration_only'
                              ? 'Registration Only'
                              : 'With Book Material',
                        ),
                        if (couponApplied.isNotEmpty)
                          _row(
                            'Coupon:',
                            '$couponApplied (${discountPercentage.toInt()}% OFF)',
                          ),
                        _row(
                          'Amount Paid:',
                          'Rs ${totalPayable.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (_) => false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBrandGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Go to Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
