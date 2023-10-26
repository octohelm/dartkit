import 'package:copy_with_extension/copy_with_extension.dart';

part '__generated__/request.g.dart';

@CopyWith(skipFields: true)
class Request<T> {
  final String method;
  final Uri uri;
  final Map<String, dynamic>? headers;
  final T? body;
  final Stream<List<int>>? requestBody;

  const Request({
    required this.method,
    required this.uri,
    this.headers,
    this.body,
    this.requestBody,
  });

  @override
  String toString() {
    return "$method $uri";
  }

  factory Request.uri(
    String uri, {
    String method = "GET",
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T? body,
  }) {
    var u = Uri.parse(uri);

    return Request<T>(
      method: method.toUpperCase(),
      uri: Uri(
        scheme: u.scheme,
        host: u.host,
        port: u.port,
        path: u.path,
        fragment: u.fragment != "" ? u.fragment : null,
        queryParameters: {
          ...u.queryParameters,
          ...?queryParameters?.map(
            (key, value) => MapEntry(
                key,
                value is List
                    ? value.map((e) => e.toString())
                    : [value.toString()]),
          ),
        },
      ),
      headers: headers,
      body: body,
    );
  }
}
