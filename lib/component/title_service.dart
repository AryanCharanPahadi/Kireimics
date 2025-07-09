import 'dart:html' as html;

class TitleService {
  static void setTitle(String title) {
    html.document.title = title;

    // Handle <meta name="title">
    final metaTitle =
        html.document.head!.querySelector("meta[name='title']")
            as html.MetaElement?;
    if (metaTitle != null) {
      metaTitle.content = title;
    } else {
      final newMeta =
          html.MetaElement()
            ..name = 'title'
            ..content = title;
      html.document.head!.append(newMeta);
    }
  }
}
