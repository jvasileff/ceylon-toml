import ceylon.test {
    test, ignore, assertEquals, assertTrue
}
import com.vasileff.ceylon.toml {
    parseToml, TomlParseException
}

shared object basicStrings {
    shared test void empty()
        =>  checkValue("""""""", "");

    ignore
    shared test void unterminated() {
        assertTrue {
            parseToml("""key = "abc""") is TomlParseException;
        };
        assertTrue {
            parseToml("""key = "abc
                         """) is TomlParseException;
        };
        assertTrue {
            parseToml("""key = "abc
                         key2 = "def" """) is TomlParseException;
        };
    }

    ignore
    shared test void unterminatedLineRecover() {
        checkValue {
            input = """"abc
                    """;
            expected = "abc";
            withError = true;
        };

        value input = """key = "abc
                         key2 = "def" """;
        assert (is TomlParseException e = parseToml(input));
        assertEquals {
            actual = e.partialResult.get("key2");
            expected = "def";
        };
    }

    ignore
    shared test void unescapes() {
        checkValue {
            input = """"\b\t\n\f\r\"\\" """;
            expected = "\b\t\n\f\r\"\\";
        };
    }

    ignore
    shared test void unescapeError() {
        checkValue {
            input = """"\xhello" """;
            expected = "xhello";
            withError = true;
        };
    }

    ignore
    shared test void unicode4digit() {
        checkValue {
            input = """"-\u0023\u0024-" """;
            expected = "-#$-";
        };
    }

    ignore
    shared test void unicode8digit() {
        checkValue {
            input = """"-\U0001D419\U0001D419-" """;
            expected = "-\{#01D419}\{#01D419}-";
        };
    }

    ignore
    shared test void unicode4digitLengthErrors() {
        assertTrue {
            parseToml("""key = "\u023 " """) is TomlParseException;
            "Too few 'u' digits then non-hex char";
        };
        assertTrue {
            parseToml("""key = "\u023" """) is TomlParseException;
            "Too few 'u' digits then end of string";
        };
        assertTrue {
            parseToml("""key = "\u023
                         """) is TomlParseException;
            "Too few 'u' digits then newline";
        };
        assertTrue {
            parseToml("""key = "\u023""") is TomlParseException;
            "Too few 'u' digits then eof";
        };
    }

    ignore
    shared test void unicode8digitLengthErrors() {
        assertTrue {
            parseToml("""key = "\U001D419 " """) is TomlParseException;
            "Too few 'U' digits then non-hex char";
        };
        assertTrue {
            parseToml("""key = "\U001D419" """) is TomlParseException;
            "Too few 'U' digits then end of string";
        };
        assertTrue {
            parseToml("""key = "\U001D419
                         """) is TomlParseException;
            "Too few 'U' digits then newline";
        };
        assertTrue {
            parseToml("""key = "\U001D419""") is TomlParseException;
            "Too few 'U' digits then eof";
        };
    }

    ignore
    shared test void unicodeBadCodePoint() {
        assertTrue {
            parseToml("""key = "\U#00110000" """) is TomlParseException;
        };
    }
}
