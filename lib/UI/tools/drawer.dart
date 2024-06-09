import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/utilities/dialogs/logout_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

Container buildDrawer(BuildContext context) {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

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
            return Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 16),
                child: ListTile(
                  onTap: () async {
                    if (descriptionList[index] == 'Log out') {
                      Navigator.of(superContext).pop();
                      final shouldLogout = await showLogOutDialog(context);
                      if (shouldLogout) {
                        // ignore: use_build_context_synchronously
                        superContext
                            .read<AuthBloc>()
                            .add(const AuthEventLogOut());
                      }
                    } else {
                      await _launchURL('https://ieberlin.netlify.app/');
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
  Icons.logout,
];

List<String> descriptionList = [
  'About Developer',
  'Log out',
];
