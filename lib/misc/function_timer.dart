typedef Future<Null> TimeFunction();

Future<Duration> time(String name, bool logTime, TimeFunction f) async {
  if(!logTime){
    await f();
    return Duration.zero;
  }
  print('$name Start');
  DateTime start = DateTime.now();
  await f();
  DateTime end = DateTime.now();
  print('$name Done ${end.difference(start).inMilliseconds}ms');
  return end.difference(start);
}
