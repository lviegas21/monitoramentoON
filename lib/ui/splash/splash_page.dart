import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      Get.offAllNamed("/home");
    });
    return Scaffold(
      backgroundColor: Colors.blue, // Define a cor de fundo como azul
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/monitora.png', // Certifique-se de ter a imagem na pasta 'assets'
              width: 200.0, // Defina o tamanho da imagem conforme necessário
              height: 200.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Monitoramento ON', // Substitua pelo nome da sua aplicação
              style: TextStyle(
                color: Colors.white, // Define a cor do texto como branco
                fontSize: 24.0, // Defina o tamanho da fonte conforme necessário
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const LinearProgressIndicator(
        backgroundColor: Colors.white, // Cor de fundo da barra de progresso
        valueColor: AlwaysStoppedAnimation<Color>(
            Colors.blue), // Cor da barra de progresso
      ),
    );
  }
}
