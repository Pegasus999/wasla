// import 'package:flutter/material.dart';
// import 'package:pin_input_text_field/pin_input_text_field.dart';
// import 'package:wasla/Constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class OtpPage extends StatefulWidget {
//   const OtpPage({super.key, required this.number});
//   final number;
//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   bool loading = false;
//   bool wrongPinEntered = false;
//   String? code;
//   String? confirmation;
//   FirebaseAuth auth = FirebaseAuth.instance;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     sendOtp();
//   }

//   sendOtp() async {
//     try {
//       await auth.verifyPhoneNumber(
//         phoneNumber: '+213${widget.number}',
//         verificationCompleted: (PhoneAuthCredential credential) {
//           print(credential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           print(e);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           print("sent verification token : $verificationId $resendToken");
//           setState(() {
//             confirmation = verificationId;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           print("codeAuto retrival Timeout : $verificationId");
//         },
//       );

//       print(confirmation);
//     } catch (err) {
//       print("error");
//       print(err);
//     }
//   }

//   checkOtp() async {
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//           verificationId: confirmation!, smsCode: code!);
//       await auth.signInWithCredential(credential);
//       Navigator.pop(context, true);
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Constants.background,
//         body: SizedBox(
//           height: MediaQuery.of(context).size.height -
//               MediaQuery.of(context).padding.top,
//           child: Column(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   width: 200,
//                   child: Center(
//                     child: Image.asset('assets/images/logo.png'),
//                   ),
//                 ),
//               ),
//               _form(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   _form(BuildContext context) {
//     return Container(
//       height: 400,
//       decoration: BoxDecoration(
//         border: Border.all(color: Constants.greenBack),
//         borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(30), topRight: Radius.circular(30)),
//         color: Constants.greenPop,
//       ),
//       child: Column(children: [
//         const SizedBox(height: 30),
//         const Center(
//           child: Text(
//             "Enter Verification Code",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//           ),
//         ),
//         const SizedBox(height: 20),
//         Text(
//           "A verification code has been sent to your mobile number +213-${widget.number}",
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//         ),
//         const SizedBox(height: 20),
//         _input(),
//         const SizedBox(height: 40),
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               loading = true;
//             });
//             checkOtp();
//             setState(() {
//               loading = false;
//             });
//           },
//           child: Container(
//             width: 300,
//             height: 45,
//             decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.all(Radius.circular(16)),
//                 color: Constants.orangePop),
//             child: loading
//                 ? Constants.loading
//                 : const Center(
//                     child: Text("Login",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600)),
//                   ),
//           ),
//         ),
//         const SizedBox(height: 30),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 sendOtp();
//               },
//               child: const Text(
//                 "Resend",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         )
//       ]),
//     );
//   }

//   _input() {
//     return SizedBox(
//       width: 300,
//       child: PinInputTextField(
//         pinLength: 6, // Specify the OTP length

//         decoration: UnderlineDecoration(
//             textStyle: TextStyle(
//                 fontSize: 20.0,
//                 color: wrongPinEntered ? Colors.red : Constants.black),
//             colorBuilder: FixedColorBuilder(Constants.black)),
//         onSubmit: (pin) {
//           if (pin.length == 6) {
//             checkOtp();
//           }
//         },
//       ),
//     );
//   }
// }
