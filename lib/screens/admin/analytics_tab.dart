import 'package:flutter/material.dart';

class AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.show_chart, color: Color(0xFF2E7D32)),
                      title: Text('Sales Data'),
                      subtitle: Text('View detailed sales data'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to sales data screen
                      },
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.pie_chart, color: Color(0xFF2E7D32)),
                      title: Text('User Engagement'),
                      subtitle: Text('View user engagement metrics'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to user engagement screen
                      },
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.bar_chart, color: Color(0xFF2E7D32)),
                      title: Text('Revenue Reports'),
                      subtitle: Text('View revenue reports'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to revenue reports screen
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}