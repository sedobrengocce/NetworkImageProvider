import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'network_image_safe_provider.dart' as image_provider;

class NetworkImageSafeProvider
    extends ImageProvider<image_provider.NetworkImageSafeProvider>
    implements image_provider.NetworkImageSafeProvider {
  const NetworkImageSafeProvider(
    this.url, {
    this.placeholder,
    this.scale = 1.0,
    this.headers,
  })  : assert(url != null),
        assert(placeholder != null),
        assert(scale != null);

  @override
  ImageStreamCompleter load(
      image_provider.NetworkImageSafeProvider key, DecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<image_provider.NetworkImageSafeProvider>(
              'Image key', key),
        ];
      },
    );
  }

  @override
  Future<NetworkImageSafeProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageSafeProvider>(this);
  }

  @override
  final String url;

  @override
  final String placeholder;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null)
        client = debugNetworkImageHttpClientProvider();
      return true;
    }());
    return client;
  }

  Future<ui.Codec> _loadAsync(
    NetworkImageSafeProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
  ) async {
    ByteData data;
    try {
      Uint8List bytes;
      assert(key == this);

      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        data = await _loadPlaceholder();
      } else {
        bytes = await consolidateHttpClientResponseBytes(
          response,
          onBytesReceived: (int cumulative, int total) {
            chunkEvents.add(ImageChunkEvent(
              cumulativeBytesLoaded: cumulative,
              expectedTotalBytes: total,
            ));
          },
        );
        if (bytes.lengthInBytes == 0)
          throw Exception('NetworkImage is an empty file: $resolved');
      }
      return decode(bytes ?? data.buffer.asUint8List());
    } catch(e) {
      data = await _loadPlaceholder();
      return decode(data.buffer.asUint8List());
    }finally {
      await chunkEvents.close();
    }
  }

  Future<ByteData> _loadPlaceholder() async {
    final Uint8List encoded =
        utf8.encoder.convert(Uri(path: Uri.encodeFull(placeholder)).path);
    final ByteData asset = await ServicesBinding.instance.defaultBinaryMessenger
        .send(
            'flutter/assets',
            encoded.buffer
                .asByteData()); // ignore: deprecated_member_use_from_same_package
    if (asset == null) throw FlutterError('Unable to load asset: $placeholder');
    return asset;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is NetworkImageSafeProvider &&
        other.url == url &&
        other.placeholder == placeholder;
  }

  @override
  int get hashCode => ui.hashValues(url, placeholder);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImageSafeProvider')}("$url", placeholder: $placeholder)';
}
