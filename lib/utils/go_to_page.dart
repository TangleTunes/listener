import "package:flutter/src/widgets/framework.dart";
import "package:flutter/widgets.dart";
import "package:listener13/distributor_connection/smart_contract.dart";
import "package:listener13/providers/credentials_provider.dart";
import "package:listener13/providers/smart_contract_provider.dart";
import "package:listener13/providers/song_list_provider.dart";
import "package:listener13/utils/toast.dart";
import "package:provider/provider.dart";

void goToPage(BuildContext context, String page) {
  switch (page) {
    case "/start":
      {
        Navigator.pushNamed(context, page);
      }
      break;

    case "/load_credentials":
      {
        Navigator.pushNamed(context, page);
      }
      break;

    case "/create_account":
      {
        Navigator.pushNamed(context, page);
      }
      break;

    case "/load_create_account":
      {
        if (context.read<SmartContractProvider>().getSmartContract() == null) {
          goToPage(context, "/load_smart_contract");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    case "/discovery":
      {
        print(
            "is context.read<SmartContractProvider>().getSmartContract() == null? ${context.read<SmartContractProvider>().getSmartContract() == null}");
        if (context.read<SmartContractProvider>().getSmartContract() == null) {
          goToPage(context, "/load_smart_contract");
        } else if (context.read<SongListProvider>().getSongsList() == null) {
          goToPage(context, "/load_songs");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    case "/library":
      {
        if (context.read<SmartContractProvider>().getSmartContract() == null) {
          goToPage(context, "/load_smart_contract");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    case "/load_songs":
      {
        if (context.read<SmartContractProvider>().getSmartContract() == null) {
          goToPage(context, "/load_smart_contract");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    case "/unlock_account":
      {
        Navigator.pushNamed(context, page);
      }
      break;

    case "/smart_contract_settings":
      {
        if (context.read<CredentialsProvider>().getCredentials() == null) {
          goToPage(context, "/load_credentials");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    case "/account":
      {
        if (context.read<CredentialsProvider>().getCredentials() == null) {
          goToPage(context, "/load_credentials");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    case "/couple_account":
      {
        Navigator.pushNamed(context, page);
      }
      break;
    case "/load_create_account":
      {
        if (context.read<SmartContractProvider>().getSmartContract() == null) {
          goToPage(context, "/load_smart_contract");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;
    case "/load_smart_contract":
      {
        if (context.read<CredentialsProvider>().getCredentials() == null) {
          goToPage(context, "/load_credentials");
        } else {
          Navigator.pushNamed(context, page);
        }
      }
      break;

    default:
      {
        toast("Page not found $page");
      }
      break;
  }
}

void goToPreviousPage(BuildContext context) {
  Navigator.pop(context);
}
