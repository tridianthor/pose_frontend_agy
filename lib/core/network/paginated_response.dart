class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore => next != null && next!.isNotEmpty;

  int get currentPage {
    if (previous == null) return 1;
    final uri = Uri.parse(previous!);
    final pageStr = uri.queryParameters['page'];
    if (pageStr != null) {
      return (int.tryParse(pageStr) ?? 1) + 1;
    }
    return 2;
  }

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) fromJsonT,
  ) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    return PaginatedResponse<T>(
      count: json['count'] as int? ?? rawResults.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: rawResults.map((item) => fromJsonT(item)).toList(),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T item) toJsonT) {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((item) => toJsonT(item)).toList(),
    };
  }
}
