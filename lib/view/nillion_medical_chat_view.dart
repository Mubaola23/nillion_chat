import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nillion_chat/service/nillion_provider.dart';

class NillionGeminiMedicalChatView extends StatefulWidget {
  const NillionGeminiMedicalChatView({super.key});

  @override
  State<NillionGeminiMedicalChatView> createState() =>
      _NillionGeminiMedicalChatViewState();
}

class _NillionGeminiMedicalChatViewState
    extends State<NillionGeminiMedicalChatView> {
  String apiKey = "AIzaSyBgN98INBeeXkQ4_Yfw6Gp9goShqkPbpiE";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text("Medical ChatBot"),
      ),
      body: LlmChatView(
        suggestions: const [
          "I've been feeling dizzy lately. What now?",
          "How do I know if I need to see a doctor?",
          "What should I eat to boost my immunity?",
        ],
        style: LlmChatViewStyle(
          backgroundColor: Colors.white,
          chatInputStyle: ChatInputStyle(
            hintText: "Enter your message",
            decoration: const BoxDecoration().copyWith(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        provider: NillionProvider(
          model: GenerativeModel(
            model: "gemini-2.0-flash",
            apiKey: apiKey,
            systemInstruction: Content.system(
              "You are a professional medical health assistant. Only respond to health and medically related questions and make them concise and straight to the point without too much explanation."
              "If a question is unrelated to health or medicine, politely inform the user that you can only answer medical-related queries.",
            ),
          ),
        ),
        welcomeMessage:
            "Hello👋 I’m here to help with your medical questions. Please tell me how I can assist you.",
      ),
    );
  }
}
