import 'package:flutter/material.dart';
import 'dart:math' as math;

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmi;
  String _category = '';

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final double? heightCm = double.tryParse(_heightController.text.trim());
    final double? weightKg = double.tryParse(_weightController.text.trim());

    if (heightCm == null ||
        weightKg == null ||
        heightCm <= 0 ||
        weightKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid height and weight values.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);

    setState(() {
      _bmi = bmi;
      _category = _getBmiCategory(bmi);
    });
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _categoryColor() {
    switch (_category) {
      case 'Underweight':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.deepOrange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F8),
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E8A83), Color(0xFF30B6AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF39BFB7).withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -70,
            top: 170,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF0E8A83).withOpacity(0.11),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0E8A83), Color(0xFF2CB6AD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0E8A83).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/hospital_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'BMI Health Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Measure your body balance in seconds.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _legendItem('Fast Result', const Color(0x33FFFFFF),
                              Colors.white),
                          _legendItem('Smart Gauge', const Color(0x33FFFFFF),
                              Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D6E68),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use cm and kg for accurate BMI calculation.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          icon: Icons.height,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          icon: Icons.line_weight,
                        ),
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0E8A83), Color(0xFF39BFB7)],
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _calculateBmi,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bolt_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Calculate BMI',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_bmi != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _categoryColor().withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 16,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.analytics_outlined,
                                color: Color(0xFF0D6E68)),
                            SizedBox(width: 8),
                            Text(
                              'Your BMI Result',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0D6E68),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 190,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 10, end: _bmi),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedBmi, child) {
                              return CustomPaint(
                                painter: _BmiGaugePainter(animatedBmi),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 64),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _bmi!.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0E8A83),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'BMI Score',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Text(
                          'Range: 10 - 40',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          backgroundColor: _categoryColor().withOpacity(0.14),
                          label: Text(
                            _category,
                            style: TextStyle(
                              color: _categoryColor(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _legendItem('Underweight',
                                Colors.orange.withOpacity(0.14), Colors.orange),
                            _legendItem('Normal',
                                Colors.green.withOpacity(0.14), Colors.green),
                            _legendItem(
                                'Overweight',
                                Colors.deepOrange.withOpacity(0.14),
                                Colors.deepOrange),
                            _legendItem('Obese', Colors.red.withOpacity(0.14),
                                Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
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
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF257D77)),
        prefixIcon: Icon(icon, color: const Color(0xFF0E8A83)),
        filled: true,
        fillColor: const Color(0xFFEFF8F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF27A79F), width: 1.4),
        ),
      ),
    );
  }

  Widget _legendItem(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  _BmiGaugePainter(this.bmi);

  final double bmi;

  static const double _min = 10;
  static const double _max = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height - 16);
    final double radius = math.min(size.width * 0.38, 105);
    const double startAngle = math.pi;
    const double sweepAngle = math.pi;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    _drawSegment(
      canvas,
      arcRect,
      trackPaint,
      startAngle,
      sweepAngle,
      10,
      18.5,
      Colors.orange,
    );
    _drawSegment(
      canvas,
      arcRect,
      trackPaint,
      startAngle,
      sweepAngle,
      18.5,
      25,
      Colors.green,
    );
    _drawSegment(
      canvas,
      arcRect,
      trackPaint,
      startAngle,
      sweepAngle,
      25,
      30,
      Colors.deepOrange,
    );
    _drawSegment(
      canvas,
      arcRect,
      trackPaint,
      startAngle,
      sweepAngle,
      30,
      40,
      Colors.red,
    );

    final TextPainter minLabel = TextPainter(
      text: const TextSpan(
        text: '10',
        style: TextStyle(color: Colors.black54, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    minLabel.paint(
      canvas,
      Offset(center.dx - radius - 6, center.dy - 2),
    );

    final TextPainter maxLabel = TextPainter(
      text: const TextSpan(
        text: '40',
        style: TextStyle(color: Colors.black54, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    maxLabel.paint(
      canvas,
      Offset(center.dx + radius - 12, center.dy - 2),
    );

    final double clamped = bmi.clamp(_min, _max);
    final double normalized = (clamped - _min) / (_max - _min);
    final double needleAngle = startAngle + (normalized * sweepAngle);

    final Offset needleTip = Offset(
      center.dx + (radius - 4) * math.cos(needleAngle),
      center.dy + (radius - 4) * math.sin(needleAngle),
    );

    final Paint needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, needlePaint);
    canvas.drawCircle(center, 7, Paint()..color = Colors.black87);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  void _drawSegment(
    Canvas canvas,
    Rect arcRect,
    Paint paint,
    double start,
    double sweep,
    double from,
    double to,
    Color color,
  ) {
    final double segmentStart = start + ((from - _min) / (_max - _min)) * sweep;
    final double segmentSweep = ((to - from) / (_max - _min)) * sweep;
    paint.color = color;
    canvas.drawArc(arcRect, segmentStart, segmentSweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _BmiGaugePainter oldDelegate) {
    return oldDelegate.bmi != bmi;
  }
}
