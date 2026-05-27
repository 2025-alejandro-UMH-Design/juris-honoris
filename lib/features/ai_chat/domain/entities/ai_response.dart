import 'package:equatable/equatable.dart';

class AIResponse extends Equatable {
  final String message;
  final bool needsLawyer;
  final String cleanMessage;

  const AIResponse({
    required this.message,
    required this.needsLawyer,
    required this.cleanMessage,
  });

  /// Parsea la respuesta cruda del modelo, extrayendo el tag [NECESITA_ABOGADO: SI/NO].
  /// Si el tag no está presente, asume que no necesita abogado y usa el mensaje completo.
  factory AIResponse.fromRaw(String rawResponse) {
    const tagSi = '[NECESITA_ABOGADO: SI]';
    const tagNo = '[NECESITA_ABOGADO: NO]';

    bool needsLawyer = false;
    String cleanMessage = rawResponse.trim();

    if (rawResponse.contains(tagSi)) {
      needsLawyer = true;
      cleanMessage = rawResponse.replaceAll(tagSi, '').trim();
    } else if (rawResponse.contains(tagNo)) {
      needsLawyer = false;
      cleanMessage = rawResponse.replaceAll(tagNo, '').trim();
    }

    // Elimina líneas vacías finales que puedan quedar tras remover el tag
    cleanMessage = cleanMessage.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    return AIResponse(
      message: rawResponse,
      needsLawyer: needsLawyer,
      cleanMessage: cleanMessage,
    );
  }

  @override
  List<Object?> get props => [message, needsLawyer, cleanMessage];
}
