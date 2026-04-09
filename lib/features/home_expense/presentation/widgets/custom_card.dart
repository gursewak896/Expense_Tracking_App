// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TaskProgressCard extends StatelessWidget {
//   final double progress; // 0.0 to 1.0
//   final VoidCallback onPressed;

//   const TaskProgressCard({
//     super.key,
//     required this.progress,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 132,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xFF6D5DF6),
//             Color(0xFF8E7CFF),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           /// LEFT SIDE TEXT
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Your today's task",
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 "almost done!",
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               /// BUTTON
//               SizedBox(
//                 height: 36,
//                 child: ElevatedButton(
//                   onPressed: onPressed,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white.withOpacity(0.95),
//                     foregroundColor: const Color(0xFF6D5DF6), // purple text
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 18,
//                       vertical: 0,
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     "View Task",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           /// RIGHT SIDE PROGRESS
//           SizedBox(
//             height: 60,
//             width: 60,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 /// Background circle
//                 SizedBox(
//                   height: 64,
//                   width: 64,
//                   child: CircularProgressIndicator(
//                     value: 1,
//                     strokeWidth: 5,
//                     valueColor: AlwaysStoppedAnimation(
//                       Colors.white.withOpacity(0.2),
//                     ),
//                   ),
//                 ),

//                 /// Progress circle
//                 SizedBox(
//                   height: 64,
//                   width: 64,
//                   child: CircularProgressIndicator(
//                     value: progress,
//                     strokeWidth: 5,
//                     strokeCap: StrokeCap.round,
//                     valueColor: const AlwaysStoppedAnimation(Colors.white),
//                   ),
//                 ),

//                 /// Percentage Text
//                 Text(
//                   "${(progress * 100).toInt()}%",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     // fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               IconButton(
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(), // remove min size
//                   onPressed: () {},
//                   icon: Container(
//                       decoration: ShapeDecoration(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6)),
//                           color: Colors.white.withOpacity(0.2)),
//                       child: const Icon(
//                         Icons.more_horiz,
//                         size: 18,
//                         color: Colors.white,
//                       ))),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
