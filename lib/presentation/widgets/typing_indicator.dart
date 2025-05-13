import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color dotColor;
  
  const TypingIndicator({
    Key? key,
    this.dotColor = const Color(0xFF6495ED),
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation1 = Tween<double>(begin: 0, end: 6).animate(_controller1);
    _animation2 = Tween<double>(begin: 0, end: 6).animate(_controller2);
    _animation3 = Tween<double>(begin: 0, end: 6).animate(_controller3);
    
    // Delayed start for second and third dots
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller2.repeat(reverse: true);
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation1,
          builder: (context, child) => _buildDot(_animation1.value),
        ),
        const SizedBox(width: 4),
        AnimatedBuilder(
          animation: _animation2,
          builder: (context, child) => _buildDot(_animation2.value),
        ),
        const SizedBox(width: 4),
        AnimatedBuilder(
          animation: _animation3,
          builder: (context, child) => _buildDot(_animation3.value),
        ),
      ],
    );
  }

  Widget _buildDot(double height) {
    return Container(
      width: 6,
      height: 6 + height,
      decoration: BoxDecoration(
        color: widget.dotColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}