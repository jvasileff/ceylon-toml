import com.vasileff.ceylon.toml {
    TomlTable, TomlArray, TomlValue
}
import ceylon.collection {
    IdentitySet
}
import ceylon.time.timezone {
    TimeZone, ZoneDateTime, timeZone, zoneDateTime
}
import ceylon.time {
    Time, Date, DateTime,
    time, date, dateTime
}
import com.vasileff.ceylon.toml.lexer {
    ...
}

shared [TomlTable, ParseException*] parse({Character*} input) =>
        object satisfies Producer<[TomlTable, ParseException*]> {
    value lexer = Lexer(input);
    value result = TomlTable();
    variable [ParseException*] errors = [];
    variable Token | Finished | Null nextToken = null;
    variable value currentTable = result;
    value createdButNotDefined = IdentitySet<TomlTable>();

    String formatToken(Token token)
        =>  if (token.type == newline) then "newline"
            else if (token.type == newline) then "eof"
            else if (token.text.shorterThan(10)) then "'``token.text``'"
            else "'``token.text[...10]``...'";

    ParseException error(Token? token, String? description = null) {
        // TODO this is no good for errors like:
        // error: unexpected '['; table [first-Table] has already been defined at 75:1
        value sb = StringBuilder();
        sb.append("unexpected ");
        if (!exists token) {
            sb.append("end-of-file");
        }
        else {
            sb.append(formatToken(token));
        }
        if (exists description) {
            sb.append("; ");
            sb.append(description);
        }
        if (exists token) {
            sb.append(" at ``token.line``:``token.column``");
        }
        value exception = ParseException(token, sb.string);
        errors = errors.withTrailing(exception);
        return exception;
    }

    Token? peek() {
        value token = nextToken else lexer.next();
        nextToken = token;
        return if (!is Finished token) then token else null;
    }

    Token? peekIf(Boolean(TokenType) | TokenType type) {
        value token = peek();
        if (!exists token) {
            return null;
        }
        if (is TokenType type) {
            if (type == token.type) {
                return token;
            }
        }
        else if (type(token.type)) {
            return token;
        }
        return null;
    }

    Token? peekIfAny(Boolean(TokenType) | TokenType+ type) {
        value token = peek();
        if (!exists token) {
            return null;
        }
        for (t in type) {
            if (is TokenType t) {
                if (t == token.type) {
                    return token;
                }
            }
            else if (t(token.type)) {
                return token;
            }
        }
        return null;
    }

    Token? advance() {
        value token = peek();
        nextToken = null;
        if (exists token) {
            errors = concatenate(errors, token.errors);
        }
        return token;
    }

    Boolean check(Boolean(TokenType) | TokenType type)
        =>  peekIf(type) exists;

    Boolean checkAny(Boolean(TokenType) | TokenType+ type)
        =>  peekIfAny(*type) exists;

    Token? advanceIf(Boolean(TokenType) | TokenType type) {
        value token = peekIf(type);
        if (token exists) {
            advance();
        }
        return token;
    }

    Token? advanceIfAny(Boolean(TokenType) | TokenType+ type) {
        value token = peekIfAny(*type);
        if (token exists) {
            advance();
        }
        return token;
    }

    Boolean accept(Boolean(TokenType) | TokenType type)
        =>  advanceIf(type) exists;

    Boolean acceptAny(Boolean(TokenType) | TokenType+ type)
        =>  advanceIfAny(*type) exists;

    Integer acceptRun(Boolean(TokenType) | TokenType type) {
        variable Integer count = 0;
        while (accept(type)) {
            count++;
        }
        return count;
    }

    Integer acceptRunAny(Boolean(TokenType) | TokenType+ type) {
        variable Integer count = 0;
        while (acceptAny(*type)) {
            count++;
        }
        return count;
    }

    Token consume(Boolean(TokenType) | TokenType type, String errorDescription) {
        if (exists token = advanceIf(type)) {
            return token;
        }
        throw error(peek(), errorDescription);
    }

    Boolean endOfFile
        =>  !peek() exists;

    shared actual [TomlTable, ParseException*] get() {
        while (!endOfFile) {
            try {
                lexer.inMode(LexerMode.key, parseLine);
            }
            catch (ParseException e) {
                acceptRun(not('\n'.equals));
            }
        }
        return [result, *errors];
    }

     """
            BareKey
     """
    String parseBareKey() {
        value token = consume(bareKey, "expected a bare key");
        validateBareKey(token, token.text);
        return token.text;
    }

     """
            BasicString
     """
    String parseBasicString() {
        value token = consume(basicString, "expected a basic string");
        assert (exists s = token.processedText);
        return String(s);
    }

     """
            MultilineBasicString
     """
    String parseMultilineBasicString() {
        value token = consume(multilineBasicString, "expected a multi-line basic string");
        assert (exists s = token.processedText);
        return String(s);
    }

     """
            LiteralString
     """
    String parseLiteralString() {
        value token = consume(literalString, "expected a literal string");
        assert (exists s = token.processedText);
        return String(s);
    }

     """
            MultilineLiteralString
     """
    String parseMultilineLiteralString() {
        value token = consume(
            multilineLiteralString,
            "expected a multi-line literal string"
        );
        assert (exists s = token.processedText);
        return String(s);
    }

     """
            key : word | basicString | literalString
     """
    String parseKey() {
        switch(peek()?.type)
        case (bareKey) { return parseBareKey(); }
        case (basicString) { return parseBasicString(); }
        case (literalString) { return parseLiteralString(); }
        else {
            throw error(peek(), "expected a key");
        }
    }

    TomlArray parseTomlArray() {
        // TODO disallow heterogenous arrays
        //      (have parseValue return a type descriptor?)
        value array = TomlArray();
        consume(openBracket, "expected '[' to start the array");
        while (!check(closeBracket)) {
            acceptRunAny(comment, newline);
            array.add(parseValue());
            acceptRunAny(comment, newline);
            if (!accept(comma)) {
                break;
            }
            acceptRunAny(comment, newline);
        }
        accept(comma); // trailing comma ok
        acceptRunAny(comment, newline);
        consume(closeBracket, "expected ']' to end the array");
        return array;
    }

    TomlTable parseInlineTable() {
        value table = TomlTable();
        consume(openBrace, "expected '{' to start the inline table");
        lexer.inMode {
            LexerMode.key;
            void () {
                while (!check(closeBrace)) {
                    table.putAll { parseKeyValuePair() };
                    if (!accept(comma)) {
                        break;
                    }
                }
            };
        };
        accept(comma); // trailing comma ok
        consume(closeBrace, "expected '}' to end the inline table");
        return table;
    }

     """
            Integer: ('+' | '-')? DIGIT+ ('_' DIGIT+)*
     """
    String parseInteger(
            Token? signToken = null,
            Token? leadingDigitsToken = null) {

        value positive
            =   if (exists signToken)
                    then signToken.type == plus
                else if (!leadingDigitsToken exists)
                    then accept(plus) || !accept(minus)
                else true;

        value sb = StringBuilder();

        if (!positive) {
            sb.appendCharacter('-');
        }

        sb.append {
            (leadingDigitsToken
                else consume(digits, "expected digits")).text;
        };

        while (accept(underscore)) {
            value t = consume(digits, "expected digits after '_'");
            sb.append(t.text);
        }

        return sb.string;
    }

     """
            Float: Integer '.' Integer? (('E' | 'e') Integer)?
     """
    Integer | Float parseNumber(
            Token? signToken = null,
            Token? leadingDigitsToken = null) {

        value firstToken
            =   signToken else leadingDigitsToken else peek();

        value wholePart
            =   parseInteger(signToken, leadingDigitsToken);

        value fractionalPart
            =   if (accept(period))
                then parseInteger()
                else null;

        value exponent
            =   if (accept(exponentCharacter))
                then "e" + parseInteger()
                else null;

        if (!fractionalPart exists && !exponent exists) {
            switch (i = Integer.parse(wholePart))
            case (is Integer) {
                return i;
            }
            else {
                throw error(firstToken, i.message);
            }
        }
        else {
            value floatString
                =   wholePart
                    + "." + (fractionalPart else "0")
                    + (exponent else "");
            switch (f = Float.parse(floatString))
            case (is Float) {
                return f;
            }
            else {
                throw error(firstToken, f.message);
            }
        }
    }

    Integer consumeDigits(
            Token? token, Integer count, String errorCount,
            Range<Integer>? range = null, String? errorRange = null) {
        value t = token else consume(digits, errorCount);
        if (t.text.size != count) {
            throw error(t, errorCount);
        }
        assert (is Integer result = Integer.parse(t.text));
        if (exists range, !result in range) {
            throw error(t, errorRange);
        }
        return result;
    }

    Time parseTime(Token? leadingDigitsToken = null) {
        value hours = consumeDigits {
            leadingDigitsToken;
            count = 2;
            errorCount = "expected two digits for hours";
            range = 0..23;
            errorRange = "hours must be between 00 and 23";
        };
        consume(colon, "expected ':'");
        value minutes = consumeDigits {
            null;
            count = 2;
            errorCount = "expected two digits for minutes";
            range = 0..59;
            errorRange = "hours must be between 00 and 59";
        };
        consume(colon, "expected ':'");
        value seconds = consumeDigits {
            null;
            count = 2;
            errorCount = "expected two digits for seconds";
            range = 0..59;
            errorRange = "seconds must be between 00 and 59";
        };
        Integer millis;
        if (accept(period)) {
            value millisToken = consume(digits, "expected milliseconds");
            assert (is Integer ms = Integer.parse(
                        millisToken.text[0:3].padTrailing(3, '0')));
            millis = ms;
        }
        else {
            millis = 0;
        }
        return time(hours, minutes, seconds, millis);
    }

    TimeZone parseTimeZone() {
        if (accept(zuluCharacter)) {
            return timeZone.offset(0);
        }

        value sign
            =   switch (consume([plus, minus].contains,
                        "expected 'Z', '+' or '-' for timezone offset").type)
                case (plus) 1
                else -1;

        value hours = consumeDigits {
            null;
            count = 2;
            errorCount = "expected two digits for hours";
            range = 0..23;
            errorRange = "hours must be between 00 and 23";
        };

        consume(colon, "expected ':'");

        value minutes = consumeDigits {
            null;
            count = 2;
            errorCount = "expected two digits for minutes";
            range = 0..59;
            errorRange = "hours must be between 00 and 59";
        };

        return timeZone.offset(sign * hours, sign * minutes, 0);
    }

    Date | DateTime | ZoneDateTime parseDateTime(Token? leadingDigitsToken = null) {
        value year = consumeDigits {
            leadingDigitsToken;
            count = 4;
            "expected four digits for year";
        };
        consume(minus, "expected '-'");
        value month = consumeDigits {
            null;
            count = 2;
            "expected 2 digits for month";
            range = 1..31;
            errorRange = "month must be between 01 and 12";
        };
        consume(minus, "expected '-'");
        value day = consumeDigits {
            null;
            count = 2;
            "expected 2 digits for day";
            range = 1..31;
            errorRange = "day must be between 01 and 31";
        };

        value timePart = accept(timeCharacter) then parseTime();

        if (!exists timePart) {
            return date(year, month, day);
        }

        value zone = checkAny(zuluCharacter, minus, plus) then parseTimeZone();

        if (!exists zone) {
            return dateTime(year, month, day, timePart.hours, timePart.minutes,
                    timePart.seconds, timePart.milliseconds);
        }

        return zoneDateTime(zone, year, month, day, timePart.hours, timePart.minutes,
                    timePart.seconds, timePart.milliseconds);
    }

    Integer | Float | Time | Date | DateTime | ZoneDateTime parseNumberOrDate() {
        if (checkAny(plus, minus)) {
            return parseNumber();
        }

        value leadingDigits = consume(digits, "expected digits");

        switch (peek()?.type)
        case (underscore | exponentCharacter) {
            return parseNumber(null, leadingDigits);
        }
        case (colon) {
            return parseTime(leadingDigits);
        }
        case (minus) {
            return parseDateTime(leadingDigits);
        }
        else {
            // it's an integer
            return parseNumber(null, leadingDigits);
        }
    }

     """
            value : basicString | literalString | ...
     """
    TomlValue parseValue() {
        value token = peek();
        switch (type = token?.type)
        case (basicString) { return parseBasicString(); }
        case (multilineBasicString) { return parseMultilineBasicString(); }
        case (literalString) { return parseLiteralString(); }
        case (multilineLiteralString) { return parseMultilineLiteralString(); }
        case (openBracket) { return parseTomlArray(); }
        case (openBrace) { return parseInlineTable(); }
        case (trueKeyword) { advance(); return true; }
        case (falseKeyword) { advance(); return false; }
        case (plus | minus | digits) { return parseNumberOrDate(); }
        else {
            throw error(peek(), "expected a toml value");
        }
    }

     """
            keyValuePair : key '=' value Comment? (Newline | EOF)
     """
    String->TomlValue parseKeyValuePair() {
        value key = lexer.inMode(LexerMode.key, parseKey);
        consume(equal, "expected '='");
        return key -> lexer.inMode(LexerMode.val, parseValue);
    }

    [String*] parseKeyPath() {
        switch (p = peek())
        case (null) {
            throw error(null, "expected a key");
        }
        else if (p.type == period) {
            throw error(p, "table name may not start with '.'");
        }

        variable {String*} result = [];
        variable value lastWasDot = true;
        variable value lastPart = null of Token?;

        while (exists part = advanceIfAny(bareKey, basicString, literalString, period)) {
            lastPart = part;

            if (lastWasDot && part.type == period) {
                throw error(part, "consecutive '.'s may not exist between keys");
            }
            else if (part.type == period) {
                lastWasDot = true;
            }
            else {
                if (!lastWasDot) {
                    throw error(part, "keys must be separated by '.'");
                }
                lastWasDot = false;
                switch (part.type)
                case (bareKey) {
                    validateBareKey(part, part.text);
                    result = result.follow(part.text);
                }
                case (basicString | literalString) {
                    assert (exists text = part.processedText);
                    result = result.follow(text);
                }
                else {
                    throw error(part, "invalid key");
                }
            }
        }

        if (lastWasDot) {
            throw error(lastPart, "table name may not end with '.'");
        }

        return result.sequence().reversed;
    }

    void parseTable() {
        value openToken = consume(openBracket, "expected '['");
        value path = lexer.inMode(LexerMode.key, parseKeyPath);
        if (!nonempty path) {
            throw error(openToken, "table name must not be empty");
        }
        currentTable = path.fold(this.result)((table, pathPart) {
            switch (obj = table.get(pathPart))
            case (is TomlTable) {
                return obj;
            }
            case (is Null) {
                value newTable = TomlTable();
                createdButNotDefined.add(newTable);
                table.put(pathPart, newTable);
                return newTable;
            }
            else {
                currentTable = TomlTable(); // ignore subsequent key/value pairs
                // TODO actually provide the leading key path... (can't use fold)
                throw error(openToken, "a value already exists for the given key");
            }
        });
        if (!createdButNotDefined.remove(currentTable)) {
            // TODO format path, once we have a serializer
            throw error(openToken, "table ``path`` has already been defined");
        }
        consume(closeBracket, "expected ']'");
    }

    void parseArrayOfTables() {
        value openToken = consume(doubleOpenBracket, "expected '[['");
        value path = lexer.inMode(LexerMode.key, parseKeyPath);
        if (!nonempty path) {
            throw error(openToken, "table name must not be empty");
        }
        value container = path.exceptLast.fold(this.result)((table, pathPart) {
            switch (obj = table.get(pathPart))
            case (is TomlTable) {
                return obj;
            }
            case (is Null) {
                value newTable = TomlTable();
                createdButNotDefined.add(newTable);
                table.put(pathPart, newTable);
                return newTable;
            }
            else {
                currentTable = TomlTable(); // ignore subsequent key/value pairs
                // TODO actually provide the leading key path... (can't use fold)
                throw error(openToken, "a value already exists for the given key");
            }
        });
        TomlArray array;
        switch (obj = container.get(path.last))
        case (is TomlArray) {
            // TODO do we care how this array was defined? Track '[[' arrays vs. inline?
            array = obj;
        }
        case (is Null) {
            array = TomlArray();
            container.put(path.last, array);
        }
        else {
            throw error(openToken, "a non-array value already exists for the given key");
        }

        currentTable = TomlTable();
        array.add(currentTable);

        consume(doubleCloseBracket, "expected ']]'");
    }

     """
            line : comment | newline | keyValuePair | table | arrayOfTables
     """
    void parseLine() {
        switch (peek()?.type)
        case (comment) { advance(); }
        case (newline) { advance(); }
        case (bareKey | basicString | literalString) {
            currentTable.putAll { parseKeyValuePair() };
            accept(comment);
            if (!endOfFile && !accept(newline)) {
                throw error(peek(), "expected a newline or eof after key/value pair");
            }
        }
        case (openBracket) {
            parseTable();
            accept(comment);
            if (!endOfFile && !accept(newline)) {
                throw error(peek(), "expected a newline or eof after table header");
            }
        }
        case (doubleOpenBracket) {
            parseArrayOfTables();
            accept(comment);
            if (!endOfFile && !accept(newline)) {
                throw error(peek(),
                        "expected a newline or eof after array of tables header");
            }
        }
        else {
            throw error(peek());
        }
    }

    void validateBareKey(Token token, String key) {
        function validChar(Character c)
            =>     c in 'A'..'Z'
                || c in 'a'..'z'
                || c in '0'..'9'
                || c == '_' || c == '-'; 
        if (!key.every(validChar)) {
            throw error {
                token;
                "bare keys may only contain the characters \
                 'A-Z', 'a-z', '0-9', '_', and '-'";
            };
        }
    }
}.get();

interface Producer<T> {
    shared formal T get();
}
