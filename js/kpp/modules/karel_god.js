

function karel_god(lenguage) {
    let lang_dict = {
        java: {
            superMove: 'superMove',
            putBeeper: 'superPutBeeper',
        },
        pascal: {
            superMove: 'super-avanza',
            putBeeper: 'super-deja-zumbador',
        },
        kpp: {
            superMove: 'superAvanza',
            putBeeper: 'superDejaZumbador',
        },
    }

    function declareFunction(name, instructions) {
        return [[name, instructions.concat([['RET']]), 1]];
    }
    console.log(yylineno);
    
    let response =    declareFunction(
            lang_dict[lenguage]['superMove'],
            [
                ['FORWARD']
            ]
        ).concat(
            declareFunction(
                lang_dict[language]['putBeeper'],
                [
                    ['LEAVEBUZZER']
                ]
            )
        )
    return response;
}