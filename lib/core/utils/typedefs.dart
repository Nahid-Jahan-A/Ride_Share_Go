import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Type alias for Future Either result
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Type alias for Stream Either result
typedef ResultStream<T> = Stream<Either<Failure, T>>;

/// Type alias for Either result (synchronous)
typedef Result<T> = Either<Failure, T>;

/// Type alias for void Future Either result
typedef ResultVoid = Future<Either<Failure, void>>;

/// Type alias for JSON map
typedef Json = Map<String, dynamic>;

/// Type alias for list of JSON
typedef JsonList = List<Map<String, dynamic>>;

/// Callback type for pagination
typedef PaginatedCallback<T> = Future<List<T>> Function(int page, int limit);
