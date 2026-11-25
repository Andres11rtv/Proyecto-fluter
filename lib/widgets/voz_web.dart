import 'dart:js_interop';

@JS('speechSynthesis')
external _Sintesis? get _motor;

@JS('SpeechSynthesisUtterance')
extension type _Frase._(JSObject _) implements JSObject {
  external factory _Frase(String texto);
  external set lang(String idioma);
}

extension type _Sintesis(JSObject _) implements JSObject {
  external void speak(_Frase frase);
  external void cancel();
}

bool get vozDisponible => _motor != null;

void leer(String texto) {
  final frase = _Frase(texto)..lang = 'es';
  _motor?.cancel();
  _motor?.speak(frase);
}

void silenciar() => _motor?.cancel();
