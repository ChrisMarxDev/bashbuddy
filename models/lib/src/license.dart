import 'general.dart';

class LicenseResponse {
  final String license;
  final String? error;
  final bool valid;

  LicenseResponse({required this.license, this.error, required this.valid});

  factory LicenseResponse.fromJson(Json json) {
    return LicenseResponse(
      license: json['license'],
      error: json['error'],
      valid: json['valid'],
    );
  }

  Json toJson() => {
        'license': license,
        'error': error,
        'valid': valid,
      };
}
