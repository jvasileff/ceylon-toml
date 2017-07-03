import com.vasileff.ceylon.toml {
    TomlTable, TomlArray, TomlValue
}
import com.vasileff.ceylon.toml.lexer {
    ...
}
import ceylon.collection {
    IdentitySet
}

shared [TomlTable, ParseException*] parse({Token*} tokenStream)
    =>  Parser(tokenStream).parse();

class Parser({Token*} tokenStream) extends BaseParser(tokenStream) {
    value result = TomlTable();
    variable value currentTable = result;
    value createdButNotDefined = IdentitySet<TomlTable>();

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

    shared [TomlTable, ParseException*] parse() {
        while (!check(eof)) {
            try {
                parseLine();
            }
            catch (ParseException e) {
                acceptRun(not([newline, eof].contains));
            }
        }
        return [result, *errors];
    }

     """
            BareKey
     """
    String parseBareKey() {
        value token = consume(word, "expected a bare key");
        validateBareKey(token, token.text);
        return token.text;
    }

     """
            BasicString
     """
    String parseBasicString() {
        // TODO validate and unescape
        value token = consume(basicString, "expected a basic string");
        return String(token.text.rest.exceptLast);
    }

     """
            MultilineBasicString
     """
    String parseMultilineBasicString() {
        // TODO validate and unescape
        value token = consume(multilineBasicString, "expected a multi-line basic string");
        return String(token.text.skip(3).exceptLast.exceptLast.exceptLast);
    }

     """
            LiteralString
     """
    String parseLiteralString() {
        // TODO validate
        value token = consume(literalString, "expected a literal string");
        return String(token.text.rest.exceptLast);
    }

     """
            MultilineLiteralString
     """
    String parseMultilineLiteralString() {
        // TODO validate and unescape
        value token = consume(multilineLiteralString,
            "expected a multi-line literal string");
        return String(token.text.skip(3).exceptLast.exceptLast.exceptLast);
    }

     """
            key : word | basicString | literalString
     """
    String parseKey() {
        switch(peek().type)
        case (word) { return parseBareKey(); }
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
            acceptRun(comment, newline);
            array.add(parseValue());
            acceptRun(comment, newline);
            if (!accept(comma)) {
                break;
            }
            acceptRun(comment, newline);
        }
        accept(comma); // trailing comma ok
        acceptRun(comment, newline);
        consume(closeBracket, "expected ']' to end the array");
        return array;
    }

    TomlTable parseInlineTable() {
        value table = TomlTable();
        consume(openBrace, "expected '{' to start the inline table");
        while (!check(closeBrace)) {
            table.putAll { parseKeyValuePair() };
            if (!accept(comma)) {
                break;
            }
        }
        accept(comma); // trailing comma ok
        consume(closeBrace, "expected '}' to end the inline table");
        return table;
    }

     """
            value : basicString | literalString | ...
     """
    TomlValue parseValue() {
        value token = peek();
        switch (type = token.type)
        case (basicString) { return parseBasicString(); }
        case (multilineBasicString) { return parseMultilineBasicString(); }
        case (literalString) { return parseLiteralString(); }
        case (multilineLiteralString) { return parseMultilineLiteralString(); }
        case (openBracket) { return parseTomlArray(); }
        case (openBrace) { return parseInlineTable(); }
        case (word) {
            if (token.text == "true") {
                advance();
                return true;
            }
            else if (token.text == "false") {
                advance();
                return false;
            }
            else {
                advance();
                try {
                    return parseTomlValue(
                        tomlValueTokenStream(
                            token.text,
                            token.position,
                            token.line,
                            token.column)
                    );
                }
                catch (ParseException e) {
                    // TODO remove temp hack not to lose the error!
                    errors = errors.withTrailing(e);
                    throw e;
                }
            }
        }
        else {
            throw error(token, "expected a value");
        }
    }

     """
            keyValuePair : key '=' value Comment? (Newline | EOF)
     """
    String->TomlValue parseKeyValuePair() {
        value key = parseKey();
        consume(equal, "expected '='");
        value val = parseValue();
        return key -> val;
    }

    [String*] parseKeyPath() {
        function splitWord(Token token) {
            assert (token.type == word);
            return token.text
                .split('.'.equals, false, false)
                .map((string)
                    =>  if (string.empty)
                        then null
                        else if (string == ".")
                        then Token(period, string,
                                    // FIXME track exact position
                                   token.position, token.line, token.column)
                        else Token(word, string,
                                   token.position, token.line, token.column))
                .coalesced;
        }

        // "word" tokens may have '.' separators, so split them
        value parts
            =   acceptRun(word, basicString, literalString)
                    .flatMap((token)
                        =>  if (token.type == word)
                            then splitWord(token)
                            else [token])
                    .sequence();

        if (!nonempty parts) {
            return [];
        }

        if (parts.first.type == period) {
            throw error(parts.first, "table name may not start with '.'");
        }

        if (parts.last.type == period) {
            throw error(parts.first, "table name may not end with '.'");
        }

        variable {String*} result = [];
        variable value lastWasDot = true;

        for (part in parts) {
            if (lastWasDot && part.type == period) {
                throw error(parts.first, "consecutive '.'s may not exist between keys");
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
                case (word) {
                    validateBareKey(part, part.text);
                    result = result.follow(part.text);
                }
                case (basicString) {
                    // TODO unescape
                    result = result.follow(String(part.text.rest.exceptLast));
                }
                case (literalString) {
                    result = result.follow(String(part.text.rest.exceptLast));
                }
                else {
                    throw error(part, "invalid key");
                }
            }
        }

        return result.sequence().reversed;
    }

    void parseTable() {
        value openToken = consume(openBracket, "expected '['");
        value path = parseKeyPath();
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
        value path = parseKeyPath();
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
        switch (t = peek().type)
        case (comment) { advance(); }
        case (newline) { advance(); }
        case (word | basicString | literalString) {
            currentTable.putAll { parseKeyValuePair() };
            accept(comment);
            if (!accept(newline, eof)) {
                throw error(peek(), "expected a newline or eof after key/value pair");
            }
        }
        case (openBracket) {
            parseTable();
            accept(comment);
            if (!accept(newline, eof)) {
                throw error(peek(), "expected a newline or eof after table header");
            }
        }
        case (doubleOpenBracket) {
            parseArrayOfTables();
            accept(comment);
            if (!accept(newline, eof)) {
                throw error(peek(),
                        "expected a newline or eof after array of tables header");
            }
        }
        else {
            throw error(peek());
        }
    }
}
