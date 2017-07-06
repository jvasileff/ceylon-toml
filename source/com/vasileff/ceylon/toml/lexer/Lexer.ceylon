shared class Lexer({Character*} characters) {
    shared variable LexerMode mode = LexerMode.key;
    value t = Tokenizer(characters);
    variable value eofEmitted = false;

    shared T inMode<T>(LexerMode mode, T() do) {
        value save = this.mode;
        try {
            this.mode = mode;
            return do();
        }
        finally {
            this.mode = save;
        }
    }

    shared Token | Finished next() {
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
        case ('.') { return t.newToken(period); }
        case (':') { return t.newToken(colon); }
        case ('+') { return t.newToken(plus); }
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
                    // multi-line
                    value unescaped = acceptStringContent(false, true);
                    return t.newToken(multilineBasicString, unescaped);
                }
                // empty
                return t.newToken(basicString, "");
            }
            // single-line
            value unescaped = acceptStringContent(false, false);
            return t.newToken(basicString, unescaped);
        }
        case ('\'') {
            if (t.accept('\'')) {
                // empty string or start of multiline string
                if (t.accept('\'')) {
                    //  multi-line
                    value unescaped = acceptStringContent(true, true);
                    return t.newToken(multilineLiteralString, unescaped);
                }
                // empty
                return t.newToken(literalString, "");
            }
            // single-line
            value unescaped = acceptStringContent(true, false);
            return t.newToken(literalString, unescaped);
        }
        else if (c == '\r' || c == '\n') {
            t.acceptRun("\r\n");
            return t.newToken(newline);
        }
        else if (c == '\t' || c == ' ') {
            t.acceptRun("\t ");
            t.ignore();
            return next();
        }
        else if (mode == LexerMode.key) {
            if (isBareKeyCharacter(c)) {
                t.acceptRun(isBareKeyCharacter);
                return t.newToken(bareKey);
            }
            else {
                return t.newToken(error);
            }
        }
        else { // mode == LexerMode.val
            switch (c)
            case ('-') { return t.newToken(minus); }
            case ('_') { return t.newToken(underscore); }
            case ('e') { return t.newToken(exponentCharacter); }
            case ('E') { return t.newToken(exponentCharacter); }
            case ('z') { return t.newToken(zuluCharacter); }
            case ('Z') { return t.newToken(zuluCharacter); }
            case ('T') { return t.newToken(timeCharacter); }
            case ('t' | 'f') {
                t.acceptRun(or(Character.letter, Character.digit));
                return switch (t.text())
                    case ("true") t.newToken(trueKeyword)
                    case ("false") t.newToken(falseKeyword)
                    else t.newToken(error);
            }
            else if (c in '0'..'9') {
                t.acceptRun(isDigit);
                return t.newToken(digits);
            }
            else {
                return t.newToken(error);
            }
        }
    }

    String acceptStringContent(Boolean literal, Boolean multiLine) {
        value sb = StringBuilder();
        value quoteChar = literal then '\'' else '"';
        variable value lastWasSlash = false;
        if (multiLine, exists c = t.peek(), c in "\r\n") {
            // ignore immediate newline
            t.accept('\r');
            t.accept('\n');
        }
        while (exists c = t.peek()) {
            if (!multiLine && c in "\r\n") {
                break;
            }
            else if (lastWasSlash) {
                lastWasSlash = false;
                switch (c)
                case ('b') { t.advance(); sb.appendCharacter('\b'); }
                case ('t') { t.advance(); sb.appendCharacter('\t'); }
                case ('n') { t.advance(); sb.appendCharacter('\n'); }
                case ('f') { t.advance(); sb.appendCharacter('\f'); }
                case ('r') { t.advance(); sb.appendCharacter('\r'); }
                case ('"') { t.advance(); sb.appendCharacter('"'); }
                case ('\\') { t.advance(); sb.appendCharacter('\\'); }
                case ('u' | 'U') {
                    t.advance();
                    value expected = c == 'u' then 4 else 8;
                    value digits = t.read(isHexDigit, expected);
                    if (digits.size != expected) {
                        t.error("``expected`` hex digits expected but only \
                                    found ``digits.size``");
                    }
                    else {
                        assert (is Integer int = Integer.parse(digits, 16));
                        try {
                            sb.appendCharacter(int.character);
                        }
                        catch (OverflowException e) {
                            t.error("invalid codepoint");
                        }
                    }
                }
                else {
                    // don't advance; reprocess character on next iteration
                    t.error("invalid escape character");
                    sb.appendCharacter('\\');
                }
            }
            else if (c == quoteChar) {
                t.advance();
                if (!multiLine) {
                    return sb.string;
                }
                else {
                    // if """ done, else accept " or ""
                    if (t.accept(quoteChar)) {
                        if (t.accept(quoteChar)) {
                            return sb.string;
                        }
                        sb.appendCharacter(quoteChar);
                    }
                    sb.appendCharacter(quoteChar);
                }
            }
            else if (c < #20.character && !c in "\r\n") {
                t.error("control character found");
                t.advance();
                sb.appendCharacter(#FFFD.character);
            }
            else if (!literal && c == '\\') {
                t.advance();
                lastWasSlash = true;
            }
            else {
                t.advance();
                sb.appendCharacter(c);
            }
        }
        if (lastWasSlash) {
            t.error("string ended in '\\'");
        }
        t.error("unterminated string");
        return sb.string;
    }

    Boolean isBareKeyCharacter(Character c)
        =>     c.letter
            || c.digit
            || c in "_-";

    Boolean isCommentCharacter(Character c)
        =>     c in '\{#20}'..'\{#10ffff}'
            || c == '\t';

    Boolean isDigit(Character c)
        =>     c in '0'..'9';

    Boolean isHexDigit(Character c)
        =>     c in '0'..'9'
            || c in 'A'..'F';
}
