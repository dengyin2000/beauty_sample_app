import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        title: 'Beauty gallery',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Beauty gallery'),
      ),
      providers: [
        ChangeNotifierProvider<SelectedIndexModel>.value(
            value: SelectedIndexModel()),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<SelectedIndexModel>(
        builder:
            (BuildContext context, SelectedIndexModel value, Widget child) {
          return Column(
            children: <Widget>[
              TabBarWidget(),
              Expanded(
                child: PageView(
                  onPageChanged: (int page) {
                    value.setSelectedIndex(page);
                  },
                  controller: value.getPageController(),
                  children: <Widget>[
                    BeautyListWidget(
                      tabIndex: 0,
                    ),
                    BeautyListWidget(
                      tabIndex: 1,
                    ),
                    BeautyListWidget(
                      tabIndex: 2,
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

typedef OnTabBarTabSelectedCallback = Function(int index);

class TabBarWidget extends StatefulWidget {
  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TabWidget(
            label: "清纯美女",
            value: 0,
          ),
        ),
        Expanded(
          child: TabWidget(
            label: "美女明星",
            value: 1,
          ),
        ),
        Expanded(
          child: TabWidget(
            label: "性感美女",
            value: 2,
          ),
        )
      ],
    );
  }
}

class TabWidget extends StatefulWidget {
  final String label;
  final int value;
  final int selectedIndex;

  const TabWidget({Key key, this.label, this.value, this.selectedIndex})
      : super(key: key);

  @override
  _TabWidgetState createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedIndexModel>(builder:
        (BuildContext context, SelectedIndexModel value, Widget child) {
      return Container(
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            SizedBox(
              child: FlatButton(
                  onPressed: () {
                    value.setSelectedIndex(widget.value);
                    value.getPageController().animateToPage(widget.value,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.fastOutSlowIn);
                  },
                  child: Text(widget.label)),
              width: double.infinity,
            ),
            Visibility(
              visible: value.selectedIndex == widget.value,
              child: SizedBox(
                width: double.infinity,
                height: 4,
                child: Container(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

class BeautyListWidget extends StatefulWidget {
  final int tabIndex;

  const BeautyListWidget({Key key, this.tabIndex}) : super(key: key);
  @override
  _BeautyListWidgetState createState() => _BeautyListWidgetState();
}

class _BeautyListWidgetState extends State<BeautyListWidget> with AutomaticKeepAliveClientMixin<BeautyListWidget> {

  Future<List<Beauty>> _future;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<Beauty>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<Beauty>> snapshot) {
        var connectionState = snapshot.connectionState;
        if (connectionState == ConnectionState.done && snapshot.hasData) {
          var data = snapshot.data;
          return GridView.builder(
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, ),
            itemBuilder: (BuildContext context, int index) {
              return FadeInImage.assetNetwork(placeholder: 'assets/loading.png', image: data[index].thumbURL);
            },
            itemCount: data.length,
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _future = getBeautysForTab(widget.tabIndex);
  }

  @override
  bool get wantKeepAlive => true;
}

