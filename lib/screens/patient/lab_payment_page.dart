import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LabPaymentPage extends StatefulWidget {
  final String orderId;
  final String testName;
  final double amount;

  const LabPaymentPage({
    super.key,
    required this.orderId,
    required this.testName,
    required this.amount,
  });

  @override
  State<LabPaymentPage> createState() => _LabPaymentPageState();
}

class _LabPaymentPageState extends State<LabPaymentPage> {
  bool _isProcessing = false;

  void _launchUpi() async {
    setState(() => _isProcessing = true);

    // Provide a dummy merchant UPI ID for the hospital
    String upiId = "hospital.caresync@upi";
    String merchantName = "CareSync Hospital";
    String transactionNote = "Lab Test: ${widget.testName}";
    String amount = widget.amount.toStringAsFixed(2);
    
    // Construct the standard universal UPI intent link
    String upiUrl = "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(merchantName)}&am=$amount&cu=INR&tn=${Uri.encodeComponent(transactionNote)}";
    
    Uri uri = Uri.parse(upiUrl);

    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No UPI app found. Please install Google Pay, Paytm, or PhonePe.")),
          );
        }
      } else {
        // Since standard url_launcher cannot capture the transaction success from the external UPI app,
        // we will prompt the user to confirm if the payment was successful when they return.
        if (!mounted) return;
        _showConfirmationDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open UPI apps: $e")));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Payment Verification"),
        content: const Text("Did you complete the payment successfully in your UPI app?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("No / Failed", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _markAsPaid();
            },
            child: const Text("Yes, Payment Successful", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsPaid() async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('lab_orders').doc(widget.orderId).update({
        'paymentStatus': 'Paid',
        'paidAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Verified")
            ]),
            content: Text("Your payment of \$${widget.amount.toStringAsFixed(2)} for ${widget.testName} has been recorded successfully."),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to previous screen
                },
                child: const Text("Done"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving payment: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("UPI Payment"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            const Text("Pay securely using any UPI app", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 30),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.testName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Text("\$${widget.amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isProcessing ? null : _launchUpi,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_to_mobile, color: Colors.white, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            "Pay \$${widget.amount.toStringAsFixed(2)} via UPI", 
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniAppIcon(Icons.g_mobiledata, Colors.blue),
                const SizedBox(width: 12),
                _miniAppIcon(Icons.payment, Colors.indigo),
                const SizedBox(width: 12),
                _miniAppIcon(Icons.phone_android, Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text("Supports Google Pay, PhonePe, Paytm, BHIM, etc.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAppIcon(IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: bg, size: 28),
    );
  }
}
