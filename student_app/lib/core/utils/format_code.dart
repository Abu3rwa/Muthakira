/// Groups a long one-time code so it can be read back and typed accurately.
library;

String groupCode(String code, {int size = 5}) {
  final String raw = code.trim();
  if (raw.length <= size) return raw;
  final StringBuffer buffer = StringBuffer();
  for (int index = 0; index < raw.length; index += size) {
    if (index > 0) buffer.write('-');
    buffer.write(raw.substring(index, index + size > raw.length ? raw.length : index + size));
  }
  return buffer.toString();
}
