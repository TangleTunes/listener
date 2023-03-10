import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';
import 'package:listener13/distributor_connection/distributer_contact.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'package:web3dart/web3dart.dart';

class DistributorTcp {
  void sendChunkReq(
      Uint8List songId, int chunkNum, int amount, Socket socket) async {
    String rpcUrl =
        "http://localhost:9090/chains/tst1pzdpzlwxnjw9t8xwyj89ymqkty08j6s96flnu4w8903k0xf3zx2jy3h5u5h/evm";
    EthereumAddress contractAddr =
        EthereumAddress.fromHex('0xb3dB807507d6De3D9e2F335b2e4f6C5DE1Fa6A9E');
    String privateKey = await loadPrivateKey();
    File abiFile = File('lib/distributor_connection/smartcontract.abi.json');
    SmartContract smartContract =
        SmartContract(rpcUrl, contractAddr, privateKey, abiFile);
    await smartContract.init(rpcUrl, privateKey);
    String distributorHex = "0x4e14a01e2d3adcb483a56f1ffdea920da86c62cb";
    Uint8List BODY = await smartContract.createChunkGetTransactionTest(
        songId, chunkNum, amount, distributorHex);
    //Add body length as header (4 bytes)

    int bodyLength = BODY.length;
    final byteD = ByteData(4);
    byteD.setUint32(0, bodyLength, Endian.little);
    Uint8List HEADER = byteD.buffer.asUint8List();

    Uint8List PAYLOAD = Uint8List.fromList(HEADER + BODY);
    print("I sent this signed transaction: $PAYLOAD");
    await sendMessage(socket, PAYLOAD);
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
  }

  Future<void> sendMessage(Socket socket, Uint8List message) async {
    socket.add(message);
    socket.flush();
    await Future.delayed(Duration(seconds: 2));
  }
}
