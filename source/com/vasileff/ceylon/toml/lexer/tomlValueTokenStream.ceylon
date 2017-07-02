"Generates tokens for only numbers and dates"
shared {Token*} tomlValueTokenStream(
        {Character*} characters,
        Integer offsetPosition = 0,
        Integer offsetLine = 1,
        Integer offsetColumn = 1) => object
        satisfies {Token*} {

    iterator() => object satisfies Iterator<Token> {
        value t = Tokenizer(characters, offsetPosition, offsetLine, offsetColumn);

        shared actual Token | Finished next() {
            value c = t.advance();
            if (!exists c) {
                return finished;
            }

            switch (c)
            case ('+') { return t.newToken(plus); }
            case ('-') { return t.newToken(minus); }
            case ('.') { return t.newToken(period); }
            case ('_') { return t.newToken(underscore); }
            case ('e') { return t.newToken(exponentCharacter); }
            case ('E') { return t.newToken(exponentCharacter); }
            case ('z') { return t.newToken(zuluCharacter); }
            case ('Z') { return t.newToken(zuluCharacter); }
            else if (c in '0'..'9') {
                t.acceptRun(isDigit);
                return t.newToken(digits);
            }
            else {
                return t.newToken(error);
            }
        }
    };
};
