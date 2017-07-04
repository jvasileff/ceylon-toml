import com.vasileff.ceylon.toml.lexer {
    ...
}

abstract class BaseParser(Lexer tokenStream) {
    value eofToken = Token(eof, "", -1, -1, -1, []);
    variable Token | Finished | Null nextToken = null;
    shared variable [ParseException*] errors = [];

    shared Token | Finished next() {
        while (true) {
            value t = tokenStream.next();
            if (!is Finished t, t.type == whitespace) {
                continue;
            }
            return t;
        }
    }

    shared String formatToken(Token token)
        =>  if (token.type == newline) then "newline"
            else if (token.type == newline) then "eof"
            else if (token.text.shorterThan(10)) then "'``token.text``'"
            else "'``token.text[...10]``...'";

    shared ParseException error(Token token, String? description = null) {
        // TODO this is no good for errors like:
        // error: unexpected '['; table [first-Table] has already been defined at 75:1
        value sb = StringBuilder();
        sb.append("unexpected ");
        sb.append(formatToken(token));
        if (exists description) {
            sb.append("; ");
            sb.append(description);
        }
        sb.append(" at ``token.line``:``token.column``");
        value exception = ParseException(token, sb.string);
        errors = errors.withTrailing(exception);
        return exception;
    }

    shared Token peek() {
        value t = nextToken else next();
        nextToken = t;
        return if (is Token t) then t else eofToken;
    }

    shared Boolean check(Boolean(TokenType) | TokenType+ type)
        =>  let (p = peek().type)
            type.any((type)
                =>  if (is TokenType type)
                    then p == type
                    else type(p));

    shared Token advance() {
        value result = peek();
        nextToken = null;
        errors = concatenate(errors, result.errors);
        return result;
    }

    shared Boolean accept(Boolean(TokenType) | TokenType+ type) {
        if (check(*type)) {
            advance();
            return true;
        }
        return false;
    }

    shared [Token*] acceptRun(Boolean(TokenType) | TokenType+ type) {
        variable {Token*} result = [];
        while (check(*type)) {
            result = result.follow(advance());
        }
        return result.sequence().reversed;
    }

    shared Token consume(Boolean(TokenType) | TokenType type, String errorDescription) {
        if (check(type)) {
            return advance();
        }
        throw error(peek(), errorDescription);
    }
}
