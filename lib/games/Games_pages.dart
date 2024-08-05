import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'games_page.dart';
import 'games_page2.dart';

class Games_menu extends StatelessWidget{
  Games_menu({super.key});
  final PageController controller = PageController();

  @override

  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/screen_bg.png'
          ),
          fit: BoxFit.cover
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: controller,
          children: [
            Games_menu1(),
            Games_menu2()
          ],
        ),
      ),
    );
  }
}