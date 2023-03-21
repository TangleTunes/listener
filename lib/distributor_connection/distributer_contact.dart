import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:either_dart/either.dart';
import 'package:flutter/services.dart';
import 'package:listener/error_handling/app_error.dart';
import 'package:tuple/tuple.dart';
import 'package:web3dart/crypto.dart';
import 'smart_contract.dart';

const int chunkSize = 32500;

class DistributorContact {
  SmartContract smartContract;
  String distributorHex;
  String distributorIP;
  int distributorPort;

  late Socket socket; // FIXME
  late Stream<Tuple2<int, Uint8List>> stream;

  DistributorContact._create(this.smartContract, this.distributorHex,
      this.distributorIP, this.distributorPort) {}

  /// Public factory
  static Future<Either<MyError, DistributorContact>> create(
      SmartContract smartC, String hex, String ip, int port) async {
    // Call the private constructor
    var thisObj = DistributorContact._create(smartC, hex, ip, port);

    // Do initialization that requires async

    try {
      thisObj.socket = await Socket.connect(thisObj.distributorIP,
          thisObj.distributorPort); //FIXME error handling if this fails
    } on Exception catch (e) {
      return Left(MyError(
          key: AppError.SocketConnectionFailed,
          message:
              "Could not connect to distributor at ${thisObj.distributorIP}:${thisObj.distributorPort}",
          exception: e));
    }
    thisObj.stream =
        thisObj.socket.transform(StreamTransformer.fromBind((tcpStream) async* {
      ListQueue<int> queue = ListQueue();

      await for (final tcp_msg in tcpStream) {
        queue.addAll(tcp_msg);

        if (queue.length >= 8) {
          int chunkId = readInt32(queue, 0);

          int contentLength = readInt32(queue, 4);
          print(
              "just recieved a tcp message! with header: chunkId $chunkId length ${contentLength}");
          if (queue.length >= contentLength) {
            //oentire response from distributor in queue!
            for (int i = 0; i < 8; i++) {
              //remove  header of tcp messsage
              queue.removeFirst();
            }
            int bytesLeftInTcpMsg = contentLength;
            int chunkAmount = (contentLength / chunkSize).ceil();
            while (bytesLeftInTcpMsg > 0) {
              int chunkLength;
              if (bytesLeftInTcpMsg > chunkSize) {
                chunkLength = chunkSize;
              } else {
                chunkLength = bytesLeftInTcpMsg;
              }
              Uint8List chunk = Uint8List(chunkLength);
              int index = 0;
              for (final byte in queue.take(chunkLength)) {
                chunk[index] = byte;
                index++;
              }
              for (int j = 0; j < index; j++) {
                //pop bytes that we just read
                queue.removeFirst();
              }
              bytesLeftInTcpMsg = bytesLeftInTcpMsg - chunkLength;
              yield Tuple2(chunkId, chunk);
              chunkId++;
            }
          }
        }
      }
    })).asBroadcastStream();
    // Return the fully initialized object
    return Right(thisObj);
  }

  Future<Either<MyError, Null>> requestChunks(
      String songIdentifier, int from, int amount) async {
    print("called method requestChunks from $from and amount $amount");
    Uint8List songId = hexToBytes(songIdentifier);
    var potentialChunkTransaction = await smartContract
        .createChunkGetTransaction(songId, from, amount, distributorHex);
    if (potentialChunkTransaction.isRight) {
      Uint8List BODY = potentialChunkTransaction.right;
      int bodyLength = BODY.length;
      final byteD = ByteData(4);
      byteD.setUint32(0, bodyLength, Endian.little);
      Uint8List HEADER = byteD.buffer.asUint8List();

      Uint8List PAYLOAD = Uint8List.fromList(HEADER + BODY);
      try {
        socket.add(PAYLOAD);
        await socket.flush();
        return Right(null);
      } on Exception catch (e) {
        return Left(MyError(
            key: AppError.SendingTcpFailed,
            exception: e,
            message:
                "Unable to send a chunk request to socket ${socket.address}:${socket.port}"));
      }
    } else {
      return Left(potentialChunkTransaction.left);
    }
    //Add body length as header (4 bytes)

    // await Future.delayed(Duration(seconds: 2));
  }
}

int readInt32(ListQueue<int> queue, int startAt) {
  Uint8List resultData = Uint8List(4);
  for (int i = 0; i < 4; i++) {
    resultData[i] = queue.elementAt(i + startAt);
  }
  final byteData = ByteData.view(resultData.buffer);
  return byteData.getUint32(0, Endian.little);
}
