import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'chatwithspecificperson.dart'; // Import the chat screen or relevant file

class ConversationsPage extends StatefulWidget {
  final String jwtToken; // Accept JWT token as a parameter

  ConversationsPage({required this.jwtToken}); // Constructor to receive the token

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<dynamic> conversations = [];
  bool _isLoading = true; // Track loading state
  String? _errorMessage; // Store error message if needed

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    if (widget.jwtToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "JWT token is missing.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/chat/conversations'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          conversations = json.decode(response.body);
          _isLoading = false; // Set loading to false
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load conversations: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error occurred while fetching conversations.";
      });
      print("Error fetching conversations: $e");
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      print("Error parsing date: $e");
      return dateTimeStr; // Return the original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // New Chat Action (Add your action here)
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!)) // Show error message
          : ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          print('Conversation at index $index: ${json.encode(conversation)}'); // Debug print

          return ListTile(
            leading: Icon(Icons.person, size: 40),
            title: Text(
              '${conversation['user_email'] ?? 'Unknown'}', // Handle null values
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            subtitle: Text(
              'Last message time: ${_formatDateTime(conversation['last_message_time'] ?? '')}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              // Use user_id for the chat
              String otherUserId = conversation['user_id']?.toString() ?? "null"; // Changed to user_id
              print('Navigating to chat with user ID: $otherUserId'); // Log the user ID

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    jwtToken: widget.jwtToken,
                    otherUserId: otherUserId, // Update this line
                    userEmail: conversation['user_email'] ?? 'Unknown', // Handle null values
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
