import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/config/theme.dart';
import '../../../../../core/config/supabase_config.dart';
import '../../domain/entities/mensaje.dart';
import '../providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String incidenteId;
  final String incidenteTipo;

  const ChatPage({
    super.key,
    required this.incidenteId,
    this.incidenteTipo = 'Incidente',
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final Stream<List<MensajeEntity>> _mensajesStream;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ChatProvider>();
    _mensajesStream = provider.streamMensajes(widget.incidenteId);
    provider.getMensajes(widget.incidenteId);
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    setState(() => _enviando = true);

    try {
      await context.read<ChatProvider>().enviarMensaje(
            widget.incidenteId,
            currentUserId,
            texto,
          );
      _mensajeController.clear();
      _focusNode.requestFocus();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar mensaje: $e')),
        );
      }
    }

    setState(() => _enviando = false);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.incidenteTipo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatProvider>().getMensajes(widget.incidenteId);
            },
            tooltip: 'Recargar mensajes',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MensajeEntity>>(
              stream: _mensajesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  final cachedMensajes = chatProvider.mensajes;
                  if (cachedMensajes.isNotEmpty) {
                    return _buildMensajesList(cachedMensajes);
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  final cachedMensajes = chatProvider.mensajes;
                  if (cachedMensajes.isNotEmpty) {
                    return _buildMensajesList(cachedMensajes);
                  }
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Error de conexión: ${snapshot.error}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ChatProvider>()
                                .getMensajes(widget.incidenteId);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final mensajes = snapshot.data ?? [];
                if (mensajes.isEmpty) {
                  final cachedMensajes = chatProvider.mensajes;
                  if (cachedMensajes.isNotEmpty) {
                    _scrollToBottom();
                    return _buildMensajesList(cachedMensajes);
                  }

                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sé el primero en enviar un mensaje',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                _scrollToBottom();
                return _buildMensajesList(mensajes);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMensajesList(List<MensajeEntity> mensajes) {
    final currentUserId = SupabaseConfig.client.auth.currentUser?.id;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: mensajes.length,
      itemBuilder: (context, index) {
        final msg = mensajes[index];
        final isMine = msg.emisorId == currentUserId;
        return _buildBubble(msg, isMine);
      },
    );
  }

  Widget _buildBubble(MensajeEntity msg, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.secondaryColor : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMine ? Radius.zero : const Radius.circular(16),
          ),
        ),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.emisorNombre != null && !isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  msg.emisorNombre!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isMine ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            Text(
              msg.mensaje,
              style: TextStyle(
                fontSize: 15,
                color: isMine ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                msg.fecha != null ? _formatTime(msg.fecha!) : '',
                style: TextStyle(
                  fontSize: 10,
                  color: isMine ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mensajeController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _enviarMensaje(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: _enviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _enviando ? null : _enviarMensaje,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
