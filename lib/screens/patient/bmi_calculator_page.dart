import 'dart:math' as math;
import 'package:flutter/material.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmi;
  String _message = 'Enter your details to calculate BMI';
  Color _resultColor = Colors.teal;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double get _meterValue {
    if (_bmi == null) {
      return 22;
    }

    return _bmi!.clamp(10, 40).toDouble();
  }

  void _calculateBMI() {
    final double? heightCm = double.tryParse(_heightController.text.trim());
    final double? weightKg = double.tryParse(_weightController.text.trim());

    if (heightCm == null ||
        weightKg == null ||
        heightCm <= 0 ||
        weightKg <= 0) {
      setState(() {
        _bmi = null;
        _message = 'Please enter valid height and weight values';
        _resultColor = Colors.redAccent;
      });
      return;
    }

    final double heightM = heightCm / 100;
    final double bmiValue = weightKg / (heightM * heightM);

    setState(() {
      _bmi = bmiValue;

      if (bmiValue < 18.5) {
        _message = 'Underweight';
        _resultColor = Colors.orange;
      } else if (bmiValue < 25) {
        _message = 'Normal weight';
        _resultColor = Colors.green;
      } else if (bmiValue < 30) {
        _message = 'Overweight';
        _resultColor = Colors.deepOrange;
      } else {
        _message = 'Obesity';
        _resultColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFA),
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF5EEAD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/hospital_logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Check your Body Mass Index',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _heightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: const Icon(Icons.height),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: const Icon(Icons.monitor_weight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.calculate),
              label: const Text(
                'Calculate BMI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _bmi == null
                        ? 'Result: --'
                        : 'Result: ${_bmi!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _resultColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _resultColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildBMIDiagramMeter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIDiagramMeter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI Speed Meter',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.8,
            child: CustomPaint(
              painter: _SpeedometerPainter(
                bmiValue: _meterValue,
                needleColor:
                    _bmi == null ? Colors.grey.shade400 : _resultColor,
                hasResult: _bmi != null,
                categoryLabel: _bmi == null ? '' : _message,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendItem('Underweight', Colors.orange.shade300),
              _legendItem('Normal', Colors.green.shade400),
              _legendItem('Overweight', Colors.deepOrange.shade300),
              _legendItem('Obesity', Colors.red.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Speedometer gauge painter
// ---------------------------------------------------------------------------

class _SpeedometerPainter extends CustomPainter {
  final double bmiValue;
  final Color needleColor;
  final bool hasResult;
  final String categoryLabel;

  const _SpeedometerPainter({
    required this.bmiValue,
    required this.needleColor,
    required this.hasResult,
    required this.categoryLabel,
  });

  static const double _minBmi = 10;
  static const double _maxBmi = 40;

  // Maps a BMI value to a canvas angle (Flutter screen coords: y-axis points down).
  // Angles increase clockwise on screen, so:
  //   BMI 10 → π   = 9-o'clock (left)
  //   BMI 25 → 3π/2 = 12-o'clock (top, because sin(3π/2)=-1 → y decreases upward)
  //   BMI 40 → 2π  = 3-o'clock (right)
  double _bmiToAngle(double bmi) {
    final t = (bmi - _minBmi) / (_maxBmi - _minBmi);
    return math.pi + t * math.pi; // π … 2π (clockwise through top)
  }

  void _drawArcSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    Color color,
    double startBmi,
    double endBmi,
  ) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _bmiToAngle(startBmi),
      _bmiToAngle(endBmi) - _bmiToAngle(startBmi),
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final center = Offset(cx, cy);

    // Arc radius: leave some margin so nothing clips at the edges
    final maxR = math.min(cx * 0.88, cy * 0.92);
    const strokeWidth = 22.0;
    final arcR = maxR - strokeWidth / 2;

    // --- Background (full half-circle) ---
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcR),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.grey.shade200
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );

    // --- Coloured segments ---
    _drawArcSegment(canvas, center, arcR, strokeWidth,
        Colors.orange.shade300, 10, 18.5);
    _drawArcSegment(canvas, center, arcR, strokeWidth,
        Colors.green.shade400, 18.5, 25);
    _drawArcSegment(canvas, center, arcR, strokeWidth,
        Colors.deepOrange.shade300, 25, 30);
    _drawArcSegment(
        canvas, center, arcR, strokeWidth, Colors.red.shade400, 30, 40);

    // --- Tick marks at category boundaries ---
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final bmi in [18.5, 25.0, 30.0]) {
      final angle = _bmiToAngle(bmi);
      final inner = Offset(
        cx + (arcR - strokeWidth * 0.6) * math.cos(angle),
        cy + (arcR - strokeWidth * 0.6) * math.sin(angle),
      );
      final outer = Offset(
        cx + (arcR + strokeWidth * 0.6) * math.cos(angle),
        cy + (arcR + strokeWidth * 0.6) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // --- Needle ---
    final angle = _bmiToAngle(bmiValue.clamp(_minBmi, _maxBmi));
    final needleTip = Offset(
      cx + (arcR - strokeWidth * 0.35) * math.cos(angle),
      cy + (arcR - strokeWidth * 0.35) * math.sin(angle),
    );

    // Drop-shadow
    canvas.drawLine(
      center,
      needleTip,
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Needle
    canvas.drawLine(
      center,
      needleTip,
      Paint()
        ..color = needleColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Pivot circle
    canvas.drawCircle(center, 11,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(
        center,
        11,
        Paint()
          ..color = needleColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(center, 5, Paint()..color = needleColor);

    // --- Text inside the dial ---
    final bmiText = hasResult ? bmiValue.toStringAsFixed(1) : '--';
    _paintText(
      canvas,
      bmiText,
      Offset(cx, cy - arcR * 0.42),
      TextStyle(
        color: needleColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
    if (categoryLabel.isNotEmpty) {
      _paintText(
        canvas,
        categoryLabel,
        Offset(cx, cy - arcR * 0.22),
        TextStyle(
          color: needleColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) =>
      old.bmiValue != bmiValue ||
      old.needleColor != needleColor ||
      old.hasResult != hasResult ||
      old.categoryLabel != categoryLabel;
}
