import 'package:flutter/material.dart';

import '../../shaders/flowers_shader.dart';
import '../widgets/widgets.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late final ScrollController _scrollController;
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    _scrollController.addListener(() {
      setState(() {
        _isAtBottom = _scrollController.offset ==
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: LayoutBuilder(builder: (context, constraints) {
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          return CustomPaint(
            painter: DetailedFlowerPainter(
              screenSize: screenSize,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFd5d5e5).withOpacity(0.9),
              drawer: const SimpleDrawer(),
              body: Stack(
                children: [
                  ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: CustomScrollView(
                      controller: _scrollController,
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
                  ),
                  MessageInputRowSection(
                    scrollController: _scrollController,
                  )
                ],
              ),
            ),
          );
        }));
  }
}
