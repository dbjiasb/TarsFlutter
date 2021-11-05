
import 'invoke_argument.dart';

class InvokeArgument2 extends InvokeArgument {
  late Object arg1;
  late Object arg2;

  InvokeArgument2(this.arg1, this.arg2);

  @override
  List<Object> getArguments() {
    return [ arg1, arg2];
  }


}