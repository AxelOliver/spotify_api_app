import 'package:flutter/material.dart';

import '../../data/dbHelper.dart';
import '../../models/artist.dart';

class ImageInteractionCard extends StatefulWidget {
  dynamic contextObject;
  dynamic Function(dynamic) openObjectFunction;
  bool isFavouritable;
  bool isFavourite;

  // contextObject must be in spotify api format
  ImageInteractionCard(
      this.contextObject,
      this.openObjectFunction,
      {this.isFavouritable = true,
        this.isFavourite = false, Key? key}) : super(key: key);

  @override
  _ImageInteractionCardState createState() => _ImageInteractionCardState();
}

class _ImageInteractionCardState extends State<ImageInteractionCard> {
  _addFavourite(dynamic context) async {
    await DbHelper.instance.add(
      Artist(spotifyId: context['id'], name: context['name'], isFavourite: true),
    );
  }

  _removeFavourite(dynamic context) async {
    await DbHelper.instance.remove(context['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Card(
        color: Colors.white54,
        elevation: 15,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Ink.image(
              image: NetworkImage(widget.contextObject['images'][0]['url']),
              height: 360,
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () {
                  widget.openObjectFunction(widget.contextObject);
                  },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, left: 15, right: 15, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.contextObject['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  widget.isFavouritable ? Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FutureBuilder<bool>(
                        future: DbHelper.instance
                            .isFavourite(widget.contextObject['id']),
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: Text('Loading...'));
                          }
                          return !snapshot.data!
                              ? IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                                color: Colors.black,
                                size: 36,
                              ),
                              onPressed: () {
                                setState(() {
                                  _addFavourite(widget.contextObject);
                                });
                              }
                          )
                              : IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 36,
                            ),
                            onPressed: () {
                              setState(() {
                                _removeFavourite(widget.contextObject);
                              });
                            }
                          );
                        },
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _addFavourite(dynamic context) async {
//   await DbHelper.instance.add(
//     Artist(spotifyId: context['id'], name: context['name'], isFavourite: true),
//   );
// }
//
// _removeFavourite(dynamic context) async {
//   await DbHelper.instance.remove(context['id']);
// }
//
// bool isFavourite = false;
//
// Widget imageInteractionCard(
//         dynamic contextObject,
//         dynamic Function(dynamic) openObjectFunction,
//         {bool isFavouritable = true,
//         bool isFavourite = false}) =>
//     Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
//       child: Card(
//         color: Colors.white54,
//         elevation: 15,
//         clipBehavior: Clip.antiAlias,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           children: [
//             Ink.image(
//               image: NetworkImage(contextObject['images'][0]['url']),
//               height: 360,
//               fit: BoxFit.cover,
//               child: InkWell(
//                 onTap: () => {openObjectFunction(contextObject)},
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                   top: 15, left: 15, right: 15, bottom: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       contextObject['name'],
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   isFavouritable
//                       ? Expanded(
//                           child: Align(
//                             alignment: Alignment.centerRight,
//                             child: FutureBuilder<bool>(
//                               future: DbHelper.instance
//                                   .isFavourite(contextObject['id']),
//                               builder: (BuildContext context,
//                                   AsyncSnapshot<bool> snapshot) {
//                                 if (!snapshot.hasData) {
//                                   return Center(child: Text('Loading...'));
//                                 }
//                                 return !snapshot.data!
//                                     ? IconButton(
//                                         icon: const Icon(
//                                           Icons.favorite_border,
//                                           color: Colors.black,
//                                           size: 36,
//                                         ),
//                                         onPressed: () {
//                                           _addFavourite(contextObject);
//                                         }
//                                       )
//                                     : IconButton(
//                                         icon: const Icon(
//                                           Icons.favorite,
//                                           color: Colors.red,
//                                           size: 36,
//                                         ),
//                                         onPressed: () =>
//                                             _removeFavourite(contextObject),
//                                       );
//                               },
//                             ),
//                           ),
//                         )
//                       : Container(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
