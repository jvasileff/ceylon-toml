import com.vasileff.ceylon.toml.lexer {
    ...
}

abstract class BaseParser({Token*} tokenStream) {
    value tokens = tokenStream.filter((t) => !t.type == whitespace).iterator();
    value eofToken = Token(eof, "", -1, -1, -1);
    variable Token | Finished | Null nextToken = null;

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
        print("error: ``sb.string``");
        return ParseException(token, sb.string);
    }

    shared Token peek() {
        value t = nextToken else tokens.next();
        nextToken = t;
        return if (is Token t) then t else eofToken;
    }

    shared Boolean check(TokenType+ type)
        =>  peek().type in type;

    shared Token advance() {
        value result = peek();
        nextToken = null;
        return result;
    }

    shared Boolean accept(TokenType+ type) {
        if (check(*type)) {
            advance();
            return true;
        }
        return false;
    }

    shared [Token*] acceptRun(TokenType+ type) {
        variable {Token*} result = [];
        while (check(*type)) {
            result = result.follow(advance());
        }
        return result.sequence().reversed;
    }

    shared Token consume(TokenType type, String errorDescription) {
        if (check(type)) {
            return advance();
        }
        throw error(peek(), errorDescription);
    }
}
