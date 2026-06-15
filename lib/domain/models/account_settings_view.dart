import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/types/cloud_account.dart';

/// Read model for the Account settings screen: the resolved [status] plus the
/// stored [link] (when one exists).
class AccountSettingsView {
  const AccountSettingsView({required this.status, this.link});

  final AccountLinkStatus status;
  final CloudAccountLink? link;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountSettingsView &&
          other.status == status &&
          other.link == link;

  @override
  int get hashCode => Object.hash(status, link);
}

/// Pure resolver mapping a stored [link] plus platform/config facts to the
/// display [AccountLinkStatus]
/// (`docs/business/account-sync/account-sync.md` §Account link statuses).
///
/// Platform/config gates dominate: an unsupported platform or a build without
/// OAuth config cannot sign in regardless of any stored link.
AccountLinkStatus resolveAccountLinkStatus({
  required CloudAccountLink? link,
  required bool isConfigured,
  required bool isSupported,
}) {
  if (!isSupported) {
    return AccountLinkStatus.unsupported;
  }
  if (!isConfigured) {
    return AccountLinkStatus.unconfigured;
  }
  if (link == null) {
    return AccountLinkStatus.signedOut;
  }
  if (link.driveAppDataAuthorized) {
    return AccountLinkStatus.signedIn;
  }
  return AccountLinkStatus.needsDriveAuthorization;
}
