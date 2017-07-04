import com.vasileff.ceylon.toml {
    TomlTable
}
import com.vasileff.ceylon.toml.lexer {
    Lexer
}

shared [TomlTable, ParseException*] parse({Character*} input)
    =>  Parser(Lexer(input)).parse();
