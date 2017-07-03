shared {Token*} tomlTokenStream({Character*} characters) => object
        satisfies {Token*} {

    iterator() => object satisfies Iterator<Token> {
        value t = Tokenizer(characters);
        variable value eofEmitted = false;

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
                return t.newToken(whitespace);
            }
            else if (isWordCharacter(c)) {
                t.acceptRun(isWordCharacter);
                return t.newToken(word);
            }

            return t.newToken(error);
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
                            assert (is Integer int = Integer.parse(String(digits), 16));
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
    };
};
