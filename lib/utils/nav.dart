import 'package:flutter/material.dart';

Future<T?> pushPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));
