import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// AirGo's own visual identity: forest ink, terracotta, mint and warm paper.
class AirColors {
  static const ink = Color(0xFF1D302C);
  static const orange = Color(0xFFDE704F);
  static const mint = Color(0xFFC7E8D8);
  static const paper = Color(0xFFF8F5ED);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF64766C);
  static const border = Color(0xFFDCE5DA);
}

// Replace these placeholders with your information before submission.
const studentName = 'FIENNY HANNY ANAK ASLEE';
const matricNumber = '2025219862';
const courseName = 'CS251';
const githubUrl = 'https://github.com/YOUR_USERNAME/airgo';

void main() => runApp(const AirGoApp());

class AirGoApp extends StatelessWidget {
  const AirGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AirColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AirColors.ink,
          primary: AirColors.ink,
          secondary: AirColors.orange,
          surface: AirColors.paper,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AirColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AirColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AirColors.ink, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
      home: const AirGoShell(),
    );
  }
}

class AirGoShell extends StatefulWidget {
  const AirGoShell({super.key});

  @override
  State<AirGoShell> createState() => _AirGoShellState();
}

class _AirGoShellState extends State<AirGoShell> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: page,
        children: const [HomePage(), AboutPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        backgroundColor: AirColors.white,
        indicatorColor: AirColors.mint,
        onDestinationSelected: (index) => setState(() => page = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage, color: AirColors.ink),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info, color: AirColors.ink),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class BaggageResult {
  final double excess;
  final double charge;
  final double tax;
  final double total;

  const BaggageResult(this.excess, this.charge, this.tax, this.total);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
  final rateController = TextEditingController();
  final scrollController = ScrollController();

  String ticketClass = 'Economy';
  BaggageResult? result;

  double get allowance => ticketClass == 'Economy' ? 20.0 : 40.0;

  double get previewWeight {
    final value = double.tryParse(weightController.text.trim());
    return (value != null && value.isFinite && value >= 0) ? value : 0.0;
  }

  String? validateNumber(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Please enter a value';
    }
    final value = double.tryParse(text.trim());
    if (value == null || !value.isFinite) {
      return 'Enter a valid number';
    }
    if (value < 0) {
      return 'Value cannot be negative';
    }
    return null;
  }

  void calculate() {
    if (!formKey.currentState!.validate()) {
      setState(() => result = null);
      return;
    }

    final weight = double.parse(weightController.text.trim());
    final rate = double.parse(rateController.text.trim());

    // The four assignment rules, in the same order as the question.
    final excess = max(0.0, weight - allowance);
    final charge = excess * rate;
    final tax = charge * 0.08;
    final total = charge + tax;

    if (!charge.isFinite || !tax.isFinite || !total.isFinite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Values are too large to calculate.')),
      );
      return;
    }

    setState(() => result = BaggageResult(excess, charge, tax, total));
    FocusScope.of(context).unfocus();

    // Move to the new receipt so the result is easy to find.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void reset() {
    weightController.clear();
    rateController.clear();
    setState(() {
      ticketClass = 'Economy';
      result = null;
    });
    formKey.currentState?.reset();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final over = max(0.0, previewWeight - allowance);
    final progress = (previewWeight / allowance).clamp(0.0, 1.0).toDouble();

    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A full-width departure-board header, not another rounded card.
            Container(
              padding: const EdgeInsets.fromLTRB(23, 24, 23, 30),
              decoration: const BoxDecoration(
                color: AirColors.ink,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flight_takeoff, color: AirColors.orange),
                      const SizedBox(width: 8),
                      const Text('AIRGO',
                          style: TextStyle(
                            color: AirColors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          )),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AirColors.mint),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('BAG DESK  /  01',
                            style: TextStyle(
                              color: AirColors.mint,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text('EXCESS BAGGAGE',
                      style: TextStyle(
                        color: AirColors.mint,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.4,
                      )),
                  const SizedBox(height: 7),
                  const Text('Know your fee.\nBefore you fly.',
                      style: TextStyle(
                        color: AirColors.white,
                        fontSize: 32,
                        height: 1.13,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 15),
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 17, color: AirColors.mint),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('No hidden calculations. Just your estimate.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD7E6DF),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Live allowance monitor changes with ticket class and weight.
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AirColors.mint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR BAGGAGE ALLOWANCE',
                              style: TextStyle(
                                color: AirColors.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.3,
                              )),
                          const SizedBox(height: 9),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${allowance.toStringAsFixed(0)} kg',
                                  style: const TextStyle(
                                    color: AirColors.ink,
                                    fontSize: 29,
                                    fontWeight: FontWeight.w900,
                                  )),
                              const Spacer(),
                              Text(ticketClass.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AirColors.ink,
                                    letterSpacing: 1,
                                    fontSize: 11,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AirColors.white,
                              color: over > 0 ? AirColors.orange : AirColors.ink,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            over > 0
                                ? '${over.toStringAsFixed(2)} kg above allowance'
                                : 'Enter your weight to check the allowance',
                            style: const TextStyle(
                              color: AirColors.ink,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 27),
                    const Text('01  /  YOUR BAG',
                        style: TextStyle(
                          color: AirColors.orange,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          fontSize: 12,
                        )),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: validateNumber,
                      onChanged: (_) => setState(() => result = null),
                      decoration: const InputDecoration(
                        labelText: 'Checked baggage weight',
                        hintText: 'e.g. 25',
                        prefixIcon: Icon(Icons.luggage_outlined),
                        suffixText: 'kg',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('02  /  YOUR TICKET',
                        style: TextStyle(
                          color: AirColors.orange,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          fontSize: 12,
                        )),
                    const SizedBox(height: 10),
                    // Distinct input widget: segmented selector, not dropdown.
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'Economy',
                              label: Text('Economy'),
                              icon: Icon(Icons.airline_seat_recline_normal)),
                          ButtonSegment(
                              value: 'Business',
                              label: Text('Business'),
                              icon: Icon(Icons.airline_seat_recline_extra)),
                        ],
                        selected: {ticketClass},
                        showSelectedIcon: false,
                        expandedInsets: EdgeInsets.zero,
                        onSelectionChanged: (values) => setState(() {
                          ticketClass = values.first;
                          result = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Included: ${allowance.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                            color: AirColors.muted, fontSize: 12)),
                    const SizedBox(height: 24),
                    const Text('03  /  THE RATE',
                        style: TextStyle(
                          color: AirColors.orange,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          fontSize: 12,
                        )),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: rateController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: validateNumber,
                      onChanged: (_) => setState(() => result = null),
                      decoration: const InputDecoration(
                        labelText: 'Excess baggage rate',
                        hintText: 'e.g. 15',
                        prefixIcon: Icon(Icons.payments_outlined),
                        prefixText: 'RM ',
                        suffixText: '/kg',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AirColors.muted),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'The rate is entered by the user. An 8% service tax applies only to the excess charge.',
                            style: TextStyle(
                                color: AirColors.muted,
                                fontSize: 12,
                                height: 1.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 23),
                    FilledButton.icon(
                      onPressed: calculate,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('CALCULATE MY FEE'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AirColors.ink,
                        foregroundColor: AirColors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: 0.9),
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextButton.icon(
                      onPressed: reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Clear all'),
                      style: TextButton.styleFrom(
                          foregroundColor: AirColors.ink),
                    ),
                    if (result != null) ...[
                      const SizedBox(height: 17),
                      _BaggageReceipt(result: result!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Receipt visual: a luggage-tag inspired breakdown with a perforated line.
class _BaggageReceipt extends StatelessWidget {
  final BaggageResult result;

  const _BaggageReceipt({required this.result});

  Widget detail(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(title,
              style: const TextStyle(color: AirColors.muted))),
          Text(amount,
              style: const TextStyle(
                color: AirColors.ink,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AirColors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AirColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AirColors.orange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sell_outlined, color: AirColors.white),
                SizedBox(width: 9),
                Expanded(
                  child: Text('AIRGO / BAGGAGE FEE RECEIPT',
                      style: TextStyle(
                        color: AirColors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                        fontSize: 13,
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              children: [
                detail('Excess baggage',
                    '${result.excess.toStringAsFixed(2)} kg'),
                detail('Excess baggage charge',
                    'RM ${result.charge.toStringAsFixed(2)}'),
                detail('Service tax (8%)',
                    'RM ${result.tax.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                // Simple dashed separator for the luggage-tag effect.
                Row(
                  children: List.generate(
                    22,
                    (_) => Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: AirColors.border,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                const Text('ESTIMATED TOTAL PAYABLE',
                    style: TextStyle(
                      fontSize: 11,
                      color: AirColors.muted,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 7),
                Text('RM ${result.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      color: AirColors.ink,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 6),
                const Text('Estimate only • No payment collected',
                    style: TextStyle(
                      color: AirColors.muted,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> openGitHub(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse(githubUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the GitHub link.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the GitHub link.')),
        );
      }
    }
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AirColors.orange),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                    color: AirColors.muted, fontSize: 12)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(
                    color: AirColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 9),
            const Text('ABOUT / AIRGO',
                style: TextStyle(
                  color: AirColors.orange,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 12,
                )),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                color: AirColors.ink,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  // In-app symbol; set up the real launcher icon separately.
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: AirColors.orange,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.flight_takeoff,
                        size: 45, color: AirColors.white),
                  ),
                  const SizedBox(height: 13),
                  const Text('AIRGO',
                      style: TextStyle(
                        color: AirColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      )),
                  const SizedBox(height: 8),
                  const Text('Excess Baggage Calculator',
                      style: TextStyle(color: AirColors.mint)),
                  const SizedBox(height: 17),
                  const Text(
                    'AirGo estimates the amount payable for bags above the '
                    'Economy or Business allowance, including 8% service tax.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AirColors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('CREATED BY',
                style: TextStyle(
                    fontSize: 12,
                    color: AirColors.orange,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5)),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AirColors.white,
                border: Border.all(color: AirColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  infoRow(Icons.person_outline, 'Name', studentName),
                  const Divider(),
                  infoRow(Icons.badge_outlined, 'Matric number', matricNumber),
                  const Divider(),
                  infoRow(Icons.school_outlined, 'Course', courseName),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => openGitHub(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('OPEN GITHUB REPOSITORY'),
              style: FilledButton.styleFrom(
                backgroundColor: AirColors.orange,
                foregroundColor: AirColors.white,
                minimumSize: const Size.fromHeight(55),
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              githubUrl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AirColors.ink, fontSize: 12),
            ),
            const SizedBox(height: 25),
            Text('© ${DateTime.now().year} $studentName. All rights reserved.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AirColors.muted)),
          ],
        ),
      ),
    );
  }
}
