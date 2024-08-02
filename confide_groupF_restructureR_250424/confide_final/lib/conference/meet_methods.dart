import 'package:confide/api/apis.dart';
import 'package:confide/conference/firestore_methods.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class MeetMethods {
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;
      featureFlag.meetingPasswordEnabled = false;
      featureFlag.inviteEnabled = true;

      String name;
      if (username.isEmpty) {
        name = APIs.user.displayName!;
      } else {
        name = username;
      }

      var options = JitsiMeetingOptions(room: roomName)
        ..userDisplayName = name
        ..userEmail = APIs.user.email
        ..userAvatarURL = APIs.user.photoURL
        ..token = APIs.user.uid // at a time remove/hide this line of code.
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted;

      _firestoreMethods.addToMeetingHistory(roomName);
      await JitsiMeet.joinMeeting(options);
    } catch (e) {
      print("error: $e");
    }
  }
}
