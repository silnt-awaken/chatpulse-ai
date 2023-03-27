import 'package:chatpulse_ai/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import '../../../blocs/content/content_bloc.dart';

class CustomAppBar extends SliverPersistentHeaderDelegate {
  const CustomAppBar({
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = 1.0 - shrinkOffset / (maxExtent - minExtent);

    return BlocSelector<ContentBloc, ContentState, bool>(
      selector: (state) {
        return state.isDarkMode;
      },
      builder: (context, isDarkMode) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? darkPrimaryColor : primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Visibility(
                      visible: progress > 0.5,
                      child: AnimatedOpacity(
                        opacity: progress > 0.5 ? 1 : 0,
                        duration: const Duration(milliseconds: 1000),
                        child: IconButton(
                          icon: const Icon(Icons.menu),
                          iconSize: 28,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black.withOpacity(0.8),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => scrollController.animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ChatPulse AI',
                            style: GoogleFonts.nunitoSans(
                              textStyle: TextStyle(
                                fontSize: 24 + 2 * progress,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ),
                          BlocSelector<ContentBloc, ContentState, String>(
                            selector: (state) {
                              return state.summary;
                            },
                            builder: (context, state) {
                              return Visibility(
                                visible: state.isNotEmpty && progress > 0.8,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: SizedBox(
                                    height: 24,
                                    child: Marquee(
                                      text: state,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: TextStyle(
                                          fontSize: 16 + 2 * progress,
                                          fontWeight: FontWeight.w400,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black.withOpacity(0.8),
                                        ),
                                      ),
                                      scrollAxis: Axis.horizontal,
                                      blankSpace: 20.0,
                                      velocity: 100.0,
                                      pauseAfterRound:
                                          const Duration(seconds: 1),
                                      startPadding: 10.0,
                                      accelerationDuration:
                                          const Duration(seconds: 1),
                                      accelerationCurve: Curves.linear,
                                      decelerationDuration:
                                          const Duration(milliseconds: 500),
                                      decelerationCurve: Curves.easeOut,
                                    ),
                                  ),
                                  // child: AppText(
                                  //   state,
                                  //   fontSize: 16 + 2 * progress,
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
