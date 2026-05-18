class LabMiniTestResult {
  final int miniTestId;
  final String testName;
  final String normalRange;
  final String unit;
  final String resultValue;

  LabMiniTestResult({
    required this.miniTestId,
    required this.testName,
    required this.normalRange,
    required this.unit,
    required this.resultValue,
  });

  factory LabMiniTestResult.fromJson(Map<String, dynamic> json) {
    return LabMiniTestResult(
      miniTestId: json['mini_test_id'] as int,
      testName: json['test_name'] as String,
      normalRange: json['normal_range'] as String,
      unit: json['unit'] as String,
      resultValue: json['result_value'] as String,
    );
  }
}

class LabResult {
  final int reportId;
  final String testName;
  final String? description;
  final List<LabMiniTestResult> miniTestResults;

  LabResult({
    required this.reportId,
    required this.testName,
    this.description,
    required this.miniTestResults,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    final raw = json['mini_test_results'] as List<dynamic>? ?? [];
    return LabResult(
      reportId: json['report_id'] as int,
      testName: json['test_name'] as String,
      description: json['description'] as String?,
      miniTestResults: raw
          .map((e) => LabMiniTestResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
