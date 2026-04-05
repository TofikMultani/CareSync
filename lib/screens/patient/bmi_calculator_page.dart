import 'dart:math';
import 'package:flutter/material.dart';

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmi;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final double? heightCm = double.tryParse(_heightController.text);
    final double? weightKg = double.tryParse(_weightController.text);

    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid height and weight values.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);
    final double clampedBmi = bmi.clamp(10.0, 40.0);

    setState(() {
      _bmi = bmi;
    });

    _animation = Tween<double>(
      begin: _animation.value,
      end: clampedBmi,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController
      ..reset()
      ..forward();
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }

  String _bmiAdvice(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. Consider a balanced diet with adequate calories and nutrients.';
    }
    if (bmi < 25.0) {
      return 'Great! You have a healthy BMI. Keep up a balanced diet and regular exercise.';
    }
    if (bmi < 30.0) {
      return 'You are overweight. Regular exercise and a balanced diet can help.';
    }
    return 'You are in the obese range. Please consult your doctor for a personalised plan.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Input Card ───────────────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Your Measurements',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _calculateBmi,
                        icon: const Icon(Icons.calculate),
                        label: const Text(
                          'Calculate BMI',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Speedometer Gauge ────────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      'BMI Meter',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: _SpeedometerPainter(
                            bmiValue: _animation.value,
                            hasBmi: _bmi != null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // ── Legend ───────────────────────────────────────────
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: const [
                        _LegendItem(color: Colors.blue, label: 'Underweight\n(<18.5)'),
                        _LegendItem(color: Colors.green, label: 'Normal\n(18.5-24.9)'),
                        _LegendItem(color: Colors.orange, label: 'Overweight\n(25-29.9)'),
                        _LegendItem(color: Colors.red, label: 'Obese\n(>=30)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Result Card ──────────────────────────────────────────────
            if (_bmi != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI: ${_bmi!.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _bmiColor(_bmi!),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _bmiColor(_bmi!).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _bmiCategory(_bmi!),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _bmiColor(_bmi!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _bmiAdvice(_bmi!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ── Speedometer CustomPainter ─────────────────────────────────────────────────

class _SpeedometerPainter extends CustomPainter {
  final double bmiValue; // 10 … 40
  final bool hasBmi;

  // Gauge range mapped onto the arc
  static const double _minBmi = 10.0;
  static const double _maxBmi = 40.0;

  // Arc starts at 200° and sweeps 140° (left → right, bottom half semi-circle)
  static const double _startAngle = 200 * pi / 180;
  static const double _sweepAngle = 140 * pi / 180;

  const _SpeedometerPainter({required this.bmiValue, required this.hasBmi});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height * 0.82;
    final double radius = size.width * 0.40;
    final double strokeW = radius * 0.22;

    // ── Draw coloured arc segments ────────────────────────────────────
    // Segment boundaries in BMI values:
    // 10 – 18.5 → blue (underweight)
    // 18.5 – 25 → green (normal)
    // 25 – 30   → orange (overweight)
    // 30 – 40   → red (obese)
    final segments = [
      _Segment(start: 10.0, end: 18.5, color: Colors.blue),
      _Segment(start: 18.5, end: 25.0, color: Colors.green),
      _Segment(start: 25.0, end: 30.0, color: Colors.orange),
      _Segment(start: 30.0, end: 40.0, color: Colors.red),
    ];

    final arcRect = Rect.fromCircle(
        center: Offset(cx, cy), radius: radius - strokeW / 2);

    for (final seg in segments) {
      final double segStart = _bmiToAngle(seg.start);
      final double segSweep = _bmiToAngle(seg.end) - segStart;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(arcRect, segStart, segSweep, false, paint);
    }

    // ── Tick marks ────────────────────────────────────────────────────
    final tickPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1.5;
    final labelStyle = TextStyle(
      color: Colors.black54,
      fontSize: radius * 0.13,
      fontWeight: FontWeight.w600,
    );

    for (final bmi in [10.0, 18.5, 25.0, 30.0, 40.0]) {
      final angle = _bmiToAngle(bmi);
      final innerR = radius - strokeW - 8;
      final outerR = radius + 4;
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
        tickPaint,
      );
      // Label
      final labelR = radius - strokeW - 20;
      final span = TextSpan(
          text: bmi == bmi.truncateToDouble()
              ? bmi.toInt().toString()
              : bmi.toString(),
          style: labelStyle);
      final tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout();
      tp.paint(
        canvas,
        Offset(cx + labelR * cos(angle) - tp.width / 2,
            cy + labelR * sin(angle) - tp.height / 2),
      );
    }

    // ── Needle ────────────────────────────────────────────────────────
    if (hasBmi) {
      final needleAngle = _bmiToAngle(bmiValue);
      final needleLen = radius - strokeW / 2 + 2;

      final needlePaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + needleLen * cos(needleAngle),
            cy + needleLen * sin(needleAngle)),
        needlePaint,
      );

      // Centre circle
      canvas.drawCircle(
          Offset(cx, cy),
          10,
          Paint()..color = Colors.black87);
      canvas.drawCircle(
          Offset(cx, cy),
          7,
          Paint()..color = Colors.white);
    }

    // ── BMI value text in the centre ──────────────────────────────────
    if (hasBmi) {
      final valueStyle = TextStyle(
        fontSize: radius * 0.28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      );
      final valueSpan = TextSpan(
          text: bmiValue.toStringAsFixed(1), style: valueStyle);
      final valueTp = TextPainter(
          text: valueSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout();
      valueTp.paint(
        canvas,
        Offset(cx - valueTp.width / 2, cy - valueTp.height - 14),
      );
    }
  }

  /// Maps a BMI value to its corresponding angle on the arc.
  double _bmiToAngle(double bmi) {
    final t = (bmi - _minBmi) / (_maxBmi - _minBmi);
    return _startAngle + t * _sweepAngle;
  }

  @override
  bool shouldRepaint(_SpeedometerPainter oldDelegate) =>
      oldDelegate.bmiValue != bmiValue || oldDelegate.hasBmi != hasBmi;
}

class _Segment {
  final double start;
  final double end;
  final Color color;
  const _Segment({required this.start, required this.end, required this.color});
}

// ── Legend Item ───────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
