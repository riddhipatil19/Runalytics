import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:runn_track/api/api_user.dart';
import 'package:runn_track/pages/login.dart';
import 'package:runn_track/util/shared_pref_helper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _name;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await SharedPrefHelper.getName();
    final email = await SharedPrefHelper.getEmail();
    setState(() {
      _name = name ?? 'Guest';
      _email = email ?? 'Not provided';
    });
  }

  void _logout() async {
    await SharedPrefHelper.clear();
    if (mounted) {
      Fluttertoast.showToast(
          msg: "Logout successful",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    }
  }

  bool isDeleting = false;
  ApiUser service = ApiUser();

  void _deleteAccount() async {
    setState(() {
      isDeleting = true;
    });
    final token = await SharedPrefHelper.getToken();
    final id = await SharedPrefHelper.getId();
    final response =
        await service.deleteUserById(id: int.parse(id!), token: token!);
    if (response['status'] == 200) {
      Fluttertoast.showToast(
          msg: response['message'],
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isDeleting = false;
      });
      _logout();
    } else {
      Fluttertoast.showToast(
          msg: response['message'],
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade400,
              ),
              alignment: Alignment.center,
              child: Text(
                (_name?.isNotEmpty == true ? _name![0].toUpperCase() : "?"),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(_name ?? '', style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(_email ?? '', style: const TextStyle(fontSize: 16)),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: isDeleting
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text("Delete Account",
                      style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
