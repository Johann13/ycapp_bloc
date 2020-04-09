typedef Future<Null> TimeFunction();

Future<Duration> time(String name, TimeFunction f) async {
  print('$name Start');
  DateTime start = DateTime.now();
  await f();
  DateTime end = DateTime.now();
  print('$name Done ${end.difference(start).inMilliseconds}ms');
  return end.difference(start);
}
