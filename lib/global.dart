// lib/global.dart
library globals;

import 'package:firebase_database/firebase_database.dart';

int level = 1;

List<int> levellist = [200, 2000, 4000, 8000, 20000];

int globalpoints = 0;

String apikey = "claud api key";

String globalresponse = "";

String globalresponsehold = "";


bool keepmessages = true;

List<String> Userinputs = [];
List<String> AiOutputs = [];

//final counterProvider = StateProvider<int>((globalref) => 0);

late DatabaseReference databaseReference;

int globalcount = 0;

bool globalupdate = false;

String botid ="claud 3 haiku";



double globalBottomPadding = 0;
  Map<String, dynamic> mainanswers = {
    "what": "",
    "why": "",
    "how": "",
    "when": "",
    "i can do": "",
  };

class globalActivity {
  String name;
  bool isComplete;
  bool isactive;

  globalActivity({required this.name, this.isComplete = false, this.isactive = false});
}

  List<globalActivity> globalactivities = [];


  globalActivity globalactivity = globalActivity(name: 'Activity 1', isComplete: false, isactive: false);

    // Add the instance to the list

  // ignore: camel_case_types
setstate()
{
        globalactivities.add(globalactivity);
        }