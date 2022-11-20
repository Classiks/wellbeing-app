import 'package:flutter/material.dart';

class NoDataForChartInfo extends StatelessWidget {
  const NoDataForChartInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No data points',
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}