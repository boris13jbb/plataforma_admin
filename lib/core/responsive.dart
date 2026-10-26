import 'package:flutter/material.dart';

/// Breakpoints mobile-first usados en la consola del hub.
abstract final class HubBreakpoints {
  static const double phoneSm = 320;
  static const double phoneMd = 375;
  static const double phoneLg = 390;
  static const double phoneXl = 430;
  static const double tablet = 768;
  static const double desktop = 1024;
}

/// Helpers de layout responsive sin acoplar lógica de negocio.
extension HubResponsiveContext on BuildContext {
  Size get hubSize => MediaQuery.sizeOf(this);

  EdgeInsets get hubPadding => MediaQuery.paddingOf(this);

  EdgeInsets get hubViewInsets => MediaQuery.viewInsetsOf(this);

  bool get isPhone => hubSize.width < HubBreakpoints.tablet;

  bool get isTablet =>
      hubSize.width >= HubBreakpoints.tablet &&
      hubSize.width < HubBreakpoints.desktop;

  bool get isDesktop => hubSize.width >= HubBreakpoints.desktop;

  /// Padding horizontal adaptable (teléfono → escritorio).
  double get pageHorizontalPadding {
    final w = hubSize.width;
    if (w < HubBreakpoints.phoneXl) return 16;
    if (w < HubBreakpoints.tablet) return 20;
    if (w < HubBreakpoints.desktop) return 24;
    return 32;
  }

  /// Ancho máximo de formularios / paneles de detalle.
  double get contentMaxWidth {
    if (isDesktop) return 960;
    if (isTablet) return 720;
    return hubSize.width;
  }

  /// Ancho de tarjetas de producto en el dashboard.
  double get productCardWidth {
    final w = hubSize.width;
    final pad = pageHorizontalPadding * 2;
    final available = w - pad;
    if (available < 360) return available;
    if (w < HubBreakpoints.tablet) return available;
    if (w < HubBreakpoints.desktop) return (available - 16) / 2;
    return 280;
  }
}

/// Envuelve el body con SafeArea + scroll al abrir el teclado.
class HubSafeScrollBody extends StatelessWidget {
  const HubSafeScrollBody({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final bottomInset = context.hubViewInsets.bottom;
    final horizontal = context.pageHorizontalPadding;
    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16 + bottomInset);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: resolvedPadding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight -
                    (resolvedPadding is EdgeInsets
                        ? (resolvedPadding.vertical)
                        : 32),
                maxWidth: maxWidth ?? context.contentMaxWidth,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
