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

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institution,
        'display_name': displayName,
        'last4': last4,
        'linked_at': linkedAt,
      };
}

class AccountData {
  String? customerId;
  List<LinkedAccount> accounts;

  AccountData({this.customerId, List<LinkedAccount>? accounts})
      : accounts = accounts ?? [];

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      customerId: json['customer_id'] as String?,
      accounts: (json['accounts'] as List<dynamic>?)
              ?.map((a) => LinkedAccount.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (customerId != null) 'customer_id': customerId,
        'accounts': accounts.map((a) => a.toJson()).toList(),
      };
}
