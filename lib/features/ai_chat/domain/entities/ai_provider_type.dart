import 'package:flutter/material.dart';

enum AIProviderType {
  groq,
  openai,
  deepseek,
  anthropic;

  String get displayName {
    switch (this) {
      case AIProviderType.groq:
        return 'Groq';
      case AIProviderType.openai:
        return 'OpenAI (ChatGPT)';
      case AIProviderType.deepseek:
        return 'DeepSeek';
      case AIProviderType.anthropic:
        return 'Claude (Anthropic)';
    }
  }

  String get key {
    switch (this) {
      case AIProviderType.groq:
        return 'groq';
      case AIProviderType.openai:
        return 'openai';
      case AIProviderType.deepseek:
        return 'deepseek';
      case AIProviderType.anthropic:
        return 'anthropic';
    }
  }

  String get baseUrl {
    switch (this) {
      case AIProviderType.groq:
        return 'https://api.groq.com/openai/v1/chat/completions';
      case AIProviderType.openai:
        return 'https://api.openai.com/v1/chat/completions';
      case AIProviderType.deepseek:
        return 'https://api.deepseek.com/v1/chat/completions';
      case AIProviderType.anthropic:
        return 'https://api.anthropic.com/v1/messages';
    }
  }

  String get defaultModel {
    switch (this) {
      case AIProviderType.groq:
        return 'llama-3.3-70b-versatile';
      case AIProviderType.openai:
        return 'gpt-4o-mini';
      case AIProviderType.deepseek:
        return 'deepseek-chat';
      case AIProviderType.anthropic:
        return 'claude-3-5-haiku-20241022';
    }
  }

  IconData? get icon {
    switch (this) {
      case AIProviderType.groq:
        return Icons.bolt;
      case AIProviderType.openai:
        return Icons.auto_awesome;
      case AIProviderType.deepseek:
        return Icons.search;
      case AIProviderType.anthropic:
        return Icons.psychology;
    }
  }

  static AIProviderType? fromKey(String key) {
    for (final provider in AIProviderType.values) {
      if (provider.key == key) return provider;
    }
    return null;
  }
}
