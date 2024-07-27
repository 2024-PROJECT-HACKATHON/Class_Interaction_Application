import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spaghetti/ApiUrl.dart';
import 'package:spaghetti/Dialog/Dialogs.dart';
import 'package:spaghetti/classroom/student/Enrollment.dart';

class EnrollmentService extends ChangeNotifier {
  final String apiUrl = Apiurl().url;
  final storage = new FlutterSecureStorage();
  List<Enrollment> enrollList = [];

  // setter
  void setEnrollList(List<Enrollment> enrollments) {
    enrollList = enrollments;
    notifyListeners();
  }

  // 새로 추가하는 메서드
  void removeEnrollment(String classId) {
    enrollList
        .removeWhere((enrollment) => enrollment.classroom.classId == classId);
    notifyListeners();
  }

  //학생 수업 목록 삭제
  Future<void> enrollmentDelete(
    BuildContext context,
    String enrollmentID,
  ) async {
    // JWT 토큰을 저장소에서 읽어오기
    String? jwt = await storage.read(key: 'Authorization');

    if (jwt == null) {
      //토큰이 존재하지 않을 때 첫페이지로 이동
      await Dialogs.showErrorDialog(context, '로그인시간이 만료되었습니다.');
      Navigator.of(context).pushReplacementNamed('/Loginpage');
      return;
    }

    // 헤더에 JWT 토큰 추가
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '${jwt}',
    };

    try {
      var response = await http.delete(
        Uri.parse('$apiUrl/student/enrollmentDelete/$enrollmentID'),
        headers: headers,
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        for (int i = 0; i < enrollList.length; i++) {
          print(i);
          if (enrollList[i].enrollmentID == enrollmentID) {
            enrollList.removeAt(i);
            notifyListeners();
          }
        }
      } else {
        await Dialogs.showErrorDialog(context, '오류발생');
      }
    } catch (exception) {
      print(exception);
      await Dialogs.showErrorDialog(context, "서버와의 통신 중 오류가 발생했습니다.");
    }
  }
}
