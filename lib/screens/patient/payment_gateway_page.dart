import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final Color primaryColor = const Color(0xFF059669);
  final Color backgroundColor = const Color(0xFFF8FAFC);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 30),
            const SizedBox(width: 10),
            Text("Payment Successful", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18))
          ]),
          content: Text(
            "Your payment of \$${widget.amount.toStringAsFixed(2)} for ${widget.title} has been processed successfully via Razorpay.\n\nPayment ID: ${response.paymentId}",
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade700),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return true indicating success strictly expected by callers
              },
              child: Text("Continue", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
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
          content: Text("Payment failed: ${response.message ?? 'Unknown Error'}", style: GoogleFonts.plusJakartaSans()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("External wallet selected: ${response.walletName}", style: GoogleFonts.plusJakartaSans()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        'color': '#059669' // Matches primaryColor
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Secure Payment", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A))),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Amount summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: primaryColor.withOpacity(0.1),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(Icons.account_balance_wallet_rounded, size: 48, color: primaryColor),
                   ),
                   const SizedBox(height: 20),
                  Text(widget.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text("\$${widget.amount.toStringAsFixed(2)}", style: GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A), // Slate 900
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _openRazorpay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text("Proceed to Pay", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Clicking above will open the standard Razorpay checkout where you can choose Card, UPI Apps, Netbanking or Wallet.", 
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 13, height: 1.5)
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text(
              "Scan to Pay via UPI",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: QrImageView(
                data: 'upi://pay?pa=7990018718@ptsbi&pn=Hitanxi%20Vipulbhai%20Rank&am=${widget.amount}&cu=INR',
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              "Use any UPI app (GPay, PhonePe, Paytm) to scan and pay.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  // Verification for QR payment
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      final TextEditingController utrController = TextEditingController();
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text("Verify Payment", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Please enter the 12-digit UPI Reference Number (UTR) to confirm your payment.",
                              style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade700, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: utrController,
                              keyboardType: TextInputType.number,
                              maxLength: 12,
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: "UTR Number",
                                labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor, width: 2),
                                ),
                                counterText: "",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Cancel", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (utrController.text.length == 12) {
                                Navigator.pop(ctx);
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Row(children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 30),
                                      const SizedBox(width: 10),
                                      Text("Payment Verified", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18))
                                    ]),
                                    content: Text(
                                      "Your UPI payment of \$${widget.amount.toStringAsFixed(2)}\nUTR: ${utrController.text}\nHas been successfully verified.",
                                      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade700),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context); // Close success dialog
                                          Navigator.pop(context, true); // Return true to previous screen
                                        },
                                        child: Text("Continue", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please enter a valid 12-digit UTR Number", style: GoogleFonts.plusJakartaSans()), 
                                    backgroundColor: Colors.red.shade400,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            },
                            child: Text("Verify", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                          )
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text("I have paid via QR", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
