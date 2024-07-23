import 'package:fluent_ui/fluent_ui.dart';
import 'package:imagine/pages/favorite.dart';
import 'package:imagine/pages/home.dart';
import 'package:imagine/pages/settings.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  // ensure init widgets
  WidgetsFlutterBinding.ensureInitialized();

  // init windows manager
  await initWindowManager();

  // run app
  runApp(const MyApp());
}

// init windows manager
Future<void> initWindowManager() async {
  // ini window manager
  await WindowManager.instance.ensureInitialized();

  // set windows property
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      // windowButtonVisibility: false,
    );
    await windowManager.setPreventClose(true);
    await windowManager.setMinimumSize(const Size(1280, 720));
    await windowManager.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: FluentThemeData(
        brightness: Brightness.light,
        // accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        // accentColor: Colors.purple,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

// extend with window listener
class _MainPageState extends State<MainPage> with WindowListener {
  int paneIndex = 0;

  // init
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  // dispose
  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // show dialog on window close
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        height: 36.0,
        title: DragToMoveArea(
          child: SizedBox(
            height: 36.0,
            child: Row(
              children: [
                Text('Imagine'),
              ],
            ),
          ),
        ),
        actions: WindowButtons(),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.compact,
        selected: paneIndex,
        onItemPressed: (value) {
          // set pane index
          setState(() {
            paneIndex = value;
          });
        },
        items: [
          // home
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Home'),
            body: const HomePage(),
          ),
          // favorite
          PaneItem(
            icon: const Icon(FluentIcons.favorite_star),
            title: const Text('Favorite'),
            body: const FavoritePage(),
            infoBadge: const InfoBadge(
              source: Text('8'),
            ),
          ),
        ],
        footerItems: [
          // settings
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: const SettingsPage(),
          )
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);
    return SizedBox(
      width: 138,
      height: 36.0,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
