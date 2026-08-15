abstract final class ProjectAuthAccounts {
  static const String adminEmail = 'admin@gmail.com';
  static const String adminUid = 'jSMOrviVBlV7fJAwpVDlb9kdhyt1';

  static const String orgManagerEmail = 'shelter@helper.org';
  static const String orgManagerUid = '4V18HCxGugXtHrh2meTeyeqZD2n2';

  static const String volunteerRahimEmail = 'rahim@volunteer.bd';
  static const String volunteerRahimUid = 'r2bSFATswwe7O51D5Fc16GgsMkG3';

  static const String donorSaymumEmail = 'saymum.rahman@tinywings.bd';
  static const String donorSaymumUid = 'RuQgI2mM8NUG7zQ0SUHYQNQwWNO2';

  static const String opportunityPosterEmail = 'circulars@tinywings.bd';
  static const String opportunityPosterUid = 'BmHdDDPMsONAUBW4ykM4mrrxu6m2';

  static const String donorSadiaEmail = 'sadia.anjum@tinywings.bd';
  static const String donorSadiaUid = 'KUZp58Zt70arYA9mst6Zir3VBwf2';

  static const String donorFahimEmail = 'fahim.chowdhury@tinywings.bd';
  static const String donorFahimUid = 'iIU6ZvfDjChsfHevzcH1uQD7d8B2';

  static const String donorNabilaEmail = 'nabila.haque@tinywings.bd';
  static const String donorNabilaUid = 'xNmRBm01yfRZou186iWJh6zj4L42';

  static const String volunteerRituEmail = 'ritu.akter@tinywings.bd';
  static const String volunteerRituUid = 'BpMU3BpnLlWd7J18OpIP5kbIBck2';

  static const Map<String, String> emailToUid = {
    adminEmail: adminUid,
    orgManagerEmail: orgManagerUid,
    volunteerRahimEmail: volunteerRahimUid,
    donorSaymumEmail: donorSaymumUid,
    opportunityPosterEmail: opportunityPosterUid,
    donorSadiaEmail: donorSadiaUid,
    donorFahimEmail: donorFahimUid,
    donorNabilaEmail: donorNabilaUid,
    volunteerRituEmail: volunteerRituUid,

    // Backward-compatible aliases from earlier drafts.
    'saymum@demo.un': donorSaymumUid,
  };

  static const Map<String, String> legacyUidToLiveUid = {
    'uid_admin': adminUid,
    'uid_org_admin': orgManagerUid,
    'uid_volunteer': volunteerRahimUid,
    'uid_donor_saymum': donorSaymumUid,
    'uid_opportunity_poster': opportunityPosterUid,
    'uid_donor_sadia': donorSadiaUid,
    'uid_donor_fahim': donorFahimUid,
    'uid_donor_nabila': donorNabilaUid,
    'uid_volunteer_ritu': volunteerRituUid,
    'user_saymum': donorSaymumUid,
  };

  static String normalizeUid(String uid) {
    return legacyUidToLiveUid[uid] ?? uid;
  }
}
