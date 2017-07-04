import com.vasileff.ceylon.toml.parser {
    parse
}

shared TomlTable | TomlParseException parseToml({Character*} input) {
    value [result, *errors] = parse(input);
    if (nonempty errors) {
        return TomlParseException(errors.collect(Exception.message), result);
    }
    return result;
}
