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
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _categoryColor() {
    switch (_category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal Weight':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF0E8A83),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF0E8A83).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF0E8A83).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Header Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0E8A83), Color(0xFF2CB6AD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0E8A83).withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Icon with premium styling
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/hospital_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Title
                      const Text(
                        'BMI Health Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      const Text(
                        'Calculate your Body Mass Index in seconds',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Feature badges
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeatureBadge('⚡', 'Instant Result'),
                          _buildFeatureBadge('📊', 'Health Insights'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Input Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Your Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D6E68),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use centimeters (cm) and kilograms (kg)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Height Input with Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Height',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D6E68),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0E8A83).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_heightController.text.isEmpty ? "0" : _heightController.text} cm',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0E8A83),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., 170',
                              prefixIcon: const Icon(Icons.height,
                                  color: Color(0xFF0E8A83), size: 20),
                              suffixText: 'cm',
                              filled: true,
                              fillColor: const Color(0xFFEFF8F7),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0E8A83),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Weight Input with Visual Indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Weight',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D6E68),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF0E8A83).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_weightController.text.isEmpty ? "0" : _weightController.text} kg',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0E8A83),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., 70',
                              prefixIcon: const Icon(Icons.line_weight_outlined,
                                  color: Color(0xFF0E8A83), size: 20),
                              suffixText: 'kg',
                              filled: true,
                              fillColor: const Color(0xFFEFF8F7),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0E8A83),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Calculate Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0E8A83), Color(0xFF39BFB7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0E8A83).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _calculateBmi,
                            borderRadius: BorderRadius.circular(14),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calculate,
                                      color: Colors.white, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Calculate BMI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
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
                const SizedBox(height: 24),

                // Result Section
                if (_bmi != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _categoryColor().withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _categoryColor().withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Result Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                color: _categoryColor(), size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Your BMI Result',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _categoryColor(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // BMI Gauge
                        SizedBox(
                          height: 220,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 10, end: _bmi),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedBmi, child) {
                              return CustomPaint(
                                painter: _BmiGaugePainter(animatedBmi),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 70),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _bmi!.toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            color: _categoryColor(),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'BMI Score',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
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
                        const SizedBox(height: 8),
                        Text(
                          'Range: 10 - 40',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: _categoryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _categoryColor().withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            _category.toUpperCase(),
                            style: TextStyle(
                              color: _categoryColor(),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // BMI Categories Legend
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'BMI Categories',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D6E68),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _categoryBadge(
                                      'Underweight', Colors.blue, '< 18.5'),
                                  _categoryBadge(
                                      'Normal', Colors.green, '18.5 - 24.9'),
                                  _categoryBadge(
                                      'Overweight', Colors.orange, '25 - 29.9'),
                                  _categoryBadge('Obese', Colors.red, '≥ 30'),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildFeatureBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBadge(String label, Color color, String range) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
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
    final Offset center = Offset(size.width / 2, size.height - 20);
    final double radius = math.min(size.width * 0.4, 120);
    const double startAngle = math.pi;
    const double sweepAngle = math.pi;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    _drawSegment(
      canvas,
      arcRect,
      trackPaint,
      startAngle,
      sweepAngle,
      10,
      18.5,
      Colors.blue,
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
      Colors.orange,
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
        style: TextStyle(
            color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    minLabel.paint(
      canvas,
      Offset(center.dx - radius - 10, center.dy - 4),
    );

    final TextPainter maxLabel = TextPainter(
      text: const TextSpan(
        text: '40',
        style: TextStyle(
            color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    maxLabel.paint(
      canvas,
      Offset(center.dx + radius - 4, center.dy - 4),
    );

    final double clamped = bmi.clamp(_min, _max);
    final double normalized = (clamped - _min) / (_max - _min);
    final double needleAngle = startAngle + (normalized * sweepAngle);

    final Offset needleTip = Offset(
      center.dx + (radius - 6) * math.cos(needleAngle),
      center.dy + (radius - 6) * math.sin(needleAngle),
    );

    final Paint needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, needlePaint);
    canvas.drawCircle(center, 9, Paint()..color = Colors.black87);
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
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
