import ceylon.test {
    test, ignore, assertEquals, assertTrue
}
import com.vasileff.ceylon.toml {
    parseToml, TomlParseException
}

shared object mlBasicStrings {
    value tq = "\"\"\"";

    shared test void empty() {
        checkValue {
            input = "``tq````tq``";
            expected = "";
        };
    }

    ignore
    shared test void unterminated() {
        assertTrue {
            parseToml("key = ``tq``abc") is TomlParseException;
        };
        assertTrue {
            parseToml("key = ``tq``abc
                       ") is TomlParseException;
        };
    }

    ignore
    shared test void unescapes() {
        checkValue {
            input = "``tq``\\b\\t\\n\\f\\r\\\"\\\\``tq``";
            expected = "\b\t\n\f\r\"\\";
        };
    }


// TODO
    ignore
    shared test void unescapeError() {
        value input = "key = ``tq``\\xhello``tq`` ";
        "Illegal escape \\x should generate an error"
        assert (is TomlParseException e = parseToml(input));
        assertEquals {
            actual = e.partialResult.get("key");
            expected = "xhello";
            "should produce result anyway";
        };
    }

    ignore
    shared test void unicode4digit() {
        checkValue {
            input = "``tq``-\\u0023\\u0024-``tq`` ";
            expected = "-#$-";
        };
    }

    ignore
    shared test void unicode8digit() {
        checkValue {
            input = "``tq``-\\U0001D419\\U0001D419-``tq``";
            expected = "-\{#01D419}\{#01D419}-";
        };
    }

    ignore
    shared test void unicode4digitLengthErrors() {
        assertTrue {
            parseToml("key = ``tq``\\u023 ``tq``") is TomlParseException;
            "Too few 'u' digits then non-hex char";
        };
        assertTrue {
            parseToml("key = ``tq``\\u023``tq``") is TomlParseException;
            "Too few 'u' digits then end of string";
        };
        assertTrue {
            parseToml("key = ``tq``\\u023
                       ``tq``") is TomlParseException;
            "Too few 'u' digits then newline";
        };
        assertTrue {
            parseToml("key = ``tq``\\u023``tq``") is TomlParseException;
            "Too few 'u' digits then eof";
        };
    }

    ignore
    shared test void unicode8digitLengthErrors() {
        assertTrue {
            parseToml("key = ``tq``\\U001D419 ``tq``") is TomlParseException;
            "Too few 'U' digits then non-hex char";
        };
        assertTrue {
            parseToml("key = ``tq``\\U001D419``tq``") is TomlParseException;
            "Too few 'U' digits then end of string";
        };
        assertTrue {
            parseToml("key = ``tq``\\U001D419
                       ``tq``") is TomlParseException;
            "Too few 'U' digits then newline";
        };
        assertTrue {
            parseToml("key = ``tq``\\U001D419") is TomlParseException;
            "Too few 'U' digits then eof";
        };
    }

    ignore
    shared test void unicodeBadCodePoint() {
        assertTrue {
            parseToml("key = ``tq``\\U#00110000``tq``") is TomlParseException;
        };
    }

    // * A newline immediately following the opening delimiter will be trimmed
    // * All other whitespace and newline characters remain intact

    shared test void twoLine() {
        checkValue {
            input = "``tq``abc\ndef``tq``";
            expected = "abc\ndef";
        };
    }

    ignore
    shared test void twoLineSkipFirst() {
        checkValue {
            input = "``tq``\nabc\ndef``tq``";
            expected = "abc\ndef";
        };
    }

    shared test void threeLine() {
        checkValue {
            input = "``tq``abc\n\ndef``tq``";
            expected = "abc\n\ndef";
        };
    }

    shared test void threeLineEmptyLast() {
        checkValue {
            input = "``tq``abc\ndef\n``tq``";
            expected = "abc\ndef\n";
        };
    }

    ignore
    shared test void threeLineSkipFirst() {
        checkValue {
            input = "``tq``\n\nabc\ndef``tq``";
            expected = "\nabc\ndef";
        };
    }
}
