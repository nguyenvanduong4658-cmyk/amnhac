class AppAssets {
  static const String imagePath = "assets/images/";

  static String getImage(String fileName) {
    return "$imagePath$fileName";
  }
}