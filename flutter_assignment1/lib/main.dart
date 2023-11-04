import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter User App',
      home: CrudScreen(),
    );
  }
}

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final Dio _dio = Dio();
  TextEditingController _fnameController = TextEditingController();
  TextEditingController _lnameController = TextEditingController();
  String? _selectedUserId; // Store the selected user's objectId

  List<Map<String, dynamic>> _users = [];

  Future<void> _fetchUsers() async {
    try {
      Response response = await _dio.get(
        'https://parseapi.back4app.com/classes/MyClass',
        options: Options(
          headers: {
            'X-Parse-Application-Id': 'X86c5vVWQjIb5Yl19TXMBKlD4oTsm00B5cTFqYZR',
            'X-Parse-REST-API-Key': 'RAjk0AzzrTGGJb7MG1ubKwrqYR57hCqCEmJc3Zg9',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response.data['results']);
        });
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<void> _createUser() async {
    try {
      await _dio.post(
        'https://parseapi.back4app.com/classes/MyClass',
        options: Options(
          headers: {
            'X-Parse-Application-Id': 'X86c5vVWQjIb5Yl19TXMBKlD4oTsm00B5cTFqYZR',
            'X-Parse-REST-API-Key': 'RAjk0AzzrTGGJb7MG1ubKwrqYR57hCqCEmJc3Zg9',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'fname': _fnameController.text,
          'lname': _lnameController.text,
        },
      );
      _fnameController.clear();
      _lnameController.clear();
      _fetchUsers();
    } catch (error) {
      print('Error creating user: $error');
    }
  }

  Future<void> _updateUser() async {
    if (_selectedUserId != null) {
      try {
        await _dio.put(
          'https://parseapi.back4app.com/classes/MyClass/$_selectedUserId',
          options: Options(
            headers: {
              'X-Parse-Application-Id': 'X86c5vVWQjIb5Yl19TXMBKlD4oTsm00B5cTFqYZR',
              'X-Parse-REST-API-Key': 'RAjk0AzzrTGGJb7MG1ubKwrqYR57hCqCEmJc3Zg9',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'fname': _fnameController.text,
            'lname': _lnameController.text,
          },
        );
        _selectedUserId = null; // Reset selected user after update
        _fnameController.clear();
        _lnameController.clear();
        _fetchUsers();
      } catch (error) {
        print('Error updating user: $error');
      }
    } else {
      print('No user selected for update.');
    }
  }

  Future<void> _deleteUser(String objectId) async {
    try {
      await _dio.delete(
        'https://parseapi.back4app.com/classes/MyClass/$objectId',
        options: Options(
          headers: {
            'X-Parse-Application-Id': 'X86c5vVWQjIb5Yl19TXMBKlD4oTsm00B5cTFqYZR',
            'X-Parse-REST-API-Key': 'RAjk0AzzrTGGJb7MG1ubKwrqYR57hCqCEmJc3Zg9',
          },
        ),
      );
      _fetchUsers();
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _fnameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: _lnameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _selectedUserId = null; // Reset selected user when creating a new user
                        _createUser();
                      },
                      child: Text('Create'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _updateUser,
                      child: Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = _users[index];
                return ListTile(
                  title: Text('${user['fname']} ${user['lname']}'),
				  subtitle: Text('User ID: ${user['objectId']}'), //this can be removed if not needed
                  onTap: () {
                    setState(() {
                      _selectedUserId = user['objectId'];
                      _fnameController.text = user['fname'];
                      _lnameController.text = user['lname'];
                    });
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteUser(user['objectId']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
