shared {Token*} tomlTokenStream({Character*} characters) => object
        satisfies {Token*} {

    iterator() => object satisfies Iterator<Token> {
        value t = Tokenizer(characters);
        variable value eofEmitted = false;

        function acceptEscape() {
            if (!t.accept('\\')) {
                return false;
            }
            // let parser complain about bad escapes
            if (t.accept("uU")) {
                t.acceptRun(isHexDigit);
            }
            else {
                t.accept(not("\r\n".contains));
            }
            return true;
        }

        shared actual Token | Finished next() {
            if (eofEmitted) {
                return finished;
            }
            value c = t.advance();
            if (!exists c) {
                eofEmitted = true;
                return t.newToken(eof, "");
            }

            switch (c)
            case ('{') { return t.newToken(openBrace); }
            case ('}') { return t.newToken(closeBrace); }
            case (',') { return t.newToken(comma); }
            case ('=') { return t.newToken(equal); }
            case ('[') {
                return t.newToken {
                    if (t.accept('['))
                    then doubleOpenBracket
                    else openBracket;
                };
            }
            case (']') {
                return t.newToken {
                    if (t.accept(']'))
                    then doubleCloseBracket
                    else closeBracket;
                };
            }
            case ('#') {
                t.acceptRun(isCommentCharacter);
                return t.newToken(comment);
            }
            case ('"') {
                if (t.accept('"')) {
                    // empty string or start of multiline string
                    if (t.accept('"')) {
                        while (true) {
                            t.acceptRun(not('"'.equals));
                            if (t.accept('"') && t.accept('"') && t.accept('"')
                                    || !t.peek() exists) {
                                return t.newToken(multilineBasicString);
                            }
                        }
                    }
                    return t.newToken(basicString);
                }
                // let parser complain about non-terminated strings
                while (t.acceptRun(isBasicUnescapedCharacter) > 0
                        || acceptEscape()) {}
                t.accept('"');
                return t.newToken(basicString);
            }
            case ('\'') {
                if (t.accept('\'')) {
                    // empty string or start of multiline string
                    if (t.accept('\'')) {
                        while (true) {
                            t.acceptRun(not('\''.equals));
                            if (t.accept('\'') && t.accept('\'') && t.accept('\'')
                                    || !t.peek() exists) {
                                return t.newToken(multilineLiteralString);
                            }
                        }
                    }
                    return t.newToken(literalString);
                }
                // let parser complain about non-terminated strings
                t.acceptRun(isLiteralCharacter);
                t.accept('\'');
                return t.newToken(literalString);
            }
            else if (c == '\r' || c == '\n') {
                t.acceptRun("\r\n");
                return t.newToken(newline);
            }
            else if (c == '\t' || c == ' ') {
                t.acceptRun("\t ");
                return t.newToken(whitespace);
            }
            else if (isWordCharacter(c)) {
                t.acceptRun(isWordCharacter);
                return t.newToken(word);
            }

            return t.newToken(error);
        }
    };
};
