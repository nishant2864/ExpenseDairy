import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/finance_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/ui_elements.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FinanceProvider>();
    _firstNameController = TextEditingController(text: provider.userFirstName);
    _lastNameController = TextEditingController(text: provider.userLastName);
    _emailController = TextEditingController(text: provider.userEmail);
    _phoneController = TextEditingController(text: provider.userPhone);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _save() {
    final provider = context.read<FinanceProvider>();
    provider.saveUserName(_firstNameController.text.trim(), _lastNameController.text.trim());
    provider.saveContactInfo(_emailController.text.trim(), _phoneController.text.trim());
    // In a real app, you'd save the image path or bytes to SharedPreferences or a database.
    // For this migration, we'll stick to the text data.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Color(0xFF09637E), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const AppBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildAvatarPicker(),
                const SizedBox(height: 28),
                _buildFormSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourcePicker(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF09637E), Color(0xFF2D5BA3)]),
                  image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: _selectedImage == null ? Center(
                  child: Text(
                    _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ) : null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF09637E), shape: BoxShape.circle),
                child: const Icon(LucideIcons.camera, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Change picture', style: TextStyle(color: Color(0xFF09637E), fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFormSection() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _formField(LucideIcons.user, 'First Name', 'First name', _firstNameController),
          _divider(),
          _formField(LucideIcons.userPlus, 'Last Name', 'Last name', _lastNameController),
          _divider(),
          _formField(LucideIcons.mail, 'Email', 'Email address', _emailController, keyboard: TextInputType.emailAddress),
          _divider(),
          _formField(LucideIcons.phone, 'Phone', 'Phone number', _phoneController, keyboard: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _formField(IconData icon, String label, String hint, TextEditingController controller, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF09637E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF09637E), size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  keyboardType: keyboard,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.white.withOpacity(0.1), indent: 52);

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Profile Picture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(LucideIcons.camera, color: Colors.white),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: Colors.white),
                title: const Text('Choose from Library', style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () { Navigator.pop(context); setState(() => _selectedImage = null); },
                ),
              ListTile(
                leading: const Icon(LucideIcons.x, color: Colors.white54),
                title: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
