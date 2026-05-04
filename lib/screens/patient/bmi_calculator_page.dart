import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

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

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

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
        SnackBar(
          content: Text('Please enter valid height and weight values.', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        return Colors.blue.shade400;
      case 'Normal Weight':
        return primaryColor;
      case 'Overweight':
        return Colors.orange.shade500;
      case 'Obese':
        return Colors.red.shade500;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'BMI Calculator',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, 
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
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
                color: primaryColor.withOpacity(0.05),
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
                color: primaryColor.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Header Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [primaryColor, const Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Icon with premium styling
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.monitor_weight_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'BMI Health Scanner',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Calculate your Body Mass Index in seconds',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Input Section
                Text(
                  'Enter Your Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Height Input
                      _inputField(
                        label: 'Height',
                        controller: _heightController,
                        hint: 'e.g., 170',
                        suffix: 'cm',
                        icon: Icons.height_rounded,
                      ),
                      
                      const SizedBox(height: 24),

                      // Weight Input
                      _inputField(
                        label: 'Weight',
                        controller: _weightController,
                        hint: 'e.g., 70',
                        suffix: 'kg',
                        icon: Icons.monitor_weight_outlined,
                      ),

                      const SizedBox(height: 32),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _calculateBmi,
                          child: Text(
                            'Calculate BMI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
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
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _categoryColor().withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _categoryColor().withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Result Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monitor_heart_rounded, color: _categoryColor(), size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'Your BMI Result',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _categoryColor(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // BMI Gauge
                        SizedBox(
                          height: 200,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 10, end: _bmi),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedBmi, child) {
                              return CustomPaint(
                                painter: _BmiGaugePainter(animatedBmi, primaryColor),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _bmi!.toStringAsFixed(1),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 56,
                                            fontWeight: FontWeight.w900,
                                            color: _categoryColor(),
                                            letterSpacing: -2,
                                          ),
                                        ),
                                        Text(
                                          'BMI Score',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.grey.shade500,
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
                        
                        const SizedBox(height: 32),

                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: _categoryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _category.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: _categoryColor(),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // BMI Categories Legend
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI Categories',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _categoryLegendRow('Underweight', '< 18.5', Colors.blue.shade400),
                              const SizedBox(height: 8),
                              _categoryLegendRow('Normal', '18.5 - 24.9', primaryColor),
                              const SizedBox(height: 8),
                              _categoryLegendRow('Overweight', '25 - 29.9', Colors.orange.shade500),
                              const SizedBox(height: 8),
                              _categoryLegendRow('Obese', '≥ 30', Colors.red.shade500),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({required String label, required TextEditingController controller, required String hint, required String suffix, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (controller.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${controller.text} $suffix',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
            suffixText: suffix,
            suffixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
            filled: true,
            fillColor: const Color(0xFFF1F5F9), // Slate 100
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _categoryLegendRow(String label, String range, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        Text(
          range,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  _BmiGaugePainter(this.bmi, this.primaryColor);

  final double bmi;
  final Color primaryColor;

  static const double _min = 10;
  static const double _max = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height - 20);
    final double radius = math.min(size.width * 0.45, 140);
    const double startAngle = math.pi;
    const double sweepAngle = math.pi;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    _drawSegment(canvas, arcRect, trackPaint, startAngle, sweepAngle, 10, 18.5, Colors.blue.shade400);
    _drawSegment(canvas, arcRect, trackPaint, startAngle, sweepAngle, 18.5, 25, primaryColor);
    _drawSegment(canvas, arcRect, trackPaint, startAngle, sweepAngle, 25, 30, Colors.orange.shade500);
    _drawSegment(canvas, arcRect, trackPaint, startAngle, sweepAngle, 30, 40, Colors.red.shade500);

    final double clamped = bmi.clamp(_min, _max);
    final double normalized = (clamped - _min) / (_max - _min);
    final double needleAngle = startAngle + (normalized * sweepAngle);

    final Offset needleTip = Offset(
      center.dx + (radius - 12) * math.cos(needleAngle),
      center.dy + (radius - 12) * math.sin(needleAngle),
    );

    final Paint needlePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, needlePaint);
    canvas.drawCircle(center, 12, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(center, 6, Paint()..color = Colors.white);
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
