# NetworkImageSafeProvider

A NetworkImageProvider with placeholder.

# Installation

## 1. Depend on it

Add this to your package's pubspec.yaml file:

``` dart
dependencies:
  network_safe_image_provider: ^1.0.0
``` 

## 2. Install it
You can install packages from the command line:

with Flutter:

``` bash
$ flutter pub get
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

## 3. Import it
Now in your Dart code, you can use:
``` dart
import 'package:network_safe_image_provider/network_safe_image_provider.dart';
```


# Usage

Use `NetworkImageSafeProvider` instead of `Image.network` to load images from the network and use a placeholder if floading fails.

Example:
``` dart
var avatar = new Image(
  image: new NetworkImageSafeProvider('http://example.com/avatars/123.jpg', placeholder: 'assets/placeholder.png'),
);
``` 

Remeber to add your placeholder image to your assets in `pubspec.yaml`