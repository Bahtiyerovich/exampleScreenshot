import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  ScreenshotController screenshotController = ScreenshotController();

  String text = '';
  String subject = '';
  List<String> imagePaths = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 5.0),
                    color: Colors.amberAccent,
                  ),
                  child:
                      const Text("This widget will be captured as an image")),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              child: const Text('Capture Above Widget'),
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
            ElevatedButton(
              child: const Text('Capture An Invisible Widget'),
              onPressed: () {
                var container = Container(
                    padding: const EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 5.0),
                      color: Colors.redAccent,
                    ),
                    child: Text(
                      "This is an invisible widget",
                      style: Theme.of(context).textTheme.headline6,
                    ));
                screenshotController
                    .captureFromWidget(
                        InheritedTheme.captureAll(
                          context,
                          Material(child: container),
                        ),
                        delay: const Duration(seconds: 1))
                    .then((capturedImage) {
                  ShowCapturedWidget(context, capturedImage);
                });
              },
            ),
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
            const Padding(padding: EdgeInsets.only(top: 12.0)),
            Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: text.isEmpty && imagePaths.isEmpty
                      ? null
                      : () => _onShare(context),
                  child: const Text('Share'),
                );
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 12.0)),
            Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: text.isEmpty && imagePaths.isEmpty
                      ? null
                      : () => _onShareWithResult(context),
                  child: const Text('Share With Result'),
                );
              },
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
                // Image.memory(capturedImage)
                    // ? null
                    // : () => _onShare(context);
              },
            )
          ],
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  void _onDeleteImage(int position) {
    imagePaths.removeAt(position);
    setState(() {});
  }

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _onShareWithResult(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    ShareResult result;
    if (imagePaths.isNotEmpty) {
      result = await Share.shareFilesWithResult(imagePaths,
          text: text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      result = await Share.shareWithResult(text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Share result: ${result.status}"),
    ));
  }
}
