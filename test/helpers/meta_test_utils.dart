import 'package:dcql/dcql.dart';

/// Creates test meta with W3C type values
DcqlMeta createW3cMeta(List<List<String>> typeValues) {
  return DcqlMeta(typeValues: typeValues);
}

/// Creates test meta with SD-JWT VCT values
DcqlMeta createSdJwtMeta(List<String> vctValues) {
  return DcqlMeta(vctValues: vctValues);
}

/// Creates test meta with mdoc doctype value
DcqlMeta createMdocMeta(String doctypeValue) {
  return DcqlMeta(doctypeValue: doctypeValue);
}
