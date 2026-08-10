class DashboardSummaryModel {
  final double todaySales;
  final int todayTransactions;
  final int lowStockCount;
  final int totalProducts;

  const DashboardSummaryModel({
    required this.todaySales,
    required this.todayTransactions,
    required this.lowStockCount,
    required this.totalProducts,
  });

  String get formattedTodaySales {
    final intPrice = todaySales.toInt();
    final buffer = StringBuffer();
    final str = intPrice.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return DashboardSummaryModel(
      todaySales: parseDouble(json['today_sales'] ?? json['todaySales']),
      todayTransactions: parseInt(json['today_transactions'] ?? json['todayTransactions']),
      lowStockCount: parseInt(json['low_stock_count'] ?? json['lowStockCount']),
      totalProducts: parseInt(json['total_products'] ?? json['totalProducts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_sales': todaySales,
      'today_transactions': todayTransactions,
      'low_stock_count': lowStockCount,
      'total_products': totalProducts,
    };
  }

  @override
  String toString() =>
      'DashboardSummaryModel(sales: $todaySales, txCount: $todayTransactions, lowStock: $lowStockCount, totalProducts: $totalProducts)';
}
