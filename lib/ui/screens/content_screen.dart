import 'package:chatpulse_ai/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/content/content_bloc.dart';
import '../../shaders/flowers_shader.dart';
import '../widgets/widgets.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late final ScrollController _scrollController;
  bool _isAtBottom = true;
  bool _scrollable = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.extentInside >
            _scrollController.position.viewportDimension) {
          _scrollable = true;
        }

        _isAtBottom = _scrollController.offset ==
            _scrollController.position.maxScrollExtent;

        if (_scrollController.position.userScrollDirection ==
                ScrollDirection.forward &&
            BlocProvider.of<ContentBloc>(context).state.responseStatus ==
                ResponseStatus.generating) {
          context.read<ContentBloc>().add(
              const ContentChangeResponseStatusEvent(
                  responseStatus: ResponseStatus.idle,
                  hasDraggedWhileGenerating: true));
        }
      });
    });
  }

  void reset() {
    setState(() {
      _isAtBottom = true;
      _scrollable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: LayoutBuilder(builder: (context, constraints) {
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          return BlocSelector<ContentBloc, ContentState, bool>(
            selector: (state) {
              return state.isDarkMode;
            },
            builder: (context, isDarkMode) {
              return CustomPaint(
                painter: DetailedFlowerPainter(
                  screenSize: screenSize,
                  color: isDarkMode ? darkAccentColor : accentColor,
                ),
                child: Scaffold(
                  backgroundColor: isDarkMode ? darkPrimaryColor : primaryColor,
                  drawer: SimpleDrawer(
                    reset: () => reset(),
                  ),
                  body: SafeArea(
                    child: Stack(
                      children: [
                        CustomScrollView(
                          scrollBehavior: NoGlowScrollBehavior(),
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverPersistentHeader(
                                delegate: CustomAppBar(
                                  scrollController: _scrollController,
                                ),
                                floating: true,
                                pinned: _isAtBottom),
                            SliverList(
                                delegate: SliverChildListDelegate([
                              ContentSection(
                                scrollController: _scrollController,
                              )
                            ]))
                          ],
                        ),
                        Builder(builder: (context) {
                          return Visibility(
                            visible: !_isAtBottom && !_scrollable,
                            child: Positioned.fill(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                behavior: HitTestBehavior.deferToChild,
                                onTap: () {
                                  _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? darkPrimaryColor
                                        : primaryColor,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: isDarkMode
                                        ? darkAccentColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            )),
                          );
                        }),
                        MessageInputRowSection(
                          scrollController: _scrollController,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}
