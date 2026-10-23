import 'package:flutter/material.dart';

class PdfDocumentView extends StatelessWidget {
  const PdfDocumentView({super.key, required String url});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'A pré-visualização integrada do PDF está disponível na versão web. '
          'Use o botão de abrir para visualizar o arquivo.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
