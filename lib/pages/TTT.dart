import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TTT extends StatefulWidget {
  const TTT({Key? key, required this.isAI}) : super(key: key);

  final bool isAI;

  @override
  State<TTT> createState() => _TTTState();
}

class _TTTState extends State<TTT> {
  List<String> gridComponents = List.filled(9, '');
  List<Color> gridColour = List.filled(9, Colors.white);
  bool isDifficult = true;
  bool isXTurn = true;
  bool pauseGrid = false;
  int currentOccupied = 0;
  int xWins = 0;
  int oWins = 0;
  String tttButton = "";

  @override
  // ignore: curly_braces_in_flow_control_structures
  void initState() {
    super.initState();
    tttButton = "Hard difficulty";
    if (widget.isAI) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await setDifficulty(context);
          setState(() {});
        },
      );
    } else {
      tttButton = "it's X turn!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showResetAndHomepageDialog(context, false),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe Game '),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt, size: 28),
              onPressed: () {
                showResetAndHomepageDialog(context, true);
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  horizontalTitleGap: -5,
                  leading: const Icon(Icons.home),
                  title: const Text('Get Back To Home Screen'),
                  onTap: () => {
                    Navigator.of(context).pop(),
                    showResetAndHomepageDialog(context, false),
                  },
                ),
                widget.isAI
                    ? ListTile(
                        horizontalTitleGap: -5,
                        leading: const Icon(Icons.speed_outlined),
                        title: const Text('Change Difficulty'),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await setDifficulty(context);
                          setState(() {});
                        },
                      )
                    : const SizedBox(),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Reset Score'),
                  onTap: () => {
                    Navigator.of(context).pop(),
                    showResetAndHomepageDialog(context, true),
                  },
                ),
                const Expanded(child: SizedBox()),
                const Divider(
                  thickness: 2,
                  color: Colors.black38,
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Image.asset('assets/images/Github.png', width: 30),
                  title: const Text('GitHub'),
                  onTap: () => _launchUrl('https://github.com/joYousefShaban'),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Image.asset('assets/images/Linkedin.png', width: 30),
                  title: const Text('LinkedIn'),
                  onTap: () =>
                      _launchUrl('https://www.linkedin.com/in/yousefshaban/'),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (gridComponents[index] == '' && !pauseGrid) {
                            currentOccupied++;
                            gridComponents[index] = isXTurn ? 'X' : 'O';
                            if (!widget.isAI) {
                              isXTurn = !isXTurn;
                              if (isXTurn) {
                                tttButton = "it's X turn!";
                              } else {
                                tttButton = "it's O turn!";
                              }
                            }
                            //check winner if AI or not
                            if (checkWinner()) {
                              tttButton = "Play Again";
                            } else if (currentOccupied == 9) {
                              showDrawDialog(context);
                              pauseGrid = true;
                              tttButton = "Play Again";
                            } else if (widget.isAI) {
                              print("xd");
                              aiAlgo();
                              if (checkWinner() || currentOccupied == 9) {
                                tttButton = "Play Again";
                                if (currentOccupied == 9) {
                                  showDrawDialog(context);
                                  pauseGrid = true;
                                }
                              }
                            }
                          }
                        });
                      },
                      child: GridTile(
                        child: Container(
                          decoration: BoxDecoration(
                            border: _determineBorder(index),
                            color: gridColour[index],
                          ),
                          child: Center(
                            child: Text(
                              gridComponents[index],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 55),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Expanded(child: SizedBox()),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.grey))),
                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 30),
                  ),
                ),
                onPressed: () {
                  if (pauseGrid) {
                    reset();
                  }
                },
                child: Text(tttButton),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        const Text(
                          'Player X',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          xWins.toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ]),
                      Column(children: [
                        const Text(
                          'Player O',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          oWins.toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ]),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  void scoreReset() {
    setState(() {
      xWins = 0;
      oWins = 0;
    });
    reset();
  }

  void reset() {
    setState(() {
      isXTurn = true;
      pauseGrid = false;
      currentOccupied = 0;
      if (widget.isAI) {
        if (isDifficult) {
          tttButton = "Hard difficulty";
        } else {
          tttButton = "Medium difficulty";
        }
      } else {
        tttButton = "it's X turn!";
      }
      for (int i = 0; i < 9; i++) {
        gridComponents[i] = '';
        gridColour[i] = Colors.white;
        if (i != 8) {
          patternSum[i] = 0;
        }
      }
    });
  }

  void aiAlgo() {
    currentOccupied++;
    //create HashMap
    LinkedHashMap<int, int> sortedPatternSum = LinkedHashMap();
    for (int i = 0; i < 8; i++) {
      if (isDifficult && patternSum[i] < 0) {
        sortedPatternSum[i] = (patternSum[i].abs())*2;
      } else {
        sortedPatternSum[i] = patternSum[i];
      }
    }
    //sort HashMap
    var sortedKeys = sortedPatternSum.keys.toList(growable: false)
      ..sort(
          (k1, k2) => sortedPatternSum[k2]!.compareTo(sortedPatternSum[k1]!));
    sortedPatternSum = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => sortedPatternSum[k]!);
    //pass highest possibility to attack(hard)/defend(hard&medium)
    for (int i in sortedPatternSum.keys) {
      if (checkGridLine(i + 1)) {
        break;
      }
    }
  }

  List<int> patternSum = List.filled(8, 0);
  //1st index will be the pattern sum of 1st row
  //2nd index will be the pattern sum of 2st row
  //3rd index will be the pattern sum of 3st row
  //4th index will be the pattern sum of 1st column
  //5th index will be the pattern sum of 2st column
  //6th index will be the pattern sum of 3st column
  //7th index will be the pattern sum of diagonal
  //8th index will be the pattern sum of reverse diagonal

  bool checkWinner() {
    //ADD ALL
    patternSum = List.filled(8, 0);
    for (int i = 0; i < 9; i++) {
      if (gridComponents[i] != '') {
        switch (i) {
          case 0:
            gridComponents[i] == 'X'
                ? {patternSum[0]++, patternSum[3]++, patternSum[6]++}
                : {patternSum[0]--, patternSum[3]--, patternSum[6]--};
            break;
          case 1:
            gridComponents[i] == 'X'
                ? {patternSum[0]++, patternSum[4]++}
                : {patternSum[0]--, patternSum[4]--};
            break;
          case 2:
            gridComponents[i] == 'X'
                ? {patternSum[0]++, patternSum[5]++, patternSum[7]++}
                : {patternSum[0]--, patternSum[5]--, patternSum[7]--};
            break;
          case 3:
            gridComponents[i] == 'X'
                ? {patternSum[1]++, patternSum[3]++}
                : {patternSum[1]--, patternSum[3]--};
            break;
          case 4:
            gridComponents[i] == 'X'
                ? {
                    patternSum[1]++,
                    patternSum[4]++,
                    patternSum[6]++,
                    patternSum[7]++
                  }
                : {
                    patternSum[1]--,
                    patternSum[4]--,
                    patternSum[6]--,
                    patternSum[7]--
                  };
            break;
          case 5:
            gridComponents[i] == 'X'
                ? {patternSum[1]++, patternSum[5]++}
                : {patternSum[1]--, patternSum[5]--};
            break;
          case 6:
            gridComponents[i] == 'X'
                ? {patternSum[2]++, patternSum[3]++, patternSum[7]++}
                : {patternSum[2]--, patternSum[3]--, patternSum[7]--};
            break;
          case 7:
            gridComponents[i] == 'X'
                ? {patternSum[2]++, patternSum[4]++}
                : {patternSum[2]--, patternSum[4]--};
            break;
          case 8:
            gridComponents[i] == 'X'
                ? {patternSum[2]++, patternSum[5]++, patternSum[6]++}
                : {patternSum[2]--, patternSum[5]--, patternSum[6]--};
            break;
        }
      }
    }

    //CHECK ROW
    if (patternSum[0] == 3 || patternSum[0] == -3) {
      return applyWinner(patternSum[0], 1);
    } else if (patternSum[1] == 3 || patternSum[1] == -3) {
      return applyWinner(patternSum[1], 2);
    } else if (patternSum[2] == 3 || patternSum[2] == -3) {
      return applyWinner(patternSum[2], 3);
    }
    //CHECK COLUMN
    else if (patternSum[3] == 3 || patternSum[3] == -3) {
      return applyWinner(patternSum[3], 4);
    } else if (patternSum[4] == 3 || patternSum[4] == -3) {
      return applyWinner(patternSum[4], 5);
    } else if (patternSum[5] == 3 || patternSum[5] == -3) {
      return applyWinner(patternSum[5], 6);
    }
    //CHECK Diagonal`
    else if (patternSum[6] == 3 || patternSum[6] == -3) {
      return applyWinner(patternSum[6], 7);
    }
    //CHECK ReverseDiagonal
    else if (patternSum[7] == 3 || patternSum[7] == -3) {
      return applyWinner(patternSum[7], 8);
    }
    //NONE WON YET
    return false;
  }

  bool applyWinner(int numberOfSymbol, int line) {
    pauseGrid = true;
    if (numberOfSymbol == 3) {
      xWins++;
      showWinningDialog(context, true);
    } else {
      oWins++;
      showWinningDialog(context, false);
    }
    checkGridLine(line);
    //CHANGE THE COLOUR OF THE WINNER

    return true;
  }

  bool checkGridLine(int line) {
    switch (line) {
      case 1:
      case 2:
      case 3:
        for (int i = (line * 3) - 3; i < line * 3; i++) {
          if (pauseGrid) {
            gridColour[i] = Colors.red;
          } else {
            if (gridComponents[i] == '') {
              gridComponents[i] = 'O';
              i = 9;
              return true;
            }
          }
        }
        break;
      case 4:
      case 5:
      case 6:
        for (int i = line - 4; i < 9; i += 3) {
          if (pauseGrid) {
            gridColour[i] = Colors.red;
          } else {
            if (gridComponents[i] == '') {
              gridComponents[i] = 'O';
              i = 9;
              return true;
            }
          }
        }
        break;
      case 7:
        for (int i = 0; i < 9; i += 4) {
          if (pauseGrid) {
            gridColour[i] = Colors.red;
          } else {
            if (gridComponents[i] == '') {
              gridComponents[i] = 'O';
              i = 9;
              return true;
            }
          }
        }
        break;
      case 8:
        for (int i = 2; i < 7; i += 2) {
          if (pauseGrid) {
            gridColour[i] = Colors.red;
          } else {
            if (gridComponents[i] == '') {
              gridComponents[i] = 'O';
              i = 9;
              return true;
            }
          }
        }
        break;
    }
    return false;
  }

  Future setDifficulty(BuildContext context) {
    // set up the AlertDialog
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        scoreReset();
      },
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Choose the AI difficulty:"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: const Text('Hard'),
                  value: true,
                  groupValue: isDifficult,
                  onChanged: (value) {
                    setState(() {
                      tttButton = "Hard difficulty";
                      isDifficult = value as bool;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('Medium'),
                  value: false,
                  groupValue: isDifficult,
                  onChanged: (value) {
                    setState(() {
                      tttButton = "Medium difficulty";
                      isDifficult = value as bool;
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              okButton,
            ],
          );
        });
      },
    );
  }

  Border _determineBorder(int index) {
    BorderSide borderSide = const BorderSide(
      color: Colors.grey,
      width: 1.5,
    );
    switch (index) {
      case 0:
        return Border(bottom: borderSide, right: borderSide);

      case 1:
        return Border(left: borderSide, bottom: borderSide, right: borderSide);

      case 2:
        return Border(left: borderSide, bottom: borderSide);

      case 3:
        return Border(bottom: borderSide, right: borderSide, top: borderSide);

      case 4:
        return Border(
          left: borderSide,
          bottom: borderSide,
          right: borderSide,
          top: borderSide,
        );
      case 5:
        return Border(left: borderSide, bottom: borderSide, top: borderSide);
      case 6:
        return Border(right: borderSide, top: borderSide);
      case 7:
        return Border(left: borderSide, top: borderSide, right: borderSide);
      case 8:
        return Border(left: borderSide, top: borderSide);
      default:
        return const Border();
    }
  }

  showDrawDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Draw!"),
      content: const Text("No score has been changed"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showWinningDialog(BuildContext context, bool didXWin) {
    // set up the AlertDialog
    String alertTitle;
    String alertContent;
    if (didXWin == true) {
      alertTitle = "X Won!";
      alertContent = "Your score is now:$xWins";
    } else {
      alertTitle = "O Won!";
      alertContent = "Your score is now:$oWins";
    }

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(alertTitle),
      content: Text(alertContent),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showResetAndHomepageDialog(BuildContext context, bool type) {
    //if is false that means reset button was pressed, otherwise homepage button was pressed
    String alertTitle = "Alert Dialog";
    String alertContent;
    String continueButtonText;
    if (type) {
      alertContent = "You sure you want to reset the game?";
      continueButtonText = "Reset";
    } else {
      alertContent = "You sure you want to leave the game?";
      continueButtonText = "Quit";
    }

    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(continueButtonText),
      onPressed: () {
        if (type) {
          scoreReset();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(alertTitle),
      content: Text(alertContent),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }
}
