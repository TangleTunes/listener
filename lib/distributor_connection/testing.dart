import 'package:listener13/distributor_connection/distributer_contact.dart';

void main() async {
  DistributorContact d = DistributorContact(
      "0800000722040506080000072204050608000007220405060800000722040506");
  await d.initialize();
  print("initialized");
  var returnedChunk = await d.requestChunk(0);
  print("I decoded the following chunk $returnedChunk");
}
