import com.vasileff.ceylon.toml.parser {
    parse
}
import com.vasileff.ceylon.toml.lexer {
    tomlTokenStream
}

shared TomlTable | TomlParseException parseToml({Character*} input) {
    value [result, *errors] = parse(tomlTokenStream(input));
    if (nonempty errors) {
        return TomlParseException(errors.collect(Exception.message), result);
    }
    return result;
}
