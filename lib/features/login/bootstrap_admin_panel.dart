import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// True cuando la UI de bootstrap debe mostrarse (debug/profile).
///
/// En release (`kReleaseMode`) la UI se oculta. La callable
/// `bootstrapHubAdmin` **sigue existiendo** en el backend; ocultar la UI
/// no desactiva ni endurece esa función.
bool get showHubBootstrapUi => !kReleaseMode;

/// UI colapsada para el bootstrap del *primer* hubAdmin.
///
/// La seguridad real está en Cloud Functions (`bootstrapHubAdmin`: Auth +
/// secreto + colección `hubAdmins` vacía). Ocultar o colapsar esto no sustituye
/// esas comprobaciones; solo reduce uso accidental y superficie social en UI.
class BootstrapAdminPanel extends StatelessWidget {
  BootstrapAdminPanel({
    super.key,
    required this.secretController,
    required this.busy,
    required this.onActivate,
    /// Por defecto sigue [showHubBootstrapUi]. En tests se puede forzar.
    bool? visible,
  }) : visible = visible ?? showHubBootstrapUi;

  final TextEditingController secretController;
  final bool busy;
  final VoidCallback onActivate;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        title: Text(
          'Primer administrador (avanzado)',
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          'Solo si aún no existe ningún hubAdmin. El servidor lo rechaza si ya hay uno.',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Text(
            'No pegues secretos en chats ni en capturas. Si ya hay un admin, '
            'usa el procedimiento documentado (Admin SDK / script controlado), '
            'no este formulario.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: secretController,
            obscureText: true,
            enabled: !busy,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Secreto bootstrap',
              prefixIcon: Icon(Icons.vpn_key_outlined),
            ),
            onSubmitted: (_) => busy ? null : onActivate(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: busy ? null : onActivate,
            child: const Text('Activar primer hubAdmin'),
          ),
        ],
      ),
    );
  }
}
