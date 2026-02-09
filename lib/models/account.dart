class LinkedAccount {
  final String id;
  final String? institution;
  final String? displayName;
  final String? last4;
  final String linkedAt;

  LinkedAccount({
    required this.id,
    this.institution,
    this.displayName,
    this.last4,
    required this.linkedAt,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      id: json['id'] as String,
      institution: json['institution'] as String?,
      displayName: json['display_name'] as String?,
      last4: json['last4'] as String?,
      linkedAt: json['linked_at'] as String,
    );
  }

  String get label {
    return [institution, displayName, last4 != null ? '****$last4' : null]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
  }
}
