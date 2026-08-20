class AppUrls {
  const AppUrls._();

  /// Base URL of the deployed web app, used to build shareable links
  /// (student dashboard, session invites, class join links) on platforms
  /// where `Uri.base.origin` isn't the public app URL (native mobile, or
  /// web embedded behind a proxy that leaves it empty).
  static const String webBase = 'https://eduplay-8792f.web.app';
}
