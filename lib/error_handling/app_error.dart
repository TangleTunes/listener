enum AppError {
  SocketConnectionFailed,
  SmartContractCreateFailed,
  SmartContractTransactionFailed,
  SmartContractCallFailed,
  SmartContractSignTransactionFailed,
  DetermineNonceFailed,
  SendingTcpFailed,
  PlaybackError,
  IncorrectPrivateKeyPassword,
  NonexistetOrCorruptedPrivateKeyFile,
  NonexistetOrCorruptedSmartContractFile,
  // some errors codes
}

class MyError {
  final AppError key;
  final String message;
  final Exception? exception;

  const MyError({
    required this.key,
    required this.message,
    this.exception,
  });
}
