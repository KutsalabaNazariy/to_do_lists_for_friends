import 'package:hands_on_layouts/friend.dart';

class Favor {
  final String uuid;
  final String description;
  final DateTime dueDate;
  final bool? accepted;
  final DateTime completed;
  final Friend friend;

  Favor({
    required this.uuid,
    required this.description,
    required this.dueDate,
    required this.accepted,
    required this.completed,
    required this.friend,
  });

  /// returns true if the favor is active ( the user is doing it )
  get isDoing => accepted == true;

  /// returns true if the user has not answered the request yet
  get isRequested => accepted == null;

  /// returns true if the favor is already completed
  get isCompleted => true;

  /// returns true if the favor was not accepted
  get isRefused => accepted == false;

  Favor copyWith({
    String? uuid,
    String? description,
    DateTime? dueDate,
    bool? accepted,
    DateTime? completed,
    Friend? friend,
  }) {
    return Favor(
      uuid: uuid ?? this.uuid,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      accepted: accepted ?? this.accepted,
      completed: completed ?? this.completed,
      friend: friend ?? this.friend,
    );
  }
}