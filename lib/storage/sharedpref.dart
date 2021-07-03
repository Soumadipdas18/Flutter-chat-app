import 'package:shared_preferences/shared_preferences.dart';

class sharedpref {
  Future<bool> saveListOfChats(List<dynamic> mList) async {
    List<String> stringsList = mList.map((i) => i.toString()).toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList("stringList", stringsList);
  }

  Future<List<String>?> getListOfChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getStringList("stringList");
  }
}
