import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:safe_space/home.dart';
import 'package:safe_space/login.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);   
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatefulWidget {
  
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final Location location = Location();
 int _count = 0;

  void _onBoxTapped() {
    setState(() {
      _count++;
    });

    if (_count == 3) {
      // Navigate to the new page
      Navigator.pushNamed(context, '/new-page');
    }
  }
  @override
  void initState() {
    super.initState();
    // navigate();
  }
    final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> navigate() async {
    final LocationData? position = await location.getLocation();
    final double lat = position?.latitude ?? 123213;
    final double long = position?.longitude ?? 2312312;

    setState(() {
      mytarget = LatLng(lat, long);
    });


    if (currentUser == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Signin()), // Change to your SignUp page
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Maps(mytarget, currentUser!.uid)),
        (route) => false,
      );
    }
  }

  late LatLng mytarget;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(4281483342),body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Text("TIC TAC TOE",style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.w500,decoration: TextDecoration.underline,decorationStyle:TextDecorationStyle.dotted),)
          ,          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("0",style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(width:10),
                          Text(":",style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(width:10),
 Text("0",style: TextStyle(fontSize: 30,color:Colors.blue.withOpacity(0.5),fontWeight: FontWeight.bold),),
         
            ]
            ,
          )
,
           Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Handle Tic-Tac-Toe cell click here.
                        if (index == 8) {
                          // If the bottom-left cell is clicked three times, navigate to another page.
                          setState(() {
                            _count++;
                            if (_count== 3) {
                             
                              navigate();
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color:Colors.blue.withOpacity(0.3),
                              width: 2.5,
                                
                              
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '',
                              style: TextStyle(fontSize: 32.0),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          
            SizedBox(height:30),
            Container(width: MediaQuery.of(context).size.width-50,height: 50,decoration:BoxDecoration(borderRadius: BorderRadius.circular(10),color: hexToColor("#212124"),),child: Center(child: Text("New Game",style: TextStyle(fontSize: 19,color: Colors.white,),)) ,)
     ,  SizedBox(height: 15,),
                   Container(width: MediaQuery.of(context).size.width-50,height: 50,decoration:BoxDecoration(borderRadius: BorderRadius.circular(10),color: hexToColor("#212124"),),child: Center(child: Text("Game Over",style: TextStyle(fontSize: 19,color: Colors.white,),)) ,)

        ],
      ),
    ),);
    
  }
}
