class Receipt {
  final int? id;
  final String imagePath;
  final String? ocrText;
  final Map<String, dynamic>? extractedData;
  final DateTime scannedAt;
  final int? expenseId;
  final bool isProcessed;

  Receipt({
    this.id,
    required this.imagePath,
    this.ocrText,
    this.extractedData,
    required this.scannedAt,
    this.expenseId,
    this.isProcessed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'ocrText': ocrText,
      'extractedData': extractedData != null 
          ? extractedData.toString() 
          : null,
      'scannedAt': scannedAt.toIso8601String(),
      'expenseId': expenseId,
      'isProcessed': isProcessed ? 1 : 0,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      imagePath: map['imagePath'],
      ocrText: map['ocrText'],
      extractedData: map['extractedData'] != null
          ? Map<String, dynamic>.from(map['extractedData'])
          : null,
      scannedAt: DateTime.parse(map['scannedAt']),
      expenseId: map['expenseId'],
      isProcessed: map['isProcessed'] == 1,
    );
  }

  Receipt copyWith({
    int? id,
    String? imagePath,
    String? ocrText,
    Map<String, dynamic>? extractedData,
    DateTime? scannedAt,
    int? expenseId,
    bool? isProcessed,
  }) {
    return Receipt(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      ocrText: ocrText ?? this.ocrText,
      extractedData: extractedData ?? this.extractedData,
      scannedAt: scannedAt ?? this.scannedAt,
      expenseId: expenseId ?? this.expenseId,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}