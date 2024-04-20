import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/select_option.dart';
import 'package:magic/snappable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(
    cameraDescription: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cameraDescription});
  final CameraDescription cameraDescription;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
        cameraDescription: cameraDescription,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cameraDescription});
  final CameraDescription cameraDescription;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfImage = 1;
  late final PageController _pageController;
  late final CameraController _cameraController;
  final key = GlobalKey<SnappableState>();
  SelectOption selectOption = SelectOption.none;
  bool isAnimate = false;
  @override
  void initState() {
    selectOption = SelectOption.none;
    _pageController = PageController(initialPage: 5 * numberOfImage + 3);
    _cameraController =
        CameraController(widget.cameraDescription, ResolutionPreset.max);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _cameraController
            .initialize()
            .then((value) => null)
            .catchError((e) {
          switch (e.code) {
            case "CameraAccessDenied":
              showDialog(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                        title: Text("Notification"),
                        content: Text("Access was denied"),
                      ));
              break;
            default:
              showDialog(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                        title: Text("Notification"),
                        content: Text('Some thing wrong'),
                      ));
              break;
          }
        }),
        builder: (context, snapshot) {
          return Scaffold(
            body: selectOption == SelectOption.none
                ? getPageViewWine()
                : getWineWithCamera(),
          );
        });
  }

  GestureDetector getPageViewWine() {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          selectOption = SelectOption.selected;
          isAnimate = true;
        });
      },
      onTapDown: (details) {
        _pageController.jumpToPage(10 * numberOfImage);
      },
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        itemBuilder: (context, index) {
          var nameImage = index % numberOfImage;
          return GestureDetector(
            onTap: () {
              if (selectOption == SelectOption.none) {
                _pageController.animateToPage(1000,
                    duration: const Duration(seconds: 45),
                    curve: Curves.easeInOut);
              }
            },
            child: Container(
              color: Colors.orangeAccent,
              child: Center(
                child: Image.asset('assets/images/$nameImage.png'),
              ),
            ),
          );
        },
      ),
    );
  }

  Stack getWineWithCamera() {
    return Stack(children: [
      SizedBox(
        height: double.infinity,
        child: CameraPreview(_cameraController),
      ),
      FadeOutUpBig(
        animate: isAnimate,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.orangeAccent,
        ),
      ),
      Snappable(
          key: key,
          snapOnTap: true,
          onSnapped: () {},
          duration: const Duration(seconds: 3),
          child: Center(
            child: Center(child: Image.asset("assets/images/0.png")),
          ))
    ]);
  }
}
