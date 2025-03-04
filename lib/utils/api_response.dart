enum LoadingState { idle, loading, error, success }

class ApiResponse<T> {
  final T? data;
  final String? error;
  final LoadingState state;

  ApiResponse._({
    this.data,
    this.error,
    this.state = LoadingState.idle,
  });

  factory ApiResponse.loading() => ApiResponse._(state: LoadingState.loading);
  
  factory ApiResponse.success(T data) => ApiResponse._(
    data: data,
    state: LoadingState.success,
  );
  
  factory ApiResponse.error(String error) => ApiResponse._(
    error: error,
    state: LoadingState.error,
  );

  factory ApiResponse.idle() => ApiResponse._(state: LoadingState.idle);

  bool get isLoading => state == LoadingState.loading;
  bool get isSuccess => state == LoadingState.success;
  bool get isError => state == LoadingState.error;
  bool get isIdle => state == LoadingState.idle;
}
