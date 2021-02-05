import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:documentscanner2/Home.dart';
import 'package:documentscanner2/Providers/documentProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class ShowImage extends StatefulWidget {
  File file;
  var imagePixelSize;
  double width;
  double height;
  Offset tl, tr, bl, br;
  GlobalKey<AnimatedListState> animatedListKey;
  ShowImage(
      {this.file,
      this.bl,
      this.br,
      this.tl,
      this.height,
      this.tr,
      this.imagePixelSize,
      this.width,
      this.animatedListKey});

  @override
  _ShowImageState createState() => _ShowImageState();
}

String dropdownValue;

List<String> spinnerItems = ['One', 'Two', 'Three', 'Four', 'Five'];
List<String> directoryItems;
enum ImageOption { JPG, PDF }

class _ShowImageState extends State<ShowImage> {
  ImageOption _site = ImageOption.JPG;
  final pdf = pw.Document();
  TextEditingController nameController = TextEditingController();
  final _focusNode = FocusNode();
  MethodChannel channel = new MethodChannel('opencv');
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  bool isBottomOpened = false;
  PersistentBottomSheetController controller;
  var whiteboardBytes;
  var originalBytes;
  var grayBytes;
  bool isGrayBytes = false;
  bool isOriginalBytes = false;
  bool isWhiteBoardBytes = false;
  bool isRotating = false;
  int angle = 0;
  String canvasType = "original";
  double tl_x;
  double tr_x;
  double bl_x;
  double br_x;
  double tl_y;
  double tr_y;
  double bl_y;
  double br_y;
  var bytes;
  int selectedRadio;
  bool isShowingBottomSheet;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    directoryItems = List();
    isShowingBottomSheet = false;
    selectedRadio = 1;
    nameController.text = "Scan" + DateTime.now().toString();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: nameController.text.length,
        );
      }
    });
    otherFunction();

    tl_x = (widget.imagePixelSize.width / widget.width) * widget.tl.dx;
    tr_x = (widget.imagePixelSize.width / widget.width) * widget.tr.dx;
    bl_x = (widget.imagePixelSize.width / widget.width) * widget.bl.dx;
    br_x = (widget.imagePixelSize.width / widget.width) * widget.br.dx;

    tl_y = (widget.imagePixelSize.height / widget.height) * widget.tl.dy;
    tr_y = (widget.imagePixelSize.height / widget.height) * widget.tr.dy;
    bl_y = (widget.imagePixelSize.height / widget.height) * widget.bl.dy;
    br_y = (widget.imagePixelSize.height / widget.height) * widget.br.dy;
    convertToGray();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isBottomOpened) {
      Navigator.of(context).pop();
      isBottomOpened = false;
    } else if (isShowingBottomSheet) {
      Navigator.of(context).pop();
      isShowingBottomSheet = false;
      return true;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Discard this Scan?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              thickness: 2,
            ),
            Text(
              "This will discard the scans you have captured. Are you sure?",
              style: TextStyle(color: Colors.grey[500]),
            )
          ],
        )),
        actions: <Widget>[
          OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              // showBottomSheet(context: context, builder: (context)=>Container(
              //   color: Colors.red,
              // ));
              Route route =
                  MaterialPageRoute(builder: (context) => build(context));
              Navigator.pushReplacement(context, route);
              // Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              return false;
            },
            child: Text(
              "Discard",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
    return true;
  }

  otherFunction() async {
    directoryItems = await _inFutureList();
    if (directoryItems.isNotEmpty) {
      dropdownValue =
          directoryItems.isNotEmpty ? dropdownValue = directoryItems[0] : "";
    }
  }

  Future<Null> _cropImage() async {
  
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: widget.file.path,
    
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      print("if condition");
      widget.file = croppedFile;
    } else {
      print("else condition");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (isBottomOpened) {
              Navigator.of(context).pop();
              isBottomOpened = false;
            } else if (isShowingBottomSheet) {
              Navigator.of(context).pop();
              isShowingBottomSheet = false;
              return true;
            }
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Discard this Scan?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    Text(
                      "This will discard the scans you have captured. Are you sure?",
                      style: TextStyle(color: Colors.grey[500]),
                    )
                  ],
                )),
                actions: <Widget>[
                  OutlineButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      // showBottomSheet(context: context, builder: (context)=>Container(
                      //   color: Colors.red,
                      // ));
                      Route route = MaterialPageRoute(
                          builder: (context) => build(context));
                      Navigator.pushReplacement(context, route);
                      // Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  OutlineButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      return false;
                    },
                    child: Text(
                      "Discard",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            );
            return true;
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () async {
              setState(() {
                isShowingBottomSheet = true;
              });
              // _inFutureList();
              _saveModalBottomSheet(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              bytes == null
                  ? Container()
                  : isRotating
                      ? Center(
                          child: Container(
                              height: 150,
                              width: 100,
                              child: Center(
                                  child: Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                ),
                              ))))
                      : Center(
                          child: Container(
                              padding: EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                  maxHeight: double.infinity * double.infinity,
                                  maxWidth: double.infinity * 2),
                              child: Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                              ))),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.black,
        onTap: (index) async {
          if (index == 0) {
            if (isBottomOpened) {
              isBottomOpened = false;
              Navigator.of(context).pop();
            }
            setState(() {
              isRotating = true;
            });
            Timer(Duration(seconds: 1), () async {
              bytes = await channel.invokeMethod('rotate', {"bytes": bytes});
            });

            Timer(Duration(seconds: 4), () async {
              if (angle == 360) {
                angle = 0;
              }
              angle = angle + 90;
              bytes = await channel
                  .invokeMethod('rotateCompleted', {"bytes": bytes});
              setState(() {
                isRotating = false;
              });
            });
          }

          if (index == 1) {
            if (isBottomOpened) {
              isBottomOpened = false;
              Navigator.of(context).pop();
            }
            _cropImage();
            // Navigator.of(context)
            //     .push(MaterialPageRoute(
            //   builder: (context) =>
            //       NewImage(widget.file, widget.animatedListKey),
            // ))
            //     .then((value) {
            //   if (value != null) {
            //     tl_x = value[1];
            //     tl_y = value[2];
            //     tr_x = value[3];
            //     tr_y = value[4];
            //     bl_x = value[5];
            //     bl_y = value[6];
            //     br_x = value[7];
            //     br_y = value[8];
            //     setState(() {
            //       bytes = value[0];
            //       isGrayBytes = false;
            //       isOriginalBytes = false;
            //       isWhiteBoardBytes = false;
            //     });
            //   }
            // });
          }
          if (index == 2) {
            if (isBottomOpened) {
              Navigator.of(context).pop();
              isBottomOpened = false;
            } else {
              isBottomOpened = true;
              BottomSheet bottomSheet = BottomSheet(
                onClosing: () {},
                builder: (context) => colorBottomSheet(),
                enableDrag: true,
              );
              controller = scaffoldKey.currentState
                  .showBottomSheet((context) => bottomSheet);
            }
          }
          if (index == 3) {
            if (isBottomOpened) {
              Navigator.of(context).pop();
              isBottomOpened = false;
            } else {
              chooseImage(ImageSource.camera);
            }
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.rotate_right,
                color: Colors.black,
              ),
              title: Text("Rotate")),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.crop,
                color: Colors.black,
              ),
              title: Text("Crop")),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.color_lens,
                color: Colors.black,
              ),
              title: Text("Retake")),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.wb_sunny,
                color: Colors.black,
              ),
              title: Text("Color")),
        ],
      ),
    );
  }

  Widget colorBottomSheet() {
    if (isOriginalBytes == false) {
      grayandoriginal();
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (originalBytes != null) {
                // print("original");
                Navigator.of(context).pop();
                isBottomOpened = false;
                canvasType = "original";
                Timer(Duration(milliseconds: 500), () {
                  angle = 0;
                  setState(() {
                    bytes = originalBytes;
                  });
                });
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isOriginalBytes
                        ? Image.memory(
                            originalBytes,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          )),
                Text("Original"),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // print("whiteboard");
              Navigator.of(context).pop();
              isBottomOpened = false;
              angle = 0;
              canvasType = "whiteboard";
              Timer(Duration(milliseconds: 500), () {
                setState(() {
                  bytes = whiteboardBytes;
                });
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 80,
                  margin: EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: isWhiteBoardBytes
                      ? Image.memory(
                          whiteboardBytes,
                          fit: BoxFit.fill,
                          height: 120,
                        )
                      : Container(
                          height: 120,
                          child: Center(
                            child: Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                )),
                          ),
                        ),
                ),
                Text("Whiteboard"),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // print("gray");
              Navigator.of(context).pop();
              isBottomOpened = false;
              angle = 0;
              canvasType = "gray";
              Timer(Duration(milliseconds: 500), () {
                setState(() {
                  bytes = grayBytes;
                });
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 80,
                  margin: EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: isGrayBytes
                      ? Image.memory(
                          grayBytes,
                          fit: BoxFit.fill,
                          height: 120,
                        )
                      : Container(
                          height: 120,
                          child: Center(
                            child: Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black),
                                )),
                          ),
                        ),
                ),
                Text("Grayscale"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<dynamic> convertToGray() async {
    var bytesArray = await channel.invokeMethod('convertToGray', {
      'filePath': widget.file.path,
      'tl_x': tl_x,
      'tl_y': tl_y,
      'tr_x': tr_x,
      'tr_y': tr_y,
      'bl_x': bl_x,
      'bl_y': bl_y,
      'br_x': br_x,
      'br_y': br_y,
    });
    setState(() {
      bytes = bytesArray;
      originalBytes = bytesArray;
    });
    return bytesArray;
  }

  Future<void> grayandoriginal() async {
    Future.delayed(Duration(seconds: 1), () {
      channel.invokeMethod('gray', {
        'filePath': widget.file.path,
        'tl_x': tl_x,
        'tl_y': tl_y,
        'tr_x': tr_x,
        'tr_y': tr_y,
        'bl_x': bl_x,
        'bl_y': bl_y,
        'br_x': br_x,
        'br_y': br_y,
      });
      channel.invokeMethod('whiteboard', {
        'filePath': widget.file.path,
        'tl_x': tl_x,
        'tl_y': tl_y,
        'tr_x': tr_x,
        'tr_y': tr_y,
        'bl_x': bl_x,
        'bl_y': bl_y,
        'br_x': br_x,
        'br_y': br_y,
      });
      channel.invokeMethod('original', {
        'filePath': widget.file.path,
        'tl_x': tl_x,
        'tl_y': tl_y,
        'tr_x': tr_x,
        'tr_y': tr_y,
        'bl_x': bl_x,
        'bl_y': bl_y,
        'br_x': br_x,
        'br_y': br_y,
      });
    });
    Timer(Duration(seconds: 7), () {
      // print("this started");
      channel.invokeMethod('grayCompleted').then((value) {
        grayBytes = value;
        isGrayBytes = true;
      });
      channel.invokeMethod('whiteboardCompleted').then((value) {
        whiteboardBytes = value;
        isWhiteBoardBytes = true;
      });
      channel.invokeMethod('originalCompleted').then((value) {
        originalBytes = value;
        isOriginalBytes = true;
        if (isBottomOpened) {
          Navigator.pop(context);
          BottomSheet bottomSheet = BottomSheet(
            onClosing: () {},
            builder: (context) => colorBottomSheet(),
            enableDrag: true,
          );
          controller = scaffoldKey.currentState
              .showBottomSheet((context) => bottomSheet);
        }
      });
    });
  }

  void _saveModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateChild) {
              //////////////////////////////////////
              return Container(
                  height: 330,
                  decoration: BoxDecoration(),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      Align(
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.black),
                          onPressed: () async {
                            isShowingBottomSheet = false;
                            Navigator.of(context).pop();
                          },
                        ),
                        alignment: Alignment.topRight,
                      ),
                      SizedBox(height: 5),
                      Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 4,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(8, 20, 20, 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Padding(padding: EdgeInsets.fromLTRB(2, 10, 20, 0)),
                                    Text(
                                      'Save as',
                                      style: TextStyle(
                                          color: Color(0xff002C10),
                                          decoration: TextDecoration.none,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ButtonBar(
                                          alignment: MainAxisAlignment.start,
                                          children: [
                                            Radio(
                                                value: 1,
                                                groupValue: selectedRadio,
                                                activeColor: Colors.green,
                                                onChanged: (val) {
                                                  // setSelectedRadio(val);
                                                  setStateChild(
                                                    () {
                                                      selectedRadio = val;
                                                      // print(
                                                      // " my radio...$selectedRadio");
                                                    },
                                                  );
                                                  // print("Radio $val");
                                                }),
                                            Text(
                                              "Pdf",
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            Radio(
                                                value: 2,
                                                groupValue: selectedRadio,
                                                activeColor: Colors.green,
                                                onChanged: (val) {
                                                  setStateChild(
                                                    () {
                                                      selectedRadio = val;
                                                      // print(
                                                      //     " my radio...$selectedRadio");
                                                    },
                                                  );
                                                  setSelectedRadio(val);
                                                  // print("Radio 2 $val");
                                                }),
                                            Text(
                                              "Image",
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(),
                                    Text(
                                      ' Add to folder',
                                      style: TextStyle(
                                          color: Color(0xff002C10),
                                          decoration: TextDecoration.none,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                      underline: Container(
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                                      onChanged: (String data) {
                                        setState(() {
                                          dropdownValue = data;
                                        });
                                      },
                                      items: directoryItems
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value.split("/")[
                                              value.split("/").length - 1]),
                                        );
                                      }).toList(),
                                      value: dropdownValue,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  width: double.infinity * .5,
                                  height: 40.5,
                                  child: RaisedButton(
                                    textColor: Colors.white,
                                    color: Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(13)),
                                    child: new Text(
                                      "Save",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      _convertImageToPDF();
                                    },
                                  ),
                                )
                              ],
                            ),
                          )),
                    ],
                  ));

              ///////////////////
            },
          );
        });
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
      // print(" my radio...$selectedRadio");
    });
  }

  void chooseImage(ImageSource gallery) async {
    File fileGallery = await ImagePicker.pickImage(source: gallery);
    if (fileGallery != null) {
      widget.file = fileGallery;
      RenderBox imageBox =
          widget.animatedListKey.currentContext.findRenderObject();
      widget.width = imageBox.size.width;
      widget.height = imageBox.size.height;
      widget.imagePixelSize = ImageSizGetter.getSize(widget.file);
      widget.tl = new Offset(20, 20);
      widget.tr = new Offset(widget.width - 20, 20);

      convertToGray();
    }
  }

  Future<List<String>> _inFutureList() async {
    var filesList = new List<String>();
    final folderName = "Document Scanner";
    final root = Directory("storage/emulated/0/$folderName");
    // String directoryPath = root.path + '/bozzetto_camera';
    List dir = root.listSync();
    for (var fileOrDir in dir) {
      if (fileOrDir is Directory) {
        // print(fileOrDir.path);
        filesList.add(fileOrDir.path);
      }
    }

    await new Future.delayed(new Duration(milliseconds: 500));
    return filesList;
  }

/**
 * Convert Image to pdf
 */

  Future<void> saveImages() async {
    if (selectedRadio == 1) {
      _convertImageToPDF();
    } else {
      _convertImage();
    }
  }

  Future<void> _convertImageToPDF() async {
    final root = Directory(dropdownValue);

    final imgaeFileName = "IMG_${DateTime.now().millisecondsSinceEpoch}";

    await widget.file.writeAsBytes(bytes).then((_) async {
      // print(ImageSizGetter.getSize(widget.file));
      Provider.of<DocumentProvider>(context, listen: false).saveDocument(
          directoryname: root,
          name: imgaeFileName,
          documentPath: widget.file.path,
          dateTime: DateTime.now(),
          animatedListKey: widget.animatedListKey,
          angle: angle);
    });
    _navPaymentSuccessful();
  }

  _navPaymentSuccessful() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        ModalRoute.withName("/Home"));
  }

  Future<void> _convertImage() async {
    final root = Directory(dropdownValue);

    final imgaeFileName = "IMG_${DateTime.now().millisecondsSinceEpoch}";

    await widget.file.writeAsBytes(bytes).then((_) async {
      // print(ImageSizGetter.getSize(widget.file));
      Provider.of<DocumentProvider>(context, listen: false).saveDocument(
          directoryname: root,
          name: imgaeFileName,
          documentPath: widget.file.path,
          dateTime: DateTime.now(),
          animatedListKey: widget.animatedListKey,
          angle: angle);
    });
    _navPaymentSuccessful();
  }
}
