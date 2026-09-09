import 'package:get/get.dart';
import '../models/call_record.dart';
import '../services/call_history_service.dart';
import 'user_session_controller.dart';

class CallHistoryController extends GetxController {
  final CallHistoryService _callHistoryService = CallHistoryService();

  final history = <CallRecord>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final session = Get.find<UserSessionController>();
    _callHistoryService.watchHistory(session.userId).listen(
      (records) {
        history.assignAll(records);
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (_) {
        isLoading.value = false;
        errorMessage.value = 'Could not load call history. Check your connection and try again.';
      },
    );
  }
}
