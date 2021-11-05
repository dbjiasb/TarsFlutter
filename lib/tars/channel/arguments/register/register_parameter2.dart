
import '../invoke/invoke_argument2.dart';
import '../invoke/invoke_argument.dart';
import 'register_parameter.dart';

class RegisterParameter2 extends RegisterParameter {
  late Object arg1;
  late Object arg2;

  RegisterParameter2(this.arg1, this.arg2);

  @override
  InvokeArgument dispatchResult(List<Object> result) {
    return InvokeArgument2(result[0], result[1]);
  }

  @override
  List<Object> getMappingParameter() {
    return [this.arg1, arg2];
  }

}