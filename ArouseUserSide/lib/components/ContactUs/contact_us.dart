import 'package:arouse_ecommerce_frontend/api/Contact_Us/contact_us_api.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final List<String> sub = [
    "I want to give feedback",
    "I want to report a problem",
    "I want to ask a question",
  ];
  String? selectedSubject;
  TextEditingController message = TextEditingController();

  void submitContactForm() async {
    await ContactUsApi().contactUs(
      context,
      name: "test",
      email: "test@gmail.com",
      subject: selectedSubject!,
      message: message.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(screenName: "Contact Us"),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 25.0,
            right: 25.0,
            top: 40,
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get in touch with us",
                style: TextStyle(
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color.fromRGBO(31, 56, 76, 1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Lorem ipsum dolor sit amet consectetur. Posuere sed odio elementum nunc volutpat egestas nunc ridiculus leo.",
                style: TextStyle(
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color.fromRGBO(84, 84, 84, 1),
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/Home_Images/ContactUs/phone.png",
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "+91 91117 94447",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(26, 76, 142, 1),
                          fontFamily: "DMSans",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Image.asset(
                        "assets/Home_Images/ContactUs/email.png",
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "hello@Sharetal.com",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(26, 76, 142, 1),
                          fontFamily: "DMSans",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Subject",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(69, 69, 69, 1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromRGBO(198, 198, 198, 1),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text("Select an Option"),
                        items: sub.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        value: selectedSubject,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSubject = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Message",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(69, 69, 69, 1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromRGBO(198, 198, 198, 1),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: message,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Enter your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                        submitContactForm();
                        message.clear();
                        selectedSubject = null;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                      ),
                      child: Text(
                        "Send",
                        style: TextStyle(
                          fontSize: 15.94,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
