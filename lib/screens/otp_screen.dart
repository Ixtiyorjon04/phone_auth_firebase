import 'package:flutter/material.dart';
import 'package:phone_auth_firebase/provider/auth_provider.dart';
import 'package:phone_auth_firebase/screens/home_screen.dart';
import 'package:phone_auth_firebase/screens/user_information_screen.dart';
import 'package:phone_auth_firebase/utils/utils.dart';
import 'package:phone_auth_firebase/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 35),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: 200,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple.shade50),
                        child: Image.asset("assets/image2.png"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Verification",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Enter the OTP send to your phone number.",
                        style: TextStyle(
                            color: Colors.black38,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        onCompleted: (value) {
                          print(otpCode);
                          setState(() {
                            otpCode = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: CustomButton(
                            text: "Verify",
                            onPressed: () {
                              print(otpCode);
                              if (otpCode != null) {
                                verifyOtp(context, otpCode!);
                              } else {
                                showSnackBar(context, "Enter 6-Digit code");
                              }
                            }),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Didn't receive any code?",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Resend New Code",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSuccess: () {
          ap.checkExistingUser().then((value) async {
            if (value == true) {
              ap.getDataFromFirestore().then(
                    (value) => ap.saveUserDataToSP().then(
                          (value) => ap.setSigIn().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                    (route) => false),
                              ),
                        ),
                  );
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInformationScreen()),
                  (route) => false);
            }
          });
        });
  }
}
