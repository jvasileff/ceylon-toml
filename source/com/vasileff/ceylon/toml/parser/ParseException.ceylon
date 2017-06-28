import com.vasileff.ceylon.toml.lexer {
    Token
}

shared class ParseException(shared Token? token, String description)
        extends Exception(description) {}
