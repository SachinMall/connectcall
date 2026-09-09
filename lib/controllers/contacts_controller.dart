import 'package:get/get.dart';
import '../models/app_user.dart';
import '../models/call_record.dart';
import '../services/call_navigator.dart';
import '../services/user_directory_service.dart';
import 'user_session_controller.dart';

class ContactsController extends GetxController {
  final UserDirectoryService _userDirectoryService = UserDirectoryService();

  final contacts = <AppUser>[].obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  List<AppUser> get filteredContacts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return contacts;
    return contacts.where((user) => user.name.toLowerCase().contains(query)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final session = Get.find<UserSessionController>();
    _userDirectoryService.watchContacts(session.userId).listen(
      (users) {
        contacts.assignAll(users);
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (_) {
        isLoading.value = false;
        errorMessage.value = 'Could not load contacts. Check your connection and try again.';
      },
    );
  }

  void updateSearch(String query) => searchQuery.value = query;

  Future<void> callContact(AppUser contact, {required bool isVideoCall}) async {
    final session = Get.find<UserSessionController>();
    final caller = session.currentUser.value;
    if (caller == null) return;

    await CallNavigator.placeCall(
      caller: caller,
      callee: contact,
      mediaType: isVideoCall ? CallMediaType.video : CallMediaType.audio,
    );
  }
}
