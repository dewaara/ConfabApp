import 'package:flutter/material.dart';

class Dialogs {
  /* static void showSnackbar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(.8),
      behavior: SnackBarBehavior.floating,
    ));
  }*/

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }

  static void showSnackbar(BuildContext context, String msg) {
    SnackBar snackBar = SnackBar(
      content: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.withAlpha(90), width: 2),
            color: const Color(0xff0c2c63).withAlpha(20)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error, color: Colors.white),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Alert !',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    msg,
                    style: TextStyle(
                        color: Colors.black87.withOpacity(.5), fontSize: 14),
                  ),
                ],
              ),
            )),
            // InkWell(
            //   onTap: (){
            //
            //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
            //   },
            //   child: Container(
            //     width: 40,
            //     height: 40,
            //     child: Icon(Icons.close, color: Colors.black.withOpacity(.8),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 16),
      duration: const Duration(seconds: 2),
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
