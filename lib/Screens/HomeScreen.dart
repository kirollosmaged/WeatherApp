import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weatherapplicaation/model/tempmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int Temperature = 0;
  int woeid = 0;
  String city="City";
  String weather="clear";
  String abbr="";
  Future<void> fetchcity(String input) async {
    var url = Uri.parse('https://www.metaweather.com/api/location/search/?query=$input');
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body)[0];
    setState(() {
      woeid=responsebody["woeid"];
      city=responsebody["title"];

    });
  }
  Future<List<tempmodel>> fetchtemperature() async {
    var url = Uri.parse('https://www.metaweather.com/api/location/$woeid');
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body)["consolidated_weather"];
    setState(() {
      Temperature=responsebody[0]["the_temp"].round();
      weather=responsebody[0]["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbr=responsebody[0]["weather_state_abbr"];

    });
    List <tempmodel>list=[];
    for(var x in responsebody){
      tempmodel y=tempmodel(applicable_date: x["applicable_date"], max_temp: x["max_temp"], min_temp: x["min_temp"], weather_state_abbr: x["weather_state_abbr"]);
      list.add(y);
    }
    return list;

  }
  Future<void> onTextSubmit(String input) async {
    await fetchcity(input);
    await fetchtemperature();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/$weather.png"),fit: BoxFit.cover
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
                child: Image.network("https://www.metaweather.com/static/img/weather/png/c.png", width: 100)
            ),
            Center(child:Text("$Temperature",
            style: TextStyle(
              color: Colors.white,
              fontSize: 60.0,

            ),
            )),
            Center(child:Text("$city",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40.0,
              ),
            )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onSubmitted: (String input){
                  onTextSubmit(input);
                },
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),

                decoration: InputDecoration(
                  hintText: "Search For Another Location..",
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  prefixIcon: Icon(Icons.search_outlined, color: Colors.white, size: 35)
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
