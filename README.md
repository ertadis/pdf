# Pdf creation library for dart / flutter

This library is divided in two parts:

* a low-level Pdf creation library that takes care of the pdf bits generation.
* a Widgets system similar to Flutter's, for easy high-level Pdf creation.

It can create a full multi-pages document with graphics,
images and text using TrueType fonts. With the ease of use you already know.

<img alt="Example document" src="https://raw.githubusercontent.com/DavBfr/dart_pdf/master/pdf/example.jpg">

Use the `printing` package <https://pub.dartlang.org/packages/printing>
for full flutter print and share operation.

The coordinate system is using the internal Pdf unit:
 * 1.0 is defined as 1 / 72.0 inch
 * you can use the constants for centimeters, milimeters and inch defined in PdfPageFormat

Example:
```dart
final pdf = Document();

pdf.addPage(Page(
      pageFormat: PdfPageFormat.a4,
      build: (Context context) {
        return Center(
          child: Text("Hello World"),
        ); // Center
      })); // Page
```

To load an image it is possible to use the dart library [image](https://pub.dartlang.org/packages/image):

```dart
final img = decodeImage(File('test.webp').readAsBytesSync());
final image = PdfImage(
  pdf.document,
	image: img.data.buffer.asUint8List(),
	width: img.width,
	height: img.height,
);

pdf.addPage(Page(
    build: (Context context) {
      return Center(
        child: Image(image),
      ); // Center
    })); // Page
```

To use a TrueType font:

```dart
final Uint8List fontData = File('open-sans.ttf').readAsBytesSync();
final ttf = Font.ttf(fontData.buffer.asByteData());

pdf.addPage(Page(
    pageFormat: PdfPageFormat.a4,
    build: (Context context) {
      return Center(
        child: Text('Hello World', style: TextStyle(font: ttf, fontSize: 40)),
      ); // Center
    })); // Page
```

To save the pdf file:

```dart
// On Flutter, use the [path_provider](https://pub.dartlang.org/packages/path_provider) library:
//   final output = await getTemporaryDirectory();
//   final file = File("${output.path}/example.pdf");
final file = File("example.pdf");
await file.writeAsBytes(pdf.save());
```
