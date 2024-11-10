import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'screens/decks_tab.dart';
import 'screens/review_tab.dart';
import 'screens/settings_tab.dart';
import 'providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  final StorageService storage;
  final ThemeProvider themeProvider;
  
  const MyApp({
    required this.storage, 
    required this.themeProvider, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, child) {
        return MaterialApp(
          title: 'DeckIt',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.seedColor,
              brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: MyHomePage(
            storage: storage,
            themeProvider: themeProvider,
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final StorageService storage;
  final ThemeProvider themeProvider;

  const MyHomePage({
    required this.storage,
    required this.themeProvider,
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      _navigatorKeys[index]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[index]!,
        storage: widget.storage,
        themeProvider: widget.themeProvider,
        tabIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = 
            !await _navigatorKeys[_currentIndex]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentIndex != 0) {
            _onTabTapped(0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.library_books),
              label: 'Decks',
            ),
            NavigationDestination(
              icon: Icon(Icons.refresh),
              label: 'Review',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final StorageService storage;
  final ThemeProvider themeProvider;
  final int tabIndex;

  const TabNavigator({
    required this.navigatorKey,
    required this.storage,
    required this.themeProvider,
    required this.tabIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            switch (tabIndex) {
              case 0:
                return DecksTab(storage: storage);
              case 1:
                return ReviewTab(storage: storage);
              case 2:
                return SettingsTab(
                  storage: storage,
                  themeProvider: themeProvider,
                );
              default:
                return DecksTab(storage: storage);
            }
          },
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  final themeProvider = await ThemeProvider.create();
  runApp(MyApp(storage: storage, themeProvider: themeProvider));
}
