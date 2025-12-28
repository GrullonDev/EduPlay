import 'package:edu_play/features/register_child/bloc/register_child_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterChildLayout extends StatelessWidget {
  const RegisterChildLayout({super.key});

  final Map<String, IconData> _avatars = const {
    'lion': Icons.pets,
    'robot': Icons.smart_toy,
    'rocket': Icons.rocket_launch,
    'star': Icons.star,
    'music': Icons.music_note,
    'painter': Icons.brush,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Passport Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ],
                border: Border.all(color: Colors.blueAccent, width: 2)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text('PASAPORTE EDUPLAY',
                        style: GoogleFonts.blackOpsOne(
                            fontSize: 20,
                            color: Colors.blue[900],
                            letterSpacing: 2)),
                  ],
                ),
                const Divider(height: 30, thickness: 2),

                // Avatar Selection
                Text('FOTO DEL AGENTE',
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 10),
                _buildAvatarSelector(context),

                const SizedBox(height: 20),

                // Form
                _buildTextField(
                    context,
                    'NOMBRE EN CLAVE',
                    Provider.of<RegisterChildProvider>(context).nameController,
                    Icons.badge),
                const SizedBox(height: 15),
                Text('EDAD DEL AGENTE',
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 10),
                _buildAgeSelector(context),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Provider.of<RegisterChildProvider>(context, listen: false)
                      .registerChild(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 5),
              icon: const Icon(Icons.check_circle, size: 28),
              label: Text('EMITIR PASAPORTE',
                  style: GoogleFonts.nunito(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAgeSelector(BuildContext context) {
    return Consumer<RegisterChildProvider>(builder: (context, bloc, _) {
      final currentAge = int.tryParse(bloc.ageController.text) ?? 7;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(11, (index) {
          final age = index + 7;
          final isSelected = currentAge == age;
          return GestureDetector(
            onTap: () {
              bloc.setAge(age);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
                    width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Center(
                child: Text(
                  '$age',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildAvatarSelector(BuildContext context) {
    return Consumer<RegisterChildProvider>(builder: (context, bloc, _) {
      return Wrap(
        spacing: 15,
        runSpacing: 15,
        alignment: WrapAlignment.center,
        children: _avatars.entries.map((entry) {
          final isSelected = bloc.selectedAvatar == entry.key;
          return GestureDetector(
            onTap: () => bloc.selectAvatar(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 3),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                              color: Colors.blueAccent, blurRadius: 8)
                        ]
                      : null),
              child: Icon(entry.value,
                  size: 30, color: isSelected ? Colors.blue : Colors.grey),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildTextField(BuildContext context, String label,
      TextEditingController controller, IconData icon,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600])),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.courierPrime(
              fontSize: 18, fontWeight: FontWeight.bold), // Typewriter style
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue[300]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }
}
