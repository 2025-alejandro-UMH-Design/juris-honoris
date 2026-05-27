import 'package:equatable/equatable.dart';

class AIProviderConfig extends Equatable {
  final String key;
  final String name;
  final String description;
  final bool isEnabled;
  final bool isActive;
  final String apiKey;
  final String model;
  final List<String> availableModels;
  final String logoEmoji;

  const AIProviderConfig({
    required this.key,
    required this.name,
    required this.description,
    this.isEnabled = false,
    this.isActive = false,
    this.apiKey = '',
    required this.model,
    required this.availableModels,
    required this.logoEmoji,
  });

  AIProviderConfig copyWith({
    String? key,
    String? name,
    String? description,
    bool? isEnabled,
    bool? isActive,
    String? apiKey,
    String? model,
    List<String>? availableModels,
    String? logoEmoji,
  }) {
    return AIProviderConfig(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      isActive: isActive ?? this.isActive,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      availableModels: availableModels ?? this.availableModels,
      logoEmoji: logoEmoji ?? this.logoEmoji,
    );
  }

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  static List<AIProviderConfig> get defaults => const [
        AIProviderConfig(
          key: 'groq',
          name: 'Groq',
          description: 'Llama 3.3 70B — Rápido y gratuito',
          logoEmoji: '⚡',
          availableModels: [
            'llama-3.3-70b-versatile',
            'llama-3.1-8b-instant',
            'mixtral-8x7b-32768',
          ],
          model: 'llama-3.3-70b-versatile',
          isEnabled: false,
          isActive: false,
          apiKey: '',
        ),
        AIProviderConfig(
          key: 'openai',
          name: 'OpenAI (ChatGPT)',
          description: 'GPT-4o Mini — Balance calidad/precio',
          logoEmoji: '🤖',
          availableModels: [
            'gpt-4o-mini',
            'gpt-4o',
            'gpt-3.5-turbo',
          ],
          model: 'gpt-4o-mini',
          isEnabled: false,
          isActive: false,
          apiKey: '',
        ),
        AIProviderConfig(
          key: 'deepseek',
          name: 'DeepSeek',
          description: 'DeepSeek Chat — Económico y eficiente',
          logoEmoji: '🔍',
          availableModels: [
            'deepseek-chat',
            'deepseek-reasoner',
          ],
          model: 'deepseek-chat',
          isEnabled: false,
          isActive: false,
          apiKey: '',
        ),
        AIProviderConfig(
          key: 'anthropic',
          name: 'Claude (Anthropic)',
          description: 'Claude 3.5 Haiku — Alta calidad legal',
          logoEmoji: '🎭',
          availableModels: [
            'claude-3-5-haiku-20241022',
            'claude-3-5-sonnet-20241022',
          ],
          model: 'claude-3-5-haiku-20241022',
          isEnabled: false,
          isActive: false,
          apiKey: '',
        ),
      ];

  @override
  List<Object?> get props => [
        key,
        name,
        description,
        isEnabled,
        isActive,
        apiKey,
        model,
        availableModels,
        logoEmoji,
      ];
}
