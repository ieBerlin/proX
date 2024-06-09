import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/circular_progress_inducator_widget.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/UI/tools/drawer.dart';
import 'package:projectx/UI/transitions.dart/transition_from_home_to_create.dart';
import 'package:projectx/connectivity_checker/cubit/connectivity_checker_cubit.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/search_bloc/search_bloc.dart';
import 'package:projectx/search_bloc/search_event.dart';
import 'package:projectx/search_bloc/search_state.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/current_crud.dart';
import 'package:projectx/services/stream/all_notes_station.dart';
import 'package:projectx/views/create_or_update_note.dart';
import 'package:projectx/views/notes_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final CRUDServices _crudServices;
  late final FirebaseCloudStorage _firebaseCloudStorage;
  Iterable<CloudNote> allNotes = [];
  String get userId => AuthService.firebase().currentUser!.id;
  late final TextEditingController textEditingController;
  bool isDrawerOpen = false;
  bool userConnected = false;
  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  @override
  void initState() {
    _crudServices = CRUDServices();
    _crudServices.openDB();
    _firebaseCloudStorage = FirebaseCloudStorage();
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: globalKey,
      drawer: buildDrawer(context),
      backgroundColor: lightBlackColor(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              FadeRoute1(
                CreateOrUpdateNote(
                  userConnected: userConnected,
                ),
              ));
        },
        backgroundColor: const Color.fromARGB(255, 64, 64, 64),
        child: Icon(
          Icons.library_add,
          color: white(),
          size: 30,
        ),
      ),
      body: BlocConsumer<ConnectivityCheckerCubit, InternetState>(
        listener: (context, state) async {
          if (state is NotConnectedState) {
            userConnected = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    )),
                content: Text(
                  'For security reasons, your documents are not synced with the cloud.',
textAlign: TextAlign.center,                    
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            final allNotes = await _crudServices.allNotes();
            await _firebaseCloudStorage.uploadNotes(
              notes: allNotes,
              userId: userId,
            );
            userConnected = true;
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          'All notes',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'SF-Compact-Display-Bold',
                            color: white(),
                            fontSize: 35,
                          ),
                        ),
                      ),
                      IconButton(
                        enableFeedback: false,
                        splashColor: transparent(),
                        splashRadius: 23,
                        onPressed: () {
                          globalKey.currentState!.openDrawer();
                        },
                        icon: Icon(
                          Icons.tune,
                          color: white(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: white(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      context.read<SearchBloc>().add(SearchTextChanged(
                            query: value,
                            notes: allNotes,
                          ));
                    },
                    controller: textEditingController,
                    style: const TextStyle(
                      fontFamily: 'Lato-Regular',
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                    cursorColor: lightBlackColor(),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search for note',
                        hintStyle: const TextStyle(
                          fontFamily: 'Lato-Regular',
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                        prefixIcon:
                            Icon(Icons.search, color: lightBlackColor()),
                        suffixIcon: IconButton(
                            enableFeedback: false,
                            splashRadius: 23,
                            onPressed: () {
                              textEditingController.clear();
                              context.read<SearchBloc>().add(SearchTextChanged(
                                    query: '',
                                    notes: allNotes,
                                  ));
                            },
                            icon: Icon(
                              Icons.clear,
                              color: lightBlackColor(),
                            ))),
                  ),
                ),
              ),
              StreamBuilder(
                stream: AllNotesStation().allNotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    if (snapshot.hasData) {
                      allNotes = snapshot.data as Iterable<CloudNote>;
                      return Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 15),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return GridViewClass(
                                    notes: allNotes,
                                    onTap: (note) {
                                      Navigator.of(context).pushNamed(
                                        createOrUpdateNoteRoute,
                                        arguments: note,
                                      );
                                    },
                                  );
                                },
                              )));
                    } else {
                      print('no data');

                      return Expanded(
                        child: Center(
                          child: Text(
                            'There is no note to show!\nTry to create one',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: white(),
                              fontFamily: "SF-Compact-Display-Bold",
                              fontSize: 27,
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    print('proggressing');

                    return circularProgressIndicatorWidget();
                  }
                },
              )
            ],
          );
        },
      ),
    ));
  }
}
