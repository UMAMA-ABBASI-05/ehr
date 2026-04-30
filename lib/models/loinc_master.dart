class LoincMaster {
  final String loincCode;
  final String longCommonName;
  final String? shortName;
  final String? component;
  final String? system;
  final String? displayName;
  final String? mobileName;

  LoincMaster({
    required this.loincCode,
    required this.longCommonName,
    this.shortName,
    this.component,
    this.system,
    this.displayName,
    this.mobileName,
  });

  // Backend response (snake_case) ko handle karne ke liye
  factory LoincMaster.fromJson(Map<String, dynamic> json) {
    return LoincMaster(
      loincCode: json['loinc_code'] ?? '',
      longCommonName: json['long_common_name'] ?? '',
      shortName: json['short_name'],
      component: json['component'],
      system: json['system'],
      displayName: json['display_name'],
      mobileName: json['mobile_name'],
    );
  }

  // API ko bhejte waqt snake_case format
  Map<String, dynamic> toJson() {
    return {
      'loinc_code': loincCode,
      'long_common_name': longCommonName,
      'short_name': shortName,
      'component': component,
      'system': system,
      'display_name': displayName,
      'mobile_name': mobileName,
    };
  }
}
