import 'package:flutter/material.dart';

/// Widget de barra de búsqueda personalizada
class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final bool autofocus;
  final TextEditingController? controller;
  final List<String>? suggestions;
  final ValueChanged<String>? onSuggestionTap;

  const CustomSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSearch,
    this.onClear,
    this.autofocus = false,
    this.controller,
    this.suggestions,
    this.onSuggestionTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);

    if (widget.suggestions != null && widget.suggestions!.isNotEmpty) {
      setState(() {
        _filteredSuggestions = widget.suggestions!
            .where((s) => s.toLowerCase().contains(value.toLowerCase()))
            .take(5)
            .toList();
        _showSuggestions = value.isNotEmpty && _filteredSuggestions.isNotEmpty;
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSubmitted(String value) {
    setState(() {
      _showSuggestions = false;
    });
    if (widget.onSearch != null) {
      widget.onSearch!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: _onChanged,
                  onSubmitted: _onSubmitted,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Buscar...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.controller != null && widget.controller!.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller?.clear();
                    widget.onClear?.call();
                    _onChanged('');
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        // Sugerencias
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _filteredSuggestions.map((suggestion) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(suggestion),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      widget.onSuggestionTap?.call(suggestion);
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  ),
                  onTap: () {
                    widget.controller?.text = suggestion;
                    widget.onChanged?.call(suggestion);
                    if (widget.onSearch != null) {
                      widget.onSearch!(suggestion);
                    }
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
