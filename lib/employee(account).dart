import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/designconstants.dart';

class EmployeeAccountPage extends StatefulWidget {
  const EmployeeAccountPage({super.key});

  @override
  State<EmployeeAccountPage> createState() => _EmployeeAccountPageState();
}

class _EmployeeAccountPageState extends State<EmployeeAccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  List<String> accessTitles = [
    "View Inventory",
    "Add Inventory",
    "Edit Inventory",
    "Delete Inventory",
    "Manage Employees",
    "Manage Roles",
    "View Reports",
    "Settings"
  ];

  List<String> roleAccessToShow = [];

  @override
  void initState() {
    super.initState();
    nameController.text = "Employee 1";
    emailController.text = "employee@gmail.com";
    phoneController.text = "09123456789";
    roleController.text = "Cashier";
    roleAccessToShow = ["View Inventory", "Add Inventory"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Account",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll)),
                    const SizedBox(height: 30),
                    _infoField("Name:", nameController),
                    const SizedBox(height: 20),
                    _infoField("Email:", emailController),
                    const SizedBox(height: 20),
                    _infoField("Phone:", phoneController),
                    const SizedBox(height: 20),
                    _infoField("Role:", roleController),
                    const SizedBox(height: 30),
                    const Text("Role Access:",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll)),
                    const SizedBox(height: 10),
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 120,
                        maxHeight: 250,
                      ),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: roleAccessToShow.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(roleAccessToShow[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              color: Colors.red,
              margin: const EdgeInsets.symmetric(horizontal: 25),
            ),
            const Expanded(flex: 5, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontFamily: fontAll)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

