import ceylon.test {
    test, ignore, assertEquals, assertTrue
}
import com.vasileff.ceylon.toml {
    parseToml, TomlParseException
}

shared object literalStrings {
    shared test void empty() {
        checkValue {
            input = """''""";
            expected = "";
        };
    }

    ignore
    shared test void unterminated() {
        assertTrue {
            parseToml("""key = 'abc""") is TomlParseException;
        };
        assertTrue {
            parseToml("""key = 'abc
                         """) is TomlParseException;
        };
        assertTrue {
            parseToml("""key = 'abc
                         key2 = 'def' """) is TomlParseException;
        };
    }

    ignore
    shared test void unterminatedLineRecover() {
        value input = """key = 'abc
                         key2 = 'def' """;
        assert (is TomlParseException e = parseToml(input));
        assertEquals {
            actual = e.partialResult.get("key2");
            expected = "def";
        };
    }

    shared test void dontUnescape() {
        checkValue {
            input = """'\b\t\n\f\r\"\\' """;
            expected = """\b\t\n\f\r\"\\""";
        };
    }

    shared test void dontUnescapeError() {
        checkValue {
            input = """'\xhello' """;
            expected = """\xhello""";
        };
    }

    shared test void ignoreUnicode4digit() {
        checkValue {
            input = """'-\u0023\u0024-' """;
            expected = """-\u0023\u0024-""";
        };
    }

    shared test void ignoreUnicode8digit() {
        checkValue {
            input = """'-\U0001D419\U0001D419-' """;
            expected = """-\U0001D419\U0001D419-""";
        };
    }
}
