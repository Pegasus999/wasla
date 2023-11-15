import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:wasla/Constants.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.number});
  final number;
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool loading = false;
  bool wrongPinEntered = false;
  String? code;
  String? sid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // sendOtp();
  }

  sendOtp() async {
    // var result = await API.sendOtp(context, widget.number);
    const result = "500";
    if (result == "500") {
      setState(() {
        sid = result;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An Error Occured"),
      ));
    }
  }

  checkOtp() async {
    // if (sid != null && code != null) {
    // var result = await API.checkOtp(sid!, code!);
    var result = "approved";
    if (result == "approved") {
    } else {
      setState(() {
        wrongPinEntered = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Wrong Code"),
      ));
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.background,
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: 200,
                  child: Center(
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ),
              _form(context),
            ],
          ),
        ),
      ),
    );
  }

  _form(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Constants.secondaryDarker),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(30)),
          color: Constants.secondary,
        ),
        child: Column(children: [
          const SizedBox(height: 30),
          const Center(
            child: Text(
              "Enter Verification Code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "A verification code has been sent to your mobile number 213-${widget.number}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          _input(),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              setState(() {
                loading = true;
              });
              checkOtp();
              setState(() {
                loading = false;
              });
            },
            child: Container(
              width: 300,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  color: Constants.main),
              child: loading
                  ? Constants.loading
                  : const Center(
                      child: Text("Login",
                          style: TextStyle(
                              color: Color.fromRGBO(184, 184, 184, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
            ),
          ),
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  sendOtp();
                },
                child: const Text(
                  "Resend",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }

  _input() {
    return SizedBox(
      width: 300,
      child: PinInputTextField(
        pinLength: 6, // Specify the OTP length
        onChanged: (value) {
          setState(() {
            code = value;
          });
        },
        decoration: UnderlineDecoration(
            textStyle: TextStyle(
                fontSize: 20.0,
                color: wrongPinEntered ? Colors.red : Constants.black),
            colorBuilder: FixedColorBuilder(Constants.black)),
        onSubmit: (pin) {
          checkOtp();
        },
      ),
    );
  }
}
