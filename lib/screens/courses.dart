import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'course_details.dart';

const kPrimary = Color(0xFF2D388F); // selected tab
const kSecondary = Color(0xFF135C56); // un-selected tab

class Course {
  final String id, name, imageUrl, pdfName;
  Course({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pdfName,
  });

  factory Course.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: d['name'] ?? '',
      imageUrl: d['image'] ?? '',
      pdfName: d['pdf'] ?? '',
    );
  }
}

class CourseService {
  static const _rootDoc = 'u7hGCO4GtXRMrBtwNlUo';
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Course>> streamOf(String subCollection) => _db
      .collection('course')
      .doc(_rootDoc)
      .collection(subCollection)
      .snapshots()
      .map((qs) => qs.docs.map(Course.fromDoc).toList());
}

class CoursesScreen extends StatefulWidget {
  final int initialIndex;

  const CoursesScreen({super.key,  this.initialIndex =0});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, 2); // keep it 0-2
    _tabCtl = TabController(
      length: 3,
      vsync: this,
      initialIndex: _current,
    );
    _tabCtl.addListener(() {
      if (_current != _tabCtl.index) {
        setState(() => _current = _tabCtl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtl.dispose();
    super.dispose();
  }

  Widget _decoratedTab(String text, int idx) {
    final selected = _current == idx;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimary : kSecondary, // primary ↔ secondary
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            textAlign: TextAlign.center),
      ),
    );
  }

  Widget _grid(String sub) => StreamBuilder<List<Course>>(
        stream: CourseService.streamOf(sub),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Error'));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('No courses'));

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: .72,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CourseDetails(course: c.name, fileName: c.pdfName,),));
                }, // TODO: push detail
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.network(
                            c.imageUrl,
                            fit: BoxFit.fill,
                            loadingBuilder: (ctx, child, prog) => prog == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                            errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, size: 40)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(c.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

  /* ------------ scaffold ------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: Colors.white,
        foregroundColor: kPrimary,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: _Search()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: TabBar(
            controller: _tabCtl,
            isScrollable: true,
            indicatorColor: Colors.transparent,
            labelPadding: EdgeInsets.all(2),
            tabs: [
              _decoratedTab('Technical Courses', 0),
              _decoratedTab('Management Courses', 1),
              _decoratedTab('IT Courses', 2),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtl,
        physics: const BouncingScrollPhysics(),
        children: [
          _grid('technical course'),
          _grid('managment course'),
          _grid('it course'),
        ],
      ),
    );
  }
}

class _Search extends SearchDelegate {
  List<Course> allCourses = [];
  bool _isLoading = true;
  bool _hasFetched = false; // Prevent re-fetching on every rebuild

  Future<void> _fetchAllCourses(BuildContext context) async {
    final technical = await CourseService.streamOf('technical course').first;
    final management = await CourseService.streamOf('managment course').first;
    final it = await CourseService.streamOf('it course').first;

    allCourses = [...technical, ...management, ...it];
    _isLoading = false;

    showSuggestions(context); // ✅ Safe here
  }

  @override
  List<Widget> buildActions(BuildContext _) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search courses'));
    }

    if (_isLoading && !_hasFetched) {
      _hasFetched = true;
      _fetchAllCourses(context); // fetch only once
      return const Center(child: CircularProgressIndicator());
    }

    final suggestions = allCourses
        .where((course) =>
        course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('No matching courses'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final c = suggestions[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(c.imageUrl)),
          title: Text(c.name),
          onTap: () {
            query = c.name;
            showResults(context);
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allCourses
        .where((course) =>
        course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        itemCount: results.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: .72,
        ),
        itemBuilder: (_, i) {
          final c = results[i];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CourseDetails(
                  course: c.name,
                  fileName: c.pdfName,
                ),
              ));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        c.imageUrl,
                        fit: BoxFit.fill,
                        loadingBuilder: (ctx, child, prog) => prog == null
                            ? child
                            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      c.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
