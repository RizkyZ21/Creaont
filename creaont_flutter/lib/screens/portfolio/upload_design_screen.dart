import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadDesignScreen
    extends StatefulWidget {

  const UploadDesignScreen({
    super.key,
  });

  @override
  State<UploadDesignScreen>
      createState() =>
          _UploadDesignScreenState();

}

class _UploadDesignScreenState
    extends State<
        UploadDesignScreen> {

  final title =
      TextEditingController();

  final desc =
      TextEditingController();

  File? image;

  Future pickImage() async {

    final picker =
        ImagePicker();

    final picked =
        await picker.pickImage(
      source:
          ImageSource.gallery,
    );

    if(picked != null){

      setState(() {

        image =
            File(picked.path);

      });

    }

  }

  void save(){

    if(title.text.isEmpty){

      return;

    }

    Navigator.pop(
      context,

      {

        "title":
            title.text,

        "desc":
            desc.text,

        "image":
            image,

      },

    );

  }

  @override
  Widget build(
      BuildContext context){

    return Scaffold(

      backgroundColor:
          const Color(
              0xFF0F0C29),

      appBar: AppBar(

        title:
            const Text(
          "Upload Design",
        ),

        backgroundColor:
            Colors.transparent,

      ),

      body: Padding(

        padding:
            const EdgeInsets
                .all(20),

        child: Column(

          children: [

            GestureDetector(

              onTap:
                  pickImage,

              child:
                  Container(

                height: 180,

                decoration:
                    BoxDecoration(

                  color:
                      Colors
                          .white10,

                  borderRadius:
                      BorderRadius.circular(
                          16),

                ),

                child:
                    image == null

                    ? const Center(

                        child:
                            Text(

                          "Tambah Gambar",

                          style:
                              TextStyle(
                            color: Colors
                                .white54,
                          ),

                        ),

                      )

                    : ClipRRect(

                        borderRadius:
                            BorderRadius.circular(
                                16),

                        child:
                            Image.file(

                          image!,

                          width: double
                              .infinity,

                          fit: BoxFit
                              .cover,

                        ),

                      ),

              ),

            ),

            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
                  title,

              style:
                  const TextStyle(
                color:
                    Colors.white,
              ),

              decoration:
                  const InputDecoration(

                hintText:
                    "Judul",

              ),

            ),

            const SizedBox(
              height: 15,
            ),

            TextField(

              controller:
                  desc,

              style:
                  const TextStyle(
                color:
                    Colors.white,
              ),

              decoration:
                  const InputDecoration(

                hintText:
                    "Deskripsi",

              ),

            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:
                    save,

                child:
                    const Text(
                  "Upload",
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}