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
    this.enableLocalSearch = false,
    this.showDropdownButton = true,
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
  final bool enableLocalSearch;
  final bool showDropdownButton;
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
  TextEditingController? _localController;

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _initLocalController();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(
    covariant InternshipRegistrationPickerField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller ||
        oldWidget.enableLocalSearch != widget.enableLocalSearch) {
      _disposeLocalController();
      _initLocalController();
    }

    if (widget.enableLocalSearch &&
        widget.controller == null &&
        oldWidget.value != widget.value) {
      _syncLocalTextWithSelection();
    }

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
    _disposeLocalController();
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

  bool get _usesTextInput =>
      widget.controller != null || widget.enableLocalSearch;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _localController;

  List<InternshipRegistrationPickerOption<T>> get _visibleOptions {
    if (!widget.enableLocalSearch) {
      return widget.options;
    }

    final query = (_effectiveController?.text ?? '').trim().toLowerCase();
    final selectedLabel = _selectedOption?.label.trim().toLowerCase();

    if (query.isEmpty || query == selectedLabel) {
      return widget.options;
    }

    return widget.options
        .where((option) {
          final label = option.label.toLowerCase();
          final subtitle = option.subtitle?.toLowerCase() ?? '';
          return label.contains(query) || subtitle.contains(query);
        })
        .toList(growable: false);
  }

  void _initLocalController() {
    if (widget.controller != null || !widget.enableLocalSearch) {
      return;
    }

    _localController = TextEditingController(text: _currentDisplayText());
  }

  void _disposeLocalController() {
    _localController?.dispose();
    _localController = null;
  }

  String _currentDisplayText() {
    if (widget.displayText?.trim().isNotEmpty ?? false) {
      return widget.displayText!.trim();
    }

    return _selectedOption?.label.trim() ?? '';
  }

  void _syncLocalTextWithSelection() {
    final controller = _localController;
    if (controller == null || _focusNode.hasFocus) {
      return;
    }

    controller.text = _currentDisplayText();
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus && _canOpenDropdown) {
      _openDropdown();
    }
  }

  void _handleQueryChanged(String value) {
    final selectedLabel = _selectedOption?.label.trim() ?? '';
    if (widget.enableLocalSearch &&
        widget.value != null &&
        value.trim() != selectedLabel) {
      widget.onChanged?.call(null);
    }

    widget.onQueryChanged?.call(value);

    if (_canOpenDropdown) {
      _openDropdown();
      _overlayEntry?.markNeedsBuild();
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

  void _handleDropdownButtonPressed() {
    if (!_canOpenDropdown) {
      return;
    }

    if (_isOpen) {
      _closeDropdown();
      return;
    }

    _focusNode.requestFocus();
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
        final visibleOptions = _visibleOptions;

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
                      child: visibleOptions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Text(
                                'Không có kết quả phù hợp.',
                                style: TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: visibleOptions.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: Color(0xFFECECEC),
                                  ),
                              itemBuilder: (context, index) {
                                final option = visibleOptions[index];
                                final isSelected = option.value == widget.value;

                                return Material(
                                  color: isSelected
                                      ? widget.accentColor.withValues(
                                          alpha: 0.08,
                                        )
                                      : Colors.white,
                                  child: InkWell(
                                    onTap: () {
                                      widget.onChanged?.call(option.value);
                                      if (widget.enableLocalSearch &&
                                          widget.controller == null) {
                                        _localController?.text = option.label;
                                      }
                                      _closeDropdown();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
    final shouldShowDropdownButton =
        widget.trailing == null &&
        widget.showDropdownButton &&
        !widget.readOnly &&
        widget.options.isNotEmpty;

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
                  if (shouldShowDropdownButton)
                    SizedBox(
                      width: 40,
                      height: 52,
                      child: IconButton(
                        onPressed: widget.enabled
                            ? _handleDropdownButtonPressed
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        color: const Color(0xFF1F1F1F),
                        disabledColor: const Color(0xFF757575),
                        tooltip: 'Mở danh sách',
                      ),
                    ),
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
    if (_usesTextInput) {
      return TextField(
        controller: _effectiveController,
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
