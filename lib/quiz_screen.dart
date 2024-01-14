// quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class QuizDialog extends StatefulWidget {
  @override
  _QuizDialogState createState() => _QuizDialogState();
}


class _QuizDialogState extends State<QuizDialog> {
  List<Map<String, dynamic>> _allQuestions = [
    {
      'question': 'What is the first and most well-known cryptocurrency?',
      'options': ['Ethereum', 'Ripple', 'Bitcoin', 'Litecoin'],
      'correctAnswer': 'Bitcoin',
    },
    {
      'question': 'Which technology is the foundation of most cryptocurrencies?',
      'options': ['Blockchain', 'Artificial Intelligence', 'Big Data', 'Cloud Computing'],
      'correctAnswer': 'Blockchain',
    },
    {
      'question': 'Who is the pseudonymous creator of Bitcoin?',
      'options': ['Satoshi Nakamoto', 'Vitalik Buterin', 'Charlie Lee', 'Roger Ver'],
      'correctAnswer': 'Satoshi Nakamoto',
    },
    {
      'question': 'What is the maximum supply of Bitcoin?',
      'options': ['21 million', '100 million', '1 billion', 'Infinite'],
      'correctAnswer': '21 million',
    },
    {
      'question': 'Which cryptocurrency is known for enabling smart contracts?',
      'options': ['Ripple', 'Litecoin', 'Ethereum', 'Cardano'],
      'correctAnswer': 'Ethereum',
    },
    {
      'question': 'What is the full form of RSI?',
      'options': ['Relative Strength Indicator', 'Relative Strength Index', 'Regular Stock Investment', 'Refined Stock Income'],
      'correctAnswer': 'Relative Strength Index',
    },
    {
      'question': 'What does RSI value 25 Indicate? Coin is:',
      'options': ['Oversold', 'OverBought', 'HighVolume', 'LowVolume'],
      'correctAnswer': 'Oversold',
    },
    {
      'question': 'EMA stands for?',
      'options': ['Exponential Moving Average ', 'Efficient Market Analysi', 'Earnings Management Approach', 'Equity Market Assessment'],
      'correctAnswer': 'Exponential Moving Average',
    },
    {
      'question': 'Which cryptocurrency is often referred to as "digital silver" in contrast to Bitcoin as "digital gold"?',
      'options': ['Ethereum', 'Ripple', 'Litecoin', 'Cardano'],
      'correctAnswer': 'Litecoin',
    },
    {
      'question': 'What is the primary purpose of a hardware wallet in the context of cryptocurrency?',
      'options': ['Mining', 'Staking', 'Securely storing private keys', 'Executing smart contracts'],
      'correctAnswer': 'Securely storing private keys',
    },

    {
      'question': 'What R:R ratio stands for in stocks??',
      'options': ['Risk to reward ratio', ' Return Ratio', 'Risky Ratio', 'Rewarding Ratio'],
      'correctAnswer': 'Risk to reward ratio',
    },
    {
      'question': 'What is the purpose of a whitepaper in the context of launching a new cryptocurrency?',
      'options': ['Marketing material', 'Technical documentation', 'User guide', 'Privacy policy'],
      'correctAnswer': 'Technical documentation',
    },
    {
      'question': 'what is the best r:r ratio considered??',
      'options': ['1:1', '2:1', '3:1', '4:1'],
      'correctAnswer': '3:1',
    },
    {
      'question': ' What is the term for a candlestick pattern that indicates a potential reversal in a down-trend?',
      'options': ['Bullish Engulfing', ' Hammer', 'Shooting Star', ' Doji'],
      'correctAnswer': 'Bullish Engulfing',
    },
    {
      'question': 'Which pattern is formed when an uptrend is likely to reverse, consisting of three candlesticks – a long green candle, a small-bodied candle, and a long red candle?',
      'options': [' Three White Soldiers', ' Evening Star', 'Three Black Crows', 'Morning Star'],
      'correctAnswer': 'Morning Star',
    },
    {
      'question': 'What is the concept of "HODL" in cryptocurrency slang?',
      'options': ['Hold On for Dear Life', 'Highly Optimized Decentralized Ledger', 'Home of Digital Learning', 'Hyperledger'],
      'correctAnswer': 'Hold On for Dear Life',
    },
    {
      'question': 'WWhat pattern is characterized by a small candle with a long upper shadow and a short lower shadow, indicating a potential bearish reversal?',
      'options': ['Hanging Man', 'B) Bullish Harami', 'C) Inverted Hammer', 'D) Dark Cloud Cover'],
      'correctAnswer':'Hanging Man',
    },
    {
      'question': 'What is the term for the pattern that forms when the price reaches a new high but pulls back, creating a pattern resembling a flag?',
      'options': ['Pennant', ' Cup and Handle', ' Ascending Triangle', 'Double Top'],
      'correctAnswer': 'Pennant',
    },
    {
      'question': 'In cryptocurrency, what does the term "FUD" stand for?',
      'options': ['Financial Underwriting Document', 'Fears, Uncertainties, Doubts', 'Fully Updated Data', 'Fundamental Understanding of Decimals'],
      'correctAnswer': 'Fears, Uncertainties, Doubts',
    },
    {
      'question': 'What is the term for a chart pattern resembling a "W," indicating a potential bullish reversal?',
      'options': ['Cup and Handle', ' Double Top', 'Triple Bottom', 'Head and Shoulders'],
      'correctAnswer': 'Triple Bottom',
    },
  ];


  List<Map<String, dynamic>> _currentQuestions = [];

  int _quizIndex = 0;
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _currentQuestions = _getRandomQuestions(10);
  }

  List<Map<String, dynamic>> _getRandomQuestions(int count) {
    List<Map<String, dynamic>> randomQuestions = [];
    List<Map<String, dynamic>> copy = List.from(_allQuestions);

    while (randomQuestions.length < count && copy.isNotEmpty) {
      int index = Random().nextInt(copy.length);
      randomQuestions.add(copy.removeAt(index));
    }

    return randomQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Quiz Bot'),
        backgroundColor: Colors.yellow, // Set the AppBar background color to yellow
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.yellow, // Set the background color to yellow
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_quizIndex < 10)
                Text(
                  _currentQuestions[_quizIndex]['question'],
                  style: TextStyle(fontSize: 18.0),
                ),
              SizedBox(height: 20.0),
              if (_quizIndex < 10)
                Column(
                  children: _buildOptions(),
                ),
              if (_quizIndex == 10)
                Text(
                  'Quiz Complete!\nYour Score: $_correctAnswers out of 10',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_quizIndex < 10) {
                    _checkAnswer(_currentQuestions[_quizIndex]['correctAnswer']);
                  } else {
                    // Reset quiz
                    setState(() {
                      _quizIndex = 0;
                      _correctAnswers = 0;
                      _loadQuestions();
                    });
                  }
                },
                child: Text(_quizIndex < 10 ? '10Questions' : 'Restart Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    List<Widget> options = [];
    for (String option in _currentQuestions[_quizIndex]['options']) {
      options.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // Set background color to blue//////////
          ),
          onPressed: () {
            _checkAnswer(option);
          },
          child: Text(
            option,
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
        ),
      );
      options.add(SizedBox(height: 10.0));
    }
    return options;
  }


  void _checkAnswer(String selectedOption) {
    String correctAnswer = _currentQuestions[_quizIndex]['correctAnswer'];

    if (selectedOption == correctAnswer) {
      setState(() {
        _correctAnswers++;
      });

      // Correct answer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Incorrect answer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect. The correct answer is $correctAnswer.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Move to the next question or end the quiz
    setState(() {
      _quizIndex++;
    });
  }
}