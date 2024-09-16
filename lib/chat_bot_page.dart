import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(
          "Welcome! I'm here to help with Monkey Pox diagnosis and information. You can upload an image for diagnosis or ask me questions about Monkey Pox symptoms, treatment, or prevention.");
    });
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({'bot': message});
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({'user': message});
    });
    _processUserMessage(message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
      await _sendImageToApi(image);
    }
  }

  Future<void> _sendImageToApi(XFile image) async {
    final String apiUrl = 'https://your-api-endpoint.com/predict';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonResponse = json.decode(responseString);

        String prediction = jsonResponse['prediction'];
        _addBotMessage("Based on the image analysis, $prediction");
      } else {
        _addBotMessage("Failed to analyze the image. Please try again.");
      }
    } catch (e) {
      _addBotMessage("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: _messages.map((message) {
                  final isUserMessage = message.containsKey('user');
                  final isImage = message['isImage'] == true;

                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Color(0xFF90CAF9)
                            : Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: isImage
                          ? Image.file(File(message['user']), height: 150)
                          : Text(
                              message.values.first,
                              style: TextStyle(
                                color: isUserMessage
                                    ? Colors.black87
                                    : Color(0xFF1E88E5),
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
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
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
