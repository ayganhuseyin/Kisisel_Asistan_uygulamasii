import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(PersonalAssistantApp());

class PersonalAssistantApp extends StatefulWidget {
  @override
  _PersonalAssistantAppState createState() => _PersonalAssistantAppState();
}

class _PersonalAssistantAppState extends State<PersonalAssistantApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kişisel Asistan',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        toggleTheme: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function toggleTheme;

  HomePage({required this.toggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> reminders = [];

  final TextEditingController taskController = TextEditingController();
  final TextEditingController reminderController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String currentTime = '';
  String currentDate = '';
  String weatherInfo = "Şehir adını girin ve hava durumunu öğrenin.";

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      final now = DateTime.now();
      setState(() {
        currentDate = "${now.day}-${now.month}-${now.year}";
        currentTime = "${now.hour}:${now.minute}:${now.second}";
      });
    });
  }

  Future<void> fetchWeather(String city) async {
    final apiKey = "98ea76eb8b2b8deae2ccb5ef80d27a86";
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=${city.trim()}&appid=$apiKey&units=metric&lang=tr";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final description = data['weather'][0]['description'];
        final temp = data['main']['temp'];
        setState(() {
          weatherInfo = "Merhaba, $city'nin hava durumu: $temp°C, $description";
        });
      } else if (response.statusCode == 401) {
        setState(() {
          weatherInfo =
              "API anahtarınız geçersiz veya etkin değil. Lütfen geçerli bir API anahtarı kullanın.";
        });
      } else if (response.statusCode == 404) {
        setState(() {
          weatherInfo = "Şehir bulunamadı. Lütfen şehir adını kontrol edin.";
        });
      } else {
        setState(() {
          weatherInfo = "Bir hata oluştu. Hata kodu: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        weatherInfo =
            "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.";
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDate = date;
          selectedTime = time;
        });
      }
    }
  }

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      setState(() {
        tasks.add({
          'text': taskController.text,
          'completed': false,
          'date':
              "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
          'time':
              "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
        });
        taskController.clear();
        selectedDate = null;
        selectedTime = null;
      });
    }
  }

  void _addReminder() {
    if (reminderController.text.isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      setState(() {
        reminders.add({
          'text': reminderController.text,
          'completed': false,
          'date':
              "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
          'time':
              "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
        });
        reminderController.clear();
        selectedDate = null;
        selectedTime = null;
      });
    }
  }

  void _toggleCompletion(List<Map<String, dynamic>> list, int index) {
    setState(() {
      list[index]['completed'] = !list[index]['completed'];
    });
  }

  void _deleteItem(List<Map<String, dynamic>> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  void _editItem(List<Map<String, dynamic>> list, int index) {
    noteController.text = list[index]['text'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notu Düzenle'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(hintText: 'Notu düzenleyin'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                list[index]['text'] = noteController.text;
              });
              Navigator.of(context).pop();
            },
            child: Text('Kaydet'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
        leading: IconButton(
          icon: Icon(Icons.lightbulb_outline),
          onPressed: () => widget.toggleTheme(),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade200, Colors.blue.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarih: $currentDate',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Saat: $currentTime',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade200,
                            Colors.green.shade400
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Şehir Girin:',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: cityController,
                                  decoration: InputDecoration(
                                    hintText: 'Şehir Adı',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.white),
                                onPressed: () {
                                  final city = cityController.text.trim();
                                  if (city.isNotEmpty) {
                                    fetchWeather(city);
                                  } else {
                                    setState(() {
                                      weatherInfo =
                                          "Lütfen bir şehir adı girin.";
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            weatherInfo,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yeni Görev Ekle:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: taskController,
                                decoration: InputDecoration(
                                  hintText: 'Görev girin',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.date_range,
                                  color: Colors.deepPurple),
                              onPressed: _pickDateTime,
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.deepPurple),
                              onPressed: _addTask,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yeni Hatırlatıcı Ekle:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: reminderController,
                                decoration: InputDecoration(
                                  hintText: 'Hatırlatıcı girin',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.date_range,
                                  color: Colors.deepPurple),
                              onPressed: _pickDateTime,
                            ),
                            IconButton(
                              icon: Icon(Icons.add_alarm,
                                  color: Colors.deepPurple),
                              onPressed: _addReminder,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Görevler:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(tasks[index]['completed']
                            ? Icons.check_circle
                            : Icons.circle_outlined),
                        title: Text(
                          "${tasks[index]['text']} (Tarih: ${tasks[index]['date']} Saat: ${tasks[index]['time']})",
                          style: TextStyle(
                            decoration: tasks[index]['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        onTap: () => _toggleCompletion(tasks, index),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () => _editItem(tasks, index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(tasks, index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                'Hatırlatıcılar:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(reminders[index]['completed']
                            ? Icons.check_circle_rounded
                            : Icons.pending_actions),
                        title: Text(
                          "${reminders[index]['text']} (Tarih: ${reminders[index]['date']} Saat: ${reminders[index]['time']})",
                          style: TextStyle(
                            decoration: reminders[index]['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        onTap: () => _toggleCompletion(reminders, index),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () => _editItem(reminders, index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(reminders, index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Yapımcı: HÜSEYİN AYĞAN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
