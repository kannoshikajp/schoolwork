import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF131313),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF131313),
          surfaceContainerHigh: Color(0xFF2C2C2C),
          primary: Color(0xFF78C8FF),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayValue = '0';
  double? _firstOperand;
  String? _pendingOperator;
  bool _shouldResetDisplay = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (RegExp(r'^[0-9,]$').hasMatch(label)) {
        _handleNumberInput(label);
      } else if (label == '+' || label == '-' || label == 'x' || label == '÷') {
        _handleOperatorInput(label);
      } else if (label == '=') {
        _handleEqualsInput();
      } else if (label == 'C') {
        _clearAll();
      } else if (label == 'backspace') {
        _handleBackspace();
      }
    });
  }

  void _handleNumberInput(String label) {
    if (_shouldResetDisplay) {
      _displayValue = label == ',' ? '0,' : label;
      _shouldResetDisplay = false;
      return;
    }
    if (label == ',') {
      if (!_displayValue.contains(',')) _displayValue += ',';
    } else {
      _displayValue = _displayValue == '0' ? label : _displayValue + label;
    }
  }

  void _handleOperatorInput(String nextOperator) {
    final currentValue = _parseDisplayValue(_displayValue);

    if (_firstOperand != null &&
        _pendingOperator != null &&
        !_shouldResetDisplay) {
      final result = _calculate(
        _firstOperand!,
        currentValue,
        _pendingOperator!,
      );
      _displayValue = _formatValue(result);
      _firstOperand = result;
    } else {
      _firstOperand = currentValue;
    }

    _pendingOperator = nextOperator;
    _shouldResetDisplay = true;
  }

  void _handleEqualsInput() {
    if (_firstOperand != null && _pendingOperator != null) {
      final currentValue = _parseDisplayValue(_displayValue);
      final result = _calculate(
        _firstOperand!,
        currentValue,
        _pendingOperator!,
      );
      _displayValue = _formatValue(result);
      _firstOperand = null;
      _pendingOperator = null;
      _shouldResetDisplay = true;
    }
  }

  double _calculate(double a, double b, String op) => switch (op) {
    '+' => a + b,
    '-' => a - b,
    'x' => a * b,
    '÷' => b != 0 ? a / b : 0,
    _ => b,
  };

  double _parseDisplayValue(String text) =>
      double.tryParse(text.replaceAll(',', '.')) ?? 0.0;

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString().replaceAll('.', ',');

  void _clearAll() {
    _displayValue = '0';
    _firstOperand = null;
    _pendingOperator = null;
    _shouldResetDisplay = false;
  }

  void _handleBackspace() {
    if (_shouldResetDisplay) return;
    _displayValue = _displayValue.length > 1
        ? _displayValue.substring(0, _displayValue.length - 1)
        : '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            final studentHeader = const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '2424801030027-Trần Phạm Thanh Trung',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );

            final displayWidget = Column(
              mainAxisAlignment: isLandscape
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _pendingOperator ?? '',
                  style: TextStyle(
                    fontSize: isLandscape ? 28 : 32,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF78C8FF),
                  ),
                ),
                Text(
                  _displayValue,
                  style: TextStyle(
                    fontSize: isLandscape ? 60 : 72,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );

            final leftPanel = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                studentHeader,
                Expanded(
                  child: Container(
                    alignment: isLandscape
                        ? Alignment.topRight
                        : Alignment.bottomRight,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: isLandscape ? 8 : 16,
                    ),
                    child: displayWidget,
                  ),
                ),
              ],
            );

            final rightPanel = Padding(
              padding: EdgeInsets.all(isLandscape ? 8.0 : 12.0),
              child: _buildKeypad(buttonHeight: isLandscape ? 48 : 72),
            );

            return Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(child: leftPanel),
                if (isLandscape) Expanded(child: rightPanel) else rightPanel,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypad({required double buttonHeight}) {
    const rows = [
      ['0', 'C', ',', 'backspace'],
      ['7', '8', '9', '÷'],
      ['4', '5', '6', 'x'],
      ['1', '2', '3', '-'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows) ...[
          _buildRow(row, buttonHeight),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: buttonHeight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _onButtonPressed('='),
                  child: const Text(
                    '=',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildButton('+', buttonHeight)),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> labels, double buttonHeight) {
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildButton(label, buttonHeight),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildButton(String label, double buttonHeight) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: buttonHeight,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHigh,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _onButtonPressed(label),
        child: label == 'backspace'
            ? const Icon(Icons.backspace_outlined, size: 22)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}
