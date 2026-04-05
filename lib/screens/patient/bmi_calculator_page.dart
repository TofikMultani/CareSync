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
    const double minBmi = 10;
    const double maxBmi = 40;

    final double normalized = (_meterValue - minBmi) / (maxBmi - minBmi);

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
            'BMI Diagram Meter',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double markerLeft =
                  (constraints.maxWidth - 22) * normalized;

              return SizedBox(
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: 22,
                      child: Row(
                        children: [
                          _meterSegment(color: Colors.orange.shade300),
                          _meterSegment(color: Colors.green.shade400),
                          _meterSegment(color: Colors.deepOrange.shade300),
                          _meterSegment(color: Colors.red.shade400),
                        ],
                      ),
                    ),
                    Positioned(
                      left: markerLeft,
                      top: 0,
                      child: Column(
                        children: [
                          Icon(Icons.arrow_drop_down,
                              color: _resultColor, size: 28),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _resultColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10', style: TextStyle(color: Colors.grey)),
              Text('18.5', style: TextStyle(color: Colors.grey)),
              Text('25', style: TextStyle(color: Colors.grey)),
              Text('30', style: TextStyle(color: Colors.grey)),
              Text('40', style: TextStyle(color: Colors.grey)),
            ],
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

  Widget _meterSegment({required Color color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
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
