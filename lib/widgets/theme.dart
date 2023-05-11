/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of widget;

enum FontWeight { normal, bold }

enum FontStyle { normal, italic }

@immutable
class TextStyle {
  const TextStyle({
    this.inherit = true,
    this.color,
    Font font,
    Font fontNormal,
    Font fontBold,
    Font fontItalic,
    Font fontBoldItalic,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.lineSpacing,
    this.height,
    this.background,
  })  : assert(inherit || color != null),
        assert(inherit || font != null),
        assert(inherit || fontSize != null),
        assert(inherit || fontWeight != null),
        assert(inherit || fontStyle != null),
        assert(inherit || letterSpacing != null),
        assert(inherit || wordSpacing != null),
        assert(inherit || lineSpacing != null),
        assert(inherit || height != null),
        fontNormal = fontNormal ??
            (fontStyle != FontStyle.italic && fontWeight != FontWeight.bold
                ? font
                : null),
        fontBold = fontBold ??
            (fontStyle != FontStyle.italic && fontWeight == FontWeight.bold
                ? font
                : null),
        fontItalic = fontItalic ??
            (fontStyle == FontStyle.italic && fontWeight != FontWeight.bold
                ? font
                : null),
        fontBoldItalic = fontBoldItalic ??
            (fontStyle == FontStyle.italic && fontWeight == FontWeight.bold
                ? font
                : null);

  factory TextStyle.defaultStyle() {
    return TextStyle(
      color: PdfColors.black,
      fontNormal: Font.helvetica(),
      fontBold: Font.helveticaBold(),
      fontItalic: Font.helveticaOblique(),
      fontBoldItalic: Font.helveticaBoldOblique(),
      fontSize: _defaultFontSize,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      letterSpacing: 1.0,
      wordSpacing: 1.0,
      lineSpacing: 0.0,
      height: 1.0,
    );
  }

  final bool inherit;

  final PdfColor color;

  final Font fontNormal;

  final Font fontBold;

  final Font fontItalic;

  final Font fontBoldItalic;

  // font height, in pdf unit
  final double fontSize;

  /// The typeface thickness to use when painting the text (e.g., bold).
  final FontWeight fontWeight;

  /// The typeface variant to use when drawing the letters (e.g., italics).
  final FontStyle fontStyle;

  static const double _defaultFontSize = 12.0 * PdfPageFormat.point;

  // spacing between letters, 1.0 being natural spacing
  final double letterSpacing;

  // spacing between lines, in pdf unit
  final double lineSpacing;

  // spacing between words, 1.0 being natural spacing
  final double wordSpacing;

  final double height;

  final PdfColor background;

  TextStyle copyWith({
    PdfColor color,
    Font font,
    Font fontNormal,
    Font fontBold,
    Font fontItalic,
    Font fontBoldItalic,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    double lineSpacing,
    double height,
    PdfColor background,
  }) {
    return TextStyle(
      inherit: inherit,
      color: color ?? this.color,
      font: font ?? this.font,
      fontNormal: fontNormal ?? this.fontNormal,
      fontBold: fontBold ?? this.fontBold,
      fontItalic: fontItalic ?? this.fontItalic,
      fontBoldItalic: fontBoldItalic ?? this.fontBoldItalic,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      height: height ?? this.height,
      background: background ?? this.background,
    );
  }

  /// Creates a copy of this text style replacing or altering the specified
  /// properties.
  TextStyle apply({
    PdfColor color,
    Font font,
    Font fontNormal,
    Font fontBold,
    Font fontItalic,
    Font fontBoldItalic,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    double letterSpacingFactor = 1.0,
    double letterSpacingDelta = 0.0,
    double wordSpacingFactor = 1.0,
    double wordSpacingDelta = 0.0,
    double heightFactor = 1.0,
    double heightDelta = 0.0,
  }) {
    assert(fontSizeFactor != null);
    assert(fontSizeDelta != null);
    assert(fontSize != null || (fontSizeFactor == 1.0 && fontSizeDelta == 0.0));
    assert(letterSpacingFactor != null);
    assert(letterSpacingDelta != null);
    assert(letterSpacing != null ||
        (letterSpacingFactor == 1.0 && letterSpacingDelta == 0.0));
    assert(wordSpacingFactor != null);
    assert(wordSpacingDelta != null);
    assert(wordSpacing != null ||
        (wordSpacingFactor == 1.0 && wordSpacingDelta == 0.0));
    assert(heightFactor != null);
    assert(heightDelta != null);
    assert(heightFactor != null || (heightFactor == 1.0 && heightDelta == 0.0));

    return TextStyle(
      inherit: inherit,
      color: color ?? this.color,
      font: font ?? this.font,
      fontNormal: fontNormal ?? this.fontNormal,
      fontBold: fontBold ?? this.fontBold,
      fontItalic: fontItalic ?? this.fontItalic,
      fontBoldItalic: fontBoldItalic ?? this.fontBoldItalic,
      fontSize:
          fontSize == null ? null : fontSize * fontSizeFactor + fontSizeDelta,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing == null
          ? null
          : letterSpacing * letterSpacingFactor + letterSpacingDelta,
      wordSpacing: wordSpacing == null
          ? null
          : wordSpacing * wordSpacingFactor + wordSpacingDelta,
      height: height == null ? null : height * heightFactor + heightDelta,
      background: background,
    );
  }

  /// Returns a new text style that is a combination of this style and the given
  /// [other] style.
  TextStyle merge(TextStyle other) {
    if (other == null) {
      return this;
    }

    if (!other.inherit) {
      return other;
    }

    return copyWith(
      color: other.color,
      font: other.font,
      fontNormal: other.fontNormal,
      fontBold: other.fontBold,
      fontItalic: other.fontItalic,
      fontBoldItalic: other.fontBoldItalic,
      fontSize: other.fontSize,
      fontWeight: other.fontWeight,
      fontStyle: other.fontStyle,
      letterSpacing: other.letterSpacing,
      wordSpacing: other.wordSpacing,
      lineSpacing: other.lineSpacing,
      height: other.height,
      background: other.background,
    );
  }

  @Deprecated('use font instead')
  Font get paintFont => font;

  Font get font {
    if (fontWeight != FontWeight.bold) {
      if (fontStyle != FontStyle.italic) {
        // normal
        return fontNormal ?? fontBold ?? fontItalic ?? fontBoldItalic;
      } else {
        // italic
        return fontItalic ?? fontNormal ?? fontBold ?? fontBoldItalic;
      }
    } else {
      if (fontStyle != FontStyle.italic) {
        // bold
        return fontBold ?? fontNormal ?? fontItalic ?? fontBoldItalic;
      } else {
        // bold + italic
        return fontBoldItalic ?? fontBold ?? fontItalic ?? fontNormal;
      }
    }
  }

  @override
  String toString() =>
      'TextStyle(color:$color font:$font size:$fontSize weight:$fontWeight style:$fontStyle letterSpacing:$letterSpacing wordSpacing:$wordSpacing lineSpacing:$lineSpacing height:$height background:$background)';
}

@immutable
class Theme extends Inherited {
  const Theme({
    @required this.defaultTextStyle,
    @required this.paragraphStyle,
    @required this.header0,
    @required this.header1,
    @required this.header2,
    @required this.header3,
    @required this.header4,
    @required this.header5,
    @required this.bulletStyle,
    @required this.tableHeader,
    @required this.tableCell,
  });

  factory Theme.withFont({Font base, Font bold, Font italic, Font boldItalic}) {
    final TextStyle defaultStyle = TextStyle.defaultStyle().copyWith(
        font: base,
        fontBold: bold,
        fontItalic: italic,
        fontBoldItalic: boldItalic);
    final double fontSize = defaultStyle.fontSize;

    return Theme(
        defaultTextStyle: defaultStyle,
        paragraphStyle: defaultStyle.copyWith(lineSpacing: 5),
        bulletStyle: defaultStyle.copyWith(lineSpacing: 5),
        header0: defaultStyle.copyWith(fontSize: fontSize * 2.0),
        header1: defaultStyle.copyWith(fontSize: fontSize * 1.5),
        header2: defaultStyle.copyWith(fontSize: fontSize * 1.4),
        header3: defaultStyle.copyWith(fontSize: fontSize * 1.3),
        header4: defaultStyle.copyWith(fontSize: fontSize * 1.2),
        header5: defaultStyle.copyWith(fontSize: fontSize * 1.1),
        tableHeader: defaultStyle.copyWith(
            fontSize: fontSize * 0.8, fontWeight: FontWeight.bold),
        tableCell: defaultStyle.copyWith(fontSize: fontSize * 0.8));
  }

  factory Theme.base() => Theme.withFont();

  Theme copyWith({
    TextStyle defaultTextStyle,
    TextStyle paragraphStyle,
    TextStyle header0,
    TextStyle header1,
    TextStyle header2,
    TextStyle header3,
    TextStyle header4,
    TextStyle header5,
    TextStyle bulletStyle,
    TextStyle tableHeader,
    TextStyle tableCell,
  }) =>
      Theme(
          defaultTextStyle: defaultTextStyle ?? this.defaultTextStyle,
          paragraphStyle: paragraphStyle ?? this.paragraphStyle,
          bulletStyle: bulletStyle ?? this.bulletStyle,
          header0: header0 ?? this.header0,
          header1: header1 ?? this.header1,
          header2: header2 ?? this.header2,
          header3: header3 ?? this.header3,
          header4: header4 ?? this.header4,
          header5: header5 ?? this.header5,
          tableHeader: tableHeader ?? this.tableHeader,
          tableCell: tableCell ?? this.tableCell);

  static Theme of(Context context) {
    return context.inherited[Theme];
  }

  final TextStyle defaultTextStyle;

  final TextStyle paragraphStyle;

  final TextStyle header0;
  final TextStyle header1;
  final TextStyle header2;
  final TextStyle header3;
  final TextStyle header4;
  final TextStyle header5;

  final TextStyle bulletStyle;

  final TextStyle tableHeader;

  final TextStyle tableCell;
}
