import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class UserToDoctor extends StatefulWidget {
  final Map<String, String> doctor;

  const UserToDoctor({Key? key, required this.doctor}) : super(key: key);

  @override
  _UserToDoctorState createState() => _UserToDoctorState();
}

class _UserToDoctorState extends State<UserToDoctor> {
  bool isFollowing = false;
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.doctor["name"]} - Profile',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم الطبيب وصورته
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(widget.doctor["image"]!),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.doctor["name"]!,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.doctor["specialization"]!,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // زر المتابعة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isFollowing = !isFollowing;
                      });
                    },
                    icon: Icon(
                      isFollowing ? Icons.check : Icons.person_add,
                    ),
                    label: Text(
                      isFollowing ? "Unfollow" : "Follow",
                      style: TextStyle(fontSize: 16, color: Colors.white), // تحديد حجم الخط
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.red : Colors.teal,
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      // فتح شاشة المحادثة
                      print("Open Chat");
                    },
                    icon: const Icon(Icons.message),
                    label: const Text(
                      "Message",
                      style: TextStyle(fontSize: 16, color: Colors.white), // تحديد حجم الخط
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),

                ],
              ),
              const SizedBox(height: 20),

              // جدول الحجوزات
              const Text(
                "Appointments Calendar:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
                calendarFormat: calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    calendarFormat = format;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration:
                  BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                      color: Colors.tealAccent, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(height: 20),

              // جدول الأدوية
              const Text(
                "Prescribed Medications:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DataTable(
                columns: const [
                  DataColumn(label: Text("Medicine")),
                  DataColumn(label: Text("Dosage")),
                  DataColumn(label: Text("Timing")),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text("Paracetamol")),
                    const DataCell(Text("500 mg")),
                    const DataCell(Text("3 times/day")),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text("Ibuprofen")),
                    const DataCell(Text("200 mg")),
                    const DataCell(Text("2 times/day")),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
      // الشريط السفلي
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // العودة للصفحة الرئيسية للمريض
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: "Medications",
          ),
        ],
      ),
    );
  }
}
