import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/enums/methods.dart';
import 'package:projectx/services/cloud/cloud_note.dart';

Widget gridViewBuilder(
    double itemWidth, double itemHeight, Iterable<CloudNote> notes,Function onTap) {
  return Scaffold(
    backgroundColor: lightBlackColor(),
    body: AnimationLimiter(
      child: GridView.builder(
        itemCount: notes.length,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: (itemWidth / itemHeight),
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          final note = notes.elementAt(index);
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            duration: const Duration(milliseconds: 500),
            child: ScaleAnimation(
              duration: const Duration(milliseconds: 900),
              curve: Curves.fastLinearToSlowEaseIn,
              child: FadeInAnimation(
                child: InkWell(
                  onTap: () {
                    onTap(note);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: blackColor(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(9),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: itemWidth - 50,
                                    child: Text(
                                      note.title,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'SF-Compact',
                                        color: white(),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: enumsToColors(
                                        stringToEnums(note.importance)),
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  height: itemHeight - 60,
                                  width: itemWidth,
                                  child: Text(
                                    note.content,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: amber(),
                                      // Color.fromARGB(255, 144, 144, 144),
                                      fontFamily: 'SF-Compact-Display-Regular',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
