import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend_web/api/profile_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

enum AddressType { current, permanent }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedPhoneCode = "+91";
  String? selectedAltPhoneCode = "+91";
  bool canEditPhone = false;
  bool canEditCurAddress = false;
  bool canEditPerAddress = false;
  bool canEditBankDetails = false;
  bool canEditPan = false;
  bool canEditAadhar = false;
  bool canEditName = false;
  bool canEditOccupation = false;
  Uint8List? selectedProfileImageBytes;
  bool uploadingImage = false;

  TextEditingController occupationCtrl = TextEditingController();
  TextEditingController panCtrl = TextEditingController();
  TextEditingController aadharCtrl = TextEditingController();

  TextEditingController pinCurCtrl = TextEditingController();
  TextEditingController addr1CurCtrl = TextEditingController();
  TextEditingController addr2CurCtrl = TextEditingController();
  TextEditingController landCurCtrl = TextEditingController();
  TextEditingController cityCurCtrl = TextEditingController();
  TextEditingController stateCurCtrl = TextEditingController();

  TextEditingController pinPerCtrl = TextEditingController();
  TextEditingController addr1PerCtrl = TextEditingController();
  TextEditingController addr2PerCtrl = TextEditingController();
  TextEditingController landPerCtrl = TextEditingController();
  TextEditingController cityPerCtrl = TextEditingController();
  TextEditingController statePerCtrl = TextEditingController();

  TextEditingController accNoCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController ifscCtrl = TextEditingController();
  TextEditingController bankNameCtrl = TextEditingController();
  TextEditingController branchCtrl = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  TextEditingController altPhoneController = TextEditingController();
  bool isLoading = true;
  Map<String, dynamic>? user;
  String? profilePhoto;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadProfilePhoto();
  }

  Future<void> loadProfilePhoto() async {
    try {
      final photo = await ProfileApi().getProfilePhoto();
      if (!mounted) return;
      setState(() {
        profilePhoto = photo;
      });
    } catch (_) {}
  }

  Future<void> pickAndUploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        uploadingImage = true;
        selectedProfileImageBytes = bytes;
      });

      final base64Image = base64Encode(bytes);
      final mimeType = image.name.toLowerCase().endsWith(".png")
          ? "image/png"
          : "image/jpeg";

      await ProfileApi.uploadProfilePhoto(
        base64Image: "data:$mimeType;base64,$base64Image",
        mimeType: mimeType,
      );

      await loadProfilePhoto();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile photo updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => uploadingImage = false);
      }
    }
  }

  Future<void> loadUser() async {
    try {
      final data = await ProfileApi().getCurrentUser();
      setState(() {
        user = data;
        isLoading = false;
      });

      if (user == null) return;

      // personal
      phoneController.text = user!['phone'] ?? '';
      nameCtrl.text = user!['name'] ?? '';

      occupationCtrl.text = user!['occupation'] ?? '';
      panCtrl.text = user!['panNumber'] ?? '';
      aadharCtrl.text = user!['aadharNumber'] ?? '';
      // current address
      pinCurCtrl.text = user!['currentAddress']?['areaPincode'] ?? '';
      addr1CurCtrl.text = user!['currentAddress']?['addressLine1'] ?? '';
      addr2CurCtrl.text = user!['currentAddress']?['addressLine2'] ?? '';
      landCurCtrl.text = user!['currentAddress']?['landmark'] ?? '';
      cityCurCtrl.text = user!['currentAddress']?['city'] ?? '';
      stateCurCtrl.text = user!['currentAddress']?['state'] ?? '';

      // permanent address
      pinPerCtrl.text = user!['permanentAddress']?['areaPincode'] ?? '';
      addr1PerCtrl.text = user!['permanentAddress']?['addressLine1'] ?? '';
      addr2PerCtrl.text = user!['permanentAddress']?['addressLine2'] ?? '';
      landPerCtrl.text = user!['permanentAddress']?['landmark'] ?? '';
      cityPerCtrl.text = user!['permanentAddress']?['city'] ?? '';
      statePerCtrl.text = user!['permanentAddress']?['state'] ?? '';

      // bank
      accNoCtrl.text = user!['bankDetails']?['accountNumber'] ?? '';
      ifscCtrl.text = user!['bankDetails']?['ifscCode'] ?? '';
      bankNameCtrl.text = user!['bankDetails']?['bankName'] ?? '';
      branchCtrl.text = user!['bankDetails']?['branch'] ?? '';
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveProfileField(Map<String, dynamic> data) async {
    try {
      await ProfileApi.updateProfile(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> saveBankDetails() async {
    await saveProfileField({
      "bankDetails": {
        "accountNumber": accNoCtrl.text.trim(),
        "accountName": nameCtrl.text.trim(),
        "ifscCode": ifscCtrl.text.trim(),
        "bankName": bankNameCtrl.text.trim(),
        "branch": branchCtrl.text.trim(),
      },
    });
  }

  Future<void> updateAddress(AddressType type) async {
    try {
      final payload = {
        type == AddressType.current ? "currentAddress" : "permanentAddress":
            _buildAddressPayload(type),
      };

      await ProfileApi.updateProfile(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == AddressType.current
                ? "Current address updated successfully"
                : "Permanent address updated successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Map<String, String> _buildAddressPayload(AddressType type) {
    if (type == AddressType.current) {
      return {
        "areaPincode": pinCurCtrl.text.trim(),
        "addressLine1": addr1CurCtrl.text.trim(),
        "addressLine2": addr2CurCtrl.text.trim(),
        "landmark": landCurCtrl.text.trim(),
        "city": cityCurCtrl.text.trim(),
        "state": stateCurCtrl.text.trim(),
      };
    } else {
      return {
        "areaPincode": pinPerCtrl.text.trim(),
        "addressLine1": addr1PerCtrl.text.trim(),
        "addressLine2": addr2PerCtrl.text.trim(),
        "landmark": landPerCtrl.text.trim(),
        "city": cityPerCtrl.text.trim(),
        "state": statePerCtrl.text.trim(),
      };
    }
  }

  Widget _box(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      backgroundColor: const Color(0xFFF2F6FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: AppSizes.screenWidth(context) < 480
                          ? const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            )
                          : AppSizes.screenWidth(context) < 900
                          ? const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            )
                          : const EdgeInsets.symmetric(
                              horizontal: 64,
                              vertical: 24,
                            ),
                      width: AppSizes.screenWidth(context),
                      decoration: BoxDecoration(color: Color(0xFF1A4C8E)),
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.titleFont(context),
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Header card with avatar
                    _box(
                      Column(
                        children: [
                          Container(
                            height: 87,
                            width: 87,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1A4C8E),
                                width: 4.83,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: uploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : profilePhoto != null
                                  ? Image.memory(
                                      base64Decode(
                                        profilePhoto!.split(',').last,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        user?['name'] != null
                                            ? user!['name'][0].toUpperCase()
                                            : "U",
                                        style: const TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 32,
                                          color: Color(0xFF1A4C8E),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              pickAndUploadProfileImage();
                            },
                            child: Text(
                              'Add Photo',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF0093FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Main responsive grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1000) {
                          // 2-column layout with left wider
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _box(_personalDetails()),
                                    const SizedBox(height: 18),
                                    _box(_permanentAddress()),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _box(_currentAddress()),
                                    const SizedBox(height: 18),
                                    _box(_bankDetails()),
                                    const SizedBox(height: 18),
                                    _box(_verificationCard()),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else if (constraints.maxWidth > 600) {
                          // tablet: stack boxes in two columns
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _box(_personalDetails()),
                                    const SizedBox(height: 18),
                                    _box(_permanentAddress()),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    _box(_currentAddress()),
                                    const SizedBox(height: 18),
                                    _box(_bankDetails()),
                                    const SizedBox(height: 18),
                                    _box(_verificationCard()),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          // mobile: single column
                          return Column(
                            children: [
                              _box(_personalDetails()),
                              const SizedBox(height: 12),
                              _box(_currentAddress()),
                              const SizedBox(height: 12),
                              _box(_permanentAddress()),
                              const SizedBox(height: 12),
                              _box(_bankDetails()),
                              const SizedBox(height: 12),
                              _box(_verificationCard()),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _personalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        profileField(label: "Email", value: user!['email'].toString()),
        const SizedBox(height: 12),
        phoneField(
          label: "Phone Number",
          selectedCode: selectedPhoneCode,
          controller: phoneController,
          isVerified: user!['phoneVerified'] == true,
          isEditable: canEditPhone,
          onChanged: (v) => setState(() => selectedPhoneCode = v),
          onEdit: () {
            setState(() => canEditPhone = !canEditPhone);
          },
        ),
        const SizedBox(height: 12),
        editableField(
          label: "Full Name",
          controller: nameCtrl,
          isEditable: canEditName,
          onEditSave: () async {
            if (canEditName) {
              await saveProfileField({"name": nameCtrl.text.trim()});
            }
            setState(() => canEditName = !canEditName);
          },
        ),
        const SizedBox(height: 12),
        editableField(
          label: "Occupation",
          controller: occupationCtrl,
          isEditable: canEditOccupation,
          onEditSave: () {
            if (canEditOccupation) {
              saveProfileField({"occupation": occupationCtrl.text.trim()});
            }
            setState(() => canEditOccupation = !canEditOccupation);
          },
        ),
        const SizedBox(height: 12),
        editableField(
          label: "Pan Card No.",
          controller: panCtrl,
          isEditable: canEditPan,
          isVerified: user?['panVerified'] == true,
          onEditSave: () async {
            if (canEditPan) {
              await saveProfileField({"panNumber": panCtrl.text.trim()});
            }
            setState(() => canEditPan = !canEditPan);
          },
        ),
        const SizedBox(height: 12),
        editableField(
          label: "Aadhar Card No",
          controller: aadharCtrl,
          isEditable: canEditAadhar,
          isVerified: user?['aadharVerified'] == true,

          onEditSave: () async {
            if (canEditAadhar) {
              await saveProfileField({"aadharNumber": aadharCtrl.text.trim()});
            }
            setState(() => canEditAadhar = !canEditAadhar);
          },
        ),
        const SizedBox(height: 12),
        profileField(label: "Customer Id", value: user!['_id']),
      ],
    );
  }

  Widget _currentAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Current Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                if (canEditCurAddress) {
                  updateAddress(AddressType.current);
                }
                setState(() => canEditCurAddress = !canEditCurAddress);
              },
              child: Text(
                canEditCurAddress ? "Save" : "Edit",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0093FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildAddressField("Address Line 1", addr1CurCtrl, canEditCurAddress),
        const SizedBox(height: 8),
        buildAddressField("Address Line 2", addr2CurCtrl, canEditCurAddress),
        const SizedBox(height: 8),
        buildAddressField("Landmark", landCurCtrl, canEditCurAddress),
        const SizedBox(height: 8),
        buildAddressField("City", cityCurCtrl, canEditCurAddress),
        const SizedBox(height: 8),
        buildAddressField("State", stateCurCtrl, canEditCurAddress),
      ],
    );
  }

  Widget _permanentAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Permanent Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                if (canEditPerAddress) {
                  updateAddress(AddressType.permanent);
                }
                setState(() => canEditPerAddress = !canEditPerAddress);
              },
              child: Text(
                canEditPerAddress ? "Save" : "Edit",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0093FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildAddressField("Addres Line 1", addr1PerCtrl, canEditPerAddress),
        const SizedBox(height: 8),
        buildAddressField("Address Line 2", addr2PerCtrl, canEditPerAddress),
        const SizedBox(height: 8),
        buildAddressField("Landmark", landPerCtrl, canEditPerAddress),
        const SizedBox(height: 8),
        buildAddressField("City", cityPerCtrl, canEditPerAddress),
        const SizedBox(height: 8),
        buildAddressField("State", statePerCtrl, canEditPerAddress),
      ],
    );
  }

  Widget _bankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bank Account Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () async {
                if (canEditBankDetails) {
                  // SAVE
                  await saveBankDetails();
                }
                setState(() => canEditBankDetails = !canEditBankDetails);
              },
              child: Text(
                canEditBankDetails ? "Save" : "Edit",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0093FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildAddressField("Account Number", accNoCtrl, canEditBankDetails),
        buildAddressField("Name On the Account", nameCtrl, canEditBankDetails),
        buildAddressField("IFSC Code", ifscCtrl, canEditBankDetails),
        buildAddressField("Bank Name", bankNameCtrl, canEditBankDetails),
        buildAddressField("Branch", branchCtrl, canEditBankDetails),
      ],
    );
  }

  Widget _verificationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Verification (KYC)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 24),
        Center(child: SvgPicture.asset('assets/icons/kyc.svg')),
        SizedBox(height: 16),
        Text(
          'VERIFY YOUR PROFILE IN 3 EASY STEPS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF1F384C),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kycStep(number: "1", title: "Upload Driving License"),
            kycDivider(),
            kycStep(
              number: "2",
              title: "Upload Aadhar Card / Voter ID / Passport",
            ),
            kycDivider(),
            kycStep(number: "3", title: "Take a Selfie Photo"),
            SizedBox(height: 42),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A4C8E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Start Verification',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget editableField({
  required String label,
  required TextEditingController controller,
  required bool isEditable,
  required VoidCallback onEditSave,
  bool isVerified = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A4C8E),
                ),
              ),
              const SizedBox(width: 6),
              if (isVerified)
                const Icon(Icons.verified, color: Colors.green, size: 16),
            ],
          ),
          GestureDetector(
            onTap: onEditSave,
            child: Text(
              isEditable ? "Save" : "Edit",
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF0093FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        readOnly: !isEditable,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

Widget profileField({
  required String label,
  required String value,
  bool isVerified = false,
  bool showEdit = false,
  VoidCallback? onEdit,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A4C8E),
                ),
              ),
              const SizedBox(width: 6),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFDAFFEE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, size: 12, color: Color(0xFF006939)),
                      SizedBox(width: 3),
                      Text(
                        "VERIFIED",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF006939),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (showEdit)
            GestureDetector(
              onTap: onEdit,
              child: const Text(
                "Edit",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0093FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 9),
      TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: value,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Color(0xFFC6C6C6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF1A4C8E), width: 1.5),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

Widget phoneField({
  required String label,
  required String? selectedCode,
  required Function(String?) onChanged,
  required TextEditingController controller,
  bool isVerified = false,
  bool isEditable = false,
  VoidCallback? onEdit,
}) {
  List<String> countryCodes = ["+91", "+1", "+44", "+971", "+61"];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A4C8E),
                ),
              ),
              const SizedBox(width: 6),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFDAFFEE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, size: 12, color: Color(0xFF006939)),
                      SizedBox(width: 3),
                      Text(
                        "VERIFIED",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                          fontSize: 12,
                          color: Color(0xFF006939),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Text(
              "Edit",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF0093FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 9),

      Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFC6C6C6)),
        ),
        child: Row(
          children: [
            // Country Code DropDown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedCode,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: countryCodes.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        color: Color(0xFF1A4C8E),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: isEditable ? onChanged : null,
              ),
            ),

            Container(height: 40, width: 1.5, color: const Color(0xFFC6C6C6)),

            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: !isEditable,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter phone number",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

Widget buildAddressField(
  String label,
  TextEditingController controller,
  bool editable,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: "Inter",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A4C8E),
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        readOnly: !editable,
        decoration: InputDecoration(
          hintText: "Eg 110008",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC6C6C6), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC6C6C6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1A4C8E), width: 1.5),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

Widget kycStep({required String number, required String title}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontFamily: 'Poppins',
            letterSpacing: 0.5,
            color: Color(0xFF1A4C8E),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A4C8E),
          ),
        ),
      ),
    ],
  );
}

Widget kycDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        const SizedBox(width: 13),
        Container(width: 2, height: 22, color: Color(0xFF1A4C8E)),
      ],
    ),
  );
}
