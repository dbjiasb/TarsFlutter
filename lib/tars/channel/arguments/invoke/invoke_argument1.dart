import 'dart:typed_data';

import 'invoke_argument.dart';

class InvokeArgument1 extends InvokeArgument {
  late Object arg1;

  InvokeArgument1(this.arg1);

  @override
  List<Object> getArguments() {
    return [arg1];
  }
}
