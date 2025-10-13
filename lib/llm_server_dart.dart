import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'llm_server_dart_bindings_generated.dart';

Pointer<Pointer<Char>> stringListToPointerPointer(List<String> stringList) {
  final pointerList = stringList.map((str) => str.toNativeUtf8()).toList();
  final pointerPointer = calloc<Pointer<Char>>(pointerList.length);

  for (var i = 0; i < pointerList.length; i++) {
    pointerPointer[i] = pointerList[i].cast<Char>();
  }

  return pointerPointer;
}

_start(List<String> args) =>
    _bindings.start(args.length, stringListToPointerPointer(args));
start(String modelPath, int port) {
  List<String> args = List.of(["llama-server"]);
  args.addAll([
    "-m",
    modelPath,
    "--port",
    port.toString(),
    '--chat-template',
    'chatml'
  ]);
  _start(args);
}

_start_embedding(List<String> args) =>
    _bindings.start_embedding(args.length, stringListToPointerPointer(args));
start_embedding(String modelPath, int port) {
  List<String> args = List.of(["llama-server"]);
  args.addAll(["-m", modelPath, "--port", port.toString(), '--embedding']);
  _start_embedding(args);
}

quit() => _bindings.quit();
quit_embedding() => _bindings.quit_embedding();

const String _libName = 'llm_server_dart';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final LlmServerDartBindings _bindings = LlmServerDartBindings(_dylib);
