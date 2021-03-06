part of 'main.dart';

class ProviderDemoApp extends StatefulWidget {
  final FireStore _fireStore;
  final FireStorage _storage;
  final SpeechToTextProvider _speechProvider;

  ProviderDemoApp(this._fireStore, this._storage, this._speechProvider);

  @override
  _ProviderDemoAppState createState() => new _ProviderDemoAppState();
}

class _ProviderDemoAppState extends State<ProviderDemoApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechToTextProvider>.value(
      value: widget._speechProvider,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(
              widget._fireStore, widget._storage, widget._speechProvider),
          body: SpeechProviderExampleWidget(),
        ),
      ),
    );
  }
}

class SpeechProviderExampleWidget extends StatefulWidget {
  @override
  _SpeechProviderExampleWidgetState createState() =>
      _SpeechProviderExampleWidgetState();
}

class _SpeechProviderExampleWidgetState
    extends State<SpeechProviderExampleWidget> {
  String _currentLocaleId = "";
  void _setCurrentLocale(SpeechToTextProvider speechProvider) {
    //MUST FIX - LOCALE ID NULL ON LOGOOUT AND LOGIN
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
      try {
        print(speechProvider);
        if (speechProvider.systemLocale.localeId.isNotEmpty)
          _currentLocaleId = speechProvider.systemLocale.localeId;
      } catch (e) {
        print(e);
        _currentLocaleId = "en_GB";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var speechProvider = Provider.of<SpeechToTextProvider>(context);

    if (speechProvider.isNotAvailable) {
      return Center(
        child: Text(
            'Speech recognition not available, no permission or not available on the device.'),
      );
    }
    _setCurrentLocale(speechProvider);
    return Column(children: [
      Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btn2",
                  child: Icon(
                      !speechProvider.isAvailable || speechProvider.isListening
                          ? Icons.mic
                          : Icons.mic_none),
                  onPressed: () => _listen(speechProvider),
                ),
                FloatingActionButton(
                  heroTag: "btn3",
                  child: Text('Stop'),
                  onPressed: speechProvider.isListening
                      ? () => speechProvider.stop()
                      : null,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                DropdownButton(
                  onChanged: (selectedVal) => _switchLang(selectedVal),
                  value: _currentLocaleId,
                  items: speechProvider.locales
                      .map(
                        (localeName) => DropdownMenuItem(
                          value: localeName.localeId,
                          child: Text(localeName.name),
                        ),
                      )
                      .toList(),
                ),
              ],
            )
          ],
        ),
      ),
      Expanded(
        flex: 4,
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                'Recognized Words',
                style: TextStyle(fontSize: 22.0),
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).selectedRowColor,
                child: Center(
                  child: speechProvider.hasResults
                      ? Text(
                          speechProvider.lastResult.recognizedWords,
                          textAlign: TextAlign.center,
                        )
                      : Container(),
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                'Error Status',
                style: TextStyle(fontSize: 22.0),
              ),
            ),
            Center(
              child: speechProvider.hasError
                  ? Text(speechProvider.lastError.errorMsg)
                  : Container(),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: speechProvider.isListening
              ? Text(
                  "I'm listening...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : Text(
                  'Not listening',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    ]);
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  _listen(speechProvider) {
    speechProvider.listen(partialResults: true, localeId: _currentLocaleId);
    StreamSubscription<SpeechRecognitionEvent> _subscription;
    _subscription = speechProvider.stream.listen((recognitionEvent) async {
      switch (recognitionEvent.eventType) {
        case SpeechRecognitionEventType.finalRecognitionEvent:
          speechProvider.listen(
              partialResults: true, localeId: _currentLocaleId);
          break;
        default:
          break;
      }
    });
  }
}
