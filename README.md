# NetworkImageSafeProvider

A NetworkImageProvider with placeholder.

# Usage

Use `NetworkImageSafeProvider` instead of `Image.network` to load images from the network and use a placeholder if floading fails.

Example:
``` dart
var avatar = new Image(
  image: new NetworkImageSafeProvider('http://example.com/avatars/123.jpg', placeholder: 'assets/placeholder.png'),
);
``` 

Remeber to add your placeholder image to your assets in `pubspec.yaml`