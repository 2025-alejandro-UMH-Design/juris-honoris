import 'package:flutter/material.dart';

class ClientLawyerChatPage extends StatefulWidget {
  final String lawyerName;
  final String caseType;
  final String lawyerId;

  const ClientLawyerChatPage({
    super.key,
    required this.lawyerName,
    required this.caseType,
    required this.lawyerId,
  });

  @override
  State<ClientLawyerChatPage> createState() => _ClientLawyerChatPageState();
}

class _ClientLawyerChatPageState extends State<ClientLawyerChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(
      text: 'Hola, soy su abogado asignado. He revisado su caso y estoy listo para ayudarle. ¿Podría contarme más detalles sobre su situación?',
      isUser: false,
      time: '09:00',
    ),
    _ChatMsg(
      text: 'Muchas gracias por atenderme. Mi situación es la siguiente...',
      isUser: true,
      time: '09:02',
    ),
    _ChatMsg(
      text: 'Entiendo. Para proceder necesitaré que me envíe los siguientes documentos: acta de matrimonio, DUI vigente y comprobante de domicilio.',
      isUser: false,
      time: '09:05',
    ),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(
        text: text,
        isUser: true,
        time: TimeOfDay.now().format(context),
      ));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D5BA8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lawyerName,
              style: const TextStyle(
                color: Color(0xFF212121),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Caso: ${widget.caseType}',
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF0D5BA8)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Información del caso'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Abogado', widget.lawyerName),
                      _infoRow('Tipo de caso', widget.caseType),
                      _infoRow('Estado', 'En progreso'),
                      _infoRow('Iniciado', '27 May 2026'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFDDDDDD),
          ),
        ),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            color: const Color(0xFFE3F2FD),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: Color(0xFF0D5BA8)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Conversación confidencial y protegida',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D5BA8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildBubble(msg);
              },
            ),
          ),
          // Input
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFDDDDDD))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF757575)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adjuntar archivos — próximamente')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(color: Color(0xFFA8A8A8)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D5BA8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMsg msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: msg.isUser ? 48 : 0,
          right: msg.isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF0D5BA8) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : const Color(0xFF212121),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: TextStyle(
                color: msg.isUser
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF999999),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  final String time;
  const _ChatMsg({required this.text, required this.isUser, required this.time});
}
