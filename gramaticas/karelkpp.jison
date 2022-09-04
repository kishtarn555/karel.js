/* Karel-kpp */

%lex
%%

\s+                        {/* ignore */}
\/\/[^\n]*			           {/* ignore */}
\/\*(?:[^*]|\*(?!\/))*\*\/ {/* ignore */}
"imprimir"                 { return 'PRINT'; }
"programa"                 { return 'PROG'; }
"principal"                { return 'MAIN'; }
"metodo"                   { return 'DEF'; }
"regresar"                 { return 'RET'; }
"terminar"                 { return 'HALT'; }
"giraIzquierda"            { return 'LEFT'; }
"avanza"                   { return 'FORWARD'; }
"cogeZumbador"             { return 'PICKBUZZER'; }
"dejaZumbador"             { return 'LEAVEBUZZER'; }
"mientras"                 { return 'WHILE'; }
"repetir"                  { return 'REPEAT'; }
"anterior"                 { return 'DEC'; }
"siguiente"                { return 'INC'; }
"ant"                      { return 'DEC'; }
"sig"                      { return 'INC'; }
"esZero"                   { return 'IFZ'; }
"frenteLibre"              { return 'IFNFWALL'; }
"frenteBloqueado"          { return 'IFFWALL'; }
"izquierdaLibre"           { return 'IFNLWALL'; }
"izquierdaBloquedo"        { return 'IFLWALL'; }
"derechaLibre"             { return 'IFNRWALL'; }
"derechaBloqueada"         { return 'IFRWALL'; }
"juntoAZumbador"           { return 'IFWBUZZER'; }
"noJuntoAZumbador"   	     { return 'IFNWBUZZER'; }
"mochilaConZumbadores" 	   { return 'IFBBUZZER'; }
"mochilaSinZumbadores"		 { return 'IFNBBUZZER'; }
"orientadoAlNorte"		     { return 'IFN'; }
"orientadoAlSur"	         { return 'IFS'; }
"orientadoAlEste"		       { return 'IFE'; }
"orientadoAlOeste"	       { return 'IFW'; }
"noOrientadoAlNorte"	     { return 'IFNN'; }
"noOrientadoAlSur"	       { return 'IFNS'; }
"noOrientadoAlEste"		     { return 'IFNE'; }
"noOrientadoAlOeste"		   { return 'IFNW'; }
"variable"                 { return 'VAR';}
"var"                      { return 'VAR';}
"sino"                     { return 'ELSE'; }
"si"                       { return 'IF'; }
"!"                        { return 'NOT'; }
"no"                       { return 'NOT'; }
"||"                       { return 'OR'; }
"o"                        { return 'OR'; }
"&&"                       { return 'AND'; }
"&"				                 { return 'AND'; }
"y"				                 { return 'AND'; }
"("                        { return 'LB'; }
")"                        { return 'RB'; }
"{"                        { return 'BEGIN'; }
"}"                        { return 'END'; }
";"                        { return 'SC'; }
[0-9]+                     { return 'NUM'; }
[a-zA-Z][a-zA-Z0-9_]*      { return 'IDEN'; }
<<EOF>>                    { return 'EOF'; }

/lex

%nonassoc XIF
%nonassoc ELSE

%{
function validate(function_list, program, yy) {
	var functions = {};
	var prototypes = {};

	for (var i = 0; i < function_list.length; i++) {
		if (functions[function_list[i][0]]) {
			yy.parser.parseError("Function redefinition: " + function_list[i][0], {
				text: function_list[i][0],
				line: function_list[i][1][0][1]
			});
		}

		functions[function_list[i][0]] = program.length;
		prototypes[function_list[i][0]] = function_list[i][2];
		program = program.concat(function_list[i][1]);
	}

	var current_line = 1;
	for (var i = 0; i < program.length; i++) {
		if (program[i][0] == 'LINE') {
			current_line = program[i][1];
		} else if (program[i][0] == 'CALL') {
			if (!functions[program[i][1]] || !prototypes[program[i][1]]) {
				yy.parser.parseError("Undefined function: " + program[i][1], {
					text: program[i][1],
					line: current_line
				});
			} else if (prototypes[program[i][1]] != program[i][2]) {
				yy.parser.parseError("Function parameter mismatch: " + program[i][1], {
					text: program[i][1],
					line: current_line
				});
			}

			program[i][2] = program[i][1];
			program[i][1] = functions[program[i][1]];
		} else if (program[i][0] == 'PARAM' && program[i][1] != 0) {
			yy.parser.parseError("Unknown variable: " + program[i][1], {
				text: program[i][1],
				line: current_line
			});
		}
	}

	return program;
}
%}

%%

program
  : PROG def_list DEF MAIN LB RB block EOF
    { return validate($def_list, $block.concat([['LINE', yylineno], ['HALT']]), yy); }
  | PROG DEF MAIN LB RB block EOF
    { return validate([], $block.concat([['LINE', yylineno], ['HALT']]), yy); }
;

block
  : BEGIN expr_list END
    { $$ = $expr_list; }
;

def_list
  : def_list def
    { $$ = $def_list.concat(def); }
  | def
    { $$ = $def; }
;

def
  : DEF line identifier LB RB block
    { $$ = [[$identifier, $line.concat($block).concat([['RET']]), 1]]; }
  | DEF line identifier LB VAR identifier RB block
    {
      let res = $line.concat($block).concat([['RET']]);
      for (let i = 0; i < res.length; i++) {
        if (result[i][0]=='PARAM') {
          if (result[i][1] == $6) {
            result[i][1] =0;
          } else {
            yy.parser.parseError("Unknown variable: " + $6, {
							text: $6,
							line: yylineno,
						});
          }
        }
        $$ = [[$identifier, res, 2]];
      }
    }
  ;

expr_list
  : expr_list expr
    {$$ = $expr_list.concat($expr); }
  | expr
    {$$ = $expr; }
;

expr
  : FORWARD LB RB SC
    { $$ = [['LINE', yylineno], ['WORLDWALLS'], ['ORIENTATION'], ['MASK'], ['AND'], ['NOT'], ['EZ', 'WALL'], ['FORWARD']]; }
  | LEFT LB RB SC
    { $$ = [['LINE', yylineno], ['LEFT']]; }
  | PICKBUZZER LB RB SC
    { $$ = [['LINE', yylineno], ['WORLDBUZZERS'], ['EZ', 'WORLDUNDERFLOW'], ['PICKBUZZER']]; }
  | LEAVEBUZZER LB RB SC
    { $$ = [['LINE', yylineno], ['BAGBUZZERS'], ['EZ', 'BAGUNDERFLOW'], ['LEAVEBUZZER']]; }
  | HALT LB RB SC
    { $$ = [['LINE', yylineno], ['HALT']]; }
  | RET SC
    { $$ = [['LINE', yylineno], ['RET']]; }
  | call SC
    { $$ = $call; }
  | debugprint SC
    { $$ = $debugprint; }
  | cond
    { $$ = $cond; }
  | loop
    { $$ = $loop; }
  | repeat
    { $$ = $repeat; }
  | block
    { $$ = $block; }
  | SC
    { $$ = []; }
;

call
  : identifier LB RB 
    { $$ = [['LINE', yylineno], ['LOAD', 0], ['CALL', $identifier, 1], ['LINE', yylineno]]; }
  | identifier LB integer RB
    { $$ = [['LINE', yylineno]].concat($integer).concat([['CALL', $identifier, 2], ['LINE', yylineno]]); }
;

cond
  : IF LB term RB expr %prec XIF
    { $$ = 
      $line
      .concat($term)
      .concat([['JZ', $expr.length]])
      .concat($expr); 
    }
  | IF LB term RB expr ELSE expr
    { $$ = 
      $line
      .concat($term)
      .concat([['JZ', 1+$expr.length]])
      .concat($5)
      .concat([['JMP',$7.length]])
      .concat($7); 
    }
;

loop
  : WHILE LB term RB expr 
    { $$ = 
      $line
      .concat($term) 
      .concat([['JZ', 1+$expr.length]])
      .concat($expr)
      .concat([['JMP', -1 -($term.length+1+$expr.length)]])
      ;
    }
;

repeat
  : REPEAT line LB integer RB expr
    {
      $$ = $line
      .concat($integer)
      .concat(['DUP'])
      .concat(['JZ', 1+$expr.length])
      .concat($expr)
      .concat('JMP', -1 - ($expr.length+1));      
    }
;

debugprint
  : PRINT line LB integer RB
  {
    $$ = 
    $line
    .concat($integer)
    .concat(['PRINT']);
  }
;

identifier
  : IDEN
    { $$ = yytext; }
;

term
  : term OR and_term
    { $$ = $term.concat($and_term).concat([['OR']]); }
  | and_term
    { $$ = $and_term; }
;

and_term
  : and_term AND not_term
    { $$ = $and_term.concat($not_term).concat([['AND']]); }
  | not_term
    { $$ = $not_term; }
;

not_term
  : NOT clause
    { $$ = $clause.concat([['NOT']]); }
  | clause
    { $$ = $clause; }
  ;

clause
  : IFZ '(' integer ')'
    { $$ = $integer.concat([['NOT']]); }
  | bool_fun
    { $$ = $bool_fun; }
  | bool_fun '(' ')'
    { $$ = $bool_fun; }
  | '(' term ')'
    { $$ = $term; }
  ;

bool_fun
  : IFNFWALL
    { $$ = [['WORLDWALLS'], ['ORIENTATION'], ['MASK'], ['AND'], ['NOT']]; }
  | IFFWALL
    { $$ = [['WORLDWALLS'], ['ORIENTATION'], ['MASK'], ['AND']]; }
  | IFNLWALL
    { $$ = [['WORLDWALLS'], ['ORIENTATION'], ['ROTL'], ['MASK'], ['AND'], ['NOT']]; }
  | IFLWALL
    { $$ = [['WORLDWALLS'], ['ORIENTATION'], ['ROTL'], ['MASK'], ['AND']]; }
  | IFNRWALL
    { $$ = [['WORLDWALLS'], ['ORIENTATION'], ['ROTR'], ['MASK'], ['AND'], ['NOT']]; }
  | IFRWALL
    { $$ = [['WORLDWALLS'], ['ORIENTATION'], ['ROTR'], ['MASK'], ['AND']]; }
  | IFWBUZZER
    { $$ = [['WORLDBUZZERS'], ['LOAD', 0], ['EQ'], ['NOT']]; }
  | IFNWBUZZER
    { $$ = [['WORLDBUZZERS'], ['NOT']]; }
  | IFBBUZZER
    { $$ = [['BAGBUZZERS'], ['LOAD', 0], ['EQ'], ['NOT']]; }
  | IFNBBUZZER
    { $$ = [['BAGBUZZERS'], ['NOT']]; }
  | IFW
    { $$ = [['ORIENTATION'], ['LOAD', 0], ['EQ']]; }
  | IFN
    { $$ = [['ORIENTATION'], ['LOAD', 1], ['EQ']]; }
  | IFE
    { $$ = [['ORIENTATION'], ['LOAD', 2], ['EQ']]; }
  | IFS
    { $$ = [['ORIENTATION'], ['LOAD', 3], ['EQ']]; }
  | IFNW
    { $$ = [['ORIENTATION'], ['LOAD', 0], ['EQ'], ['NOT']]; }
  | IFNN
    { $$ = [['ORIENTATION'], ['LOAD', 1], ['EQ'], ['NOT']]; }
  | IFNE
    { $$ = [['ORIENTATION'], ['LOAD', 2], ['EQ'], ['NOT']]; }
  | IFNS
    { $$ = [['ORIENTATION'], ['LOAD', 3], ['EQ'], ['NOT']]; }
  ;

integer
  : var
    { $$ = [['PARAM', $var]]; }
  | NUM
    { $$ = [['LOAD', parseInt(yytext)]]; }
  | INC '(' integer ')'
    { $$ = $integer.concat([['INC']]); }
  | DEC	 '(' integer ')'
     { $$ = $integer.concat([['DEC']]); }
;

line
  :
    { $$ = [['LINE', yylineno]]; }
  ;