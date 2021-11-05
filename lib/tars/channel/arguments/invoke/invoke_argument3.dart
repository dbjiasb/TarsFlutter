
import 'invoke_argument.dart';

class InvokeArgument3 extends InvokeArgument {
  late Object arg1;
  late Object arg2;
  late Object arg3;

  InvokeArgument3(this.arg1, this.arg2, this.arg3);

  @override
  List<Object> getArguments() {
    return [ arg1, arg2, arg3];
  }


}