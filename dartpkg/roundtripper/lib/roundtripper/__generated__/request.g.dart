// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RequestCWProxy<T> {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Request<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  Request<T> call({
    T? body,
    Map<String, dynamic>? headers,
    String? method,
    Stream<List<int>>? requestBody,
    Uri? uri,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRequest.copyWith(...)`.
class _$RequestCWProxyImpl<T> implements _$RequestCWProxy<T> {
  final Request<T> _value;

  const _$RequestCWProxyImpl(this._value);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Request<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  Request<T> call({
    Object? body = const $CopyWithPlaceholder(),
    Object? headers = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? requestBody = const $CopyWithPlaceholder(),
    Object? uri = const $CopyWithPlaceholder(),
  }) {
    return Request<T>(
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as T?,
      headers: headers == const $CopyWithPlaceholder()
          ? _value.headers
          // ignore: cast_nullable_to_non_nullable
          : headers as Map<String, dynamic>?,
      method: method == const $CopyWithPlaceholder() || method == null
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String,
      requestBody: requestBody == const $CopyWithPlaceholder()
          ? _value.requestBody
          // ignore: cast_nullable_to_non_nullable
          : requestBody as Stream<List<int>>?,
      uri: uri == const $CopyWithPlaceholder() || uri == null
          ? _value.uri
          // ignore: cast_nullable_to_non_nullable
          : uri as Uri,
    );
  }
}

extension $RequestCopyWith<T> on Request<T> {
  /// Returns a callable class that can be used as follows: `instanceOfRequest.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$RequestCWProxy<T> get copyWith => _$RequestCWProxyImpl<T>(this);
}
