import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softwaregraduateproject/profileforanotherusers.dart';
import 'package:softwaregraduateproject/profileforanotherusersforcaregiver.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'AdminHomepage.dart';
import 'CareGiverHomepage.dart';
import 'CareRecipientHomepage.dart';
import 'Conversations.dart';
import 'Hospitaluser.dart';

class SearchPage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  final bool isGoogleSignInEnabled;

  SearchPage(this.savedEmail, this.savedPassword, this.savedToken, this.isGoogleSignInEnabled);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  int _selectedIndex = 0;
  String _selectedType = "All";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost)
      : 'http://10.0.2.2:3001'; // Mobile emulator

  Future<void> fetchUsers() async {
    final String url = '$baseUrl/getUsersforsearch';

    try {
      final String token = widget.savedToken;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> usersData = responseData['data'];

          setState(() {
            _users = usersData.map<Map<String, dynamic>>((user) {
              return {
                'name': '${user['First_name']} ${user['Last_name']}',
                'email': user['Email'] ?? '',
                'type': user['Type_oftheuser'] ?? 'Unknown',
                'bio': user['Bio'] ?? '',
                'photoUrl': user['image_path'] ?? '',
                'id': user['User_id'].toString(),
              };
            }).toList();

            _filteredUsers = List.from(_users);
          });
        } else {
          _showErrorDialog('Failed to load users: ${responseData['message']}');
        }
      } else {
        _showErrorDialog('Failed to fetch users, Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('Error fetching users: $error');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _applyFilters();
    });
  }

  void _onFilterChanged(String selectedType) {
    setState(() {
      _selectedType = selectedType;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      final matchesSearch = user['name']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());

      // Convert "Report" filter to "Admin" for filtering
      final userType = _selectedType == "Report" && user['type'] == "Admin"
          ? "Report"
          : user['type'];

      final matchesType = _selectedType == "All" || userType == _selectedType;

      return matchesSearch && matchesType;
    }).toList();

  }


  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        await fetchHomepageAndNavigate(context, widget.savedEmail, widget.savedPassword,
            widget.savedToken, widget.isGoogleSignInEnabled);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationsPage(widget.savedEmail, widget.savedPassword,
                  widget.savedToken, widget.isGoogleSignInEnabled)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SearchPage(widget.savedEmail, widget.savedPassword,
                  widget.savedToken, widget.isGoogleSignInEnabled)),
        );
        break;
    }
  }

  Future<void> fetchHomepageAndNavigate(
      BuildContext context, String email, String password, String token, bool isGoogleSignInEnabled) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/homepage'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userType = data['userType'];

        Widget homepage;
        if (userType == 'Care recipient') {
          homepage = CareRecipientHomepage(email, password, token, isGoogleSignInEnabled);
        } else if (userType == 'Admin') {
          homepage = AdminHomepage(email, password, token, isGoogleSignInEnabled);
        } else if(userType == 'Care giver') {
          homepage = CareGiverHomepage(email, password, token, isGoogleSignInEnabled);
        }else{
          homepage=HospitalUserForm(email, password, token, isGoogleSignInEnabled);
        }

        // If mounted, navigate to the homepage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homepage),
          );
        }
      } else {
        _showErrorDialog('Failed to load homepage data');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.teal.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _onSearchChanged(),
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ["All", "Care recipient", "Care giver", "Hospital", "Report"]
                  .map((type) => Expanded(
                child: ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(fontSize: 12), // Reduce font size
                  ),
                  selected: _selectedType == type,
                  onSelected: (isSelected) => _onFilterChanged(type),
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Reduce padding
                ),
              ))
                  .toList(),
            ),
            SizedBox(height: 20),

            if (_selectedType.isNotEmpty)
              Text(
                "Selected: $_selectedType", // Show the selected type
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredUsers.isNotEmpty
                  ? ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      final selectedUserId = _filteredUsers[index]['id'];
                      final selectedUserType = _filteredUsers[index]['type']; // Get the user type

                      if (selectedUserId != null &&
                          selectedUserId is String &&
                          selectedUserId.isNotEmpty) {
                        print('Tapped on user with ID: $selectedUserId');

                        if (selectedUserType == 'Care giver') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailsPage(id: selectedUserId,
                                      savedToken: widget.savedToken),
                            ),
                          );

                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailsPageforcaregiver(
                                      id: selectedUserId,
                                      savedToken: widget.savedToken),
                            ),
                          );
                        }
                      } else {
                        print('User ID is null or invalid');
                        _showErrorDialog(
                            'Invalid user data. Please try again.');
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        leading: CircleAvatar(
                          backgroundImage: _filteredUsers[index]['photoUrl'] != null &&
                              _filteredUsers[index]['photoUrl'].isNotEmpty
                              ? NetworkImage(
                              '$baseUrl/${_filteredUsers[index]['photoUrl'].startsWith('/') ? _filteredUsers[index]['photoUrl'].substring(1) : _filteredUsers[index]['photoUrl']}')
                              : NetworkImage('https://via.placeholder.com/150'),
                          child: _filteredUsers[index]['photoUrl'] == null ||
                              _filteredUsers[index]['photoUrl'].isEmpty
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                          backgroundColor: Colors.teal,
                        ),
                        title: Text(
                          _filteredUsers[index]['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal,
                          ),
                        ),
                        subtitle: Text(
                          _filteredUsers[index]['type'] == "Admin" ? "Admin" : _filteredUsers[index]['type'],
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.teal),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.teal),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.teal),
            label: 'Search',
          ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
