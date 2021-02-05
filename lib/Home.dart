import 'dart:async';
import 'package:camera/camera.dart';
import 'package:documentscanner2/Providers/documentProvider.dart';
import 'package:documentscanner2/Search.dart';
import 'package:documentscanner2/custom/custom_camera.dart';
import 'package:documentscanner2/drawer.dart';
import 'package:documentscanner2/pdfScreen.dart';
import 'package:documentscanner2/showImage.dart';
import 'package:documentscanner2/singleImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_share/flutter_share.dart';
import 'package:vector_math/vector_math_geometry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
// import 'package:image_size_getter/image_size_getter.dart';
import 'dart:io';

import 'CreateFolderDialog.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MethodChannel channel = MethodChannel('opencv');
  File _file;
  bool isFile = false;

  Size imagePixelSize;
  List<String> directoryItems = List();

  double width, height;
  @override
  void initState() {
    super.initState();
    // directoryItems = List();
    _createFolder('images');
    requestPermission();
    otherFunction();
  }

  otherFunction() async {
    await _inFutureList().then((value) {
      setState(() {
        value.forEach((element) {
          directoryItems.add(element);
        });
        // directoryItems = value;
      });
    });
  }

  Future<void> requestPermission() async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      print("Granted");
    } else if (status.isUndetermined) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
      print(statuses[Permission.storage]);
    } else {
      print("BOT Allow");
    }
  }

  final GlobalKey<AnimatedListState> animatedListKey =
      GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size - MediaQuery.of(context).size;
    return Scaffold(
      // appBar: Provider.of<DocumentProvider>(context)
      //     .allDocuments
      //     .length >
      // 1?buildAppBar()
      // :PreferredSize(
      //   preferredSize: Size(0.0,0.0),
      //   child: Container(),

      // ),
      drawer: buildDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          onPressed: () async {
            print('test');
            // WidgetsFlutterBinding.ensureInitialized();

            //     final cameras = await availableCameras();
            //     final firstCamera = cameras.first;

            chooseImage(ImageSource.camera);
            // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TakePictureScreen(camera: ,)));
          },
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                // icon: Image.asset("lib/Model/images/scan.png",
                // color: Colors.white, height: 30, width: 30),
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () async {
                  chooseImage(ImageSource.camera);
                },
              ),
              Container(
                color: Colors.white.withOpacity(0.2),
                width: 0,
                height: 0,
              ),
              Text(
                "Scan",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 15.0,
                ),
              )
              // IconButton(
              //   icon: Icon(Icons.image, color: Colors.white),
              //   onPressed: () async {
              //     chooseImage(ImageSource.gallery);
              //   },
              // )
            ],
          )),
      body: FutureBuilder(
        future: getAllDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print("has not data");
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            print("error");
            return CircularProgressIndicator();
          }
          print(
              "snapshot.data snapshot.data:${Provider.of<DocumentProvider>(context).allDocuments.length}");
          //  if ()

          return bodyWidgett();
          // Provider.of<DocumentProvider>(context)
          //                   .allDocuments
          //                   .length >
          //               1
          //     ?
          //  bodyWidgett()
          // : Container(
          //   height: MediaQuery.of(context).size.height,
          //     alignment: Alignment.center,bodyWidgett()
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Image(
          //             image: AssetImage('lib/Model/images/documents.png'),
          //             color: Colors.green,
          //           ),
          //           Text("You do not have yet any",
          //               style: TextStyle(
          //                   fontSize: 14,
          //                   color: Colors.grey,
          //                   fontStyle: FontStyle.italic)),
          //           Text("Scanned documents !!",
          //               style: TextStyle(fontSize: 18, color: Colors.black))
          //         ],
          //       ),
          //     ));
        },
      ),
    );
  }

  bodyWidgett() {
    return CustomScrollView(
      slivers: <Widget>[
        buildAppBarr(),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Folder",
                    style: TextStyle(fontSize: 15, color: Colors.green)),
                // Container(
                //   width: 70,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text("Sort",
                //           style: TextStyle(fontSize: 15, color: Colors.green))
                //         ,
                //       // SizedBox(width:5),
                //       InkWell(
                //           onTap: () {},
                //           child: Icon(
                //             Icons.sort,
                //             color: Colors.grey,
                //           ))
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 70.0,
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Card(
                child: ListTile(
              leading: Container(
                height: 30,
                width: 30,
                child: Icon(Icons.folder, color: Colors.brown),
              ),
              title: Text(directoryItems[index]),
              subtitle: Text("15 items"),
              trailing:
                  IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
            ));
          }, childCount: directoryItems.length),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Folder",
                    style: TextStyle(fontSize: 15, color: Colors.green)),
                // Container(
                //   width: 70,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text("Sort",
                //           style: TextStyle(fontSize: 15, color: Colors.green)),
                //       // SizedBox(width:5),
                //       InkWell(
                //           onTap: () {},
                //           child: Icon(
                //             Icons.sort,
                //             color: Colors.grey,
                //           ))
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        gridList(),
      ],
    );
  }

  Widget gridList() {
    var mSize = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (mSize.height - kToolbarHeight) / 2;
    final double itemWidth = mSize.width / 2;
    int fileItemCount =
        Provider.of<DocumentProvider>(context).allDocuments.length;

    print(
        "Count of list ${Provider.of<DocumentProvider>(context).allDocuments.length}");

    int gridItemCount = 0;

    if (fileItemCount > 1) {
      gridItemCount = fileItemCount - 1;
    } else {
      gridItemCount = 0;
    }
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 4.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Center(
            child: SelectCard(
              index: index,
              itemHeight: itemHeight,
              itemWidth: itemWidth,
              deletefun: () {
                Navigator.pop(context);
                DeleteDialog(
                    index: index,
                    dateTime:
                        Provider.of<DocumentProvider>(context, listen: false)
                            .allDocuments[index]
                            .dateTime);
              },
            ),
          );
        },
        childCount: gridItemCount,
      ),
    );
  }

  bodyWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Container(
        child: Column(
          children: [
            Container(
              // color: Colors.red,
              height: 25,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Folder"),
                  Container(
                    // color:Colors.green,
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Sort"),
                        // SizedBox(width:5),
                        InkWell(onTap: () {}, child: Icon(Icons.sort))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            createForlderView(context),
            Container(
              // color: Colors.red,
              height: 25,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Folder"),
                  Container(
                    // color:Colors.green,
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Sort"),
                        // SizedBox(width:5),
                        InkWell(onTap: () {}, child: Icon(Icons.sort))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _createGridView()
          ],
        ),
      ),
    );
  }

  buildDrawer() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Color(0xffF0F0F0),
      ),
      child: Container(
        width: 220.2,
        child: Drawer(
          child: Column(
            children: [
              DocDrawer(),
              Spacer(),
              Text('App beta version 1.0.0',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic)),
              SizedBox(
                height: 10,
              ),
              Text(
                'Made in INDIA',
                style: TextStyle(color: Color(0xff002C10)),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildAppBarr() {
    return SliverAppBar(
      key: animatedListKey,
      pinned: true,
      backgroundColor: Colors.green,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.image_search,
            color: Colors.white,
          ),
          onPressed: () async {
            var status = await Permission.storage.status;
            if (status.isGranted) {
              var data = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateFolderDialog(
                      title: "Custom Dialog Demo",
                      descriptions:
                          "Hii all this is a custom dialog in flutter and  you will be use in your flutter applications",
                      text: "Create folder",
                    );
                  });
              print("directory name: ${data}");
              directoryItems.add(data);
            } else {
              Map<Permission, PermissionStatus> statuses = await [
                Permission.storage,
                Permission.camera,
              ].request();
              print(statuses[Permission.storage]);
            }

            // chooseImage(ImageSource.gallery);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () async {
            showSearch(context: context, delegate: Search());
          },
        ),
      ],
    );
  }

  buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.image_search,
            color: Colors.white,
          ),
          onPressed: () async {
            var status = await Permission.storage.status;
            if (status.isGranted) {
              var data = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateFolderDialog(
                      title: "Custom Dialog Demo",
                      descriptions:
                          "Hii all this is a custom dialog in flutter and  you will be use in your flutter applications",
                      text: "Create folder",
                    );
                  });
              print("directory name: ${data}");
              directoryItems.add(data);
            } else {
              Map<Permission, PermissionStatus> statuses = await [
                Permission.storage,
                Permission.camera,
              ].request();
              print(statuses[Permission.storage]);
            }

            // chooseImage(ImageSource.gallery);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () async {
            showSearch(context: context, delegate: Search());
          },
        ),
      ],
    );
  }

  Widget _createGridView() {
    var mSize = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (mSize.height - kToolbarHeight) / 2;
    final double itemWidth = mSize.width / 2;
    int fileItemCount =
        Provider.of<DocumentProvider>(context).allDocuments.length;

    int gridItemCount = 0;

    if (fileItemCount > 1) {
      gridItemCount = fileItemCount - 1;
    } else {
      gridItemCount = 0;
    }

    return Expanded(
      child: Container(
        height: 100,
        child: GridView.count(
          key: animatedListKey,
          scrollDirection: Axis.vertical, //default
          reverse: false,
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: (itemWidth / itemHeight),
          children: List.generate(gridItemCount, (index) {
            return Center(
              child: SelectCard(
                index: index,
                itemHeight: itemHeight,
                itemWidth: itemWidth,
                deletefun: () {
                  Navigator.pop(context);
                  DeleteDialog(
                      index: index,
                      dateTime:
                          Provider.of<DocumentProvider>(context, listen: false)
                              .allDocuments[index]
                              .dateTime);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  final picker = ImagePicker();

  void chooseImage(ImageSource source) async {
    var fileGallery = await picker.getImage(source: source, imageQuality: 85);
    // pickImage(source: source);
    if (fileGallery != null) {
      _file = File(fileGallery.path);

      RenderBox imageBox = context.findRenderObject();

      // RenderBox imageBox = animatedListKey.currentContext.findRenderObject();

      width = imageBox.size.width;
      height = imageBox.size.height;
      imagePixelSize = ImageSizGetter.getSize(_file);

      Navigator.of(context).push(
        MaterialPageRoute(
          // builder: (context) => NewImage(fileGallery, animatedListKey)));
          builder: (context) => ShowImage(
            tl: Offset(20, 20),
            tr: Offset(width - 20, 20),
            bl: Offset(20, height - 20),
            br: Offset(width - 20, height - 20),
            width: width,
            height: height,
            file: _file,
            imagePixelSize: imagePixelSize,
            animatedListKey: animatedListKey,
          ),
        ),
      );
    }
  }

  Future<bool> getAllDocuments() async {
    // print("inside get documents");
    return await Provider.of<DocumentProvider>(context, listen: false)
        .getDocuments();
  }

  Future<void> onRefresh() async {
    // print("refreshed");
    Provider.of<DocumentProvider>(context, listen: false).getDocuments();
  }

  Widget buildCard() {
    // return SizeTransition(
    // sizeFactor: animation,
    return Container(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 120),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Image.asset("lib/Model/images/documents.png",
                    fit: BoxFit.fill,
                    color: Colors.green,
                    height: 100,
                    width: 100),
                SizedBox(height: 20),
                Text(
                  "you do not have yet any",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Color(0xffD0D0D0),
                      decoration: TextDecoration.none,
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 5),
                Text(
                  "scanned documents !!",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Color(0xff002C10),
                      decoration: TextDecoration.none,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),

            // margin: EdgeInsets.only(top: 120),
            // alignment: Alignment.topCenter,
            // // child: Image.asset('lib/Model/images/docIcon.png')
            // child: Image.asset("lib/Model/images/documents.png",
            //     fit: BoxFit.fill,
            //     color: Colors.green,
            //     height: 100,
            //     width: 100),
            // height: 180,
            // width: 180,
          )
        ],
      ),
      // ),
      width: double.infinity,
      height: (MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          MediaQuery.of(context).padding.top),
      color: Colors.white,
    );
  }

  Widget _buildDocumentCard(int index, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: null,
          child: Card(),
          //todo implement here
        ),
      ),
    );
  }

  Widget buildDocumentCard(int index, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PDFScreen(
                document:
                    Provider.of<DocumentProvider>(context).allDocuments[index],
                animatedListKey: animatedListKey,
              ),
            ));
          },
          child: Card(
            color: ThemeData.dark().cardColor,
            elevation: 3,
            margin: EdgeInsets.only(left: 12, right: 12, bottom: 5, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 12, top: 12, right: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(color: Colors.grey[300]),
                          right: BorderSide(color: Colors.grey[300]),
                          top: BorderSide(color: Colors.grey[300])),
                    ),
                    child: Image.file(
                      new File(Provider.of<DocumentProvider>(context)
                          .allDocuments[index]
                          .documentPath),
                      height: 150,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 150,
                          padding: EdgeInsets.all(12),
                          child: Text(
                            Provider.of<DocumentProvider>(context)
                                .allDocuments[index]
                                .name,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              Provider.of<DocumentProvider>(context)
                                      .allDocuments[index]
                                      .dateTime
                                      .day
                                      .toString() +
                                  "-" +
                                  Provider.of<DocumentProvider>(context)
                                      .allDocuments[index]
                                      .dateTime
                                      .month
                                      .toString() +
                                  "-" +
                                  Provider.of<DocumentProvider>(context)
                                      .allDocuments[index]
                                      .dateTime
                                      .year
                                      .toString(),
                              style: TextStyle(color: Colors.grey[400]),
                            )),
                      ],
                    )),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width - 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: ThemeData.dark().accentColor,
                                ),
                                onPressed: () {
                                  shareDocument(Provider.of<DocumentProvider>(
                                          context,
                                          listen: false)
                                      .allDocuments[index]
                                      .pdfPath);
                                }),
                            IconButton(
                              icon: Icon(
                                Icons.cloud_upload,
                                color: ThemeData.dark().accentColor,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: ThemeData.dark().accentColor,
                                ),
                                onPressed: () {
                                  showModalSheet(
                                      index: index,
                                      filePath: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .documentPath,
                                      dateTime: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .dateTime,
                                      name: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .name,
                                      pdfPath: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .pdfPath);
                                })
                          ],
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void shareDocument(String pdfPath) async {
    await FlutterShare.shareFile(title: "pdf", filePath: pdfPath);
  }

  void showModalSheet(
      {int index,
      String filePath,
      String name,
      DateTime dateTime,
      String pdfPath}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300])),
                      child: Image.file(
                        new File(filePath),
                        height: 80,
                        width: 50,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150,
                        padding: EdgeInsets.only(left: 12, bottom: 12),
                        child: Text(
                          name,
                          style: TextStyle(color: Colors.green, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            dateTime.day.toString() +
                                "-" +
                                dateTime.month.toString() +
                                "-" +
                                dateTime.year.toString(),
                            style: TextStyle(color: Colors.grey[400]),
                          )),
                    ],
                  )
                ],
              ),
              Divider(
                thickness: 2,
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Rename"),
                onTap: () {
                  Navigator.pop(context);
                  showRenameDialog(
                      index: index, name: name, dateTime: dateTime);
                },
              ),
              ListTile(
                leading: Icon(Icons.print),
                // title: Text("Print"),
                onTap: () async {
                  Navigator.pop(context);
                  final pdf = File(pdfPath);
                  await Printing.layoutPdf(
                      onLayout: (_) => pdf.readAsBytesSync());
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  showDeleteDialog1(index: index, dateTime: dateTime);
                },
              )
            ],
          ),
        );
      },
    );
  }

  void showDeleteDialog1({int index, DateTime dateTime}) {
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
              "Delete file",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              thickness: 2,
            ),
            Text(
              "Are you sure you want to delete this file?",
              style: TextStyle(color: Colors.grey[500]),
            )
          ],
        )),
        actions: <Widget>[
          OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              Navigator.of(context).pop();
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
              Navigator.of(context).pop();
              Provider.of<DocumentProvider>(context, listen: false)
                  .deleteDocument(
                      index, dateTime.millisecondsSinceEpoch.toString());
              Timer(Duration(milliseconds: 300), () {
                animatedListKey.currentState.removeItem(
                    index,
                    (context, animation) =>
                        buildDocumentCard(index, animation));
              });
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  void showRenameDialog({int index, DateTime dateTime, String name}) {
    TextEditingController controller = TextEditingController();
    controller.text = name;
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Rename"),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                  suffix: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                      })),
            ),
          ],
        )),
        actions: <Widget>[
          OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel")),
          OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<DocumentProvider>(context, listen: false)
                    .renameDocument(
                        index,
                        dateTime.millisecondsSinceEpoch.toString(),
                        controller.text);
              },
              child: Text("Rename")),
        ],
      ),
    );
  }

  void DeleteDialog({int index, DateTime dateTime}) {
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
              "Delete file",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              thickness: 2,
            ),
            Text(
              "Are you sure you want to delete this file?",
              style: TextStyle(color: Colors.grey[500]),
            )
          ],
        )),
        actions: <Widget>[
          OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              Navigator.of(context).pop();
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
              Provider.of<DocumentProvider>(context, listen: false)
                  .deleteDocument(
                      index, dateTime.millisecondsSinceEpoch.toString());
              // onRefresh();
              Navigator.of(context).pop();
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  _createFolder(String dirName) async {
    final folderName = "Document Scanner";
    final root = Directory("storage/emulated/0/$folderName");
    String directoryPath = root.path + '/' + dirName;

    if ((await root.exists())) {
      final subPath = Directory(directoryPath);
      subPath.create();
      print("exist");
    } else {
      print("not exist");
      root.create();
      final subPath = Directory(directoryPath);
      subPath.create();
    }
  }

  /**
   * open floder 
   */

  Widget createForlderView(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        height: _height / 1.2,
        child: ListView.builder(
            // padding: ,
            itemCount: directoryItems.length,
            itemBuilder: (context, index) {
              return Card(
                  child: ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  child: Icon(Icons.folder, color: Colors.brown),
                ),
                title: Text(directoryItems[index]),
                subtitle: Text("15 items"),
                trailing:
                    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
              ));
            }),
      ),
    );
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
}

class SelectCard extends StatelessWidget {
  //           child: SelectCard(index: index,itemHeight: itemHeight, itemWidth: itemWidth,),

  const SelectCard(
      {Key key, this.index, this.itemWidth, this.itemHeight, this.deletefun})
      : super(key: key);
  final int index;
  final double itemWidth;
  final double itemHeight;
  final Function deletefun;

  @override
  Widget build(BuildContext context) {
    var t = itemWidth / itemHeight;
    // print(
    //     "me  ${Provider.of<DocumentProvider>(context).allDocuments[index].name}");

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SingleImage(
                  imgFile: File(Provider.of<DocumentProvider>(context)
                      .allDocuments[index]
                      .documentPath),
                  fileName: Provider.of<DocumentProvider>(context)
                      .allDocuments[index]
                      .name)),
        );
      },
      onLongPress: deletefun,
      child: Container(
          height: 280,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                    aspectRatio: t / .70,
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Image.file(
                        File(Provider.of<DocumentProvider>(context)
                            .allDocuments[index]
                            .documentPath),
                        fit: BoxFit.cover,
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 4, top: 5),
                  child: Text(
                    "${Provider.of<DocumentProvider>(context).allDocuments[index].name}",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
