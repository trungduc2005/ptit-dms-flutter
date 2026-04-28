import 'package:flutter/material.dart';

class InternshipRegistrationPickerOption<T> {
  const InternshipRegistrationPickerOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

class InternshipRegistrationPickerField<T> extends StatefulWidget {
  const InternshipRegistrationPickerField({
    required this.hintText,
    required this.options,
    super.key,
    this.label = '',
    this.value,
    this.displayText,
    this.controller,
    this.onChanged,
    this.onQueryChanged,
    this.enabled = true,
    this.readOnly = false,
    this.isLoading = false,
    this.errorText,
    this.trailing,
    this.accentColor = const Color(0xFFADACB2),
    this.maxMenuHeight = 220,
  });

  final String label;
  final T? value;
  final String? displayText;
  final TextEditingController? controller;
  final List<InternshipRegistrationPickerOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<String>? onQueryChanged;
  final String hintText;
  final bool enabled;
  final bool readOnly;
  final bool isLoading;
  final String? errorText;
  final Widget? trailing;
  final Color accentColor;
  final double maxMenuHeight;

  @override
  State<InternshipRegistrationPickerField<T>> createState() =>
      _InternshipRegistrationPickerFieldState<T>();
}

class _InternshipRegistrationPickerFieldState<T>
    extends State<InternshipRegistrationPickerField<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(
    covariant InternshipRegistrationPickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled || widget.options.isEmpty) {
      _closeDropdown();
      return;
    }

    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openDropdown();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _closeDropdown(rebuild: false);
    super.dispose();
  }

  InternshipRegistrationPickerOption<T>? get _selectedOption {
    for (final option in widget.options) {
      if (option.value == widget.value) {
        return option;
      }
    }
    return null;
  }

  bool get _canOpenDropdown => widget.enabled && widget.options.isNotEmpty;

  void _handleFocusChanged() {
    if (_focusNode.hasFocus && _canOpenDropdown) {
      _openDropdown();
    }
  }

  void _handleQueryChanged(String value) {
    widget.onQueryChanged?.call(value);

    if (_canOpenDropdown) {
      _openDropdown();
    }
  }

  void _handleFieldTap() {
    if (!_canOpenDropdown) {
      return;
    }

    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _openDropdown();
  }

  void _openDropdown() {
    if (!_canOpenDropdown) {
      return;
    }

    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final fieldSize = renderBox.size;

    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

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
                        itemCount: widget.options.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFECECEC),
                        ),
                        itemBuilder: (context, index) {
                          final option = widget.options[index];
                          final isSelected = option.value == widget.value;

                          return Material(
                            color: isSelected
                                ? widget.accentColor.withValues(alpha: 0.08)
                                : Colors.white,
                            child: InkWell(
                              onTap: () {
                                widget.onChanged?.call(option.value);
                                _closeDropdown();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      option.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF1F1F1F),
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    if ((option.subtitle ?? '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        option.subtitle!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF757575),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ],
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

    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    } else {
      _isOpen = true;
    }
  }

  void _closeDropdown({bool rebuild = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (!_isOpen) {
      return;
    }

    if (mounted && rebuild) {
      setState(() {
        _isOpen = false;
      });
      return;
    }

    _isOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final errorText = widget.errorText?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.trim().isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _fieldKey,
            behavior: HitTestBehavior.opaque,
            onTap: _handleFieldTap,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFADACB2), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTextContent()),
                  if (widget.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (widget.trailing != null)
                    SizedBox(width: 40, height: 52, child: widget.trailing),
                ],
              ),
            ),
          ),
        ),
        if (errorText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextContent() {
    if (widget.controller != null) {
      return TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: _handleFieldTap,
        onChanged: _handleQueryChanged,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF757575),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          fillColor: Colors.transparent,
          filled: false,
        ),
        style: const TextStyle(
          color: Color(0xFF1F1F1F),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
      );
    }

    final displayText = widget.displayText?.trim().isNotEmpty ?? false
        ? widget.displayText!.trim()
        : _selectedOption?.label.trim() ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        displayText.isEmpty ? widget.hintText : displayText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: displayText.isEmpty
              ? const Color(0xFF757575)
              : const Color(0xFF1F1F1F),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
      ),
    );
  }
}
