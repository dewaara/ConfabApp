import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:confide/helper/shape_image_positioned.dart';
import '../auth/home_screen.dart';
import '../auth/login_screen.dart';
import '../main.dart';

class SplashScreenTwo extends StatefulWidget {
  const SplashScreenTwo({Key? key}) : super(key: key);

  @override
  State<SplashScreenTwo> createState() => _SplashScreenTwoState();
}

class _SplashScreenTwoState extends State<SplashScreenTwo>
    with TickerProviderStateMixin {
  final double _buttonWidth = 100;

  late AnimationController _buttonScaleController;
  late Animation<double> _buttonScaleAnimation;
  void _initButtonScale() {
    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation =
        Tween<double>(begin: 1, end: .9).animate(_buttonScaleController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _buttonWidthController.forward();
            }
          });
  }

  late AnimationController _buttonWidthController;
  late Animation<double> _buttonWidthAnimation;
  void _initButtonWidth(double screenWidth) {
    _buttonWidthController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _buttonWidthAnimation = Tween<double>(begin: _buttonWidth, end: screenWidth)
        .animate(_buttonWidthController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _positionedController.forward();
        }
      });
  }

  late AnimationController _positionedController;
  late Animation<double> _positionedAnimation;
  void _initPositioned(double screenWidth) {
    _positionedController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    // 160 = 20 left padding + 20 right padding + 10 left positioned + 10 right positioned + 100 button width
    _positionedAnimation = Tween<double>(begin: 10, end: screenWidth - 160)
        .animate(_positionedController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _screenScaleController.forward();
        }
      });
  }

  late AnimationController _screenScaleController;
  late Animation<double> _screenScaleAnimation;
  void _initScreenScale() {
    _screenScaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _screenScaleAnimation = Tween<double>(begin: 1, end: 24)
        .animate(_screenScaleController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (FirebaseAuth.instance.currentUser != null) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
          }
        }
      });
  }

  @override
  void initState() {
    _initButtonScale();
    _initScreenScale();
    super.initState();
  }

  @override
  void dispose() {
    _buttonScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    final double screenWidth = mq.width;
    _initButtonWidth(screenWidth);
    _initPositioned(screenWidth);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xffe2e7ef),
      child: Stack(
        children: [
          const ShapeImagePositioned(),
          const ShapeImagePositioned(top: -100),
          const ShapeImagePositioned(top: -150),
          const ShapeImagePositioned(top: -200),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Confide,',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  // 'We promise you will have the most fuss-free time with us ever',
                  'Confide with Confidence: Your Secure Chat Companion. 🙋🏻',
                  // 'Private Chats, Unwavering Security: Chat Safely with ConfideApp !! 🙋🏻',
                  style: TextStyle(
                    color: const Color(0xff0c2c63).withOpacity(.8),
                    fontSize: 20,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                AnimatedBuilder(
                  animation: _buttonScaleController,
                  builder: (_, child) => Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: CupertinoButton(
                      onPressed: () {
                        _buttonScaleController.forward();
                      },
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _buttonWidthController,
                            builder: (_, child) => Container(
                              height: _buttonWidth,
                              width: _buttonWidthAnimation.value,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(.7),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _positionedController,
                            builder: (_, child) => Positioned(
                              top: 10,
                              left: _positionedAnimation.value,
                              child: AnimatedBuilder(
                                animation: _screenScaleController,
                                builder: (_, child) => Transform.scale(
                                  scale: _screenScaleAnimation.value,
                                  child: Container(
                                    height: _buttonWidth - 20,
                                    width: _buttonWidth - 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xff0c2c63),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: _screenScaleController.isDismissed
                                        ? const Icon(
                                            CupertinoIcons.chevron_right_2,
                                            color: CupertinoColors.white,
                                            size: 30,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
