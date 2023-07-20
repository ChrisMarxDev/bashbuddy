import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:term_buddy/logic/settings.dart';
import 'package:term_buddy/themes.dart';
import 'package:term_buddy/util/log.dart';
import 'package:term_buddy/widgets/title.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(darkModeProvider);
    return SingleChildScrollView(
      child: Column(
        // padding: const EdgeInsets.all(16.0),
        children: [
          const TitleWidget(title: 'Settings'),
          SwitchListTile(
              value: state,
              onChanged: (value) {
                ref.read(darkModeProvider.notifier).save(value);
              },
              title: const Text('Dark Mode (Beta)')),
          const VersionInfoTile(),
          TextButton(
              onPressed: () {
                launchUrlString(
                    'mailto:bashbuddy@christopher-marx.de?subject=Bash%20Buddy%20Feedback&body=Hey%20Chris%2C%0A%0A');
              },
              child: const Text(
                'Give Feedback',
                style: TextStyle(fontSize: 20),
              )),
          const SizedBox(
            height: 20,
          ),
          const ContactView(),
          const SizedBox(height: 800, child: LogOutputView()),

          // ElevatedButton(onPressed: (){}, child: child)
        ],
      ),
    );
  }
}

final appVersionFutureProvider = FutureProvider.autoDispose<String>(
    (ref) => PackageInfo.fromPlatform().then((value) => value.version));

class VersionInfoTile extends ConsumerWidget {
  const VersionInfoTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: ref.watch(appVersionFutureProvider.future),
        builder: (context, data) {
          final version = data.data ?? '';
          return ListTile(
            title: const Text('App Version'),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(version, style: context.textTheme().titleMedium),
            ),
          );
        });
  }
}

class ContactView extends StatelessWidget {
  const ContactView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          RichText(
              text: TextSpan(
            text: 'Email: ',
            style: TextStyle(color: context.mainTextColor()),
            children: [
              TextSpan(
                text: 'bashbuddy@christopher-marx.de',
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      launchUrlString('mailto:bashbuddy@christopher-marx.de'),
                style: TextStyle(
                  color: context.primary(),
                ),
              ),
            ],
          )),
          RichText(
            text: TextSpan(
              text: 'Twitter: ',
              style: TextStyle(color: context.mainTextColor()),
              children: [
                TextSpan(
                  text: '@ChrisMarxDev',
                  style: TextStyle(
                    color: context.primary(),
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        launchUrlString('https://twitter.com/ChrisMarxDev'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogOutputView extends StatefulWidget {
  const LogOutputView({
    Key? key,
  }) : super(key: key);

  @override
  State<LogOutputView> createState() => _LogOutputViewState();
}

class _LogOutputViewState extends State<LogOutputView> {
  @override
  Widget build(BuildContext context) {
    final logOutput = memoryLogOutput;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh)),
                const Text('Log Output',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: logOutput.all()));
                    },
                    child: Row(
                      children: const [
                        Text('Copy'),
                        Icon(Icons.post_add_rounded),
                      ],
                    )),
              ],
            ),
            Expanded(
              child: SelectionArea(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: logOutput.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(logOutput.builder(index)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
