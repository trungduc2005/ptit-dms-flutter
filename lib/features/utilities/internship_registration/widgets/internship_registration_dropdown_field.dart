import 'package:flutter/material.dart';

class InternshipRegistrationDropdownField<T> extends StatefulWidget {
  const InternshipRegistrationDropdownField({
    required this.label,
    required this.items,
    required this.hintText,
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.accentColor = const Color(0xFFADACB2),
    this.maxMenuHeight = 220,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final bool enabled;
  final Color accentColor;
  final double maxMenuHeight;

  @override
  State<InternshipRegistrationDropdownField<T>> createState() =>
      _InternshipRegistrationDropdownFieldState<T>();
}

class _InternshipRegistrationDropdownFieldState<T>
    extends State<InternshipRegistrationDropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void didUpdateWidget(
    covariant InternshipRegistrationDropdownField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled && _isOpen) {
      _closeDropdown();
      return;
    }

    _overlayEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  DropdownMenuItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) {
        return item;
      }
    }
    return null;
  }

  void _toggleDropdown() {
    if (!widget.enabled || widget.items.isEmpty) {
      return;
    }

    if (_isOpen) {
      _closeDropdown();
      return;
    }

    _openDropdown();
  }

  void _openDropdown() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final fieldSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 8),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: fieldSize.width,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: widget.maxMenuHeight,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 24,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFECECEC),
                        ),
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isSelected = item.value == widget.value;

                          return Material(
                            color: isSelected
                                ? widget.accentColor.withValues(alpha: 0.08)
                                : Colors.white,
                            child: InkWell(
                              onTap: () {
                                widget.onChanged?.call(item.value);
                                _closeDropdown();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  child: item.child,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.enabled
        ? const Color(0xFFADACB2)
        : const Color(0xFFADACB2);

    final selectedItem = _selectedItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _fieldKey,
            onTap: _toggleDropdown,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: selectedItem != null
                        ? DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            child: selectedItem.child,
                          )
                        : Text(
                            widget.hintText,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
