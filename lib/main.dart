import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, SystemNavigator, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(UrduNovelApp());
}

class UrduNovelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xff70543e),
        scaffoldBackgroundColor: Color(0xff70543e),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff70543e),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سفالگر',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Image.asset('assets/splash_image.png'),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage('assets/splash_image.png'),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UrduNovelAppStateful()),
                    );
                  },
                  child: Text('Start Reading', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff70543e),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final page = await showDialog<int>(
                      context: context,
                      builder: (context) => GoToPageDialog(totalPages: 100),
                    );
                    if (page != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UrduNovelAppStateful(initialPage: page - 1)),
                      );
                    }
                  },
                  child: Text('Go to Page', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff70543e),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UrduNovelAppStateful(continueReading: true)),
                    );
                  },
                  child: Text('Continue Reading', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff70543e),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('Exit App', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff70543e),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UrduNovelAppStateful extends StatefulWidget {
  final int? initialPage;
  final bool continueReading;

  UrduNovelAppStateful({this.initialPage, this.continueReading = false});

  @override
  _UrduNovelAppState createState() => _UrduNovelAppState();
}

class _UrduNovelAppState extends State<UrduNovelAppStateful> {
  bool isDarkTheme = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadThemePreference();
    if (widget.continueReading) {
      _loadLastReadPage();
    } else if (widget.initialPage != null) {
      _pageController = PageController(initialPage: widget.initialPage!);
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = !isDarkTheme;
      prefs.setBool('isDarkTheme', isDarkTheme);
    });
  }

  Future<void> _loadLastReadPage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadPage = prefs.getInt('lastReadPage') ?? 0;
    setState(() {
      _pageController = PageController(initialPage: lastReadPage);
    });
  }

  Future<void> _saveLastReadPage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastReadPage', index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سفالگر',
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: NovelScreen(
          toggleTheme: _toggleTheme,
          isDarkTheme: isDarkTheme,
          pageController: _pageController,
          saveLastReadPage: _saveLastReadPage,
          initialPage: widget.initialPage,
          continueReading: widget.continueReading,
        ),
      ),
      locale: Locale('ur'), // Set locale to Urdu for RTL layout
    );
  }
}

class NovelScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkTheme;
  final PageController pageController;
  final Future<void> Function(int) saveLastReadPage;
  final int? initialPage;
  final bool continueReading;

  NovelScreen({
    required this.toggleTheme,
    required this.isDarkTheme,
    required this.pageController,
    required this.saveLastReadPage,
    this.initialPage,
    this.continueReading = false,
  });

  @override
  _NovelScreenState createState() => _NovelScreenState();
}

class _NovelScreenState extends State<NovelScreen> {
  List<String> novelPages = [];
  int currentPageIndex = 0;
  Set<int> bookmarks = {};

  @override
  void initState() {
    super.initState();
    _loadNovelText();
    _loadBookmarks();
    if (widget.continueReading) {
      _loadLastReadPage();
    } else if (widget.initialPage != null) {
      currentPageIndex = widget.initialPage!;
    }
  }

  Future<void> _loadNovelText() async {
    final text = await rootBundle.loadString('assets/novel.txt');
    setState(() {
      novelPages = _paginateText(text);
    });
  }

  List<String> _paginateText(String text) {
    const int charsPerPage = 800;
    List<String> pages = [];
    for (int i = 0; i < text.length; i += charsPerPage) {
      int endIndex = i + charsPerPage;
      if (endIndex > text.length) endIndex = text.length;
      pages.add(text.substring(i, endIndex));
    }
    return pages;
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks = (prefs.getStringList('bookmarks') ?? []).map(int.parse).toSet();
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (bookmarks.contains(currentPageIndex)) {
        bookmarks.remove(currentPageIndex);
      } else {
        bookmarks.add(currentPageIndex);
      }
      prefs.setStringList('bookmarks', bookmarks.map((e) => e.toString()).toList());
    });
  }

  Future<void> _loadLastReadPage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadPage = prefs.getInt('lastReadPage') ?? 0;
    setState(() {
      currentPageIndex = lastReadPage;
      widget.pageController.jumpToPage(lastReadPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سفالگر',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: _toggleBookmark,
            color: widget.isDarkTheme ? Colors.white : Colors.black,
          ),
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.toggleTheme();
            },
            color: widget.isDarkTheme ? Colors.white : Colors.black,
          ),
        ],
      ),
      body: novelPages.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: widget.pageController,
              itemCount: novelPages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                  widget.saveLastReadPage(index);
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Text(
                          novelPages[index],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Center(
                        child: Text(
                      (index+1).toString(),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class GoToPageDialog extends StatefulWidget {
  final int totalPages;

  GoToPageDialog({required this.totalPages});

  @override
  _GoToPageDialogState createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<GoToPageDialog> {
  final _pageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Go to Page'),
      content: TextField(
        controller: _pageController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Page Number',
          hintText: 'Enter page number (1-${widget.totalPages})',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {

            print(widget.totalPages);
            final page = int.tryParse(_pageController.text);
            if (page != null && page > 0 && page <= widget.totalPages) {
              Navigator.of(context).pop(page);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid page number')),
              );
            }
          },
          child: Text('Go'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
