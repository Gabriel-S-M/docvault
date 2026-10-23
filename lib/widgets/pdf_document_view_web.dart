import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PdfDocumentView extends StatelessWidget {
  final String url;

  const PdfDocumentView({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final iframe = element as web.HTMLIFrameElement;
        iframe
          ..src = url
          ..title = 'Visualização do documento PDF'
          ..style.border = '0'
          ..style.display = 'block'
          ..style.width = '100%'
          ..style.height = '100%';
      },
    );
  }
}
