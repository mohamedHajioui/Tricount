import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';
import 'package:prbd_2425_a07/views/pages/view_tricount.dart';

class TricountCard extends StatelessWidget {
  final Tricount tricount;

  const TricountCard({
    Key? key,
    required this.tricount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final participantCount = tricount.participants.length;
    final otherParticipants = participantCount - 1;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TricountView(tricountId: tricount.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tricount.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  otherParticipants > 0
                      ? 'il y a $otherParticipants participant${otherParticipants > 1 ? 's' : ''}'
                      : 'you are alone',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              (tricount.description?.trim().isEmpty ?? true) ? "No description" : tricount.description!,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              "by ${tricount.creatorName}",
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
