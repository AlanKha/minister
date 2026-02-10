class CategoryRule {
  final String id;
  final String category;
  final String pattern;
  final bool caseSensitive;

  const CategoryRule({
    required this.id,
    required this.category,
    required this.pattern,
    this.caseSensitive = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'pattern': pattern,
        'caseSensitive': caseSensitive,
      };

  factory CategoryRule.fromJson(Map<String, dynamic> json) => CategoryRule(
        id: json['id'] as String,
        category: json['category'] as String,
        pattern: json['pattern'] as String,
        caseSensitive: json['caseSensitive'] as bool? ?? false,
      );
}
