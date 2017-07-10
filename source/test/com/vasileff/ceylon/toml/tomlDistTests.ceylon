import ceylon.test {
    test, assertEquals
}
import com.vasileff.ceylon.toml {
    parseToml, TomlParseException
}
import ceylon.json {
    parseJson = parse,
    JsonObject
}

shared
object tomlDistTests {
    void runTest(String filename) {
        assert (exists tomlText
            =   `module`.resourceByPath("``filename``.toml")
                        ?.textContent("UTF-8"));
        assert (exists jsonText
            =   `module`.resourceByPath("``filename``.json")
                        ?.textContent("UTF-8"));

        assert (!is TomlParseException toml = parseToml(tomlText));
        assert (is JsonObject json = parseJson(jsonText));

        assertEquals(toml, json);
    }

    // NOTE the date-time "dob" example.toml was changed to a String since
    //      json doesn't support first class dates
    shared test void example()
        =>  runTest("example");

    shared test void fruit()
        =>  runTest("fruit");

    shared test void hardExample()
        =>  runTest("hard_example");
}
