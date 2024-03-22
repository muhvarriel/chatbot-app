import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget customCachedImage(
    {required String url,
    double? width,
    double? height,
    bool? isRectangle,
    bool? withBorder,
    double? radius}) {
  return kIsWeb
      ? AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn,
          width: width ?? 35,
          height: height ?? 35,
          decoration: BoxDecoration(
            shape:
                (isRectangle ?? false) ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: (isRectangle ?? false)
                ? BorderRadius.circular(radius ?? 0)
                : null,
            border: (withBorder ?? false)
                ? Border.all(
                    color: Theme.of(Get.context!).colorScheme.primary,
                    width: 3.5)
                : null,
            image: DecorationImage(
              image: NetworkImage(url, scale: 0.5),
              fit: BoxFit.cover,
            ),
          ),
        )
      : CachedNetworkImage(
          width: width ?? 35,
          height: height ?? 35,
          imageUrl: url,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape:
                  (isRectangle ?? false) ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: (isRectangle ?? false)
                  ? BorderRadius.circular(radius ?? 0)
                  : null,
              border: (withBorder ?? false)
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 3.5)
                  : null,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              SizedBox(
                  width: width ?? 35,
                  height: height ?? 35,
                  child: CircularProgressIndicator(
                      value: downloadProgress.progress)),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
}
