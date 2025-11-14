class AppAssets {
  AppAssets._();

  /// Ruta dentro de Firebase Storage para el logo principal
  static const String ready2GoLogoStoragePath = 'ready2go.png';

  /// URL pública de respaldo por si falla la obtención dinámica
  static const String ready2GoLogoFallbackUrl =
      'https://firebasestorage.googleapis.com/v0/b/delivery-app-15f53.appspot.com/o/ready2go.png?alt=media&token=2e411e3b-3dc6-4a4f-999e-0734c6e5132d';

  /// Asset local de respaldo cuando no se puede cargar desde la red
  static const String ready2GoLogoAsset = 'assets/images/logo/ready2go.png';
}
