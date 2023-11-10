import 'dart:ui';

Future<Image> imageFromAsset(String assetKey) async {
  final buffer = await ImmutableBuffer.fromAsset(assetKey);
  final Codec codec = await instantiateImageCodecFromBuffer(buffer);
  final FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
