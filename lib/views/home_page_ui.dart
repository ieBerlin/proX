import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/connectivity_checker/cubit/connectivity_checker_cubit.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/stream/all_notes_station.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _HomePageState();
}

class _HomePageState extends State<MyWidget> {
  final AllNotesStation _allNotesStation = AllNotesStation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<ConnectivityCheckerCubit, InternetState>(
        builder: (context, state) {
          return FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () {},
            child: (state is ConnectedState)
                ? const CircleAvatar(
                    backgroundColor: Colors.green,
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.red,
                  ),
          );
        },
      ),
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: BlocConsumer<ConnectivityCheckerCubit, InternetState>(
        listener: (context, state) {
          if (state is NotConnectedState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 10),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  content: Text(
                    'For security reasons, your documents are not synced with the cloud.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        },
        builder: (context, state) {
          if (state is ConnectedState) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 20),
              ),
            );
          } else if (state is NotConnectedState) {
            return const Center(
              child: Text(
                'Not connected',
                style: TextStyle(fontSize: 20),
              ),
            );
          } else {
            return StreamBuilder(
              stream: _allNotesStation.allNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  allNotes.forEach((element) {
                    print(element);
                  });
                } else {
                  log('it has no data');
                }
                return const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
