import 'package:flutter/material.dart';

Widget imageInteractionCard(dynamic contextObject, dynamic Function(dynamic) function) => Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 4),
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
              image: NetworkImage(contextObject['images'][0]['url']),
              height: 360,
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () => {function(contextObject)},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, left: 15, right: 15, bottom: 8),
              child: Text(
                contextObject['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
);