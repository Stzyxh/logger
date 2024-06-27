import 'package:call_log/call_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/screens/About/about.dart';
import 'package:logger/screens/Analytics/analytics.dart';
import 'package:logger/screens/Home/home.dart';
import 'package:logger/screens/manager.dart';
import 'package:logger/utils/filters.dart';

class ApplicationUi extends StatefulWidget {
  final Future<void> Function() refresher;
  const ApplicationUi({
    super.key,
    required this.entries,
    required this.refresher,
  });

  final Iterable<CallLogEntry>? entries;

  @override
  State<ApplicationUi> createState() => _ApplicationUiState();
}

class _ApplicationUiState extends State<ApplicationUi> {
  late Iterable<CallLogEntry>? currentLogs;
  bool isProcessing = false;

  // Logs filters
  Map logFilters = {
    "specific_ph": false,
    "phone_to_match": "",
    "selected_call_types": [...CallType.values],
    "date_range_op": "All Time",
    "start_date": DateTime.now(),
    "end_date": DateTime.now()
  };

  void filterLogs(Map filters) async {
    var callTypes = filters["selected_call_types"] as List<CallType>;
    var phoneToMatch = filters["phone_to_match"] as String;
    var shouldUseSpecificPhoneNumber = filters["specific_ph"] as bool;
    var dateRangeOption = filters["date_range_op"] as String;
    var startDate = filters["start_date"] as DateTime;
    var endDate = filters["end_date"] as DateTime;

    setState(() {
      isProcessing = true;
      logFilters["start_date"] = startDate;
      logFilters["end_date"] = endDate;
      logFilters["date_range_op"] = dateRangeOption;
      logFilters["specific_ph"] = shouldUseSpecificPhoneNumber;
      logFilters["phone_to_match"] = phoneToMatch;
      logFilters["selected_call_types"] = callTypes;
    });

    var filteredLogs = await fetchFilteredLogs();
    setState(() {
      currentLogs = filteredLogs;
      isProcessing = false;
    });
  }

  Future<Iterable<CallLogEntry>> fetchFilteredLogs() {
    return compute(getFilteredLogs, {
      "logs": currentLogs,
      "filters": logFilters,
    });
  }

  void removeLogFilters() {
    setState(() {
      logFilters = {
        "specific_ph": false,
        "phone_to_match": "",
        "selected_call_types": [...CallType.values],
        "date_range_op": "All Time",
        "start_date": DateTime.now(),
        "end_date": DateTime.now()
      };
      currentLogs = widget.entries;
    });
  }

  @override
  void initState() {
    super.initState();
    currentLogs = widget.entries;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScreenManager(
          initialIndex: 1,
          currentFilters: logFilters,
          logs: currentLogs,
          filterLogs: filterLogs,
          removeLogFilters: removeLogFilters,
          items: <Screen>[
            Screen(
              index: 0,
              label: "Logs",
              icon: Icons.call_outlined,
              selectedIcon: Icons.call,
              screen: HomeScreen(
                entries: currentLogs,
                refreshEntries: widget.refresher,
              ),
            ),
            Screen(
              index: 1,
              label: "Analytics",
              icon: Icons.pie_chart_outline,
              selectedIcon: Icons.pie_chart,
              screen: AnalyticsScreen(
                entries: currentLogs,
              ),
            ),
            const Screen(
              label: "About",
              index: 2,
              icon: Icons.info,
              selectedIcon: Icons.info,
              screen: AboutScreen(),
            ),
          ],
        ),
        if (isProcessing)
          Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator())),
      ],
    );
  }
}