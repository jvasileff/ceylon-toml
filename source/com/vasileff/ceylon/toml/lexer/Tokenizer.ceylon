shared class Tokenizer({Character*} input) {
    value builder = StringBuilder();
    value iterator = PeekingIterator(input.iterator());

    variable Integer position = 0;
    variable Integer line = 1;
    variable Integer column = 1;

    shared variable Integer startPosition = 0;
    shared variable Integer startLine = 1;
    shared variable Integer startColumn = 1;

    shared Character? advance() {
        if (!is Finished c = iterator.next()) {
            position += 1;
            if (c == '\n') {
                line += 1;
                column = 1;
            }
            else if (c != '\r') {
                column += 1;
            }
            builder.appendCharacter(c);
            return c;
        }
        return null;
    }

    shared void ignore() {
        builder.clear();
        startPosition = position;
        startLine = line;
        startColumn = column;
    }

    shared Character? peek()
        =>  if (!is Finished p = iterator.peek()) then p else null;

    shared Boolean accept(String | Character | Boolean(Character) valid) {
        switch (valid)
        case (is String) {
            if (exists p = peek(), p in valid) {
                advance();
                return true;
            }
            return false;
        }
        case (is Character) {
            if (exists p = peek(), p == valid) {
                advance();
                return true;
            }
            return false;

        }
        else {
            if (exists p = peek(), valid(p)) {
                advance();
                return true;
            }
            return false;
        }
    }

    shared Integer acceptRun(String | Boolean(Character) valid) {
        variable value count = 0;
        while (accept(valid)) {
            count++;
        }
        return count;
    }

    shared String text()
        =>  builder.string;

    shared Token newToken(TokenType type, String text = this.text()) {
        value result = Token(type, text, startPosition, startLine, startColumn);
        ignore();
        return result;
    }
}
