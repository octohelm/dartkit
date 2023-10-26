import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:roundtripper/roundtripbuilders.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_multipart/form_data.dart' show ReadFormData;
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

  test("form data", () async {
    var server = await ShelfTestServer.create();
    server.handler.expect("POST", "/anything", (request) async {
      final formData = <String, String>{
        await for (final formData in request.multipartFormData)
          formData.name: await formData.part.readString(),
      };

      return shelf.Response.ok(jsonEncode({
        "url": request.url.toString(),
        "headers": request.headers,
        "form": formData,
      }));
    });

    var fd = FormDataExtra.fromMap({
      "field": "f",
      "file": MultipartFile.fromString("123"),
    });

    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "${server.url}/anything",
        method: "POST",
        body: fd,
      ));

      expect(resp.statusCode, 200);

      var json = await resp.json();

      expect(json["form"], {"field": "f", "file": "123"});
    });
  });
}

class FormDataExtra extends FormData implements RequestBodyEncoder {
  FormDataExtra() : super();

  factory FormDataExtra.fromMap(
    Map<String, dynamic> m, [
    ListFormat collectionFormat = ListFormat.multi,
  ]) {
    var fd = FormData.fromMap(m, collectionFormat);

    return (FormDataExtra()
      ..fields.addAll(fd.fields)
      ..files.addAll(fd.files));
  }

  @override
  MediaType get contentType => MediaType(
        'multipart',
        'form-data',
        {
          "boundary": boundary,
        },
      );
}
