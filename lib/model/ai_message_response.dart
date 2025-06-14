class AiMessageResponse {
  final String id;
  final List<Choice> choices;
  final int created;
  final String model;
  final String object;
  final String? serviceTier;
  final String? systemFingerprint;
  final Usage usage;
  final String signature;
  final dynamic promptLogprobs;

  AiMessageResponse({
    required this.id,
    required this.choices,
    required this.created,
    required this.model,
    required this.object,
    this.serviceTier,
    this.systemFingerprint,
    required this.usage,
    required this.signature,
    this.promptLogprobs,
  });

  factory AiMessageResponse.fromJson(Map<String, dynamic> json) {
    return AiMessageResponse(
      id: json['id'],
      choices: (json['choices'] as List)
          .map((e) => Choice.fromJson(e))
          .toList(),
      created: json['created'],
      model: json['model'],
      object: json['object'],
      serviceTier: json['service_tier'],
      systemFingerprint: json['system_fingerprint'],
      usage: Usage.fromJson(json['usage']),
      signature: json['signature'],
      promptLogprobs: json['prompt_logprobs'],
    );
  }
}

class Choice {
  final String? finishReason;
  final int index;
  final dynamic logprobs;
  final AiMessage message;
  final String? stopReason;

  Choice({
    this.finishReason,
    required this.index,
    this.logprobs,
    required this.message,
    this.stopReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      finishReason: json['finish_reason'],
      index: json['index'],
      logprobs: json['logprobs'],
      message: AiMessage.fromJson(json['message']),
      stopReason: json['stop_reason'],
    );
  }
}

class AiMessage {
  final String content;
  final dynamic refusal;
  final String role;
  final dynamic annotations;
  final dynamic audio;
  final dynamic functionCall;
  final List<dynamic> toolCalls;
  final dynamic reasoningContent;

  AiMessage({
    required this.content,
    this.refusal,
    required this.role,
    this.annotations,
    this.audio,
    this.functionCall,
    required this.toolCalls,
    this.reasoningContent,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      content: json['content'],
      refusal: json['refusal'],
      role: json['role'],
      annotations: json['annotations'],
      audio: json['audio'],
      functionCall: json['function_call'],
      toolCalls: json['tool_calls'] ?? [],
      reasoningContent: json['reasoning_content'],
    );
  }
}

class Usage {
  final int completionTokens;
  final int promptTokens;
  final int totalTokens;
  final dynamic completionTokensDetails;
  final dynamic promptTokensDetails;

  Usage({
    required this.completionTokens,
    required this.promptTokens,
    required this.totalTokens,
    this.completionTokensDetails,
    this.promptTokensDetails,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      completionTokens: json['completion_tokens'],
      promptTokens: json['prompt_tokens'],
      totalTokens: json['total_tokens'],
      completionTokensDetails: json['completion_tokens_details'],
      promptTokensDetails: json['prompt_tokens_details'],
    );
  }
}
