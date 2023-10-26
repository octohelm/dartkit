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
    String? method,
    Uri? uri,
    Map<String, dynamic>? headers,
    T? body,
    Stream<List<int>>? requestBody,
    int? maxRedirects,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRequest.copyWith(...)`.
class _$RequestCWProxyImpl<T> implements _$RequestCWProxy<T> {
  const _$RequestCWProxyImpl(this._value);

  final Request<T> _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Request<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  Request<T> call({
    Object? method = const $CopyWithPlaceholder(),
    Object? uri = const $CopyWithPlaceholder(),
    Object? headers = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? requestBody = const $CopyWithPlaceholder(),
    Object? maxRedirects = const $CopyWithPlaceholder(),
  }) {
    return Request<T>(
      method: method == const $CopyWithPlaceholder() || method == null
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String,
      uri: uri == const $CopyWithPlaceholder() || uri == null
          ? _value.uri
          // ignore: cast_nullable_to_non_nullable
          : uri as Uri,
      headers: headers == const $CopyWithPlaceholder()
          ? _value.headers
          // ignore: cast_nullable_to_non_nullable
          : headers as Map<String, dynamic>?,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as T?,
      requestBody: requestBody == const $CopyWithPlaceholder()
          ? _value.requestBody
          // ignore: cast_nullable_to_non_nullable
          : requestBody as Stream<List<int>>?,
      maxRedirects: maxRedirects == const $CopyWithPlaceholder()
          ? _value.maxRedirects
          // ignore: cast_nullable_to_non_nullable
          : maxRedirects as int?,
    );
  }
}

extension $RequestCopyWith<T> on Request<T> {
  /// Returns a callable class that can be used as follows: `instanceOfRequest.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$RequestCWProxy<T> get copyWith => _$RequestCWProxyImpl<T>(this);
}
