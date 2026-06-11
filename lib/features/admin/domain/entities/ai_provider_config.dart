class AIProviderConfig {
  final String key;
  final String name;
  final String logoEmoji;
  final String description;
  final String apiKey;
  final String model;
  final List<String> availableModels;
  final bool isEnabled;
  final bool isActive;

  const AIProviderConfig({
    required this.key,
    required this.name,
    required this.logoEmoji,
    required this.description,
    required this.apiKey,
    required this.model,
    required this.availableModels,
    required this.isEnabled,
    required this.isActive,
  });

  AIProviderConfig copyWith({
    String? apiKey,
    String? model,
    bool? isEnabled,
    bool? isActive,
  }) {
    return AIProviderConfig(
      key: key,
      name: name,
      logoEmoji: logoEmoji,
      description: description,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      availableModels: availableModels,
      isEnabled: isEnabled ?? this.isEnabled,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'logoEmoji': logoEmoji,
    'description': description,
    'apiKey': apiKey,
    'model': model,
    'availableModels': availableModels,
    'isEnabled': isEnabled,
    'isActive': isActive,
  };

  factory AIProviderConfig.fromJson(Map<String, dynamic> j) {
    return AIProviderConfig(
      key: j['key'] as String,
      name: j['name'] as String,
      logoEmoji: j['logoEmoji'] as String? ?? '',
      description: j['description'] as String? ?? '',
      apiKey: j['apiKey'] as String? ?? '',
      model: j['model'] as String? ?? '',
      availableModels: (j['availableModels'] as List?)?.cast<String>() ?? [],
      isEnabled: j['isEnabled'] as bool? ?? false,
      isActive: j['isActive'] as bool? ?? false,
    );
  }
}

// Providers disponibles por defecto
List<AIProviderConfig> get defaultProviders => [
  const AIProviderConfig(
    key: 'anthropic',
    name: 'Claude (Anthropic)',
    logoEmoji: '🤖',
    description: 'Especialista en razonamiento legal — recomendado para Honduras',
    apiKey: '',
    model: 'claude-sonnet-4-6',
    availableModels: [
      'claude-sonnet-4-6',
      'claude-haiku-4-5-20251001',
      'claude-opus-4-8',
    ],
    isEnabled: true,
    isActive: true,
  ),
  const AIProviderConfig(
    key: 'openai',
    name: 'ChatGPT (OpenAI)',
    logoEmoji: '✨',
    description: 'Modelo de lenguaje general de OpenAI',
    apiKey: '',
    model: 'gpt-4o',
    availableModels: ['gpt-4o', 'gpt-4o-mini', 'gpt-3.5-turbo'],
    isEnabled: false,
    isActive: false,
  ),
];
