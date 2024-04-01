import 'dart:async';
import 'dart:convert';

//import 'dart:ffi';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'global.dart';


GetIt locator = GetIt.instance;

var app2 = locator<_MyAppState2>();

void setupLocator() {
  locator.registerLazySingleton(() => _MyAppState2());
}


void main() {
   runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
    setupLocator();
    globalActivity activity = globalActivity(name: '', isComplete: false, isactive: false);
    //openfirebase();


    // Add the instance to the list

}

void openfirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  databaseReference = FirebaseDatabase.instance.reference();
  createRecord();
}


void createRecord() {
  databaseReference.child("path").set({
    'key': 'value',
    // Add other key-value pairs you want to save
  });
}

void readData() {
  databaseReference.child("path").once().then((DataSnapshot snapshot) {
    print('Data : ${snapshot.value}');
  } as FutureOr Function(DatabaseEvent value));
}

     void updatemyapp2(String text, String botstate, String sysprompt) {
      app2.changebotstate(botstate, sysprompt);
      app2.callAIEndpoint(text);
     }



final counterStateProvider = StateProvider<int>((ref) {
return 0;
});


Future<Map<String, dynamic>> loadJsonData() async {
  try {
    String jsonString = "";
    if(botid == "claud 3 haiku")
    {
    jsonString = await rootBundle.loadString('assets/data/claud.json');
    }
    else
    {
    jsonString = await rootBundle.loadString('assets/data/claudopus.json');
    }
      Map<String, dynamic> jsonMap = json.decode(jsonString);
        return jsonMap;
    // Use jsonString to parse the JSON.
  } catch (e) {
    print('Failed to load JSON data: $e');
    throw Exception('Failed to load JSON data');
  }
}

Future<List<String>> loadHardcodedData() async {
  String contentString = await rootBundle.loadString('assets/data/hardcoded.txt');
  List<String> lines = contentString.split('\n');
  return lines;
}

class MyHomePage extends ConsumerStatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}




class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    globalBottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Scaffold(
          // The Scaffold widget provides a consistent visual structure to apps.
          body: SafeArea(
            // SafeArea widget is used here to avoid intrusions by the operating system.
            child: MyHomePage(),
          ),
        ),
      ),
    );
  }
}


class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _selectedIndex = 0;

HomeList homelist  = HomeList();

  
static List<Widget> _widgetOptions = <Widget>[
  HomeList(),
  MyApp2(), // Custom widget added here
  SpeechScreen(),
  ActivityList(),
  GeneratorPage(),
  ];

  

void _onItemTapped(int index) {
  setState(() {
    if(index ==  4)
    {
      _selectedIndex = index;
    }
    else
    {
      _selectedIndex = 2;
    }
    ref.read(counterStateProvider.state).state = globalpoints;
    HomeList.update();
  });

  // Increment the provider state whenever a BottomNavigationBar item is tapped.
  // For demonstration, let's increment the counter regardless of which item is tapped.
  // You might want to restrict this action to certain conditions based on your app's logic.
}


 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI'),
        actions: <Widget>[
          // Use Consumer to access and display the counter
          Consumer(builder: (context, ref, _) {
            final points = ref.watch(counterStateProvider);
            return Text("Level ${level}    Points: $points / ${levellist[level - 1]}");
          }),
          SizedBox(width: 50),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'chat'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Activities'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}



class MyApp2 extends StatefulWidget {
  @override
  _MyAppState2 createState() => _MyAppState2();
}

class _MyAppState2 extends State<MyApp2> {
  TextEditingController _controller = TextEditingController();
  String _response = '';
  bool isFirstTime = true; // Add a variable to track the first interaction
  int messagecount = 0;
  String botstate = "normal";
  String sysprompt = "start by asking the user if they would like to engage in the self knowledge tip for the day";
  bool shouldShowButtons = false;
  bool hardcoded = true;
  List<String> hardcodedresponses = [];
  int newheight = 400;
  final ScrollController _scrollController = ScrollController();
  bool IsInputMode = false;
  String buttontext = "Next";
  String button1text = "Yes";
  String button2text = "use ai";
  String button3text = "no";
  int jump = 0;
  bool recordnext = false;
  Map<String, String> recordedanswers = {};
  String answerkey = "";
  late FocusNode focusNodecustom = FocusNode();
  int boxsize = 20;
  String newsysprompt = "";

  void changebotstate(String state, String syspro) {
botstate = state;
if(botstate == "xxx") {
newsysprompt = syspro;
  }
  }

    void _toggleTextFieldFocus() {
    setState(() {
    });
  }



void _onItemTapped() {
      showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Input something',
                  ),
                ),
              ),
              SizedBox(width: 10), // Optional: Adds some space between the text field and button
              ElevatedButton(
                onPressed: () {
                  if(recordnext) {
                    recordedanswers[answerkey] = _controller.text;
                  }
                  if(!IsInputMode || _controller.text.isNotEmpty) {
                    buttontext = "Next";
                  
                    if(!hardcoded) {
                      callAIEndpoint(_controller.text);
                    } else {
                      if(messagecount > -1) {
                        hardcodemessages();
                      } else {
                        
                      }
                      _controller.text = "";
                      messagecount++;
                      if(IsInputMode) {
                        IsInputMode = false;
                      }
                    }
                  }
                  Navigator.pop(context); // Close the modal bottom sheet
                },
                child: Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  },
);

    }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 25),
      curve: Curves.linear,
    );
  }

    void hardcodemessages() async {
    int oldheight = newheight;
    int start = messagecount;
    _response += "\n-------------------------------------------------------------------------\n";
    if(_controller.text.length > 0)
    {
    _response += "user response: ${_controller.text}\n\n";

    _controller.text = "";

    }
                          for (int i = messagecount; i < hardcodedresponses.length; i++)
                          {
                            if(hardcodedresponses[i].contains("--button--"))
                            {
                              String buttontexttypes = hardcodedresponses[i].substring(10, 11).toString();
                              if(buttontexttypes.contains("1"))
                              {
                              button1text = "explore";
                              button2text = "later";
                              button3text = "?";
                              }
                              else if(buttontexttypes.contains("2"))
                              {
                                if(hardcodedresponses[i].contains("jump"))
                                {
                                  int start = hardcodedresponses[i].indexOf("jump")+4;
                                  jump = int.parse(hardcodedresponses[i].substring(start, start+3));
                                }
                                button1text = "yes";
                                button2text = "no";
                                button3text = "take break";
                              }
                              else if(buttontexttypes.contains("3"))
                              {
                                button1text = "explain";
                                button2text = "don't explain";
                                button3text = "?";
                              }
                              toggleButtons();
                              boxsize = 20;
                              break;
                            }
                            if(hardcodedresponses[i].contains("--input here--"))
                            {
                              answerkey = hardcodedresponses[i].substring(14);
                              recordnext = true;

                              buttontext = "Input";
                              break;
                            }
                              _response = "$_response${hardcodedresponses[i]}\n";
                              messagecount = i+1;
                          }
                          newheight = (messagecount - 1) - start;
                          setState(() {
                          _response = _response;
                          newheight = newheight;
                          Timer(const Duration(seconds: 1), () => _scrollToBottom());
                          IsInputMode = true;
      
                          });

                              if(messagecount > 169)
                              {
                                for (String answer in recordedanswers.keys)
                                {
                                  _response += "\n$answer: ${recordedanswers[answer]}\n";
                                }
                              }
  }



    Future<void> callAIEndpoint(String text) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');

      if(botstate == "normal"){
      sysprompt = """use the following data to help the user obtain a goal
      what goal = ${mainanswers["what"]}
      why the goal? = ${mainanswers["why"]}
      how to achieve the goal? = ${mainanswers["how"]}
      when to achieve the goal? = ${mainanswers["when"]}
      plan 3 short (between 5 minute and a day) not broad activities to help them achieve it and when you do wrap it in a 1. 2. and 3. which ends with '|' .
  if you ever ask a question wrap it in a '*' """;
    }

    if(botstate == "xxx"){
      sysprompt = newsysprompt;
    }

    if(botstate == "summerise")
    {
      sysprompt = "summerise the following into a job title";
    }

Map<String, dynamic> myData = await loadJsonData();
  print(myData); // Use your JSON data as needed

    myData["system"] = sysprompt;

    for(int i = 0; i <Userinputs.length; i++)
    {
      myData["messages"].add({"role": "user", "content": Userinputs[i]});
      myData["messages"].add({"role": "assistant", "content": AiOutputs[i]});
    //jsondata = jsondata.replaceFirst("*u", '{"role": "user", "content": "${Userinputs[i]}"}');
    //jsondata = jsondata.replaceFirst("*a", '{"role": "assistant", "content": "${AiOutputs[i]}"}');
    if(i == Userinputs.length-1)
    {
      myData["messages"].add({"role": "user", "content": text});
      break;
     //jsondata = jsondata.replaceFirst("*x", "");
    }
    else
    {
      //jsondata = jsondata.replaceFirst("*x", "*u\n*u\n*a");
    }
    }

    if(Userinputs.length == 0)
    {
      myData["messages"].add({"role": "user", "content": text});
    }

    /*var requestBody = {
      'model': 'claude-3-haiku-20240307',
      'max_tokens': 2048,
      'stream': false,
      'system': sysprompt,
      'messages': [
        {'role': 'user', 'content': text}
      ]
    };*/

    final response = await http.post(
      url,
      headers: {
        'anthropic-version': '2023-06-01',
        'x-api-key': apikey, // Be sure to replace 'YOUR_API_KEY' with your actual API key
        'Content-Type': 'application/json',
      },
      body: jsonEncode(myData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
              if(botstate == "summerise")
        {
          mainanswers["i can do"] = data['content'][0]['text'];
        }
        if(botstate == "xxx")
        {
            Userinputs.add(text);
            AiOutputs.add(data['content'][0]['text']);
            globalresponsehold = "\n\n" + globalresponsehold + "\n\nUSER: ${text} \n\nAI: ${data['content'][0]['text']}";
            globalresponse = data['content'][0]['text'];
        }
        else if (botstate == "normal")
        {
      
      setState(() {
        if(botstate == "normal")
        {
        toggleButtons();
        if (!isFirstTime) {
        }
        String mainstring = data['content'][0]['text'].toString();
        if(mainstring.contains("1."))
        {
          String newstring = mainstring.toString();
          int startindex = newstring.indexOf("1.");
          int endindex = newstring.indexOf("|", startindex);
          newstring = newstring.substring(startindex + 2, endindex);
          globalActivity activity = globalActivity(name: newstring, isComplete: false);
          globalactivities.add(activity);
        }
                if(mainstring.contains("2."))
        {
          String newstring = mainstring.toString();
          int startindex = newstring.indexOf("2.");
          int endindex = newstring.indexOf("|", startindex);
          newstring = newstring.substring(startindex + 2, endindex);
          globalActivity activity = globalActivity(name: newstring, isComplete: false);
          globalactivities.add(activity);
        }
                if(mainstring.contains("3."))
        {
          String newstring = mainstring.toString();
          int startindex = newstring.indexOf("3.");
          int endindex = newstring.indexOf("|", startindex);
          newstring = newstring.substring(startindex + 2, endindex);
          globalActivity activity = globalActivity(name: newstring, isComplete: false);
          globalactivities.add(activity);
        }

        botstate = "normal";
        isFirstTime = false;
        _response = "$_response\n\nUser: $text\n\nAI: " + data['content'][0]['text'];
        Userinputs.add(text);
        AiOutputs.add(_response);
        _scrollToBottom();
        }

      });
    }
    }
    else
    {
    print('Request failed with status: ${response.statusCode}.');
    }

    
    }

          @override
  void initState() {
    super.initState();
    loadHardcodedData().then((loadedResponses) {
      setState(() {
        hardcodedresponses = loadedResponses;
        focusNodecustom.canRequestFocus = false;
        setState(() {
                          _response = """Are you happy to engage in todays self knowledge session?""";
                          toggleButtons();
                        });
      });
    });
  }



  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true, // Default value is true
        body: Center(
          child: Column(
            children: [
              Container(
                height: 430, // Fixed height for the SingleChildScrollView
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _response,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: boxsize.toDouble()),
              if (shouldShowButtons) // Conditional rendering of buttons
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if(jump > 0)
                          {
                            messagecount = jump;
                            jump = 0;

                          }
                          hardcodemessages();
                          toggleButtons();
                          boxsize = 45;
                          messagecount++;
                        },
                        child: Text(button1text,
                        )
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          print(messagecount);
                          if(messagecount == 0)
                          {
                            hardcoded = false;
                            botstate = "normal";
                            callAIEndpoint("state my goal and the what, why, how, when of it");
                          }
                            if(jump > 0)
                          {
                            jump = 0;

                
                          hardcodemessages();
                          toggleButtons();
                          boxsize = 45;
                          messagecount++;
                          }
                          // Button logic here
                        },
                        child: Text(button2text,),
                        style: ElevatedButton.styleFrom(
    minimumSize: Size(10, 40), // Set the minimum size
  ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Button logic here
                        },
                        child: Text(button3text),
                        style: ElevatedButton.styleFrom(
    minimumSize: Size(10, 40), // Set the minimum size
  ),
                      ),
                    ],
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                    
                    child:
                     TextField(
                      readOnly: true,
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter text',
                      ),
                      onTap:_onItemTapped,
                    ),
                  ),
        
                ],
              ),
            ),
      ),
    );
  }

  void toggleButtons() {
    setState(() {
      shouldShowButtons = !shouldShowButtons;
    });
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  _GeneratorPage createState() => _GeneratorPage();
}

class _GeneratorPage extends State<GeneratorPage> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();
  TextEditingController _controller5 = TextEditingController();
  TextEditingController _controller6 = TextEditingController();
  IconData _icon = Icons.save; // Initial icon
  String inputtext = "";

   String dropdownValue = 'claud 3 haiku';

  // List of items in our dropdown menu
  var items = [
    'claud 3 haiku',
    'claud 3 opus',
  ];



    void _changeIcon() {
    setState(() {
      // Toggle icon as an example
      if (_icon == Icons.save) {
        _icon = Icons.check;
      } else {
        _icon = Icons.save;
      }
    });
  }

    void addtomemory()
  {
    setState(() {
    mainanswers["what"] = _controller1.text.toString();
    mainanswers["why"] = _controller2.text;
    mainanswers["how"] = _controller3.text;
    mainanswers["when"] = _controller4.text;
    mainanswers["i can do"] = _controller4.text;
    });
  }


@override
  void initState() {
    setState(() {
      _controller1.text = mainanswers["what"];
      _controller2.text = mainanswers["why"];
      _controller3.text = mainanswers["how"];
      _controller4.text = mainanswers["when"];
      _controller5.text = mainanswers["i can do"];
      _controller6.text = apikey;
    });
    // TODO: implement initState
    super.initState();
  }
  

  void _onItemTapped(TextEditingController controller, BuildContext context, String inputtext) {
      showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: inputtext,
                  ),
                ),
              ),
              SizedBox(width: 10), // Optional: Adds some space between the text field and button
              ElevatedButton(
                onPressed: () {
                  addtomemory();
                  if(inputtext == "what are you good at?")
                  {
                    updatemyapp2(controller.text.toString(), "summerise", "none");
                  }
                  if(inputtext == "API KEY")
                  {
                    apikey = controller.text.toString();
                  }
                  Navigator.pop(context); // Close the modal bottom sheet
                },
                child: Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
    );
  },
);

  }


  @override
Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( // Added for scrollability
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                TextField(
                        readOnly: true,
                        onTap: () => _onItemTapped(_controller1, context, "what is your goal?"),
                        controller: _controller1,
                        decoration: InputDecoration(
                          labelText: 'what is your goal?',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        readOnly: true,
                        onTap: () =>  _onItemTapped(_controller2, context, "why is it your goal?"),
                        controller: _controller2,
                        decoration: InputDecoration(
                          labelText: 'why is it your goal?',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        readOnly: true,
                        onTap: () => _onItemTapped(_controller3, context, "how are you going to achieve your goal?"),
                        controller: _controller3,
                        decoration: InputDecoration(
                          labelText: 'how are you going to achieve your goal?',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        readOnly: true,
                        onTap: () => _onItemTapped(_controller4, context, "when are you going to achieve your goal?"),
                        controller: _controller4,
                        decoration: InputDecoration(
                          labelText: 'when are you going to achieve your goal?',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        readOnly: true,
                        onTap: () => _onItemTapped(_controller5, context, "what are you good at?"),
                        controller: _controller5,
                        decoration: InputDecoration(
                          labelText: 'what are you good at?',
                        ),
                      ),
                      SizedBox(height: 30.0),
                      TextField(
                        readOnly: true,
                        onTap: () => _onItemTapped(_controller6, context, "API KEY"),
                        controller: _controller6,
                        decoration: InputDecoration(
                          labelText: 'API KEY',
                        ),
                      ),
              DropdownButton<String>(
      // Not necessary for Option 1
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = newValue!;
          botid = newValue;
        });
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList()),
              SizedBox(height: 60.0),
              ElevatedButton(
                onPressed: () {
                  addtomemory();
                  _changeIcon();
                },
                child: Icon(_icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ActivityList extends ConsumerStatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends ConsumerState<ActivityList> {
   final AudioPlayer audioPlayer = AudioPlayer();

  void playAudio() async {
    await audioPlayer.play(AssetSource('audio/cash.mp3'));
    // Make sure you have added the audio file to your assets and updated pubspec.yaml accordingly
  }

  //List<Activity> activities = [];

  @override
  void initState() {
    super.initState();

    // Create an instance of Activity
  }

    // Verifying the addition (moved inside initState)
  // Function to toggle completion status
  void toggleCompletion(int index, WidgetRef ref) {
    setState(() {
            if(!globalactivities[index].isComplete){
                          globalactivities[index].isComplete = true;
      globalpoints += 100;
      if(globalpoints >= levellist[level-1]){
        level += 1;
        //globalpoints = 0;
      }
      ref.read(counterStateProvider.state).state = globalpoints;
      playAudio();
            }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity List'),
      ),
      body: ListView.builder(
        itemCount: globalactivities.length,
        itemBuilder: (context, index) {
          final activity = globalactivities[index];
          return Card(
            color: activity.isComplete ? Colors.green : null, // Change color if complete
            child: ListTile(
              title: Text(activity.name),
              trailing: IconButton(
                icon: Icon(
                  activity.isComplete ? Icons.check : Icons.close,
                  color: const Color.fromARGB(255, 129, 129, 129),
                ),
                onPressed: () => toggleCompletion(index, ref),
              ),
            ),
          );
        },
      ),
    );
  }
}
  

class HomeList extends ConsumerStatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();

    static void update()
  {
  }
}

class _HomeListState extends ConsumerState<HomeList> {
  //List<Activity> activities = [];
  int count = 0;




  @override
  void initState() {
    super.initState();
             setState(() {
              if(globalactivities.length > 0)
              globalcount = 1;
  });
  }

    // Verifying the addition (moved inside initState)
  // Function to toggle completion status
  void toggleCompletion(int index, WidgetRef ref) {
    setState(() {
            if(!globalactivities[index].isComplete){
                          globalactivities[index].isComplete = true;
      globalpoints += 100;
      ref.read(counterStateProvider.state).state = globalpoints;
            }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home List'),
      ),
     body: Column(
      children: <Widget>[
        Expanded(
          // Use Expanded to make the ListView take up all available space except for the button
          child: ListView.builder(
            itemCount: globalcount, // Update this with your actual item count
            itemBuilder: (context, index) {
              final activity = globalactivities[index];
              if(globalactivities.length > 0){globalcount = 3;}
              return Card(
                color: activity.isComplete ? Colors.green : null, // Change color if complete
                child: ListTile(
                  title: Text(activity.name),
                  trailing: IconButton(
                    icon: Icon(
                      activity.isComplete ? Icons.check : Icons.circle,
                      color: const Color.fromARGB(255, 129, 129, 129),
                    ),
                    onPressed: () {
                      count++;
                      // Your toggle completion logic here
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0), // Add some padding around the button
          child: ElevatedButton(
            onPressed: () {
              // Your button action here
            },
            child: Text('Use Ai'),
          ),
        ),
      ],
    ),
  );
  }
}



class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Flag to track if listening
  String _text = 'Press the button and start speaking'; // Displayed text
  TextEditingController _controller = TextEditingController(); // Controller for the input field
  String _spokentext = ""; // Stores recognized speech
  Timer? _silenceTimer; // Timer for detecting silence
  FlutterTts flutterTts = FlutterTts(); // Text-to-speech instance
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder(); // Sound recorder instance
  bool _isRecording = false; // Flag to track if currently recording
  bool Monitoring = true;
  final List<MaterialColor> recordingcolors = [Colors.red, Colors.blue, Colors.yellow, Colors.green];
  int colorindex = 0;
  String adventuretext = "you are to act as a text adventure.\nfollow the following rules.\n1. first thing you do is ask the player what setting they would like and set that as the story setting\n2. Next ask them what weapon they would like\n3. when you find enemies state their level from 1-10, and have enemies every few prompts\n4. allow the player to do whatever\n5. make stupid actions kill the player\n6. make each response less than 20 words\n7. describe a background sound for response and describe it in 2 words and surrond that in '*'";
  bool keepmessages = true;
  Timer? _listeningTimeout;
  bool usingmic = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initRecorder(); // Initialize the recorder
    initializeTts();
  }

   void initializeTts() {
    flutterTts.setCompletionHandler(() {
    if(usingmic){
      _stopListening();
      _stopRecording();
      _listen();
      }
      // Here you can handle the completion event, such as updating the UI
    });
   }

  // Initialize the sound recorder
  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(Duration(milliseconds: 250));
  }
  

  // Start recording sound
  void _startRecording() async {
    colorindex = 1;
    Monitoring = true;
    await _recorder.startRecorder(
      toFile: 'sound_level_monitor.aac',
      codec: Codec.aacADTS,
    );
    // Listen for recording progress to monitor sound level
    _recorder.onProgress!.listen((e) {
      final soundLevel = e.decibels; // Use decibels as a proxy for sound level
      //_text = soundLevel.toString();
      setState(() {
        //_text = 'Sound Level: $soundLevel dB'; // Update displayed text with sound level
        if(soundLevel! > 66 && Monitoring == true){
          _listen();
          Monitoring = false;
          //_text = "speak now";
          //
          _stopRecording();
          colorindex = 2;
          return;
        }
      });
    });
    setState(() => _isRecording = true);
  }

  // Stop recording sound
  void _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
  }

  // Convert text to speech
  Future speak(String text) async {
    flutterTts.setVolume(0.10);
    var result = await flutterTts.speak(text);
    //_listen();
    if (result == 1) {
      print("Successfully played text.");
    } else {
      print("Failed to play text.");
    }
  }

  // Start or stop listening to speech input
  void _listen() async {
    _isListening = false;
    if(keepmessages == false)
    {
      Userinputs.clear();
      AiOutputs.clear();
    }
    colorindex = 2;
    if (!_isListening) {
      bool available = await _speech.initialize(

    );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          partialResults: false,
          
          onResult: (val) {
            setState(() {
              _spokentext = val.recognizedWords;
              _text = "waiting...";
              colorindex = 3;
              updatemyapp2(_spokentext, "xxx", _controller.text);
              _cancelListeningTimeout();


            });
            _resetSilenceTimer(); // Reset silence timer on new speech input
            _cancelListeningTimeout();
          },
        );
      }
    } else {
      _stopListening();
    }
    if(colorindex != 3 || colorindex!= 4)
    {
    _startListeningTimeout();
    }
  }

  void _startListeningTimeout() {
    _cancelListeningTimeout(); // Prevent multiple timeouts running simultaneously
    _listeningTimeout = Timer(Duration(seconds: 4), () {
      // This code is executed if no speech is detected within 10 seconds
      print("No speech detected!");
      setState(() {
        _listen();
      });
      _stopListening();
    });
  }

  void _cancelListeningTimeout() {
    _listeningTimeout?.cancel();
  }

  // Reset the silence detection timer
  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(Duration(seconds: 2), () {
      if (globalresponse.isNotEmpty) {
        setState(() => _text = globalresponsehold);
        speak(globalresponse); // Convert the recognized text to speech
        colorindex = 0;
        //_stopListening();
        globalresponse = ""; // Stop listening after silence
        _stopListening();
        _startRecording();
        //_listen(); // Restart listening for new input
      } else {
        reset(); // Reset if no speech was detected
        _stopListening();
        _startRecording();
      }
    });
  }

  // Helper function to reset the app state
  void reset() {
    _resetSilenceTimer();
  }

  // Stop listening to speech input
  void _stopListening() {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
      _silenceTimer?.cancel();
    }
  }

  void _resetmessages()
  {
    Userinputs.clear();
    AiOutputs.clear();
    globalresponsehold = "";
  }

  // Dispose resources
  @override
  void dispose() {
    super.dispose();
    _silenceTimer?.cancel();
  }

  _switchmicmode()
  {
    if(usingmic == false)
    {
      usingmic = true;
      _listen();
    }
    else
    {
      usingmic = false;
      _cancelListeningTimeout();
      _stopListening();
      _stopRecording();
      _speech.cancel();
      colorindex = 0;
    }
  }

  // UI Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Demo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _switchmicmode,
        backgroundColor: recordingcolors[colorindex], // Toggle listening state
        child: Icon(_isListening ? Icons.circle : Icons.circle),
      ),
      
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'System prompt'),
          ),
        Row(
          children: [
            FloatingActionButton(
            onPressed: _resetmessages, // Toggle listening state
            child: Icon(Icons.refresh)
            ),
            FloatingActionButton(
            onPressed: (){_controller.text = adventuretext;}, // Toggle listening state
            child: Icon(Icons.gamepad),
            ),
          ],
        ),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
                child: Text(_text), // Display the current text
              ),
            ),
          ),
        ],
      ),
    );
  }
}