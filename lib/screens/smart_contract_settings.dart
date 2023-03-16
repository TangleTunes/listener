import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/smart_contract_provider.dart';

class SmartContractSettings extends StatelessWidget {
  const SmartContractSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
        "Your smart contract: ${context.read<SmartContractProvider>().getSmartContract().toString()}");
  }
}
