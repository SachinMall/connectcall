import 'package:get/get.dart';
import 'incoming_call_controller.dart';
import 'user_session_controller.dart';

class HomeController extends GetxController {
  final selectedTabIndex = 0.obs;

  void changeTab(int index) => selectedTabIndex.value = index;

  @override
  void onInit() {
    super.onInit();
    final session = Get.find<UserSessionController>();
    if (!Get.isRegistered<IncomingCallController>()) {
      Get.put(IncomingCallController(session.userId), permanent: true);
    }
  }
}
