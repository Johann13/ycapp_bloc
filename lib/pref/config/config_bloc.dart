abstract class ConfigBloc {
  final defaults = <String, dynamic>{
    'YcAppRedditLink': 'https://www.reddit.com/r/YcApp/',
    'YcAppDiscordLink': 'https://discord.gg/bYWmx2y',
    'MainChannelId': '-LO4RXOIYbfmHBxRQsb3',
    'MainChannelTwitchUrl': 'https://www.twitch.tv/yogscast',
    'MainChannelTwitchId': 20786541,
    'MainChannelYoutubeId': 'UCH-_hzb2ILSCo9ftVSnrCIQ',
    'MainTwitchChannelScheduleLink': 'https://schedule.yogscast.com',
    'websiteLink': 'https://yogs.app',
    'JingleJamDonationLink': '',
    'JingleJamSchedule': 'https://schedule.yogscast.com',
    'ShowFanChannelCreator': true,
    'ShowEditorCreator': true,
    'ShowYogsDBLink': false,
    'ShowYoutubeImportButton': false,
    'merchSubTitles':
        '1:SHUT UP! SHUT UP! SHUT UP!|4:Buy some f*cking merch!|2:FOR THE MIDDENLANDS!|2:For the Champion of the People!|10:The Yogscast Offical Merchandise Store|2:Sharky and Palp|2:Dance til’ you\'re dead|2:T-Shirts and Hoodies|1:You are my Uno|4:Posters and Mugs!|2:Are you a nature Boy?|4:I am Bees!|4:Fucking Toddy!|2:100% Win Rate|1:Berry Cool|20:Happy Festag!|4:They love their cats!|2:SALT|2:HWAPOON!|6:Cat with a Bat|1:YASS|1:Crabs!|1:Beepulon!|2:You Bouphed it!|6:Buy Shirt...|4:Buy Shirt again!|4:Want some Cat nip?|4:I\'m here just for Terry...|4:Attack of the 50ft Woman|4:It\'s Perfectly Balanced|20:🙂|10:BIG RIPZ|2:DOME DOME DOME|2:Visit Sips Co. Univerity Today!|5: BIG LYDS!|5: High Rollers',
    'YogconLink': 'http://yogscast.com/yogcon',
    'YogconLiveLink': 'https://www.twitch.tv/yogscast',
    'YogconShowCountdown': false,
    'YogconDateString': '3rd - 4th of August',
    'YogconStart': 1564790400000,
    'YogconEnd': 1564963200000,
    'usePushy': false,
    'JjStart': 1575219600000,
    'JjScheduleDate': 1574614800000,
    'JjShowSchedule': true,
  };

  Future<Null> init();

  String getString(String key);

  int getInt(String key);

  bool getBool(String key);
}
