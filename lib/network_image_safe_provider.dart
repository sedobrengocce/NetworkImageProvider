library network_image_safe_provider;

import 'package:flutter/widgets.dart';
import '_network_image_safe_provider_io.dart' as image_provider;

abstract class NetworkImageSafeProvider
    extends ImageProvider<NetworkImageSafeProvider> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const factory NetworkImageSafeProvider(
    String url, 
    {
    String placeholder,
    double scale,
    Map<String, String> headers,
  }) = image_provider.NetworkImageSafeProvider;

  /// The URL from which the image will be fetched.
  String get url;

  String get placeholder;

  /// The scale to place in the [ImageInfo] object of the image.
  double get scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  ///
  /// When running flutter on the web, headers are not used.
  Map<String, String> get headers;

  @override
  ImageStreamCompleter load(
      NetworkImageSafeProvider key, DecoderCallback decode);
}