// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:devtools_app/devtools_app.dart';
import 'package:devtools_extensions/api.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
// import 'package:devtools_app/src/shared/diagnostics/inspector_service.dart';
// import 'package:devtools_app/src/shared/diagnostics/diagnostics_node.dart';
import 'package:flutter/material.dart';
import 'package:rohd/rohd.dart' as rohd show InspectorService;

class RohdDevToolsExtension extends StatelessWidget {
  const RohdDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: RohdExtensionHomePage(),
    );
  }
}

class RohdExtensionHomePage extends StatefulWidget {
  const RohdExtensionHomePage({super.key});

  @override
  State<RohdExtensionHomePage> createState() => _RohdExtensionHomePageState();
}

class _RohdExtensionHomePageState extends State<RohdExtensionHomePage> {
  int counter = 0;

  String? message;

  @override
  void initState() {
    super.initState();

    // TODO(Quek): Init the inspector service
    final invokeJson = rohd.InspectorService();

    // Example of the devtools extension registering a custom handler.
    extensionManager.registerEventHandler(
      DevToolsExtensionEventType.themeUpdate,
      (event) {
        final themeUpdateValue =
            event.data?[ExtensionEventParameters.theme] as String?;
        setState(() {
          message = themeUpdateValue;
        });
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      testCode();
      counter++;
    });
    extensionManager.postMessageToDevTools(
      DevToolsExtensionEvent(
        DevToolsExtensionEventType.unknown,
        data: {'increment_count': counter},
      ),
    );
  }

  Future<void> testCode() async {
    // From Kenzii discord, https://github.com/flutter/devtools/blob/master/packages/devtools_app/lib/src/shared/diagnostics/inspector_service.dart#L1367-L1371
    final checkServiceExtensionState = await serviceManager
        .serviceExtensionManager
        .isServiceExtensionAvailable('ext.module_tree');

    final response =
        await serviceManager.service!.callServiceExtension('ext.module_tree');
    final json = response.json!;
    print('is module tree ready? $checkServiceExtensionState');
    print('extension module json = $json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ROHD DevTools Extension'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button $counter times'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Increment and post count to DevTools'),
            ),
            const SizedBox(height: 48.0),
            Text('Received theme update from DevTools: $message'),
            ElevatedButton(
                onPressed: () => testCode(), child: const Text('Quek Btn')),
            const SizedBox(height: 48.0),
            ElevatedButton(
              onPressed: () => extensionManager
                  .showNotification('Yay, DevTools Extensions!'),
              child: const Text('Show DevTools notification'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => extensionManager.showBannerMessage(
                key: 'example_message_single_dismiss',
                type: 'warning',
                message: 'Warning: with great power, comes great '
                    'responsibility. I\'m not going to tell you twice.\n'
                    '(This message can only be shown once)',
                extensionName: 'rohd',
              ),
              child: const Text(
                'Show DevTools warning (ignore if already dismissed)',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => extensionManager.showBannerMessage(
                key: 'example_message_multi_dismiss',
                type: 'warning',
                message: 'Warning: with great power, comes great '
                    'responsibility. I\'ll keep reminding you if you '
                    'forget.\n(This message can be shown multiple times)',
                extensionName: 'rohd',
                ignoreIfAlreadyDismissed: false,
              ),
              child: const Text(
                'Show DevTools warning (can show again after dismiss)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}