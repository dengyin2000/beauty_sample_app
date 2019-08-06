import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

