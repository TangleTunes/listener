// ignore_for_file: prefer_const_constructors
import 'package:convert/convert.dart';

import 'dart:async';
import 'dart:typed_data';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:listener13/components/audioplayer.dart';
import 'package:listener13/providers/current_song_provider.dart';
import 'package:listener13/providers/playback_provider.dart';
import 'package:listener13/theme/theme_constants.dart';
import 'package:listener13/utils/go_to_page.dart';
import 'package:provider/provider.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../audio_player/playback.dart';
import '../distributor_connection/distributer_contact.dart';
import '../distributor_connection/smart_contract.dart';
import '../error_handling/app_error.dart';
import '../providers/smart_contract_provider.dart';
import '../providers/song_list_provider.dart';
import '../utils/toast.dart';
import 'library.dart';
import 'account.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  int _selectedIndex = 1;
  double _value = 20;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 38,
        backgroundColor: Color(0xFF091227),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'library',
            icon: Icon(
              Icons.favorite_border_outlined,
            ),
          ),
          BottomNavigationBarItem(
            label: 'search',
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            label: 'account',
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedIconTheme: IconThemeData(color: COLOR_TERTIARY),
        unselectedIconTheme: IconThemeData(color: COLOR_SECONDARY),
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
            switch (_selectedIndex) {
              case 0:
                goToPage(context, "/library");
                break;
              case 1:
                break;
              case 2:
                goToPage(context, "/account");
                break;
            }
          });
        },
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Search for a song',
                style: TextStyle(
                  color: COLOR_SECONDARY,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SearchableList<Song>(
                  //style: const TextStyle(fontSize: 25),
                  onPaginate: () async {
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {});
                  },
                  builder: (Song song) => SongItem(song: song),
                  loadingWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(COLOR_SECONDARY),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Loading songs...',
                        style: TextStyle(color: COLOR_SECONDARY),
                      )
                    ],
                  ),
                  errorWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Error while fetching songs',
                        style: TextStyle(color: COLOR_SECONDARY),
                      )
                    ],
                  ),
                  asyncListCallback: () async {
                    await Future.delayed(
                      const Duration(
                        milliseconds: 1000,
                      ),
                    );
                    return context.read<SongListProvider>().getSongsList();
                  },
                  asyncListFilter: (q, list) {
                    return list
                        .where((element) =>
                            element.songName.contains(q) ||
                            element.artist.contains(q))
                        .toList();
                  },
                  emptyWidget: const EmptyView(),
                  onRefresh: () async {},
                  onItemSelected: (Song item) async {
                    context.read<CurrentSongProvider>().updateSong(item);

                    SmartContract sc = context
                        .read<SmartContractProvider>()
                        .getSmartContract()!;
                    Song currentSong =
                        context.read<CurrentSongProvider>().getSong()!;
                    toast("Finding a distributor");
                    Either<MyError, List<dynamic>> scDistributorAnswer =
                        await sc.getRandDistributor(
                            currentSong.songId); //FIXME could be null
                    if (scDistributorAnswer.isRight) {
                      String distributorHex = scDistributorAnswer.right[0].hex;
                      Uri uri =
                          Uri.parse("tcp://" + scDistributorAnswer.right[1]);
                      Either<MyError, DistributorContact> dc =
                          await DistributorContact.create(
                              sc, distributorHex, uri.host, uri.port);
                      if (dc.isRight) {
                        context
                            .read<CurrentSongProvider>()
                            .setDistributor(dc.right);
                      } else {
                        toast(dc.left.message);
                      }

                      Playback playback =
                          context.read<PlaybackProvider>().getPlayback();

                      Uint8List songidBytes = currentSong.songId;
                      String songIdentifier = hex.encode(songidBytes);
                      if (currentSong.distributorContact != null) {
                        Either<MyError, Null> setAudio =
                            await playback.setAudio(
                                songIdentifier,
                                currentSong.byteSize,
                                currentSong.distributorContact
                                    as DistributorContact);
                        if (setAudio.isRight) {
                        } else {
                          toast(setAudio.left.message);
                        }
                      } else {
                        toast("No node is distributing this song");
                      }
                    } else {
                      toast(scDistributorAnswer.left.message);
                      MaterialPageRoute(
                          builder: (context) => AccountPage(tabSelected: 1));
                    }
                  },
                  inputDecoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search here',
                    suffixIcon: Icon(
                      Icons.search,
                      color: COLOR_PRIMARY,
                      size: 28,
                    ),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: COLOR_PRIMARY,
                    ),
                    filled: true,
                    fillColor: COLOR_SECONDARY,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Container(
              color: Color(0xFF091227),
              child: Column(
                children: [
                  // ValueListenableBuilder<ProgressBarState>(
                  //   valueListenable: context
                  //       .read<PlaybackProvider>()
                  //       .getPlayback()
                  //       .progressNotifier,
                  //   builder: (_, value, __) {
                  //     return ProgressBar(
                  //       thumbColor: COLOR_TERTIARY,
                  //       // thumbGlowColor: COLOR_TERTIARY,
                  //       progressBarColor: COLOR_TERTIARY,
                  //       bufferedBarColor: COLOR_QUATERNARY,
                  //       baseBarColor: COLOR_SECONDARY,
                  //       thumbGlowRadius: 15,
                  //       onSeek:
                  //           context.read<PlaybackProvider>().getPlayback().seek,
                  //       progress: value.current,
                  //       buffered: value.buffered,
                  //       total: value.total,
                  //     );
                  //   },
                  // ),
                  Builder(
                      builder: (BuildContext context) => audioPlayer(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongItem extends StatefulWidget {
  final Song song;

  const SongItem({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 110,
        width: 380,
        decoration: BoxDecoration(
          color: COLOR_SECONDARY,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.song.songName,
                        style: const TextStyle(
                          color: COLOR_PRIMARY,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Artist: ${widget.song.artist}',
                        style: const TextStyle(
                          color: COLOR_PRIMARY,
                        ),
                      ),
                      Text(
                        'Duration: ${formatedTime(widget.song.duration)}',
                        style: const TextStyle(
                          color: COLOR_PRIMARY,
                        ),
                      ),
                      Text(
                        'Price: ${widget.song.price} MIOTA',
                        style: const TextStyle(
                          color: COLOR_PRIMARY,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        iconSize: 35,
                        icon: (isPressed)
                            ? Icon(Icons.favorite_border_outlined,
                                color: COLOR_TERTIARY)
                            : Icon(Icons.favorite, color: COLOR_TERTIARY),
                        onPressed: () {
                          setState(() {
                            //changes the button from a full heart to a border heart
                            //TODO add that it adds the song to favorites
                            if (!isPressed) {
                              isPressed = true;
                            } else {
                              isPressed = false;
                            }
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('No song is found with this name',
            style: TextStyle(color: COLOR_SECONDARY)),
      ],
    );
  }
}

//changes the time in seconds to time in minutes
String formatedTime(int duration) {
  int sec = duration % 60;
  int min = (duration / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute : $second min";
}
