shared class Tokenizer({Character*} input,
        Integer offsetPosition = 0,
        Integer offsetLine = 1,
        Integer offsetColumn = 1) {

    value builder = StringBuilder();
    value iterator = PeekingIterator(input.iterator());

    variable Integer position = offsetPosition;
    variable Integer line = offsetLine;
    variable Integer column = offsetColumn;

    shared variable Integer startPosition = position;
    shared variable Integer startLine = line;
    shared variable Integer startColumn = column;

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
