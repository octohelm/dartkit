import 'dart:async';
import 'dart:convert';

import 'package:context/context.dart';
import 'package:filesize/filesize.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:roundtripper/roundtripbuilders.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_test_handler/shelf_test_handler.dart';
import 'package:test/test.dart';

var logger = Logger(StdLogSink("roundtripper"));

void main() async {
  var c = Client(roundTripBuilders: [
    ThrowsNot2xxError(),
    RequestBodyConvert(),
    RequestLog(),
  ]);

  var ctx = Logger.withLogger(logger);

  test("get", () async {
    var server = await ShelfTestServer.create();

    server.handler.expect("GET", "/anything", (request) {
      return shelf.Response.ok(jsonEncode({
        "url": request.url.toString(),
        "headers": request.headers,
      }));
    });

    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "${server.url}/anything",
        queryParameters: {
          "int": 1,
          "slice": [1, 2],
        },
        headers: {
          "x-int": 1,
          "x-slice": [1, 2],
        },
      ));

      expect(resp.statusCode, 200);

      var json = await resp.json();

      expect(json["url"], "anything?int=1&slice=1&slice=2");
      expect(json["headers"]["x-int"], "1");
      expect(json["headers"]["x-slice"], "1, 2"); // ?
    });
  });

  test("post", () async {
    var server = await ShelfTestServer.create();

    server.handler.expect("POST", "/anything", (request) async {
      return shelf.Response.ok(jsonEncode({
        "url": request.url.toString(),
        "headers": request.headers,
        "data": await request.readAsString(),
      }));
    });

    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "${server.url}/anything",
        method: "POST",
        body: {
          "a": 1,
          "b": "s",
        },
      ));

      expect(resp.statusCode, 200);

      var json = await resp.json();

      expect(jsonDecode(json["data"]), {
        "a": 1,
        "b": "s",
      });

      expect(
          json["headers"]["content-type"], "application/json; charset=utf-8");
    });
  });

  test("download & progress", () async {
    var server = await ShelfTestServer.create();

    server.handler.expect("GET", "/bytes/102400", (request) async {
      return shelf.Response.ok(List<int>.generate(102400, (_) => 1));
    });

    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "${server.url}/bytes/102400",
        method: "GET",
      ));

      expect(resp.statusCode, 200);

      var complete = 0;
      var len = resp.contentLength;

      var f = StreamController(sync: true);

      f.stream.listen((event) {});

      await f.addStream(
        resp.responseBody.transform(
          StreamTransformer<List<int>, List<int>>.fromHandlers(
            handleData: (data, sink) {
              sink.add(data);
              complete += data.length;
              logger.info("receive ${filesize(complete)} / ${filesize(len)}");
            },
          ),
        ),
      );

      f.close();
    });
  });

  test("throws not 2xx error", () async {
    var server = await ShelfTestServer.create();

    server.handler.expect("GET", "/status/401", (request) async {
      return shelf.Response.unauthorized("");
    });

    await ctx.run(() async {
      await expectLater(
        c.fetch(Request.uri("${server.url}/status/401")),
        throwsA(
          (e) => e is ResponseException && e.statusCode == 401,
        ),
      );
    });
  });

  test("cancel", () async {
    var server = await ShelfTestServer.create();

    server.handler.expect("GET", "/status/200", (request) async {
      await Future.delayed(Duration(milliseconds: 10));
      return shelf.Response.ok("");
    });

    await ctx.run(() async {
      final cc = Context.withTimeout(const Duration(milliseconds: 3));

      await expectLater(
        cc.run(() => c.fetch(Request.uri("${server.url}/status/200"))),
        throwsA((e) {
          return e is ResponseException && e.statusCode == 499;
        }),
      );
    });
  });
}
