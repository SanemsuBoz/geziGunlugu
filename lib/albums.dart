import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'db/dbPhoto.dart';
import 'models/photo.dart';
import 'models/utility.dart';

class Albums extends StatefulWidget {
  Albums() : super();

  final String title = "Albums";

  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  late Future<File> imageFile;
  late Image image;
  late DbPhoto dbPhoto;
  late List<Photo> images;

  @override
  void initState() {
    super.initState();
    images = [];
    dbPhoto = DbPhoto();
    refreshImages();
  }

  refreshImages() {
    dbPhoto.getPhotos().then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  pickImageFromGallery() async {
    final picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path) as Future<File>;
    Uint8List bytes = await pickedFile.readAsBytes();
    String imgString = new String.fromCharCodes(bytes);
    Photo photo = Photo(imgString);
    dbPhoto.insert(photo);
    refreshImages();
    /*ImagePicker imagePicker = new ImagePicker();
    imagePicker.getImage(source: ImageSource.gallery).then((imgFile) {
      String imgString = Utility.base64String(imgFile!.readAsBytesSync());
      Photo photo = Photo(imgString);
      dbPhoto.insert(photo);
      refreshImages();
    });*/
  }

  pickImageFromCamera() async {
    final picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.camera);
    imageFile = File(pickedFile!.path) as Future<File>;
    Uint8List bytes = await pickedFile.readAsBytes();
    String imgString = new String.fromCharCodes(bytes);
    Photo photo = Photo(imgString);
    dbPhoto.insert(photo);
    refreshImages();
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((photo) {
          return Utility.imageFromBase64String(photo.photoName);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: gridView(),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  IconButton(
                    color: Colors.blue,
                    icon: Icon(Icons.photo_library),
                    onPressed: () => pickImageFromGallery(),
                  ),
                  IconButton(
                    color: Colors.blue,
                    padding: EdgeInsets.only(left: 280),
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => pickImageFromCamera(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
