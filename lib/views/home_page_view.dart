import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:projectx/services/crud/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Services _services;
  late final TextEditingController _email;
  @override
  void initState() {
    _email = TextEditingController();
    _services = Services();
    super.initState();
  }

  @override
  void dispose() {
    _services.close();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(hintText: 'Enter email'),
          ),
          TextButton(
              onPressed: () async {
                try {
                  final user =
                      await _services.getOrCreateUser(email: _email.text);
                  log('------------');
                  log(user.id.toString());
                  log(user.email.toString());
                  log('------------');
                } on GenericException catch (e) {
                  log('error :( $e');
                } catch (e) {
                  log('error :( $e');
                }
              },
              child: const Text('Create user'))
        ],
      ),
    );
  }
}
/*try {
                  final user = await _services.createAnUser(email: email.text);
                  log(user.toString());
                  log('user has been created');
                } on UserAlreadyExistsBerlin catch (e) {
                  log('user already exists');
                } on DatabaseIsntOpenedCrudBerlin catch (e) {
                  log('An error occured while opening db');
                } on GenericExption12 catch (e) {
                  log('an error occured' + '$e');
                } catch (e) {
                  log('an error occured');
                } */