import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/utilities/dialogs/logout_dialog.dart';

Container buildDrawer(BuildContext context) {
  final superContext = context;
  return Container(
      alignment: Alignment.center,
      color: lightBlackColor(),
      width: MediaQuery.of(context).size.width * (3 / 4),
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: iconList.length,
          itemBuilder: (context, index) {
            log(context.toString());
            return Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 16),
                child: ListTile(
                  onTap: () async {
                    if (descriptionList[index] == 'Dark mode') {
                    } else if (descriptionList[index] == 'Log out') {
                      Navigator.of(superContext).pop();
                      final shouldLogout = await showLogOutDialog(context);
                      if (shouldLogout) {
                        // ignore: use_build_context_synchronously
                        superContext.read<AuthBloc>().add(const AuthEventLogOut());
                      }
                    }
                  },
                  minLeadingWidth: 10,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    iconList[index],
                    color: menuBarItemColor(),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      index == 0
                          ? const SizedBox(
                              height: 10,
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Divider(
                                height: 0.1,
                                thickness: 0.1,
                                color: menuBarItemColor(),
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * (3 / 4) -
                                150,
                            child: Text(
                              descriptionList[index],
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'SF-Compact-Rounded-Semibold',
                                fontSize: 20,
                                color: menuBarItemColor(),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: menuBarItemColor(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ));
          }));
}

List<IconData> iconList = [
  Icons.info,
  Icons.dark_mode,
  Icons.logout,
];

List<String> descriptionList = [
  'About developer About developer About developer',
  'Dark mode',
  'Log out',
];
