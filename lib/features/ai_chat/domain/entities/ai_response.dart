import 'package:equatable/equatable.dart';

class AIResponse extends Equatable {
  final String message;
  final bool needsLawyer;
  final String cleanMessage;
  final String? specialty;

  const AIResponse({
    required this.message,
    required this.needsLawyer,
    required this.cleanMessage,
    this.specialty,
  });

  factory AIResponse.fromRaw(String rawResponse, {String? specialty}) {
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

    cleanMessage = cleanMessage.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    return AIResponse(
      message: rawResponse,
      needsLawyer: needsLawyer,
      cleanMessage: cleanMessage,
      specialty: specialty,
    );
  }

  @override
  List<Object?> get props => [message, needsLawyer, cleanMessage, specialty];
}
