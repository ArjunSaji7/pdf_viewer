import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf_viewer/screens/courses.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget courseButton(String title, VoidCallback press) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF00A79C),
                Color(0xFF0171BA),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Lottie.asset(width: 25, height: 25, 'assets/logos/right.json'),
            ],
          ),
        ),
      ),
    );
  }

  Widget gridItem(String title) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Expandable AppBar with background image
            SliverAppBar(
              shadowColor: Colors.white,
              backgroundColor: Colors.white,
              expandedHeight: 250.0,
              pinned: false,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double collapsePercent = (1 -
                          (constraints.maxHeight - kToolbarHeight) /
                              (250 - kToolbarHeight))
                      .clamp(0.0, 1.5);

                  final bool isCollapsed = collapsePercent > 0.8;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(
                      left: 1,
                    ),
                    background: Stack(
                      children: [
                        // Background Image
                        Image.asset(
                          'assets/images/Smeclabs-Family.png',
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fitWidth,
                        ),

                        // Positioned Badge Image
                        Positioned(
                          left: 30,
                          top: 10,
                          child: Image.asset(
                            'assets/images/25th.png',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // TextField at bottom
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isCollapsed ? 0.0 : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: isCollapsed ? 0 : 50,
                              child: Material(
                                elevation: 5,
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                                child: TextField(
                                  controller: SearchController(),
                                  decoration: InputDecoration(
                                    hintText: "Search...",
                                    hintStyle: TextStyle(
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.blue,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // All body content below the AppBar
            SliverToBoxAdapter(
              child: Column(
                children: [
                  sectionTitle(
                      "India's Best Center for Technology & Management Courses"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Largest Training Campus with 75000 SqFt",
                      style: TextStyle(
                          color: Colors.blue[300], fontWeight: FontWeight.w100),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // Handle button tap
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Join Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  LogoCarousel(),
                  SizedBox(height: 20),
                  courseButton(
                    "Technical Courses",
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursesScreen(initialIndex: 0,),
                          ));
                    },
                  ),
                  SizedBox(height: 20),
                  courseButton(
                    "IT Courses",
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursesScreen(initialIndex: 2,),
                          ));
                    },
                  ),
                  SizedBox(height: 20),
                  courseButton(
                    "Management Courses",
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursesScreen(initialIndex: 1,),
                          ));
                    },
                  ),
                  SizedBox(height: 20),
                  sectionTitle("For Whom?"),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            gridItem("Students and Professionals"),
                            gridItem("Companies and Recruiters"),
                          ],
                        ),
                        Row(
                          children: [
                            gridItem("Colleges"),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  sectionTitle("Trending Courses For After"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(label: Text("Plus Two")),
                      Chip(label: Text("Degree")),
                      Chip(label: Text("Diploma")),
                      Chip(label: Text("Engineering")),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoCarousel extends StatefulWidget {
  @override
  _LogoCarouselState createState() => _LogoCarouselState();
}

class _LogoCarouselState extends State<LogoCarousel> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;

  final List<String> logos = [
    'assets/logos/google.jpg',
    'assets/logos/microsoft.jpg',
    'assets/logos/emerson.jpg',
    'assets/logos/scheneider.jpg',
    'assets/logos/siemens.jpg',
    'assets/logos/honeywell.jpg',
    'assets/logos/bosch.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    const scrollSpeed = 1.0;
    _timer = Timer.periodic(Duration(milliseconds: 40), (_) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double newScroll = currentScroll + scrollSpeed;

        if (newScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(newScroll);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loopedLogos = [...logos, ...logos];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            "Our online-courses training collaborates with over 200+ multinational companies",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: loopedLogos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Image.asset(
                  fit: BoxFit.fill,
                  loopedLogos[index],
                  height: 40,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
