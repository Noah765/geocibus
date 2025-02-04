import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWithLinks extends StatefulWidget {
  const TextWithLinks(this.text, {this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<TextWithLinks> createState() => _TextWithLinksState();
}

class _TextWithLinksState extends State<TextWithLinks> {
  late final List<_TextSegment> _segments;

  @override
  void initState() {
    super.initState();

    final links = RegExp(r'https:\/\/[\w./#-]+').allMatches(widget.text).toList();
    _segments = [
      if (widget.text.isNotEmpty && (links.isEmpty || links[0].start != 0)) _Text(widget.text.substring(0, links.isEmpty ? null : links[0].start)),
      for (final (i, link) in links.indexed) ...[
        _Link(widget.text.substring(link.start, link.end), gestureRecognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(widget.text.substring(link.start, link.end)))),
        if (i != links.length - 1 && link.end != links[i + 1].start) _Text(widget.text.substring(link.end, links[i + 1].start)),
      ],
      if (links.isNotEmpty && links.last.end < widget.text.length) _Text(widget.text.substring(links.last.end)),
    ];
  }

  @override
  void dispose() {
    for (final e in _segments) {
      if (e is _Link) e.gestureRecognizer.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      style: widget.style,
      textAlign: widget.textAlign,
      TextSpan(
        children: [
          for (final segment in _segments)
            switch (segment) {
              _Text() => TextSpan(text: segment.text),
              _Link() => TextSpan(
                  text: segment.text,
                  style: const TextStyle(color: Colors.lightBlue, decoration: TextDecoration.underline, decorationColor: Colors.lightBlue),
                  recognizer: segment.gestureRecognizer,
                ),
            },
        ],
      ),
    );
  }
}

sealed class _TextSegment {
  const _TextSegment();
}

class _Text extends _TextSegment {
  const _Text(this.text);

  final String text;
}

class _Link extends _TextSegment {
  const _Link(this.text, {required this.gestureRecognizer});

  final String text;
  final TapGestureRecognizer gestureRecognizer;
}
