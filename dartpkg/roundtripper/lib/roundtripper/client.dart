import 'dart:typed_data';

import 'package:context/context.dart';

import 'adapter.dart';
import 'http_status.dart';
import 'interfaces.dart';
import 'request.dart';
import 'response.dart';

typedef Conn = HttpClientAdapter Function();

class Client {
  final List<RoundTripBuilder> roundTripBuilders;
  late Conn conn;

  Client({
    Conn? conn,
    this.roundTripBuilders = const [],
  }) {
    this.conn = conn ?? createAdapter;
  }

  Future<Response> fetch(Request request) {
    RoundTrip rt = _send;
    for (var n = roundTripBuilders.length - 1; n >= 0; n--) {
      rt = roundTripBuilders[n].build(rt);
    }
    return rt(request);
  }

  String _stringifyPath(Uri uri) {
    if (uri.hasQuery) {
      return uri.toString();
    }
    return "${uri.origin}${uri.path}";
  }

  Future<Response> _send(Request request) async {
    final c = conn();

    try {
      final cancelFuture = Context.done?.map((e) {
        return ResponseException.fromException(
          HttpStatus.clientClosedRequest,
          e,
        );
      }).first;

      final fetchFuture = c
          .fetch(
            RequestOptions(
              method: request.method,
              path: _stringifyPath(request.uri),
              headers: request.headers?.map(
                (key, value) =>
                    MapEntry(key, value is List ? value.join(", ") : value),
              ),
              // always true for custom processing
              validateStatus: (i) => true,
            ),
            request.requestBody?.map((list) => Uint8List.fromList(list)),
            cancelFuture,
          )
          .then((resp) => Response(
                request: request,
                statusCode: resp.statusCode,
                headers: resp.headers,
                responseBody: resp.stream.map((list) => list.toList()),
              ));

      if (cancelFuture != null) {
        final ret = await Future.any<dynamic>([
          fetchFuture,
          cancelFuture,
        ]);

        if (!(ret is Response)) {
          throw ret;
        }

        return ret;
      } else {
        return await fetchFuture;
      }
    } catch (e) {
      rethrow;
    } finally {
      c.close();
    }
  }
}
