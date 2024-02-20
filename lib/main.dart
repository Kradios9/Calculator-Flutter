import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: MyBindings(),
      title: "Flutter Calculator",
      home: MainScreen(),
    );
  }
}
class MyBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalculateController());
    Get.lazyPut(() => ThemeController());
  }
}
class ThemeController extends GetxController {
  bool isDark = true;
  final switcherController = ValueNotifier<bool>(false);

  lightTheme() {
    isDark = false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    update();
  }

  darkTheme() {
    isDark = true;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    update();
  }

  @override
  void onInit() {
    switcherController.addListener(() {
      if (switcherController.value) {
        lightTheme();
      } else {
        darkTheme();
      }
    });
    super.onInit();
  }
}
class CalculateController extends GetxController {
  /*
  UserInput = What User entered with the keyboard .
  UserOutput = Calculate the numbers that the user entered and put into userOutPut variable.
  */
  var userInput = "";
  var userOutput = "";

  /// Equal Button Pressed Func
  equalPressed() {
    String userInputFC = userInput;
    userInputFC = userInputFC.replaceAll("x", "*");
    Parser p = Parser();
    Expression exp = p.parse(userInputFC);
    ContextModel ctx = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, ctx);

    userOutput = eval.toString();
    update();
  }

  /// Clear Button Pressed Func
  clearInputAndOutput() {
    userInput = "";
    userOutput = "";
    update();
  }

  /// Delete Button Pressed Func
  deleteBtnAction() {
    userInput = userInput.substring(0, userInput.length - 1);
    update();
  }

  /// on Number Button Tapped
  onBtnTapped(List<String> buttons, int index) {
    userInput += buttons[index];
    update();
  }
}
class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  final List<String> buttons = [
    "C",
    "DEL",
    "%",
    "/",
    "9",
    "8",
    "7",
    "x",
    "6",
    "5",
    "4",
    "-",
    "3",
    "2",
    "1",
    "+",
    "0",
    ".",
    "ANS",
    "=",
  ];

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CalculateController>();
    var themeController = Get.find<ThemeController>();

    return GetBuilder<ThemeController>(builder: (context) {
      return Scaffold(
        backgroundColor: themeController.isDark
            ? DarkColors.scaffoldBgColor
            : LightColors.scaffoldBgColor,
        body: Column(
          children: [
            GetBuilder<CalculateController>(builder: (context) {
              return outPutSection(themeController, controller);
            }),
            inPutSection(themeController, controller),
          ],
        ),
      );
    });
  }

  /// In put Section - Enter Numbers
  Widget inPutSection(
      ThemeController themeController, CalculateController controller) {
    return Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: themeController.isDark
                  ? DarkColors.sheetBgColor
                  : LightColors.sheetBgColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4),
              itemBuilder: (context, index) {
                switch (index) {
                /// CLEAR BTN
                  case 0:
                    return CustomAppButton(
                      buttonTapped: () {
                        controller.clearInputAndOutput();
                      },
                      color: themeController.isDark
                          ? DarkColors.leftOperatorColor
                          : LightColors.leftOperatorColor,
                      textColor: themeController.isDark
                          ? DarkColors.btnBgColor
                          : LightColors.btnBgColor,
                      text: buttons[index],
                    );

                /// DELETE BTN
                  case 1:
                    return CustomAppButton(
                        buttonTapped: () {
                          controller.deleteBtnAction();
                        },
                        color: themeController.isDark
                            ? DarkColors.leftOperatorColor
                            : LightColors.leftOperatorColor,
                        textColor: themeController.isDark
                            ? DarkColors.btnBgColor
                            : LightColors.btnBgColor,
                        text: buttons[index]);

                /// EQUAL BTN
                  case 19:
                    return CustomAppButton(
                        buttonTapped: () {
                          controller.equalPressed();
                        },
                        color: themeController.isDark
                            ? DarkColors.leftOperatorColor
                            : LightColors.leftOperatorColor,
                        textColor: themeController.isDark
                            ? DarkColors.btnBgColor
                            : LightColors.btnBgColor,
                        text: buttons[index]);

                  default:
                    return CustomAppButton(
                      buttonTapped: () {
                        controller.onBtnTapped(buttons, index);
                      },
                      color: isOperator(buttons[index])
                          ? LightColors.operatorColor
                          : themeController.isDark
                          ? DarkColors.btnBgColor
                          : LightColors.btnBgColor,
                      textColor: isOperator(buttons[index])
                          ? Colors.white
                          : themeController.isDark
                          ? Colors.white
                          : Colors.black,
                      text: buttons[index],
                    );
                }
              }),
        ));
  }

  /// Out put Section - Show Result
  Widget outPutSection(
      ThemeController themeController, CalculateController controller) {
    return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// theme switcher
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: GetBuilder<ThemeController>(builder: (controller) {
                return AdvancedSwitch(
                  controller: controller.switcherController,
                  activeImage: const AssetImage('assets/day_sky.png'),
                  inactiveImage: const AssetImage('assets/night_sky.jpg'),
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  activeChild: Text(
                    'Day',
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  inactiveChild: Text(
                    'Night',
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(1000)),
                  width: 100.0,
                  height: 45.0,
                  enabled: true,
                  disabledOpacity: 0.5,
                );
              }),
            ),

            /// Main Result - user input and output
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 70),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      controller.userInput,
                      style: GoogleFonts.ubuntu(
                          color:
                          themeController.isDark ? Colors.white : Colors.black,
                          fontSize: 38),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      controller.userOutput,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: themeController.isDark ? Colors.white : Colors.black,
                        fontSize: 60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  /// is Operator Check
  bool isOperator(String y) {
    if (y == "%" || y == "/" || y == "x" || y == "-" || y == "+" || y == "=") {
      return true;
    }
    return false;
  }
}
class CustomAppButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback buttonTapped;

  const CustomAppButton({
    Key? key,
    required this.color,
    required this.textColor,
    required this.text,
    required this.buttonTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttonTapped,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark Theme Colors
class DarkColors {
  static const scaffoldBgColor = Color(0xff22252D);
  static const sheetBgColor = Color(0xff292D36);
  static const btnBgColor = Color.fromARGB(255, 33, 36, 42);
  static const leftOperatorColor = Color.fromARGB(255, 7, 255, 209);
}

/// Light Them Colors
class LightColors {
  static const scaffoldBgColor = Color(0xffFFFFFF);
  static const sheetBgColor = Color(0xffF9F9F9);
  static const btnBgColor = Color.fromARGB(255, 243, 243, 243);
  static const operatorColor = Colors.deepPurpleAccent;
  static const leftOperatorColor = Color.fromARGB(255, 1, 157, 128);
}