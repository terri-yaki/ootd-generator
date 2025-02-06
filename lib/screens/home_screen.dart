// File: lib/screens/home_screen.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import 'wardrobe_screen.dart';
import '../models/wardrobe_data.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// Custom scroll behavior to disable scrollbars.
class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

/// AnimatedStaggeredOutfit animates each outfit item in a stack with a staggered delay.
/// Items animate with a decelerate curve (fast at first, then slowing down).
/// Each card is square (fixed size), has rounded corners with an outline,
/// and the background color of the card is _tan. The cards are slightly overlapped;
/// the bottom one covers the upper one by 15 pixels. The overall container height is increased by 30px.
/// Each item is clickable to show its properties in a popup window.
class AnimatedStaggeredOutfit extends StatefulWidget {
  final List<ClothingItem> items;
  final bool slideFromLeft;
  const AnimatedStaggeredOutfit({
    super.key,
    required this.items,
    required this.slideFromLeft,
  });

  @override
  State<AnimatedStaggeredOutfit> createState() => _AnimatedStaggeredOutfitState();
}

class _AnimatedStaggeredOutfitState extends State<AnimatedStaggeredOutfit>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final int _delayPerItem = 150; // duration per item for smoother animation
  final Color _tan = const Color(0xFFD9CBA3);
  final Color _mochabrown = const Color(0xFF7B6D47);

  @override
  void initState() {
    super.initState();
    int itemCount = max(widget.items.length, 1); // avoid zero duration.
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: itemCount * _delayPerItem),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedStaggeredOutfit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare the IDs of items to decide if the outfit has changed.
    final oldIds = oldWidget.items.map((e) => e.id).toList();
    final newIds = widget.items.map((e) => e.id).toList();
    if (!listEquals(oldIds, newIds)) {
      _controller.dispose();
      int itemCount = max(widget.items.length, 1);
      _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: itemCount * _delayPerItem),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build each animated item with staggered slide transition and click handler.
  Widget _buildAnimatedItem(int index, ClothingItem item) {
    double start = index / widget.items.length;
    double end = (index + 1) / widget.items.length;
    // All items start far off-screen to the right.
    final beginOffset = const Offset(3.0, 0);
    final animation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      // Using easeOutBack gives a nice overshoot effect.
      curve: Interval(start, end, curve: Curves.easeOutBack),
    ));

    // Define fixed card size and overlapping.
    const double cardSize = 130;
    const double overlap = 15;
    double topPosition = index * (cardSize - overlap);
    double screenWidth = MediaQuery.of(context).size.width;
    double leftPosition = (screenWidth - cardSize) / 2;

    return Positioned(
      top: topPosition,
      left: leftPosition,
      child: SlideTransition(
        position: animation,
        child: GestureDetector(
          onTap: () {
            // Show popup with item details.
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(item.name.isNotEmpty ? item.name : 'Item Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: item.imagePath.startsWith('assets/')
                                ? AssetImage(item.imagePath)
                                : FileImage(File(item.imagePath)) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Category: ${item.category.toString().split('.').last.toUpperCase()}'),
                      if (item.tags.isNotEmpty)
                        Text('Tags: ${item.tags.join(', ')}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: cardSize,
            height: cardSize,
            decoration: BoxDecoration(
              color: _tan,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _mochabrown, width: 1),
              image: DecorationImage(
                image: item.imagePath.startsWith('assets/')
                    ? AssetImage(item.imagePath)
                    : FileImage(File(item.imagePath)) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardSize = 130;
    const double overlap = 15;
    final double stackHeight = widget.items.isEmpty
        ? 0
        : cardSize + (widget.items.length - 1) * (cardSize - overlap) + 30;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          return _buildAnimatedItem(index, item);
        }),
      ),
    );
  }
}

/// HomeScreen displays the current outfit with dismissible functionality and navigates to the WardrobeScreen for managing items.
/// When swiped, the outfit items animate in from left or right based on swipe direction.
/// The item tree is reloaded every time the user returns to the HomeScreen,
/// but only if the wardrobe has changed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<ClothingItem> _currentOutfit = [];
  bool _slideFromLeft = true;
  final Color _caramel = const Color(0xFFB29C70);
  List<String> _wardrobeSnapshot = [];

  @override
  void initState() {
    super.initState();
    _generateRandomOutfit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

// Called when the user returns to this screen.
@override
void didPopNext() {
  final currentSnapshot = WardrobeData.items.map((item) => item.id).toList();
  if (!listEquals(_wardrobeSnapshot, currentSnapshot)) {
    _generateRandomOutfit();
    _wardrobeSnapshot = currentSnapshot;
  }
}

// Generate a random outfit in fixed order: top, bottom, footwear, accessory.
void _generateRandomOutfit() {
  final allItems = WardrobeData.items; // Get the list from Hive.
  List<ClothingItem> newOutfit = [];
  for (var category in [
    ClothingCategory.top,
    ClothingCategory.bottom,
    ClothingCategory.footwear,
    ClothingCategory.accessory
  ]) {
    List<ClothingItem> itemsForCategory =
        allItems.where((item) => item.category == category).toList();
    if (itemsForCategory.isNotEmpty) {
      newOutfit.add(itemsForCategory[Random().nextInt(itemsForCategory.length)]);
    }
  }
  setState(() {
    _currentOutfit = newOutfit;
  });
  _wardrobeSnapshot = allItems.map((item) => item.id).toList();
}


  // onDismiss handler: remove dismissed widget immediately.
  void _onDismissHandler(DismissDirection direction) {
    setState(() {
      _slideFromLeft = direction == DismissDirection.startToEnd;
      _currentOutfit = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      content: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, opacity, child) => Opacity(
        opacity: opacity,
        child: child,
        ),
        child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: const Text(
          'coming right up...',
          textAlign: TextAlign.center,
          ),
        ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 138, 113, 68), // Creamy background color
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(milliseconds: 500),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _generateRandomOutfit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool wardrobeEmpty = WardrobeData.items.isEmpty;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Image.asset(
            'assets/ootd.png',
            height: 60,
          ),
        ),
        centerTitle: true,
      ),
      body: ScrollConfiguration(
        behavior: NoScrollbarBehavior(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: wardrobeEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: const Text(
                        '\n\n\n\nNo outfit available.\nPlease add items in your wardrobe.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Dismissible(
                      key: ValueKey(_currentOutfit.map((e) => e.id).join('-')),
                      direction: DismissDirection.horizontal,
                      resizeDuration: const Duration(milliseconds: 200),
                      onDismissed: _onDismissHandler,
                      background: Container(
                        color: Colors.red.withOpacity(0.3),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red.withOpacity(0.3),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                      child: AnimatedStaggeredOutfit(
                        items: _currentOutfit,
                        slideFromLeft: _slideFromLeft,
                      ),
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          backgroundColor: _caramel,
          onPressed: () {
            _wardrobeSnapshot = WardrobeData.items.map((item) => item.id).toList();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WardrobeScreen()),
            ).then((_) {
              _generateRandomOutfit();
            });
          },
          child: const Icon(Icons.checkroom),
        ),
      ),
    );
  }
}
