import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Timer extends ConsumerWidget {
   Timer({super.key});
  final timmerProvider = StreamProvider<int>((ref) {
    return Stream.periodic( Duration(seconds: 1), (count) => count);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final timmer = ref.watch(timmerProvider);
    return timmer.when(
      data: (data) {
        return Center(
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.blue,
                      child: Text(
                        data.toString(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(onPressed: ()async{
                    ref.invalidate(timmerProvider);
                  }, child: Text('restart'))
                ],
              ),
            ),
          ),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
