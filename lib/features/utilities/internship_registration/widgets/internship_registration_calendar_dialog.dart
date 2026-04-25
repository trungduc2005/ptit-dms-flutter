import 'package:flutter/material.dart';

Future<DateTime?> showInternshipCalendarDialog({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime selectableFirstDate,
  required DateTime selectableLastDate,
  DateTime? navigationFirstMonth,
  DateTime? navigationLastMonth,
}) {
  final normalizedInitial = _dateOnly(initialDate);
  final normalizedSelectableFirst = _dateOnly(selectableFirstDate);
  final normalizedSelectableLast = _dateOnly(selectableLastDate);

  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _InternshipCalendarDialog(
      initialDate: normalizedInitial,
      selectableFirstDate: normalizedSelectableFirst,
      selectableLastDate: normalizedSelectableLast,
      navigationFirstMonth: _monthOnly(
        navigationFirstMonth ??
            DateTime(normalizedInitial.year, normalizedInitial.month - 12),
      ),
      navigationLastMonth: _monthOnly(
        navigationLastMonth ??
            DateTime(normalizedInitial.year, normalizedInitial.month + 12),
      ),
    ),
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _monthOnly(DateTime value) {
  return DateTime(value.year, value.month);
}

class _InternshipCalendarDialog extends StatefulWidget {
  const _InternshipCalendarDialog({
    required this.initialDate,
    required this.selectableFirstDate,
    required this.selectableLastDate,
    required this.navigationFirstMonth,
    required this.navigationLastMonth,
  });

  final DateTime initialDate;
  final DateTime selectableFirstDate;
  final DateTime selectableLastDate;
  final DateTime navigationFirstMonth;
  final DateTime navigationLastMonth;

  @override
  State<_InternshipCalendarDialog> createState() =>
      _InternshipCalendarDialogState();
}

class _InternshipCalendarDialogState extends State<_InternshipCalendarDialog> {
  static const List<String> _weekdayLabels = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const TextStyle _monthTitleStyle = TextStyle(
    color: Color(0xFF333333),
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _weekdayStyle = TextStyle(
    color: Color(0xFF333333),
    fontSize: 19,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _dayStyle = TextStyle(
    color: Color(0xFF666666),
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _selectedDayStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _disabledDayStyle = TextStyle(
    color: Color(0xFFC7CDD4),
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  late DateTime _selectedDate;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  bool get _canGoPreviousMonth {
    return _visibleMonth.isAfter(widget.navigationFirstMonth);
  }

  bool get _canGoNextMonth {
    return _visibleMonth.isBefore(widget.navigationLastMonth);
  }

  String get _monthLabel {
    return '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}';
  }

  int get _leadingEmptySlots {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    return firstDayOfMonth.weekday - 1;
  }

  int get _daysInMonth {
    return DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
  }

  void _goToPreviousMonth() {
    if (!_canGoPreviousMonth) return;
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    if (!_canGoNextMonth) return;
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDisabled(DateTime day) {
    return day.isBefore(widget.selectableFirstDate) ||
        day.isAfter(widget.selectableLastDate);
  }

  @override
  Widget build(BuildContext context) {
    final totalSlots = _leadingEmptySlots + _daysInMonth;
    final trailingEmptySlots = (7 - (totalSlots % 7)) % 7;
    final itemCount = totalSlots + trailingEmptySlots;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x07AAAAAA),
              blurRadius: 32,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(_monthLabel, style: _monthTitleStyle)),
                _CalendarNavButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: _canGoPreviousMonth,
                  onTap: _goToPreviousMonth,
                ),
                const SizedBox(width: 4),
                _CalendarNavButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: _canGoNextMonth,
                  onTap: _goToNextMonth,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: _weekdayLabels
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: _weekdayStyle,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index < _leadingEmptySlots ||
                    index >= _leadingEmptySlots + _daysInMonth) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - _leadingEmptySlots + 1;
                final day = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  dayNumber,
                );

                final isSelected = _isSameDate(day, _selectedDate);
                final isDisabled = _isDisabled(day);

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => Navigator.of(context).pop(day),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: isSelected
                          ? const BoxDecoration(
                              color: Color(0xFFFA3E49),
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isDisabled
                              ? const Color(0xFFC7CDD4)
                              : const Color(0xFF666666),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        padding: EdgeInsets.zero,
        splashRadius: 18,
        iconSize: 20,
        icon: Icon(
          icon,
          color: enabled ? const Color(0xFF333333) : const Color(0xFFC7CDD4),
        ),
      ),
    );
  }
}
