/// Server order ids are UUIDs; show the first block, upper-cased
/// ("#3F2A9C1B"), which is unique enough for a customer to quote to
/// support. Mock ids ("order-1730…") are shown as they are.
String shortOrderId(String id) {
  final uuid = RegExp(r'^[0-9a-fA-F]{8}-');
  return uuid.hasMatch(id) ? id.substring(0, 8).toUpperCase() : id;
}
