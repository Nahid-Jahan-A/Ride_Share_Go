import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base use case interface for async operations returning Either
/// [Type] is the success return type
/// [Params] is the parameter type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base use case for stream operations
/// Used for real-time data subscriptions
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require any parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Stream use case that doesn't require parameters
abstract class NoParamsStreamUseCase<Type> {
  Stream<Either<Failure, Type>> call();
}

/// Parameter class for use cases that don't need parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Parameter class for pagination
class PaginationParams extends Equatable {
  final int page;
  final int limit;
  final String? cursor;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
    this.cursor,
  });

  @override
  List<Object?> get props => [page, limit, cursor];
}

/// Parameter class for ID-based lookups
class IdParams extends Equatable {
  final String id;

  const IdParams(this.id);

  @override
  List<Object?> get props => [id];
}
