import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> languageNews = [];
  List<dynamic> trendingNews = [];
  List<String> countries = [
    'us',
    'gb',
    'au',
    'ca',
    'in',
    'jp',
  ]; // Add your desired countries here
  String selectedCountry = 'us'; // Default selected country
  bool isLoading = true;
  int currentIndex = 0;

  Future<void> fetchLanguageNews(String language, String country) async {
    final apiKey = 'Your Api KEY'; // Replace with your News API key
    final url =
        'https://newsapi.org/v2/top-headlines?language=$language&country=$country&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        languageNews = data['articles'];
      });
    } else {
      throw Exception('Failed to fetch language news');
    }
  }

  Future<void> fetchTrendingNews(String country) async {
    final apiKey = 'Your Api Key'; // Replace with your News API key
    final url =
        'https://newsapi.org/v2/top-headlines?country=$country&category=general&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        trendingNews = data['articles'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch trending news');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLanguageNews('en', selectedCountry);
    fetchTrendingNews(selectedCountry);
  }

  Widget buildNewsList(List<dynamic> newsList) {
    return RefreshIndicator(
      onRefresh: () {
        return fetchLanguageNews('en', selectedCountry)
            .then((_) => fetchTrendingNews(selectedCountry));
      },
      child: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final article = newsList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(article: article),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      article['urlToImage'] != null
                          ? Image.network(
                              article['urlToImage'],
                              height: 200.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      SizedBox(height: 8.0),
                      Text(
                        article['title'] ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        article['description'] ?? '',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Source: ${article['source']['name'] ?? ''}',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      buildNewsList(languageNews),
      buildNewsList(trendingNews),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: Text(
          'The News App -${getCountryName(selectedCountry)}',
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.language,
              size: 25,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.language,
              size: 30,
              color: Colors.white,
            ),
            label: 'Language News',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.trending_up,
              size: 25,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.trending_up,
              size: 30,
              color: Colors.white,
            ),
            label: 'Trending News',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            final country = countries[index];
            return ListTile(
              title: Text(
                getCountryName(country),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: country == selectedCountry
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  selectedCountry = country;
                  isLoading = true;
                });
                fetchLanguageNews('en', selectedCountry);
                fetchTrendingNews(selectedCountry);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  String getCountryName(String countryCode) {
    switch (countryCode) {
      case 'us':
        return 'United States';
      case 'gb':
        return 'United Kingdom';
      case 'au':
        return 'Australia';
      case 'ca':
        return 'Canada';
      case 'in':
        return 'India';
      case 'jp':
        return 'Japan';
      default:
        return '';
    }
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  NewsDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75,
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
          title: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Text(
                "${article['title']}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              article['urlToImage'] != null
                  ? Image.network(
                      article['urlToImage'],
                      height: 200.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              SizedBox(height: 16.0),
              Text(
                article['title'] ?? '',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Source: ${article['source']['name'] ?? ''}',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                article['description'] ?? '',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                article['content'] ?? '',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
