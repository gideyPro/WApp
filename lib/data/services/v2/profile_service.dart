import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/account_user.dart';
import '../../models/v2/profile.dart';

/// Current-account reads and edits backed by `/v2/me`.
class ProfileServiceV2 {
  final ApiV2Client _client;

  ProfileServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<Profile> fetch() async {
    final data = await _client.getItem(ApiV2Constants.me);
    return Profile.fromJson(data);
  }

  /// Updates only the fields that are provided. Null leaves a field untouched.
  Future<AccountUser> update({
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.me,
      method: 'PATCH',
      body: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (gender != null) 'gender': gender,
      },
    );

    return AccountUser.fromJson(data);
  }

  Future<void> deleteAccount() async {
    await _client.send(ApiV2Constants.me, method: 'DELETE');
  }
}
