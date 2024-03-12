import 'package:equatable/equatable.dart';
import 'package:game_domain/game_domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

/// {@template word}
/// A model that represents a word in the crossword.
/// {@endtemplate}
@JsonSerializable(ignoreUnannotated: true)
class Word extends Equatable {
  /// {@macro word}
  const Word({
    required this.position,
    required this.axis,
    required this.answer,
    required this.clue,
    required this.hints,
    required this.solvedTimestamp,
  }) : id = '$position-$axis';

  /// {@macro word}
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  /// Unique identifier of the word determined by its position and axis.
  ///
  /// Intentionally left out of serialization to avoid redundancy.
  @JsonKey(includeToJson: false)
  final String id;

  /// Position of the board section in the board. The origin is the top left.
  @JsonKey()
  @PointConverter()
  final Point<int> position;

  /// The axis of the word in the board.
  @JsonKey()
  final Axis axis;

  /// The word answer to display in the crossword when solved.
  @JsonKey()
  final String answer;

  /// The clue to show users when guessing for the first time.
  @JsonKey()
  final String clue;

  /// The hints to show users when asked for more hints.
  @JsonKey()
  final List<String> hints;

  /// The timestamp when the word was solved. In milliseconds since epoch.
  /// If the word is not solved, this value is null.
  @JsonKey()
  final int? solvedTimestamp;

  /// Returns a json representation from this instance.
  Map<String, dynamic> toJson() => _$WordToJson(this);

  @override
  List<Object?> get props => [
        id,
        position,
        axis,
        answer,
        clue,
        hints,
        solvedTimestamp,
      ];
}

/// The two possible axis for a word in the board.
enum Axis {
  /// From left to right.
  horizontal,

  /// From top to bottom.
  vertical,
}
