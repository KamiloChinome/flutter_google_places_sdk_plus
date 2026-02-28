import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';
import 'package:web/web.dart' as web;

/// Widget used to display google place image. Used in web platforms
class GooglePlacesImg extends StatelessWidget {

  /// Construct a google place img using metadata and response object
  const GooglePlacesImg({
    Key? key,
    required this.photoMetadata,
    required this.placePhotoResponse,
  }) : super(key: key);
  /// The photo metadata
  final PhotoMetadata photoMetadata;

  /// The photo fetch response
  final FetchPlacePhotoResponse placePhotoResponse;

  @override
  Widget build(BuildContext context) {
    final imageUrl = switch (placePhotoResponse) {
      FetchPlacePhotoResponseImageUrl(imageUrl: final imageUrl) => imageUrl,
      _ => null,
    };
    if (imageUrl == null) {
      return const Text('Invalid image url!');
    }

    // ignore: undefined_prefixed_name
    platformViewRegistry.registerViewFactory(
      photoMetadata.photoReference ?? '',
      (int viewId) => web.HTMLImageElement()
        ..id = 'gp_img_$viewId'
        ..setAttribute('src', imageUrl),
    );

    final view = HtmlElementView(viewType: photoMetadata.photoReference ?? '');
    return Container(
      width: photoMetadata.width?.toDouble() ?? 0,
      height: photoMetadata.height?.toDouble() ?? 0,
      child: view,
    );
  }
}
