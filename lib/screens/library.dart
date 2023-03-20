// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:listener/components/audioplayer.dart';
import 'package:listener/theme/theme_constants.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../providers/song_list_provider.dart';
import 'discovery.dart';
import 'account.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final List<Song> likedSongs = [];

  int _selectedIndex = 0;
  double _value = 20; //this should be passed as a state between pages i think

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          break;
        case 1:
          goToPage(context, "/discovery");
          break;
        case 2:
          goToPage(context, "/account");
          break;
      }
    });
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
        onTap: _onItemTapped,
      ),
      body: Center(
        child: Column(
          children: [
            const Text('My libary',
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
                    return likedSongs;
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
                  onItemSelected: (Song item) {},
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
