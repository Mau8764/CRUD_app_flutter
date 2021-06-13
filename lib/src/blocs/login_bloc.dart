import 'dart:async';

import 'package:form_validation/src/blocs/validators.dart';

import 'package:rxdart/rxdart.dart';


class LoginBloc with Validators{

  final _emailController    = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  

  //Recuperar los datos del Steam
  Stream<String> get emailStream     => _emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream  => _passwordController.stream.transform(validarPassword);

  Stream<bool> get formValidStream   => 
      Rx.combineLatest2(emailStream, passwordStream,(e,p)=>true);


  //Insertar Valores al Stream

  Function(String) get changgeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  //Obtener el ultimo valor ingresado a los streams
  String get email=> _emailController.value; 
  String get password=> _passwordController.value;

  dispose(){
    _emailController?.close();
    _passwordController?.close();
  }

}