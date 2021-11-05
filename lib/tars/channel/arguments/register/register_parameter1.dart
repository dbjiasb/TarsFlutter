import '../invoke/invoke_argument1.dart';
import '../invoke/invoke_argument.dart';
import 'register_parameter.dart';

class RegisterParameter1 extends RegisterParameter {
  late Object arg1;

  RegisterParameter1(this.arg1);

  @override
  InvokeArgument dispatchResult(List<Object> result) {
    return InvokeArgument1(result[0]);
  }

  @override
  List<Object> getMappingParameter() {
    return [arg1];
  }
}
