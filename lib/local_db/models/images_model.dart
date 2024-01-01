class ChatMessage {
  final String id;
  final String text;

  ChatMessage({required this.id, required this.text});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }
}