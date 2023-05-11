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

part of pdf;

class PdfColor {
  const PdfColor(this.red, this.green, this.blue, [this.alpha = 1.0])
      : assert(red >= 0 && red <= 1),
        assert(green >= 0 && green <= 1),
        assert(blue >= 0 && blue <= 1),
        assert(alpha >= 0 && alpha <= 1);

  const PdfColor.fromInt(int color)
      : red = (color >> 16 & 0xff) / 255.0,
        green = (color >> 8 & 0xff) / 255.0,
        blue = (color & 0xff) / 255.0,
        alpha = (color >> 24 & 0xff) / 255.0;

  factory PdfColor.fromHex(String color) {
    if (color.startsWith('#')) {
      color = color.substring(1);
    }
    return PdfColor(
        (int.parse(color.substring(0, 1), radix: 16) >> 16 & 0xff) / 255.0,
        (int.parse(color.substring(2, 3), radix: 16) >> 8 & 0xff) / 255.0,
        (int.parse(color.substring(4, 5), radix: 16) & 0xff) / 255.0,
        (int.parse(color.substring(6, 7), radix: 16) >> 24 & 0xff) / 255.0);
  }

  final double alpha;
  final double red;
  final double green;
  final double blue;

  int toInt() =>
      ((((alpha * 255.0).round() & 0xff) << 24) |
          (((red * 255.0).round() & 0xff) << 16) |
          (((green * 255.0).round() & 0xff) << 8) |
          (((blue * 255.0).round() & 0xff) << 0)) &
      0xFFFFFFFF;

  String toHex() => '#' + toInt().toRadixString(16);

  PdfColorCmyk toCmyk() {
    return PdfColorCmyk.fromRgb(red, green, blue, alpha);
  }

  PdfColorHsv toHsv() {
    return PdfColorHsv.fromRgb(red, green, blue, alpha);
  }

  PdfColorHsl toHsl() {
    return PdfColorHsl.fromRgb(red, green, blue, alpha);
  }

  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4);
  }

  double get luminance {
    final double R = _linearizeColorComponent(red);
    final double G = _linearizeColorComponent(green);
    final double B = _linearizeColorComponent(blue);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  /// Get a complementary color with hue shifted by -120°
  PdfColor get complementary => toHsv().complementary;

  /// Get some similar colors
  List<PdfColor> get monochromatic => toHsv().monochromatic;

  List<PdfColor> get splitcomplementary => toHsv().splitcomplementary;

  List<PdfColor> get tetradic => toHsv().tetradic;

  List<PdfColor> get triadic => toHsv().triadic;

  List<PdfColor> get analagous => toHsv().analagous;

  @override
  String toString() => '$runtimeType($red, $green, $blue, $alpha)';
}

class PdfColorCmyk extends PdfColor {
  const PdfColorCmyk(this.cyan, this.magenta, this.yellow, this.black,
      [double a = 1.0])
      : super((1.0 - cyan) * (1.0 - black), (1.0 - magenta) * (1.0 - black),
            (1.0 - yellow) * (1.0 - black), a);

  const PdfColorCmyk.fromRgb(double r, double g, double b, [double a = 1.0])
      : black = 1.0 - r > g ? r : g > b ? r > g ? r : g : b,
        cyan = (1.0 - r - (1.0 - r > g ? r : g > b ? r > g ? r : g : b)) /
            (1.0 - (1.0 - r > g ? r : g > b ? r > g ? r : g : b)),
        magenta = (1.0 - g - (1.0 - r > g ? r : g > b ? r > g ? r : g : b)) /
            (1.0 - (1.0 - r > g ? r : g > b ? r > g ? r : g : b)),
        yellow = (1.0 - b - (1.0 - r > g ? r : g > b ? r > g ? r : g : b)) /
            (1.0 - (1.0 - r > g ? r : g > b ? r > g ? r : g : b)),
        super(r, g, b, a);

  final double cyan;
  final double magenta;
  final double yellow;
  final double black;

  @override
  PdfColorCmyk toCmyk() {
    return this;
  }

  @override
  String toString() => '$runtimeType($cyan, $magenta, $yellow, $black, $alpha)';
}

double _getHue(
    double red, double green, double blue, double max, double delta) {
  double hue;
  if (max == 0.0) {
    hue = 0.0;
  } else if (max == red) {
    hue = 60.0 * (((green - blue) / delta) % 6);
  } else if (max == green) {
    hue = 60.0 * (((blue - red) / delta) + 2);
  } else if (max == blue) {
    hue = 60.0 * (((red - green) / delta) + 4);
  }

  /// Set hue to 0.0 when red == green == blue.
  hue = hue.isNaN ? 0.0 : hue;
  return hue;
}

/// Same as HSB, Cylindrical geometries with hue, their angular dimension,
/// starting at the red primary at 0°, passing through the green primary
/// at 120° and the blue primary at 240°, and then wrapping back to red at 360°
class PdfColorHsv extends PdfColor {
  factory PdfColorHsv(double hue, double saturation, double value,
      [double alpha = 1.0]) {
    final double chroma = saturation * value;
    final double secondary =
        chroma * (1.0 - (((hue / 60.0) % 2.0) - 1.0).abs());
    final double match = value - chroma;

    double red;
    double green;
    double blue;
    if (hue < 60.0) {
      red = chroma;
      green = secondary;
      blue = 0.0;
    } else if (hue < 120.0) {
      red = secondary;
      green = chroma;
      blue = 0.0;
    } else if (hue < 180.0) {
      red = 0.0;
      green = chroma;
      blue = secondary;
    } else if (hue < 240.0) {
      red = 0.0;
      green = secondary;
      blue = chroma;
    } else if (hue < 300.0) {
      red = secondary;
      green = 0.0;
      blue = chroma;
    } else {
      red = chroma;
      green = 0.0;
      blue = secondary;
    }

    return PdfColorHsv._(hue, saturation, value, red + match, green + match,
        blue + match, alpha);
  }

  const PdfColorHsv._(this.hue, this.saturation, this.value, double red,
      double green, double blue, double alpha)
      : assert(hue >= 0 && hue < 360),
        assert(saturation >= 0 && saturation <= 1),
        assert(value >= 0 && value <= 1),
        super(red, green, blue, alpha);

  factory PdfColorHsv.fromRgb(double red, double green, double blue,
      [double alpha = 1.0]) {
    final double max = math.max(red, math.max(green, blue));
    final double min = math.min(red, math.min(green, blue));
    final double delta = max - min;

    final double hue = _getHue(red, green, blue, max, delta);
    final double saturation = max == 0.0 ? 0.0 : delta / max;

    return PdfColorHsv._(hue, saturation, max, red, green, blue, alpha);
  }

  /// Angular position the colorspace coordinate diagram in degrees from 0° to 360°
  final double hue;

  /// Saturation of the color
  final double saturation;

  /// Brightness
  final double value;

  @override
  PdfColorHsv toHsv() {
    return this;
  }

  /// Get a complementary color with hue shifted by -120°
  @override
  PdfColorHsv get complementary =>
      PdfColorHsv((hue - 120) % 360, saturation, value, alpha);

  /// Get a similar color
  @override
  List<PdfColorHsv> get monochromatic => <PdfColorHsv>[
        PdfColorHsv(
            hue,
            (saturation > 0.5 ? saturation - 0.2 : saturation + 0.2)
                .clamp(0, 1),
            (value > 0.5 ? value - 0.1 : value + 0.1).clamp(0, 1)),
        PdfColorHsv(
            hue,
            (saturation > 0.5 ? saturation - 0.4 : saturation + 0.4)
                .clamp(0, 1),
            (value > 0.5 ? value - 0.2 : value + 0.2).clamp(0, 1)),
        PdfColorHsv(
            hue,
            (saturation > 0.5 ? saturation - 0.15 : saturation + 0.15)
                .clamp(0, 1),
            (value > 0.5 ? value - 0.05 : value + 0.05).clamp(0, 1))
      ];

  /// Get two complementary colors with hue shifted by -120°
  @override
  List<PdfColorHsv> get splitcomplementary => <PdfColorHsv>[
        PdfColorHsv((hue - 150) % 360, saturation, value, alpha),
        PdfColorHsv((hue - 180) % 360, saturation, value, alpha),
      ];

  @override
  List<PdfColorHsv> get triadic => <PdfColorHsv>[
        PdfColorHsv((hue + 80) % 360, saturation, value, alpha),
        PdfColorHsv((hue - 120) % 360, saturation, value, alpha),
      ];

  @override
  List<PdfColorHsv> get tetradic => <PdfColorHsv>[
        PdfColorHsv((hue + 120) % 360, saturation, value, alpha),
        PdfColorHsv((hue - 150) % 360, saturation, value, alpha),
        PdfColorHsv((hue + 60) % 360, saturation, value, alpha),
      ];

  @override
  List<PdfColorHsv> get analagous => <PdfColorHsv>[
        PdfColorHsv((hue + 30) % 360, saturation, value, alpha),
        PdfColorHsv((hue - 20) % 360, saturation, value, alpha),
      ];

  @override
  String toString() => '$runtimeType($hue, $saturation, $value, $alpha)';
}

class PdfColorHsl extends PdfColor {
  factory PdfColorHsl(double hue, double saturation, double lightness,
      [double alpha = 1.0]) {
    final double chroma = (1.0 - (2.0 * lightness - 1.0).abs()) * saturation;
    final double secondary =
        chroma * (1.0 - (((hue / 60.0) % 2.0) - 1.0).abs());
    final double match = lightness - chroma / 2.0;

    double red;
    double green;
    double blue;
    if (hue < 60.0) {
      red = chroma;
      green = secondary;
      blue = 0.0;
    } else if (hue < 120.0) {
      red = secondary;
      green = chroma;
      blue = 0.0;
    } else if (hue < 180.0) {
      red = 0.0;
      green = chroma;
      blue = secondary;
    } else if (hue < 240.0) {
      red = 0.0;
      green = secondary;
      blue = chroma;
    } else if (hue < 300.0) {
      red = secondary;
      green = 0.0;
      blue = chroma;
    } else {
      red = chroma;
      green = 0.0;
      blue = secondary;
    }
    return PdfColorHsl._(hue, saturation, lightness, alpha, red + match,
        green + match, blue + match);
  }

  const PdfColorHsl._(this.hue, this.saturation, this.lightness, double alpha,
      double red, double green, double blue)
      : super(red, green, blue, alpha);

  factory PdfColorHsl.fromRgb(double red, double green, double blue,
      [double alpha = 1.0]) {
    final double max = math.max(red, math.max(green, blue));
    final double min = math.min(red, math.min(green, blue));
    final double delta = max - min;

    final double hue = _getHue(red, green, blue, max, delta);
    final double lightness = (max + min) / 2.0;
    // Saturation can exceed 1.0 with rounding errors, so clamp it.
    final double saturation = lightness == 1.0
        ? 0.0
        : (delta / (1.0 - (2.0 * lightness - 1.0).abs())).clamp(0.0, 1.0);
    return PdfColorHsl._(hue, saturation, lightness, alpha, red, green, blue);
  }

  final double hue;
  final double saturation;
  final double lightness;

  @override
  PdfColorHsl toHsl() {
    return this;
  }

  @override
  String toString() => '$runtimeType($hue, $saturation, $lightness, $alpha)';
}
