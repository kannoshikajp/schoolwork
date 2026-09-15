import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Calculator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1C1C1C),
          surfaceContainerHigh: Color(0xFF2D2D2D),
          primary: Color(0xFF4CA6FE),
          onPrimary: Colors.white,
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
  double _memoryRegister = 0.0;
  final List<String> _history = [];

  void _onButtonPressed(String label) {
    setState(() {
      if (RegExp(r'^[0-9,]$').hasMatch(label)) {
        _handleNumberInput(label);
      } else if (['+', '-', 'x', '÷'].contains(label)) {
        _handleOperatorInput(label);
      } else if (label == '=') {
        _handleEqualsInput();
      } else if (label == 'C') {
        _clearAll();
      } else if (label == 'CE') {
        _clearEntry();
      } else if (label == 'backspace') {
        _handleBackspace();
      } else if (['1/x', 'x²', '√x', '%', '+/-'].contains(label)) {
        _handleUnaryFunction(label);
      } else if (['M+', 'M-', 'MS'].contains(label)) {
        _handleMemoryAction(label);
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

    if (_firstOperand != null && _pendingOperator != null && !_shouldResetDisplay) {
      final result = _calculate(_firstOperand!, currentValue, _pendingOperator!);
      _history.add('${_formatValue(_firstOperand!)} $_pendingOperator ${_formatValue(currentValue)} = ${_formatValue(result)}');
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
      final result = _calculate(_firstOperand!, currentValue, _pendingOperator!);
      _history.add('${_formatValue(_firstOperand!)} $_pendingOperator ${_formatValue(currentValue)} = ${_formatValue(result)}');
      _displayValue = _formatValue(result);
      _firstOperand = null;
      _pendingOperator = null;
      _shouldResetDisplay = true;
    }
  }

  void _handleUnaryFunction(String op) {
    final val = _parseDisplayValue(_displayValue);
    double res = val;

    switch (op) {
      case '1/x':
        if (val != 0) res = 1 / val;
        _history.add('1/(${_formatValue(val)}) = ${_formatValue(res)}');
        break;
      case 'x²':
        res = val * val;
        _history.add('sqr(${_formatValue(val)}) = ${_formatValue(res)}');
        break;
      case '√x':
        if (val >= 0) res = math.sqrt(val);
        _history.add('√(${_formatValue(val)}) = ${_formatValue(res)}');
        break;
      case '%':
        res = val / 100;
        break;
      case '+/-':
        res = -val;
        break;
    }

    _displayValue = _formatValue(res);
    _shouldResetDisplay = true;
  }

  void _handleMemoryAction(String action) {
    final val = _parseDisplayValue(_displayValue);
    if (action == 'M+') _memoryRegister += val;
    if (action == 'M-') _memoryRegister -= val;
    if (action == 'MS') _memoryRegister = val;
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

  void _clearEntry() {
    _displayValue = '0';
  }

  void _handleBackspace() {
    if (_shouldResetDisplay) return;
    _displayValue = _displayValue.length > 1
        ? _displayValue.substring(0, _displayValue.length - 1)
        : '0';
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lịch sử tính toán',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _history.clear());
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: _history.isEmpty
                    ? const Center(child: Text('Chưa có lịch sử'))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              _history[index],
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistorySheet,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '2424801030027-Trần Phạm Thanh Trung',
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _pendingOperator ?? '',
                      style: const TextStyle(fontSize: 28, color: Color(0xFF78C8FF)),
                    ),
                    Text(
                      _displayValue,
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            _buildMemoryRow(),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['M+', 'M-', 'MS'].map((label) {
          return TextButton(
            onPressed: () => _onButtonPressed(label),
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypad() {
    const grid = [
      ['%', 'CE', 'C', 'backspace'],
      ['1/x', 'x²', '√x', '÷'],
      ['7', '8', '9', 'x'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', ',', '='],
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: grid.map((row) {
          return Row(
            children: row.map((label) {
              final isAccent = label == '=';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isAccent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHigh,
                        foregroundColor: isAccent ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _onButtonPressed(label),
                      child: label == 'backspace'
                          ? const Icon(Icons.backspace_outlined, size: 20)
                          : Text(
                              label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isAccent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}