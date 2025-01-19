import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_nfl_app/src/updates/update.dart';

import '../settings/settings_view.dart';

/// Displays a list of SampleItems.
class UpdateListView extends StatelessWidget {
  const UpdateListView({
    super.key,
    required this.updates,
  });

  final List<Update> updates;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ListView.builder(
          restorationId: 'UpdateListView',
          itemCount: updates.length,
          itemBuilder: (BuildContext context, int index) {
            final update = updates[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(update.title),
                    children: const [
                      Text('Test'),
                      Text('Content'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
