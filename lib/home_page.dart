import 'dart:async';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flappy/barriers.dart';
import 'package:flutter_flappy/bird.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const String ROUTE_NAME = '/homePageScreen';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String HIGH_SCORE_KEY = 'highScore';
  static double gokberkYAxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = gokberkYAxis;

  double upperbarrierOneHeight = 0.0;
  double lowerBarrierOneHeight = 0.0;

  double upperbarrierTwoHeight = 0.0;
  double lowerBarrierTwoHeight = 0.0;

  static double barrierXOne = -2.5;
  double barrierXTwo = barrierXOne + 1.75; // 0.75

  int score = 0;
  int highScore = 0;

  bool gameStarted = false;

  Timer scoreTimer;

  void setInitialValues() {
    setState(() {
      gokberkYAxis = 0;
      time = 0;
      height = 0;
      initialHeight = gokberkYAxis;
      barrierXOne = -2.5;
      barrierXTwo = barrierXOne + 1.75;
      score = 0;
    });
  }

  Future<void> getHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt(HIGH_SCORE_KEY) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getHighScore();
    setInitialValues();
  }

  Future<void> showLoseDialog() async {
    await CoolAlert.show(
      context: context,
      type: CoolAlertType.info,
      title: 'Oyun Bitti!',
      text: score <= 3
          ? 'Bu kadar az da yapmazsın birader! Skor dersen bu: $score'
          : '$score kardeşim, yapıyorsun bu sporu!',
      confirmBtnText: 'Bir daha!',
      cancelBtnText: 'Bu kadar yeter.',
      confirmBtnColor: Colors.black,
      cancelBtnTextStyle: TextStyle(
        color: Colors.red[900],
      ),
      showCancelBtn: true,
      barrierDismissible: false,
      animType: CoolAlertAnimType.slideInUp,
      backgroundColor: Colors.grey,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        setInitialValues();
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  void jump() {
    setState(() {
      time = 0;
      initialHeight = gokberkYAxis;
    });
  }

  void startGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gameStarted = true;
    setState(() {
      gokberkYAxis = 0;
      time = 0;
      height = 0;
      initialHeight = gokberkYAxis;
      barrierXOne = -2.5;
      barrierXTwo = barrierXOne + 1.75;
      score = 0;
    });
    scoreTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (gameStarted) {
          setState(() {
            score++;
          });
        }
      },
    );
    Timer.periodic(Duration(milliseconds: 50), (timer) async {
      time += 0.05;
      height = -4.9 * time * time + 2.0 * time;
      setState(() {
        gokberkYAxis = initialHeight - height;
        if (barrierXOne > 2) {
          barrierXOne -= 3.5;
        } else {
          barrierXOne += 0.04;
        }
        if (barrierXTwo > 2) {
          barrierXTwo -= 3.5;
        } else {
          barrierXTwo += 0.04;
        }
      });
      if (gokberkYAxis > 1.1) {
        timer.cancel();
        scoreTimer.cancel();
        if (score > highScore) {
          highScore = score;
          await prefs.setInt(HIGH_SCORE_KEY, highScore);
        }
        setState(() {});
        gameStarted = false;
      }

      if (barrierXOne >= -0.25 && barrierXOne <= 0.25) {
        if (gokberkYAxis <= -0.2 || gokberkYAxis >= 0.6) {
          timer.cancel();
          scoreTimer.cancel();
          gameStarted = false;
          if (score > highScore) {
            highScore = score;
            await prefs.setInt(HIGH_SCORE_KEY, highScore);
          }
          setState(() {});
          await showLoseDialog();
        }
      }

      if (barrierXTwo >= -0.25 && barrierXTwo <= 0.25) {
        if (gokberkYAxis <= -0.6 || gokberkYAxis >= 0.2) {
          timer.cancel();
          scoreTimer.cancel();
          gameStarted = false;
          if (score > highScore) {
            highScore = score;
            await prefs.setInt(HIGH_SCORE_KEY, highScore);
          }
          setState(() {});
          showLoseDialog();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    upperbarrierOneHeight = screenHeight / 2.5;
    lowerBarrierOneHeight = screenHeight / 5;

    upperbarrierTwoHeight = screenHeight / 5;
    lowerBarrierTwoHeight = screenHeight / 2.5;
    return GestureDetector(
      onTap: () {
        if (gameStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedContainer(
              alignment: Alignment(0, gokberkYAxis),
              duration: Duration(milliseconds: 0),
              child: MyBird(),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/ovyea.png',
                  ),
                ),
              ),
            ),
            gameStarted
                ? Container()
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 120,
                        ),
                        Text('T I K L A Y A R A K     B A Ş L A',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.5, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
            AnimatedContainer(
              alignment: Alignment(barrierXOne, -1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: upperbarrierOneHeight,
              ),
            ),
            AnimatedContainer(
              alignment: Alignment(barrierXOne, 1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: lowerBarrierOneHeight,
              ),
            ),
            AnimatedContainer(
              alignment: Alignment(barrierXTwo, -1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: upperbarrierTwoHeight,
              ),
            ),
            AnimatedContainer(
              alignment: Alignment(barrierXTwo, 1.1),
              duration: Duration(seconds: 0),
              child: MyBarrier(
                size: lowerBarrierTwoHeight,
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                width: screenWidth / 2.5,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          score.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'G Ü N C E L\nS K O R'.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                width: screenWidth / 2.5,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          highScore.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'E N     İ Y İ\nS K O R'.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
