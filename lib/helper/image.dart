String imageURL(String url, String filter) {

  if (filter.isEmpty) {
    return url;
  }

  if (isImage(url)) {
    return '$url-$filter';
  } else {
    return url;
  }
}

bool isImage(String url) {
  final low = url.toLowerCase();
  return low.endsWith('.jpg') ||
      low.endsWith('.jpeg') ||
      low.endsWith('.png') ||
      low.endsWith('.gif') ||
      low.endsWith('.webp');
}
