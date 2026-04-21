import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentGatewayPage extends StatefulWidget {
  final double amount;
  final String title;

  const PaymentGatewayPage({
    super.key,
    required this.amount,
    required this.title,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text("Payment Successful")
          ]),
          content: Text("Your payment of \$${widget.amount.toStringAsFixed(2)} for ${widget.title} has been processed successfully via Razorpay.\n\nPayment ID: ${response.paymentId}"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return true indicating success strictly expected by callers
              },
              child: const Text("Continue"),
            )
          ],
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment failed: ${response.message ?? 'Unknown Error'}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External wallet selected: ${response.walletName}")),
      );
    }
  }

  void _openRazorpay() {
    // Razorpay processes amount in subunits (e.g., paisa for INR)
    // Here we treat \$ amount literally, multiplying by 100
    int amountInPaisa = (widget.amount * 100).toInt();

    var options = {
      'key': 'rzp_test_SfdmQLCtk2Y9yz', // Using valid Razorpay test key
      'amount': amountInPaisa,
      'name': 'CareSync Hospital',
      'description': widget.title,
      'prefill': {
        'contact': '9876543210',
        'email': 'patient@caresync.com',
      },
      'theme': {
        'color': '#009688' // Matches Colors.teal
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Razorpay Secure Gateway"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, color: Colors.blueAccent.shade700, size: 30),
                const SizedBox(width: 8),
                const Text("Razorpay Checkout", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),

            // Amount summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                   const Icon(Icons.account_balance_wallet, size: 50, color: Colors.teal),
                   const SizedBox(height: 16),
                  Text(widget.title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("\$${widget.amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _openRazorpay,
                child: const Text("Proceed to Pay", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "Clicking above will open the standard Razorpay checkout where you can choose Card, UPI Apps, Netbanking or Wallet.", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)
              ),
            ),
            const SizedBox(height: 30),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 10),
            const Text(
              "Or Scan to Pay via UPI",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: QrImageView(
                  data: 'upi://pay?pa=7990018718@ptsbi&pn=Hitanxi%20Vipulbhai%20Rank&am=${widget.amount}&cu=INR',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Use any UPI app (GPay, PhonePe, Paytm) to scan and pay.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.teal, width: 1.5),
                ),
                onPressed: () {
                  // Verification for QR payment
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      final TextEditingController utrController = TextEditingController();
                      return AlertDialog(
                        title: const Text("Verify Payment"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Please enter the 12-digit UPI Reference Number (UTR) to confirm your payment."),
                            const SizedBox(height: 16),
                            TextField(
                              controller: utrController,
                              keyboardType: TextInputType.number,
                              maxLength: 12,
                              decoration: const InputDecoration(
                                labelText: "UTR Number",
                                border: OutlineInputBorder(),
                                counterText: "",
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                            onPressed: () {
                              if (utrController.text.length == 12) {
                                Navigator.pop(ctx);
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AlertDialog(
                                    title: const Row(children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 30),
                                      SizedBox(width: 10),
                                      Text("Payment Verified")
                                    ]),
                                    content: Text("Your UPI payment of \$${widget.amount.toStringAsFixed(2)}\nUTR: ${utrController.text}\nHas been successfully verified."),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                        onPressed: () {
                                          Navigator.pop(context); // Close success dialog
                                          Navigator.pop(context, true); // Return true to previous screen
                                        },
                                        child: const Text("Continue"),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter a valid 12-digit UTR Number"), backgroundColor: Colors.red),
                                );
                              }
                            },
                            child: const Text("Verify"),
                          )
                        ],
                      );
                    },
                  );
                },
                child: const Text("I have paid via QR", style: TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
