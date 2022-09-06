CodeMirror.defineMode('karelkpp', function () {
    function words(str) {
      var obj = {},
        words = str.split(' ');
      for (var i = 0; i < words.length; ++i) obj[words[i]] = true;
      return obj;
    }
    var keywords = words(
      '!codigo si sino repetir while void metodo var variable',
    );
    var indent = words(
      '{',
    );
    var dedent = words('}');
    var builtin = words(
        'avanza giraIzquierda termina dejaZumbador cogeZumbador imprimir',
    );
    var operator = words('esZero ant anterior sig siguiente');
    var atoms = words(
      'frenteLibre frenteBloqueado izquierdaLibre izquierdaBloqueada derechaLibre derechaBloqueada juntoAZumbador noJuntoAZumbador mochicaConZumbadores mochilaSinZumbadores orientadoAlNorte orientadoAlSur orientadoAlEste orientadoAlOeaste noOrientadoAlNorte orientadoAlSur noOrientadoAlSur noOrientadoAlNorte',
    );
  
    function tokenBase(stream, state) {
      var ch = stream.next();
      if (ch == '/' && stream.eat('/')) {
        state.tokenize = tokenSimpleComment;
        return tokenSimpleComment(stream, state);
      }
      if (ch == '/' && stream.eat('*')) {
        state.tokenize = tokenComment;
        return tokenComment(stream, state);
      }
      if (/[\(\);]/.test(ch)) {
        return null;
      }
      if (stream.match(/(codigo)|(importar)/, true)) {
        return "keyword";
      }
      if (/[\!\&\|]/.test(ch)) {
        return 'operator';
      }
      if (/\d/.test(ch)) {
        stream.eatWhile(/[\w\.]/);
        return 'number';
      }
      stream.eatWhile(/[\w_]/);
      var cur = stream.current();
      var style = 'variable';
      if (keywords.propertyIsEnumerable(cur)) style = 'keyword';
      else if (builtin.propertyIsEnumerable(cur)) style = 'builtin';
      else if (operator.propertyIsEnumerable(cur)) style = 'operator';
      else if (atoms.propertyIsEnumerable(cur)) style = 'atom';
      else if (indent.propertyIsEnumerable(cur)) style = 'indent';
      else if (dedent.propertyIsEnumerable(cur)) style = 'dedent';
      else if (
        state.lastTok == 'metodo'
      )
        style = 'def';
      state.lastTok = cur;
      return style;
    }
  
    function tokenSimpleComment(stream, state) {
      stream.skipToEnd();
      state.tokenize=null;
      return 'comment';
    }
  
    function tokenComment(stream, state) {
      var maybeEnd = false,
        ch;
      while ((ch = stream.next())) {
        if (ch == '/' && maybeEnd) {
          state.tokenize = null;
          break;
        }
        maybeEnd = ch == '*';
      }
      return 'comment';
    }
  
    // Interface
  
    return {
      startState: function () {
        return { tokenize: null, lastTok: null };
      },
  
      token: function (stream, state) {
        if (stream.eatSpace()) return null;
        return (state.tokenize || tokenBase)(stream, state);
      },
    };
  });
  
  CodeMirror.defineMIME('text/x-karelkpp', 'karelkpp');
  