import "package:flutter/material.dart";
import "package:intl/intl.dart";

Widget buildStepCard(String step) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        step,
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}

Widget buildInfoCard(String infoName, String infoValue) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            infoValue,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

// Widget buildCustomListTile(DateTime date) {
//   return Column(
//     children: [
//       ListTile(
//         title: Text(
//           date.toLocal().toString(),
//         ),
//       ),
//       const Divider(
//         indent: 16,
//         endIndent: 16,
//       ),
//     ],
//   );
// }

Widget buildCustomListTile(DateTime date) {
  final formattedDate =
      DateFormat("EEEE, MMM d, yyyy - h:mm a").format(date.toLocal());

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Column(
      children: [
        ListTile(
          title: Text(
            formattedDate,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
        const Divider(
          indent: 16,
          endIndent: 16,
          thickness: 1,
        ),
      ],
    ),
  );
}

Widget buildSummaryCard({
  required String title,
  required String count,
  required String date,
  required String timeRange,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$date • $timeRange",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
