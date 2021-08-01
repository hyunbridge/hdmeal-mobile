// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelfCheckSettingsPage extends StatefulWidget {
  @override
  _SelfCheckSettingsPageState createState() => _SelfCheckSettingsPageState();
}

class _SelfCheckSettingsPageState extends State<SelfCheckSettingsPage> {
  ScrollController _scrollController;

  final TextEditingController _nameTextController = new TextEditingController();
  final TextEditingController _birthTextController = new TextEditingController();
  final TextEditingController _passwordTextController = new TextEditingController();

  final _storage = new FlutterSecureStorage();

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

  void _readStorage() async {
    final all = await _storage.readAll();
    _nameTextController.text = all["hcsName"];
    _birthTextController.text = all["hcsBirth"];
    _passwordTextController.text = all["hcsPassword"];
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _readStorage();
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
                  "자가진단 프로필 설정",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '이름',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                  ),
                  controller: _nameTextController,
                  onChanged: (value) => (value.length == 0) ? _storage.delete(key: "hcsName") : _storage.write(key: "hcsName", value: value),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '생년월일(6자리)',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _birthTextController,
                  onChanged: (value) => (value.length == 0) ? _storage.delete(key: "hcsBirth") : _storage.write(key: "hcsBirth", value: value),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '비밀번호',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  controller: _passwordTextController,
                  onChanged: (value) => (value.length == 0) ? _storage.delete(key: "hcsPassword") : _storage.write(key: "hcsPassword", value: value),
                ),
              ),
              Divider(),
              ListTile(
                title: Text('프로필 삭제'),
                onTap: () async {
                  await _storage.delete(key: "hcsName");
                  _nameTextController.clear();

                  await _storage.delete(key: "hcsBirth");
                  _birthTextController.clear();

                  await _storage.delete(key: "hcsPassword");
                  _passwordTextController.clear();
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
