import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'imageprev.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

const htmlData = """
    <!DOCTYPE html>
      <html>
      <body>

        <h1 style="color:blue;">Welcome to HTML app</h1>
        <p style="color:green;">This is a paragraph.</p>

      </body>
      </html>
    """;

class _HomePageState extends State<HomePage> {
  ScreenshotController screenshotController = ScreenshotController();
  List<String> imagePaths = [];
  String text = '';
  String subject = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_html Example')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Html(data: htmlData),
            ),

            // * SCREENSHOT BUTTON

            ElevatedButton(
              child: const Text('Screenshot'),
              onPressed: () {
                screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((capturedImage) async {
                  ShowCapturedWidget(context, capturedImage!);
                }).catchError((onError) {
                  print(onError);
                });
              },
            ),

            // * IMAGE PICKER

            ImagePreviews(imagePaths, onDelete: _onDeleteImage),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add image'),
              onTap: () async {
                final imagePicker = ImagePicker();
                final pickedFile = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setState(() {
                    imagePaths.add(pickedFile.path);
                  });
                }
              },
            ),

            //* SHARE BUTTON

            ElevatedButton(
              onPressed: text.isEmpty && imagePaths.isEmpty
                  ? null
                  : () => _onShare(context),
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Captured widget screenshot"),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                _onShare(context);
                setState(() {});
              },
            ),
          ],
        ),
        body: Center(
          child:
              capturedImage != null ? Image.memory(capturedImage) : Container(),
        ),
      ),
    );
  }

//image picker
  void _onDeleteImage(int position) {
    setState(() {
      imagePaths.removeAt(position);
    });
  }

//share
  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: 'image',
          subject: 'subject',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share('text',
          subject: 'subject',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }
}
