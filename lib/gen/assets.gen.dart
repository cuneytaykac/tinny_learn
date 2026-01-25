/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsLocalizableGen {
  const $AssetsLocalizableGen();

  /// File path: assets/localizable/en.json
  String get en => 'assets/localizable/en.json';

  /// File path: assets/localizable/tr.json
  String get tr => 'assets/localizable/tr.json';

  /// List of all assets
  List<String> get values => [en, tr];
}

class $AssetsLogoGen {
  const $AssetsLogoGen();

  /// File path: assets/logo/app_logo.jpg
  AssetGenImage get appLogo => const AssetGenImage('assets/logo/app_logo.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [appLogo];
}

class $AssetsUiGen {
  const $AssetsUiGen();

  /// File path: assets/ui/applause.mp3
  String get applause => 'assets/ui/applause.mp3';

  /// File path: assets/ui/wrong.mp3
  String get wrong => 'assets/ui/wrong.mp3';

  /// List of all assets
  List<String> get values => [applause, wrong];
}

class Assets {
  const Assets._();

  static const $AssetsLocalizableGen localizable = $AssetsLocalizableGen();
  static const $AssetsLogoGen logo = $AssetsLogoGen();
  static const $AssetsUiGen ui = $AssetsUiGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
