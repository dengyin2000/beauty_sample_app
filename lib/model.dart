import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/widgets.dart';

class SelectedIndexModel with ChangeNotifier{
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  PageController _controller = PageController();
  PageController getPageController() => _controller;

  void setSelectedIndex(int index){
    _selectedIndex = index;
    notifyListeners();
  }
}

class Beauty {
  final String thumbURL;
  final String middleURL;
  final int width;
  final int height;
  final String fromPageTitleEnc;

  Beauty(this.thumbURL, this.middleURL, this.width, this.height, this.fromPageTitleEnc);

  Beauty.fromJson(Map<String, dynamic> json):
      thumbURL = json['thumbURL'],
      middleURL = json["middleURL"],
      width = json['width'],
      height = json['height'],
      fromPageTitleEnc = json['fromPageTitleEnc'];


  Map<String, dynamic> toJson() =>
      {
        'thumbURL': thumbURL,
        'middleURL': middleURL,
        'width': width,
        'height': height,
        'fromPageTitleEnc': fromPageTitleEnc
      };
}

Future<List<Beauty>> getBeautysForTab(int index) async{
  String bundleKey = '';
  switch(index) {
    case 0:
      bundleKey = 'assets/cute_beauty.json';
      break;
    case 1:
      bundleKey = 'assets/star_beauty.json';
      break;
    case 2:
      bundleKey = 'assets/sex_beauty.json';
      break;
  }
  var responseText = await rootBundle.loadString(bundleKey);
  Future.delayed(Duration(seconds: 2));
  List responseJson =  jsonDecode(responseText);
  return responseJson.map((m) => Beauty.fromJson(m)).toList();
}
void main(){
  getBeautysForTab(0).then((value){
    print(value);
  });
}