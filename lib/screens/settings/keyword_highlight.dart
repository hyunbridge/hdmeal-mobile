// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';

import 'package:hdmeal/utils/preferences_manager.dart';

class KeywordHighlightPage extends StatefulWidget {
  @override
  _KeywordHighlightPageState createState() => _KeywordHighlightPageState();
}

class _KeywordHighlightPageState extends State<KeywordHighlightPage> {
  ScrollController _scrollController;
  List<String> _keywords;

  final PrefsManager _prefsManager = PrefsManager();
  final TextEditingController _textController = new TextEditingController();

  double get _horizontalTitlePadding {
    const kBasePadding = 16.0;
    const kMultiplier = 2.0;

    if (_scrollController.hasClients) {
      if (_scrollController.offset < (150 / 2)) {
        // In case 50%-100% of the expanded height is viewed
        return kBasePadding;
      }

      if (_scrollController.offset > (150 - kToolbarHeight)) {
        // In case 0% of the expanded height is viewed
        return (150 / 2 - kToolbarHeight) * kMultiplier + kBasePadding;
      }

      // In case 0%-50% of the expanded height is viewed
      return (_scrollController.offset - (150 / 2)) * kMultiplier +
          kBasePadding;
    }

    return kBasePadding;
  }

  void _updatePrefs() {
    final keywords = List.from(_keywords);
    keywords.sort();
    _prefsManager.set("highlightedKeywords", keywords);
  }

  void _handleKeywordAdd() {
    final keyword = _textController.text.trim();
    if (keyword.trim().length > 0) {
      if (_keywords.contains(keyword)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('이미 추가된 키워드입니다.'),
          duration: const Duration(seconds: 3),
        ));
      } else {
        setState(() {
          _keywords.add(keyword.trim());
        });
        _updatePrefs();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('키워드 "$keyword"을(를) 추가했습니다.'),
          duration: const Duration(seconds: 3),
        ));
      }
    }
    _textController.clear();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _keywords = _prefsManager.get("highlightedKeywords");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            snap: false,
            stretch: true,
            flexibleSpace: new FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: _horizontalTitlePadding),
                title: Text(
                  "키워드 강조",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SwitchListTile(
                title: Text('키워드 강조 사용'),
                value: _prefsManager.get('enableKeywordHighlight'),
                onChanged: (bool value) => setState(
                    () => _prefsManager.set('enableKeywordHighlight', value)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '키워드 추가하기',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                    suffixIcon: _textController.text.trim().length > 0
                        ? IconButton(
                            onPressed: _handleKeywordAdd,
                            icon: Icon(Icons.add),
                            color: Theme.of(context).textTheme.bodyText1.color,
                          )
                        : SizedBox.shrink(),
                  ),
                  controller: _textController,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _handleKeywordAdd(),
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  '강조 키워드 목록',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('좌우로 쓸어넘겨 삭제할 수 있습니다.'),
              ),
              ..._keywords.map((e) => Dismissible(
                    key: Key(e),
                    child: ListTile(
                      title: Text(e),
                      visualDensity: VisualDensity(vertical: -4),
                    ),
                    background: Container(color: Colors.red),
                    onDismissed: (_) {
                      setState(() {
                        _keywords.remove(e);
                      });
                      _updatePrefs();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('키워드 "$e"을(를) 삭제했습니다.'),
                        duration: const Duration(seconds: 3),
                      ));
                    },
                  )),
              Divider(),
              ListTile(
                title: Text('기본값으로 복원'),
                onTap: () {
                  setState(() {
                    _prefsManager.reset('enableKeywordHighlight');
                    _prefsManager.reset('highlightedKeywords');
                    _keywords = _prefsManager.get("highlightedKeywords");
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('키워드 설정이 초기화되었습니다.'),
                    duration: const Duration(seconds: 3),
                  ));
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
