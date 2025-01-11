import 'package:flutter/material.dart';
import '../app/log_helper.dart';
import '../services/demo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _demoService = DemoService();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    Log.debug('HomePage initialized');
  }

  Future<void> _incrementCounter() async {
    // 使用性能监控包装操作
    await Log.measureAsync('increment_counter', () async {
      setState(() {
        _counter++;
        Log.info('Counter incremented to $_counter');
      });

      // 模拟一些业务逻辑
      if (_counter % 5 == 0) {
        await _demoService.performRiskyOperation();
      }

      if (_counter % 7 == 0) {
        await _demoService.fetchData();
      }
    });
  }

  void _showPerformanceMetrics() {
    Log.logMetrics();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performance metrics logged')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logger Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showPerformanceMetrics,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: $_counter'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _demoService.performRiskyOperation(),
              child: const Text('Trigger Error'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    Log.debug('HomePage disposed');
    super.dispose();
  }
}
