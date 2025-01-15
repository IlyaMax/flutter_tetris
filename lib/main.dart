import 'package:flutter/material.dart';
import 'package:flutter_tetris/game_model.dart';
import 'package:flutter_tetris/game_storage.dart';
import 'package:flutter_tetris/list_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final GameModel gameModel = GameModel(GameStorage(preferences));
  runApp(MainApp(gameModel: gameModel));
}

class MainApp extends StatefulWidget {
  final GameModel gameModel;
  const MainApp({super.key, required this.gameModel});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  GameModel get _gameModel => widget.gameModel;
  @override
  void initState() {
    super.initState();
    _gameModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: _gameModel,
          builder: (context, _) {
            return SafeArea(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      children: _gameModel.board
                          .map<Widget>(
                            (row) => Expanded(
                              child: Row(
                                children: row
                                    .map<Widget>(
                                      (isFilled) => Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: isFilled
                                                ? Colors.amber
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()
                                    .separate(const SizedBox(width: 5)),
                              ),
                            ),
                          )
                          .toList()
                          .separate(const SizedBox(height: 5)),
                    ),
                  ),
                  if (_gameModel.isGameOver)
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Game Over',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your result is ${_gameModel.seconds} sec',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Your record is ${_gameModel.record} sec',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _gameModel.init,
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.amber),
                              ),
                              label: const Text(
                                'New Game',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!_gameModel.isGameOver)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FloatingActionButton(
                              backgroundColor: Colors.black26,
                              onPressed: _gameModel.moveCurrentFigureToTheLeft,
                              child: const Icon(
                                Icons.arrow_left,
                                size: 40,
                                color: Colors.amber,
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: Colors.black26,
                              onPressed: _gameModel.moveCurrentFigureToTheRight,
                              child: const Icon(
                                Icons.arrow_right,
                                size: 40,
                                color: Colors.amber,
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              onTapDown: (_) {
                                _gameModel.accelerate();
                              },
                              onTapCancel: () {
                                _gameModel.decelerate();
                              },
                              child: FloatingActionButton(
                                backgroundColor: Colors.black26,
                                onPressed: () {},
                                child: const Icon(
                                  Icons.arrow_downward,
                                  size: 40,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: Colors.black26,
                              onPressed: _gameModel.rotate,
                              child: const Icon(
                                Icons.rotate_right,
                                size: 40,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
