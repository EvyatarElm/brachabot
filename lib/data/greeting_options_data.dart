class RecipientOption {
  final String id;
  final String label;

  const RecipientOption({required this.id, required this.label});
}

const List<RecipientOption> recipients = [
  RecipientOption(id: 'wife', label: 'לאישה'),
  RecipientOption(id: 'husband', label: 'לבעל'),
  RecipientOption(id: 'partner_m', label: 'לבן הזוג'),
  RecipientOption(id: 'partner_f', label: 'לבת הזוג'),
  RecipientOption(id: 'son', label: 'לבן'),
  RecipientOption(id: 'daughter', label: 'לבת'),
  RecipientOption(id: 'brother', label: 'לאח'),
  RecipientOption(id: 'sister', label: 'לאחות'),
  RecipientOption(id: 'friend_m', label: 'לחבר'),
  RecipientOption(id: 'friend_f', label: 'לחברה'),
  RecipientOption(id: 'father', label: 'לאב'),
  RecipientOption(id: 'mother', label: 'לאם'),
];

const List<String> ageRanges = [
  'עד 12',
  '13–17',
  '18–30',
  '31–50',
  '51–70',
  '70+',
];

const List<String> greetingStyles = [
  'חם ואישי',
  'הומוריסטי',
  'רומנטי',
  'מרגש',
  'שובב',
  'רשמי',
];

const Map<String, List<String>> occasionsByRecipient = {
  'wife': ['יום האהבה', 'יום נישואים', 'יום הולדת', 'פסח', 'ראש השנה', 'שישי סתם'],
  'husband': ['יום האהבה', 'יום נישואים', 'יום הולדת', 'פסח', 'ראש השנה', 'שישי סתם'],
  'partner_m': ['יום האהבה', 'יום נישואים', 'יום הולדת', 'פסח', 'ראש השנה', 'שישי סתם'],
  'partner_f': ['יום האהבה', 'יום נישואים', 'יום הולדת', 'פסח', 'ראש השנה', 'שישי סתם'],
  'son': ['יום הולדת', 'בר מצווה', 'פסח', 'ראש השנה', 'סיום שנת לימודים', 'חנוכה'],
  'daughter': ['יום הולדת', 'בת מצווה', 'פסח', 'ראש השנה', 'סיום שנת לימודים', 'חנוכה'],
  'brother': ['יום הולדת', 'פסח', 'ראש השנה', 'חנוכה'],
  'sister': ['יום הולדת', 'פסח', 'ראש השנה', 'חנוכה'],
  'friend_m': ['יום הולדת', 'פסח', 'ראש השנה', 'סתם כי חשקתי'],
  'friend_f': ['יום הולדת', 'פסח', 'ראש השנה', 'סתם כי חשקתי'],
  'father': ['יום האב', 'יום הולדת', 'פסח', 'ראש השנה', 'חנוכה'],
  'mother': ['יום האם', 'יום הולדת', 'פסח', 'ראש השנה', 'חנוכה'],
};
