import 'package:flutter/material.dart';
import 'package:listener13/theme/theme_constants.dart';
import 'package:listener13/utils/helper_widgets.dart';

Widget customListTile({String? title, String? singer, String? cover, onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              height: 80.0,
              width: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                //image: DecorationImage(image: NetworkImage(cover!))
              ),
            ),
            SizedBox(width: 10.0),
            Column(
              children: [
                Text(title!,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                SizedBox(height: 5.0),
                Text(
                  singer!,
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                )
              ],
            )
          ],
        )),
  );
}
