import ceylon.test {
    test, ignore, assertTrue
}
import com.vasileff.ceylon.toml {
    parseToml, TomlParseException, TomlTable
}

shared object inlineTables {
    shared test void empty() => checkValue("{}", TomlTable());
    ignore
    shared test void emptyComma() => checkValue("{,}", TomlTable());
    shared test void el1() => checkValue("{a=1}", TomlTable {"a"->1});
    shared test void el2() => checkValue("{a=1,b=2}", TomlTable {"a"->1,"b"->2});
    shared test void trailingComma() => checkValue("{a=1,b=2,}", TomlTable {"a"->1,"b"->2});

    shared test void tooManyCommas()
        =>  assertTrue(parseToml("key = {a=1,,b=2}") is TomlParseException);

    shared test void tooManyCommasTrailing()
        =>  assertTrue(parseToml("key = {a=1,b=2,,}") is TomlParseException);
}
