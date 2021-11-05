import '../invoke/invoke_argument0.dart';
import '../invoke/invoke_argument.dart';
import 'register_parameter.dart';

class RegisterParameter0 extends RegisterParameter {

  RegisterParameter0();

  @override
  InvokeArgument dispatchResult(List<Object?> result) {
    return InvokeArgument0();
  }

  @override
  List<Object> getMappingParameter() {
    return [];
  }

}