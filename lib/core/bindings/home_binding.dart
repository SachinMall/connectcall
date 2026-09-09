import 'package:get/get.dart';
import '../../controllers/call_history_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/user_session_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserSessionController(), permanent: true);
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ContactsController());
    Get.lazyPut(() => CallHistoryController());
    Get.lazyPut(() => ProfileController());
  }
}
