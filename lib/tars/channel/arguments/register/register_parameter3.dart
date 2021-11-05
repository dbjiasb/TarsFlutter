import '../invoke/invoke_argument3.dart';
import '../invoke/invoke_argument.dart';
import 'register_parameter.dart';

class RegisterParameter3 extends RegisterParameter {
  late Object arg1;
  late Object arg2;
  late Object arg3;

  RegisterParameter3(this.arg1, this.arg2, this.arg3);

  @override
  InvokeArgument dispatchResult(List<Object> result) {
    return InvokeArgument3(result[0], result[1], result[2]);
  }

  @override
  List<Object> getMappingParameter() {
    return [arg1, arg2, arg3];
  }
}
