import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_validation/src/blocs/provider.dart';
import 'package:form_validation/src/models/producto_model.dart';
import 'package:form_validation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey= GlobalKey<FormState>();
  final scaffoldkey= GlobalKey<ScaffoldState>();

  ProductosBloc productosBloc;

  ProductoModel producto = new ProductoModel();

  bool _guardando= false;
  File foto;

  @override
  Widget build(BuildContext context) {
    productosBloc= Provider.productosBloc(context);

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if(prodData != null){
      producto=prodData;
    }

    return Scaffold(
      key:scaffoldkey,
      appBar: AppBar(
        title:Text('Productos'),
        actions: <Widget> [
          IconButton(
           icon:Icon(Icons.photo_size_select_actual),
           onPressed: _seleccionarFoto,
          ),
          IconButton(
           icon:Icon(Icons.camera_alt),
           onPressed: _tomarFoto,
          ),
        ]
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            ),
          ),
        ),
      )
    );
  }

 Widget _crearNombre(){
   return TextFormField(
     initialValue: producto.titulo,
     textCapitalization: TextCapitalization.sentences,
     decoration: InputDecoration(
       labelText:'Producto'
     ),
     onSaved: (value)=>producto.titulo=value,
     validator: (value){
       if(value.length <3){
         return 'Ingrese el nombre del Producto';
       }else{
         return null;
       }
     },
   );
 }

 Widget _crearPrecio(){
   return TextFormField(
     initialValue: producto.valor.toString(),
     keyboardType: TextInputType.number,
     decoration: InputDecoration(
       labelText:'Precio'
     ),
     onSaved: (value)=>producto.valor=double.parse(value),
     validator: (value){
       if(utils.isNumeric(value)){
         return null;
       }else{
         return 'Solo números';
       }
     },
   );
 }

 Widget _crearDisponible(){
   return SwitchListTile(
     value: producto.disponible,
     title: Text('Disponible'),
     activeColor: Colors.deepPurple,
     onChanged: (value)=>setState((){
       producto.disponible = value;
     }),
   );
 }

  Widget _crearBoton(){
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      color: Colors.deepPurple,
      textColor: Colors.white,
      label: Text('Guardar'),
      icon:Icon(Icons.save),
      onPressed:(_guardando)? null : _submit,
    );
  }

  void _submit() async {
    if(!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState((){_guardando=true;});

    if(foto!= null){
      producto.fotoUrl= await productosBloc.subirFoto(foto);
    }

    if(producto.id ==null){
      productosBloc.agregarProductos(producto);
    }else{
      productosBloc.editarProductos(producto);
    }
    //setState((){_guardando=false;});
    mostrarSnackbar('Registro guardado');
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, 'home');
  }

  void mostrarSnackbar(String mensaje){
    final snackBar= SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );
    scaffoldkey.currentState.showSnackBar(snackBar);
    
  }

  Widget _mostrarFoto(){
    if (producto.fotoUrl != null){
      return FadeInImage(
        image: NetworkImage(producto.fotoUrl),
        placeholder: AssetImage('assets/jar-loading.gif'),
        height:300.0,
        fit: BoxFit.contain,
      );
    }else{
      return Image(
        image: AssetImage(foto?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover
      );
    }
  }

 _seleccionarFoto() async {
   /* final picker = ImagePicker();
   foto = (await picker.getImage(source: ImageSource.gallery)) as File;
   
   if (foto != null) {
     //limpieza
   }

   setState(() {}); */
   _procesarImagen(ImageSource.gallery);


 }

  
_tomarFoto() async {
  _procesarImagen(ImageSource.camera);
}

_procesarImagen(ImageSource origen)async {
  final picker = ImagePicker();
   final pickedFile = await picker.getImage(source: origen);
  foto = File(pickedFile.path);
      if(pickedFile != null){
        producto.fotoUrl=null;
      }
     
  setState(() {
      }); 
    
}

}