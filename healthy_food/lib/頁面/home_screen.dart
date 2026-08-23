import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        margin: EdgeInsets.only(top: 70.0, left: 50.0,),
        child: Column(children:[
        Row(children: [
          Icon(
            Icons.menu, size:35.0
            ),
          Icon(
            Icons.search, size:35.0
            ),
        ],
        ),
        SizedBox(height: 20.0),
        Row(children: [
            Text("Work Place",style: TextStyle(color:Colors.black,fontSize:24.0),),
            Icon(Icons.arrow_drop_down, size:50.0,)
        ],
        ),
        Text(
          "Choose your healthy meal",
          style: TextStyle(
            color:Colors.black,
            fontSize:17.0),
            ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(border:Border.all(color:Color(0xff66D678),),borderRadius:BorderRadius.circular(7)),
              child:Icon(
                Icons.home, 
                color:Color(0xff08F82E),size:40.0,
                ),
                ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(border:Border.all(color:Color(0xffC5C5C5),width:2.0),borderRadius:BorderRadius.circular(7)),
              child:Icon(
                Icons.favorite, 
                color:Color(0xffC5C5C5),size:40.0,
                ),
                ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(border:Border.all(color:Color(0xffCEC7C7),width:2.0),borderRadius:BorderRadius.circular(7)),
              child:Icon(
                Icons.filter_list,
                color:Color(0xffCEC7C7),size:40.0,
                ),
                ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(border:Border.all(color:Color(0xffCEC7C7),width:2.0),borderRadius:BorderRadius.circular(7)),
              child:Icon(
                Icons.shopping_cart,
                color:Color(0xffCEC7C7),size:40.0,
                ),
                )            
        ],
        ),
        SizedBox(height: 30.0,),
        Row(
          children:[
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(border: Border.all(color:Color(0xffC5C5C5)),
              borderRadius:BorderRadius.circular(10)),
              width: MediaQuery.of(context).size.width/2.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.favorite, 
                      color: Color(0xffFB0000),size:25.0
                      ),
                      
                    ],
                  ),
                   SizedBox(
                    height:20.0,
                   ),
                   Center(
                     child: ClipRRect(
                      borderRadius: BorderRadius.circular(120.0), 
                      child: Image.asset(
                        "jpg",
                        height: 150, 
                        width: 150, 
                        fit:BoxFit.cover,
                        )),
                   ),
                   SizedBox(height:5.0,),
                    Text(
          "meal",
          style: TextStyle(
            color:Colors.black,
            fontSize:20.0),
            ),
            Row(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children:[
                Text(
                  "\$",
                  style: TextStyle(
                      color:Color(0xff66D678),
                      fontSize:20.0),
                ),
                Container(
                    padding: EdgeInsets.all(3),
                    decoration:BoxDecoration(
                      color:Color(0xff66D678),borderRadius:BorderRadius.circular(30)
                    ),
                    child: Icon(
                      Icons.add,
                      color:Colors.white,
                      ))
              ],
              ),
              Spacer(),
              Container(
                margin:EdgeInsets.only(bottom:40.0),
                padding:EdgeInsets.only(left:30.0,right:30.0),
                height:60,
                width:MediaQuery.of(context).size.width,
                decoration:BoxDecoration(
                  color:Color(0xff66D678),
                  borderRadius:BorderRadius.only(
                    bottomLeft:Radius.circular(40),bottomRight:Radius.circular(40))),
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children:[
                    Text(
                      "2 items",
                      style: TextStyle(
                          color:Colors.white,
                          fontSize:20.0),
                    ),
                    Text(
                      "\$30",
                      style: TextStyle(
                          color:Colors.white,
                          fontSize:20.0),
                ),
             ],),)
                 ],
                ),
               )
             ],

            ),

           ],
          ),
         ),
        );
       }
      }