import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textSearchController = TextEditingController();
  List<User>? users;
  bool isLoading = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textSearchController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleSearch();
  }

  void _handleSearch() async {
    try {
      setState(() {
        isLoading = true;
      });
      final result =
          await AuthMethods().searchUsers(_textSearchController.text);
      setState(() {
        users = result;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần tìm kiếm (optional)
            TextField(
              controller: _textSearchController,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                    onPressed: _handleSearch, icon: const Icon(Icons.search)),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 16.0),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: users!
                          .length, // Số lượng người dùng tìm kiếm được giả định là 10
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(users![index].photoUrl),
                          ),
                          title: Text(users![index].username),
                          subtitle: Text(users![index].bio),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(userId: users![index].uid),
                            ));
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
