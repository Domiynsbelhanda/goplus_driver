import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../pages/AboutPage.dart';
import '../pages/HistoryPage.dart';
import '../pages/bodyPage.dart';

typedef T Constructor<T>();

final Map<String, Constructor<Object>> _constructors = <String, Constructor<Object>>{};

void register<T>(Constructor<T> constructor) {
  _constructors[T.toString()] = constructor as Constructor<Object>;
}

class ClassBuilder {
  static void registerClasses() {
    register<BodyPage>(() => BodyPage());
    register<AboutPage>(() => AboutPage());
    register<HistoryPage>(() => HistoryPage());
  }

  static dynamic fromString(String type) {
    if (_constructors[type] != null) return _constructors[type]!();
  }
}