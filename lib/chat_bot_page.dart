import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key, required this.title});

  final String title;

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Welcome! I'm here to help with Monkey Pox diagnosis and information. You can upload an image for diagnosis or ask me questions about Monkey Pox symptoms, treatment, or prevention.");
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({'bot': message});
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({'user': message});
    });
    _processUserMessage(message);
  }

  void _processUserMessage(String message) {
    String lowercaseMessage = message.toLowerCase();
    if (lowercaseMessage.contains('symptom')) {
      _addBotMessage("Common symptoms of Monkey Pox include:\n"
          "• Fever\n"
          "• Headache\n"
          "• Muscle aches\n"
          "• Swollen lymph nodes\n"
          "• Rash or skin lesions\n\n"
          "The rash typically begins on the face and spreads to other parts of the body.");
    } else if (lowercaseMessage.contains('treatment') ||
        lowercaseMessage.contains('medication')) {
      _addBotMessage(
          "There's no specific treatment for Monkey Pox. However, the following can help manage symptoms:\n"
          "• Antiviral medications (in severe cases)\n"
          "• Pain relievers\n"
          "• Fluids to prevent dehydration\n"
          "• Antihistamines for itching\n\n"
          "Most people recover within 2-4 weeks without specific treatment.");
    } else if (lowercaseMessage.contains('prevent')) {
      _addBotMessage("To prevent Monkey Pox:\n"
          "• Avoid close contact with infected animals or people\n"
          "• Practice good hand hygiene\n"
          "• Use personal protective equipment when caring for infected individuals\n"
          "• Isolate infected individuals\n"
          "• Consider vaccination if you're at high risk of exposure");
    } else if (lowercaseMessage.contains('diagnos')) {
      _addBotMessage(
          "For a Monkey Pox diagnosis, please upload a clear image of the affected area. I'll analyze it and provide my assessment.");
    } else {
      _addBotMessage(
          "I'm not sure how to respond to that. You can ask me about Monkey Pox symptoms, treatment, prevention, or upload an image for diagnosis.");
    }
  }

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.add({'user': image.path, 'isImage': true});
      });
      _simulateDiagnosis();
    }
  }

  void _simulateDiagnosis() {
    Future.delayed(Duration(seconds: 2), () {
      _addBotMessage(
          "Based on the image you provided, it appears that you do not have typical Monkey Pox lesions. However, for a definitive diagnosis, please consult with a healthcare professional. If you have any concerns or develop symptoms, seek medical attention promptly.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Color(0xFFF5F5F5),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUserMessage = message.containsKey('user');
                  final isImage = message['isImage'] == true;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          minWidth: 0,
                        ),
                        child: Card(
                          color: isUserMessage
                              ? Color(0xFF90CAF9)
                              : Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isImage
                                ? Image.file(File(message['user']), height: 150)
                                : Text(
                                    message.values.first,
                                    style: TextStyle(
                                        color: isUserMessage
                                            ? Colors.black87
                                            : Color(0xFF1E88E5)),
                                    softWrap: true,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.image, color: Color(0xFF1E88E5)),
                    onPressed: _uploadImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Color(0xFF1E88E5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          _addUserMessage(text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xFF1E88E5)),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _addUserMessage(_controller.text);
                        _controller.clear();
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
