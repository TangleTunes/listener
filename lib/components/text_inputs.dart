import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener/utils/helper_widgets.dart';

import '../theme/theme_constants.dart';

// Widget usernameTextInput(
//     BuildContext context, TextEditingController controller) {
//   return Container(
//       width: 373,
//       //height: 56,
//       child: TextFormField(
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Required';
//           }
//           return null;
//         },
//         controller: controller,
//         decoration: InputDecoration(
//             errorStyle: TextStyle(
//               color: COLOR_TERTIARY,
//             ),
//             errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: COLOR_TERTIARY)),
//             focusedErrorBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.9),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.0),
//             ),
//             contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5.0),
//                 borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
//             filled: true,
//             fillColor: COLOR_SECONDARY,
//             hintText: 'Your username',
//             hintStyle: TextStyle(color: COLOR_PRIMARY, fontSize: 16)),
//       ));
// }

// Widget passwordTextInput(
//     BuildContext context, TextEditingController controller) {
//   return Container(
//       width: 372,
//       //height: 56,
//       child: TextFormField(
//         validator: (value) {
//           print(
//               "password is $value which is null or empty? ${value == null || value.isEmpty}");
//           if (value == null || value.isEmpty) {
//             return 'Required';
//           }
//           return null;
//         },
//         controller: controller,
//         obscureText: true,
//         decoration: InputDecoration(
//             errorStyle: TextStyle(
//               color: COLOR_TERTIARY,
//             ),
//             errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: COLOR_TERTIARY)),
//             focusedErrorBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.9),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.0),
//             ),
//             contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5.0),
//                 borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
//             filled: true,
//             fillColor: COLOR_SECONDARY,
//             hintText: 'Your password',
//             hintStyle: TextStyle(
//               color: COLOR_PRIMARY,
//               fontSize: 16,
//             )),
//       ));
// }

// Widget repeatPasswordTextInput(
//     BuildContext context, TextEditingController controller) {
//   return Container(
//       width: 372,
//       //height: 56,
//       child: TextFormField(
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Required';
//           }
//           return null;
//         },
//         controller: controller,
//         obscureText: true,
//         decoration: InputDecoration(
//             errorStyle: TextStyle(
//               color: COLOR_TERTIARY,
//             ),
//             errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: COLOR_TERTIARY)),
//             focusedErrorBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.9),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.0),
//             ),
//             contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5.0),
//                 borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
//             filled: true,
//             fillColor: COLOR_SECONDARY,
//             hintText: 'Repeat your password',
//             hintStyle: TextStyle(
//               color: COLOR_PRIMARY,
//               fontSize: 16,
//             )),
//       ));
// }

// Widget privateKeyTextInput(
//     BuildContext context, TextEditingController controller) {
//   return Container(
//       width: 373,
//       //height: 56,
//       child: TextFormField(
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Required';
//           }
//           return null;
//         },
//         controller: controller,
//         decoration: InputDecoration(
//             errorStyle: TextStyle(
//               color: COLOR_TERTIARY,
//             ),
//             errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: COLOR_TERTIARY)),
//             focusedErrorBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.9),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.0),
//             ),
//             contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5.0),
//                 borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
//             filled: true,
//             fillColor: COLOR_SECONDARY,
//             hintText: 'Your private key',
//             hintStyle: TextStyle(
//               color: COLOR_PRIMARY,
//               fontSize: 16,
//             )),
//       ));
// }

Widget createTextInput(BuildContext context, TextEditingController controller,
    String hint, bool isObscured) {
  return Container(
      width: 372,
      //height: 56,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
        controller: controller,
        obscureText: isObscured,
        decoration: InputDecoration(
            errorStyle: TextStyle(
              color: COLOR_TERTIARY,
            ),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: COLOR_TERTIARY)),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.9),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
            filled: true,
            fillColor: COLOR_SECONDARY,
            hintText: hint,
            hintStyle: TextStyle(
              color: COLOR_PRIMARY,
              fontSize: 16,
            )),
      ));
}
