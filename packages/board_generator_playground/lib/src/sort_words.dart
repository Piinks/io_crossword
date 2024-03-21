///  Sorted words is organized with this data structure to improve the finding
///  of words to be placed in the board.
///
///  Check [sortWords] for more information
typedef SortedWords = Map<int, Map<int, Map<String, Set<String>>>>;

/// Generates the words organised by the length of the word + character
/// position + the character.
///
/// This way the searches to find a word for the available space is performed
/// with good performance.
///
/// Example:
/// The list of words ['Aunt', 'Addy', 'Adds', 'Away']
///
/// would be organized as
///
/// final organizedWords = <int, Map<int, Map<String, Set<String>>>>{
///   4: {
///     0: {
///       'a': {'Adds', 'Addy', 'Aunt', 'Away'},
///     },
///     1: {
///       'u': {'Aunt'},
///       'd': {'Adds', 'Addy'},
///       'w': {'Away'},
///     },
///     2: {
///       'n': {'Aunt'},
///       'd': {'Adds', 'Addy'},
///       'a': {'Away'},
///     },
///     3: {
///       't': {'Aunt'},
///       'y': {'Addy', 'Away'},
///       's': {'Adds'},
///     },
///   },
/// };
///
/// We can perform the following to search for words that can be added
/// in the crossword.
///
/// final fourCharacters = organizedWords[4];
///
///  If the only requirement is to have the character starting with a
///  we can just get the first
/// organizedWords[4][0]['a'].first; // Aunt
///
/// organizedWords[4][0]['a']; // Aunt, Addy, Adds, Away
/// organizedWords[4][1]['d']; // 'Addy' 'Adds'
/// organizedWords[4][1]['u']; // Aunt
///
/// If we need a word starts with a and in the second position also with a
/// organizedWords[4][0]['a'].firstWhere((word) => word.startsWith('a', 2)); // Away
///
/// If we need a word starts with a, the second position with d and ends with s
/// organizedWords[4][0]['a'].firstWhere((word) => word.startsWith('d', 2) && word.endsWith('s')); // Adds
///
/// Looks like: Map<int(numberOfCharacters), Map<int(characterPosition,
/// Map<String(letterCharacter), Set<String(Word)>>>>
SortedWords sortWords(
  Iterable<String> wordList,
) {
  final map = <int, Map<int, Map<String, Set<String>>>>{};

  for (final word in wordList) {
    if (!map.containsKey(word.length)) {
      map[word.length] = <int, Map<String, Set<String>>>{
        for (var i = 0; i < word.length; i++) i: <String, Set<String>>{},
      };
    }

    for (var i = 0; i < word.length; i++) {
      final character = word[i].toLowerCase();
      final mapCharacterPosition = map[word.length]![i]!;

      if (!mapCharacterPosition.containsKey(character)) {
        mapCharacterPosition[character] = <String>{};
      }

      mapCharacterPosition[character]!.add(word);
    }
  }

  return map;
}
