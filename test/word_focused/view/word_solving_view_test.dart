// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_domain/game_domain.dart';
import 'package:io_crossword/crossword/crossword.dart';
import 'package:io_crossword/l10n/l10n.dart';
import 'package:io_crossword/word_selection/word_selection.dart';
import 'package:io_crossword_ui/io_crossword_ui.dart';
import 'package:mockingjay/mockingjay.dart';

import '../../helpers/helpers.dart';

class _MockCrosswordBloc extends MockBloc<CrosswordEvent, CrosswordState>
    implements CrosswordBloc {}

class _MockWordSolvingBloc
    extends MockBloc<WordSelectionEvent, WordSelectionState>
    implements WordSelectionBloc {}

class _FakeWord extends Fake implements Word {
  @override
  String get id => 'id';

  @override
  String get clue => 'clue';

  @override
  Axis get axis => Axis.horizontal;

  @override
  int? get solvedTimestamp => null;

  @override
  String get answer => 'answer';
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(Locale('en'));
  });

  group('$WordSolvingView', () {
    group('renders', () {
      late WordSelection selectedWord;

      setUp(() {
        selectedWord = WordSelection(section: (0, 0), word: _FakeWord());
      });

      testWidgets(
        'a $WordSolvingLargeView when layout is large',
        (tester) async {
          await tester.pumpApp(
            layout: IoLayoutData.large,
            WordSolvingView(selectedWord: selectedWord),
          );

          expect(find.byType(WordSolvingLargeView), findsOneWidget);
          expect(find.byType(WordSolvingSmallView), findsNothing);
        },
      );

      testWidgets(
        'a $WordSolvingSmallView when layout is small',
        (tester) async {
          await tester.pumpApp(
            layout: IoLayoutData.small,
            WordSolvingView(selectedWord: selectedWord),
          );

          expect(find.byType(WordSolvingSmallView), findsOneWidget);
          expect(find.byType(WordSolvingLargeView), findsNothing);
        },
      );
    });
  });

  group('$WordSolvingLargeView', () {
    late WordSelectionBloc wordSolvingBloc;
    late CrosswordBloc crosswordBloc;
    late Widget widget;

    final selectedWord = WordSelection(section: (0, 0), word: _FakeWord());

    setUp(() {
      wordSolvingBloc = _MockWordSolvingBloc();
      crosswordBloc = _MockCrosswordBloc();

      widget = MultiBlocProvider(
        providers: [
          BlocProvider.value(value: wordSolvingBloc),
          BlocProvider.value(value: crosswordBloc),
        ],
        child: WordSolvingLargeView(selectedWord),
      );

      when(() => crosswordBloc.state).thenReturn(
        CrosswordState(
          sectionSize: 20,
          selectedWord: selectedWord,
        ),
      );
    });

    group('renders', () {
      testWidgets(
        'the clue text',
        (tester) async {
          await tester.pumpApp(widget);
          expect(find.text(selectedWord.word.clue), findsOneWidget);
        },
      );

      testWidgets(
        'a $TopBar',
        (tester) async {
          await tester.pumpApp(widget);
          expect(find.byType(TopBar), findsOneWidget);
        },
      );
    });

    testWidgets(
      'tapping the submit button sends AnswerSubmitted event',
      (tester) async {
        await tester.pumpApp(widget);

        final submitButton = find.text(l10n.submit);
        await tester.tap(submitButton);

        verify(() => crosswordBloc.add(const AnswerSubmitted())).called(1);
      },
    );

    testWidgets(
      'adds WordFocusedSuccessRequested event when state changes with solved '
      'selected word',
      (tester) async {
        whenListen(
          crosswordBloc,
          Stream.value(
            CrosswordState(
              sectionSize: 20,
              selectedWord: selectedWord.copyWith(
                solvedStatus: WordStatus.solved,
              ),
            ),
          ),
        );
        await tester.pumpApp(widget);

        verify(() => wordSolvingBloc.add(const WordFocusedSuccessRequested()))
            .called(1);
      },
    );
  });

  group('$WordSolvingSmallView', () {
    late WordSelectionBloc wordFocusedBloc;
    late CrosswordBloc crosswordBloc;
    late Widget widget;

    final selectedWord = WordSelection(section: (0, 0), word: _FakeWord());

    setUp(() {
      wordFocusedBloc = _MockWordSolvingBloc();
      crosswordBloc = _MockCrosswordBloc();

      widget = Theme(
        data: IoCrosswordTheme().themeData,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: wordFocusedBloc),
            BlocProvider.value(value: crosswordBloc),
          ],
          child: WordSolvingSmallView(selectedWord),
        ),
      );

      when(() => wordFocusedBloc.state).thenReturn(
        WordSelectionState(
          status: WordSelectionStatus.solving,
          wordIdentifier: '1',
          wordPoints: null,
        ),
      );
      when(() => crosswordBloc.state).thenReturn(
        CrosswordState(
          sectionSize: 20,
          selectedWord: selectedWord,
        ),
      );
    });

    testWidgets(
      'add AnswerUpdated event when user enters all the letters',
      (tester) async {
        await tester.pumpApp(widget);

        final input = tester.widget<IoWordInput>(find.byType(IoWordInput));
        input.onWord!('answer');

        verify(
          () => crosswordBloc.add(const AnswerUpdated('answer')),
        ).called(1);
      },
    );

    testWidgets(
      'tap the submit button sends AnswerSubmitted event',
      (tester) async {
        await tester.pumpApp(widget);

        final submitButton = find.text(l10n.submit);
        await tester.tap(submitButton);
        verify(() => crosswordBloc.add(const AnswerSubmitted())).called(1);
      },
    );

    testWidgets(
      'adds WordFocusedSuccessRequested event when state changes with solved '
      'selected word',
      (tester) async {
        whenListen(
          crosswordBloc,
          Stream.value(
            CrosswordState(
              sectionSize: 20,
              selectedWord: selectedWord.copyWith(
                solvedStatus: WordStatus.solved,
              ),
            ),
          ),
        );
        await tester.pumpApp(widget);

        verify(() => wordFocusedBloc.add(const WordFocusedSuccessRequested()))
            .called(1);
      },
    );
  });
}
