import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:term_buddy/util/extensions.dart';
import 'package:term_buddy/logic.dart';
import 'package:term_buddy/models.dart';
import 'package:term_buddy/themes.dart';
import 'package:term_buddy/widgets/async_val_page.dart';
import 'package:term_buddy/widgets/help_button.dart';
import 'package:term_buddy/widgets/title.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../logic/history.dart';
import '../util/color_util.dart';
import '../util/util.dart';

final timeFilteredHistoryLineProvider =
    Provider<AsyncValue<List<HistoryLine>>>((ref) {
  final historyState = ref.watch(historyLineStateProvider);
  final timeFilterState = ref.watch(timeframeFilterProvider);
  final data = historyState.asData?.value;
  if (timeFilterState == FilterTimeFrame.all) {
    return historyState;
  }
  final timeCutOff = DateTime.now().subtract(timeFilterState.duration);
  if (data == null) {
    return const AsyncValue.loading();
  }
  final filteredData = data
      .where((element) =>
          element.time != null && element.time!.isAfter(timeCutOff))
      .toList(growable: false);

  return AsyncData(filteredData);
});

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(timeFilteredHistoryLineProvider);
    return AsyncValuePage(
      asyncValue: entries,
      builder: (context, data) {
        // Pie chart data
        final Map<String, int> points = {};

        for (var line in data) {
          final content = line.command.split(' ').first;
          final entry = points.putIfAbsent(content, () => 0);
          points[content] = entry + 1;
        }
        final entriesSorted = points.entries.toList()
          ..sort((a, b) => b.value - a.value);
        // final colorFactory = SequentialColorFactory(primaryDark.lerpStep(primary, 15).reversed.toList());
        final colorFactory = RandomColorFactory(paletteColors);

        final max = entriesSorted.fold(
            0, (previousValue, element) => previousValue + element.value);
        final dataPoints = entriesSorted
            .takeWhile((value) => value.value > max * 0.01)
            .map((e) => DataPoint(e.key, e.value, colorFactory.next()))
            .toList();
        dataPoints.sort((a, b) => b.count - a.count);

        // scatter chart data
        final WeekDayTimeDataMap<HistoryLine> weekDayTimeDataMap =
            WeekDayTimeDataMap(
                minuteInterval: _HistoryScatterChartState.interval);

        weekDayTimeDataMap.addAll(
            data, (historyLine) => historyLine.time ?? DateTime.now());

        return HistoryView(
            dataPoints: dataPoints, weekDayTimeDataMap: weekDayTimeDataMap);
      },
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.dataPoints,
    required this.weekDayTimeDataMap,
  });

  final List<DataPoint> dataPoints;
  final WeekDayTimeDataMap<HistoryLine> weekDayTimeDataMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleWidget(title: 'History', actions: [
                HelpButton(
                  delay: const Duration(seconds: 5),
                  richText: RichText(
                    text: TextSpan(
                        text:
                            'Visualizes your history based on your \$HISTFILE.\n',
                        children: [
                          const TextSpan(
                              text:
                                  'There are only timestamps in the history if you use ZSH, which I personally recommend. \n\n'),
                          TextSpan(
                              text: 'Check out this link\n\n',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => launchUrlString('https://sourabhbajaj.com/mac-setup/iTerm/zsh.html')),
                          const TextSpan(
                              text:
                                  'The pie chart shows the most used commands, the scatter chart shows the time of day you use them.\n'),
                          const TextSpan(
                              text:
                                  'The bar chart shows the time of day you use them on each day of the week.'),
                        ]),
                  ),
                )
              ]),
              const TimeFilterToggle(),
              const Divider(
                height: 1,
                thickness: 1,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 64.0),
            children: [
              const SubTitleWidget(title: 'Most Used Top Level Commands'),
              BasePieChart(data: dataPoints),
              const SubTitleWidget(title: 'Usage by Day of Week'),
              HistoryScatterChart(weekDayTimeDataMap)
            ],
          ),
        ),
      ],
    );
  }
}

enum FilterTimeFrame {
  all('All', Duration(days: 100 * 365)),
  // day('Day', Duration(days: 1)),
  week('Last Week', Duration(days: 7)),
  month('Last Month', Duration(days: 30)),
  year('Last Year', Duration(days: 365));

  final Duration duration;
  final String label;

  const FilterTimeFrame(
    this.label,
    this.duration,
  );
}

final timeframeFilterProvider = StateProvider<FilterTimeFrame>((ref) {
  return FilterTimeFrame.all;
});

class TimeFilterToggle extends ConsumerWidget {
  const TimeFilterToggle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timeframeFilterProvider);
    final showHistoryDisclaimer = !ref.watch(isExtendedHistoryEnabledProvider);

    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          bottom: showHistoryDisclaimer ? 16 : 24,
          left: 16.0,
          right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton(
            onSelectionChanged: (value) {
              ref.read(timeframeFilterProvider.notifier).state = value.first;
            },
            segments: FilterTimeFrame.values
                .map((e) => ButtonSegment(
                      label: Text(e.label),
                      value: e,
                    ))
                .toList(),
            selected: {filter},
          ),
          if (showHistoryDisclaimer)
            Center(
                child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 32,
                right: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: context.textTheme().labelMedium,
                      text:
                          'It looks like you don\'t have the extended history enabled, which is a zsh setting for tracking timestamps in addition to history commands. This way we can only show you the overall history without dedicated statistics for timeframes.',
                      children: [
                        TextSpan(
                            text:
                                '\nPlease take a look at URL if you want to enable this feature.',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // launch url
                              })
                      ]),
                ),
              ),
            )),
        ],
      ),
    );
  }
}

class DataNode<T> {
  final int day;
  final int timeInterval;
  final List<T> entries;

  DataNode(this.day, this.timeInterval, this.entries);
}

class WeekDayTimeDataMap<T> {
  final int minuteInterval;
  final Map<int, List<List<T>>> data = {};

  WeekDayTimeDataMap({this.minuteInterval = 30});

  void add(DateTime time, T value) {
    final weekDay = time.weekday;
    final day = data.putIfAbsent(
        weekDay, () => List.generate(24 * 60 ~/ minuteInterval, (index) => []));
    final index =
        time.hour * 60 ~/ minuteInterval + time.minute ~/ minuteInterval;
    day[index].add(value);
  }

  void addAll(Iterable<T> values, DateTime Function(T) timeGetter) {
    for (var value in values) {
      add(timeGetter(value), value);
    }
  }

  List<DataNode<T>> toNodes() {
    final nodes = <DataNode<T>>[];
    for (var entry in data.entries) {
      final day = entry.key;
      final dayData = entry.value;
      for (var i = 0; i < dayData.length; i++) {
        final timeInterval = i;
        final entries = dayData[i];
        nodes.add(DataNode(day, timeInterval, entries));
      }
    }
    return nodes;
  }

  @override
  String toString() {
    return 'WeekDayTimeDataMap{minuteInterval: $minuteInterval, data: $jsonEncode(data)}';
  }

  List<T> get(int day, int time) {
    return data[day]![time];
  }
}

class DataPoint {
  final String name;
  final int count;
  final Color color;

  DataPoint(this.name, this.count, [this.color = primary]);
}

class BasePieChart extends StatefulWidget {
  final List<DataPoint> data;

  const BasePieChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State<BasePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FractionallySizedBox(
          widthFactor: 0.5,
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: (context, constraints) {
              return PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event,
                        PieTouchResponse? pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: showingSections(widget.data, constraints.maxWidth),
                ),
              );
            }),
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            direction: Axis.horizontal,
            children: widget.data
                .map((e) => LegendEntry(
                      text: '${e.name} \n(${e.count})',
                      color: e.color,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(
      List<DataPoint> data, double width) {
    final radius = width / 2 - 16;
    return List.generate(
      data.length,
      (i) {
        final isTouched = i == touchedIndex;
        final opacity = isTouched ? 1.0 : 0.6;
        // type a backslash to get a backslash
        final name = data[i].name.replaceAll('\\', '\\\\');
        final color = data[i].color;
        return PieChartSectionData(
          color: color.withOpacity(opacity),
          value: data[i].count.toDouble(),
          title:
              isTouched ? '${data[i].name} \n(${data[i].count})' : data[i].name,
          radius: isTouched ? radius + 16.0 : radius,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isTouched ? Colors.black : color,
          ),
          titlePositionPercentageOffset: 0.75,
          badgePositionPercentageOffset: 0.8,
          // badgeWidget: Icon(Icons.star, color: Colors.white),
        );
      },
    );
  }
}

class HistoryScatterChart extends StatefulWidget {
  final WeekDayTimeDataMap<HistoryLine> data;

  const HistoryScatterChart(this.data, {super.key});

  @override
  State<StatefulWidget> createState() => _HistoryScatterChartState();
}

class _HistoryScatterChartState extends State<HistoryScatterChart> {
  int touchedIndex = -1;

  Color greyColor = Colors.grey;

  int? selectedSpot;

  static const interval = 30;

  @override
  Widget build(BuildContext context) {
    final maxEntries = widget.data.toNodes().fold<int>(0,
        (previousValue, element) => max(previousValue, element.entries.length));
    final titleStyle = context.textTheme().labelMedium;
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 64, top: 8, bottom: 12),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: AspectRatio(
          aspectRatio: 1.4,
          child: LayoutBuilder(builder: (context, constraints) {
            final maxRadius = MediaQuery.of(context).size.width * 0.03;
            return ScatterChart(
              ScatterChartData(
                scatterSpots: widget.data
                    .toNodes()
                    .map((e) {
                      if (e.entries.isEmpty) {
                        return null;
                      }
                      final radius = rescale(e.entries.length.toDouble(),
                          oldMax: maxEntries.toDouble(), newMax: maxRadius);
                      return ScatterSpot(
                          e.day.toDouble(), e.timeInterval.toDouble(),
                          radius: radius,
                          color: Color.lerp(
                              context.primary().withOpacity(0.6),
                              context.primary().withOpacity(0.8),
                              radius / maxRadius));
                    })
                    .whereNotNull()
                    .toList(),
                minX: 0.5,
                maxX: 7.5,
                minY: 0,
                maxY: 24 * 60 / interval,
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 4,
                  checkToShowHorizontalLine: (value) => value % 1 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.primary().withOpacity(0.4),
                  ),
                  drawVerticalLine: true,
                  checkToShowVerticalLine: (value) => value % 1 == 0,
                  getDrawingVerticalLine: (value) => FlLine(
                    color: context.primary().withOpacity(0.4),
                  ),
                ),
                titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final val = value % 1 == 0 ? value.toInt() : -1;

                          final day = val.toWeekday();
                          if (day.isNotEmpty) {
                            return Text(
                              day,
                              style: TextStyle(
                                color: context.primary(),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          (value.toInt() * interval)
                              .minutesToFormattedString(),
                          style: titleStyle,
                        );
                      },
                    ))),
                showingTooltipIndicators:
                    selectedSpot != null ? [selectedSpot!] : [],
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  mouseCursorResolver: (FlTouchEvent touchEvent,
                      ScatterTouchResponse? response) {
                    return response == null || response.touchedSpot == null
                        ? MouseCursor.defer
                        : SystemMouseCursors.click;
                  },
                  touchTooltipData: ScatterTouchTooltipData(
                    tooltipBgColor: Colors.black,
                    getTooltipItems: (ScatterSpot touchedBarSpot) {
                      final data = widget.data.get(
                          touchedBarSpot.x.toInt(), touchedBarSpot.y.toInt());
                      final time =
                          (touchedBarSpot.y.toInt().toInt() * interval)
                              .minutesToFormattedString();
                      final day =
                          (touchedBarSpot.x.toInt().toInt()).toWeekday();
                      return ScatterTooltipItem(
                        '$day $time \n',
                        textStyle: TextStyle(
                          height: 1.2,
                          color: Colors.grey[100],
                          fontStyle: FontStyle.italic,
                        ),
                        bottomMargin: 10,
                        children: [
                          TextSpan(
                            text: '${data.length} calls',
                            style: const TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event,
                      ScatterTouchResponse? touchResponse) {
                    if (touchResponse == null ||
                        touchResponse.touchedSpot == null) {
                      return;
                    }
                    if (event is FlTapUpEvent) {
                      final sectionIndex =
                          touchResponse.touchedSpot!.spotIndex;
                      setState(() {
                        selectedSpot =
                            selectedSpot == null ? sectionIndex : null;
                      });
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class LegendEntry extends StatelessWidget {
  final String text;
  final Color color;

  const LegendEntry({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.asSemiBold()
                  .copyWith(color: weakGrey)),
        ],
      ),
    );
  }
}
