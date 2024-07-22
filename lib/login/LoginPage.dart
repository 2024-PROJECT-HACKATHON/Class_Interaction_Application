import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaghetti/classroom/classroom.dart';
import 'package:spaghetti/classroom/instructor/classroomService.dart';
import 'package:spaghetti/classroom/student/Enrollment.dart';
import 'package:spaghetti/classroom/student/EnrollmentService.dart';
import 'package:spaghetti/classroom/student/classEnterPage.dart';
import 'package:spaghetti/classroom/instructor/classCreatePage.dart';
import 'package:spaghetti/login/AuthService.dart';
import 'package:spaghetti/member/User.dart';
import 'package:spaghetti/member/UserProvider.dart';
import '../main/startPage.dart';

class LoginPage extends StatelessWidget {
  final String role;

  const LoginPage({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name;

    if (role == "student") {
      name = "학생님";
    } else {
      name = "교수님";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StartPage(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: PageView(
        children: [
          Container(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment(-0.78, -0.68),
                  child: Text('수업은 언제나',
                      style: TextStyle(fontSize: 15, color: Color(0xff696868))),
                ),
                Align(
                  alignment: Alignment(-0.7, -0.6),
                  child: Text('에코(Echo) 클래스룸', style: TextStyle(fontSize: 20)),
                ),
                Align(
                  alignment: Alignment(-0.75, -0.51),
                  child: Text('$name, 반가워요!',
                      style: TextStyle(fontSize: 15, color: Color(0xff696868))),
                ),
                Align(
                  alignment: Alignment(0, 0.4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      surfaceTintColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      loginModal(context);
                    },
                    child:
                        Text("                   카카오로 시작하기                   "),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.4, 0.39),
                  child: Image.asset(
                    'assets/images/icon_Kakao.png',
                    width: 27,
                    height: 27,
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(192, 175, 173, 172),
                      surfaceTintColor: Color.fromARGB(192, 175, 173, 172),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (role == "student") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClassEnterPage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClassCreatePage()),
                        );
                      }
                    },
                    child: Text(
                        "                     구글로 시작하기                     "),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.4, 0.6),
                  child: Image.asset(
                    'assets/images/icon_Google.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //로그인모달 메소드
  Future<dynamic> loginModal(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        var email = "";
        var password = "";
        return AlertDialog(
          title: Text("로그인"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: '아이디'),
                  onChanged: (value) {
                    email = value;
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  decoration: InputDecoration(labelText: '비밀번호'),
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true, // 비밀번호 입력
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 로그인 요청
                var response = await AuthService().login(email, password, role);
                if (response.statusCode == 200) {
                  User user =
                      AuthService().parseUser(json.decode(response.body));
                  Provider.of<UserProvider>(context, listen: false)
                      .setUser(user);
                  if (role == "student") {
                    List<Enrollment> enrollments = AuthService()
                            .parseEnrollments(json.decode(response.body)) ??
                        [];
                    Provider.of<EnrollmentService>(context, listen: false)
                        .setEnrollList(enrollments);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClassEnterPage()),
                    );
                  } else {
                    List<Classroom> classrooms = AuthService()
                            .parseClassrooms(json.decode(response.body)) ??
                        [];
                    Provider.of<ClassroomService>(context, listen: false)
                        .setClassrooms(classrooms);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClassCreatePage()),
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text("아이디 또는 비밀번호가 잘못되었습니다."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("취소"),
                          )
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('로그인'),
            ),
          ],
        );
      },
    );
  }
}
