import com.vasileff.ceylon.toml.lexer {
    ...
}

shared Integer | Float parseTomlValue({Token*} tokenStream)
    =>  ValueParser(tokenStream).parse();

class ValueParser({Token*} tokenStream) extends BaseParser(tokenStream) {

    String parseInteger(
            Token? signToken = null,
            Token? leadingDigitsToken = null) {

        value positive
            =   if (exists signToken)
                    then signToken.type == plus
                else if (!leadingDigitsToken exists)
                    then accept(plus) || !accept(minus)
                else true;

        value sb = StringBuilder();

        if (!positive) {
            sb.appendCharacter('-');
        }

        sb.append {
            (leadingDigitsToken
                else consume(digits, "expected digits")).text;
        };

        while (accept(underscore)) {
            value t = consume(digits, "expected digits after '_'");
            sb.append(t.text);
        }

        return sb.string;
    }

    Integer | Float parseNumber(
            Token? signToken = null,
            Token? leadingDigitsToken = null) {

        value firstToken
            =   signToken else leadingDigitsToken else peek();

        value wholePart
            =   parseInteger(signToken, leadingDigitsToken);

        value fractionalPart
            =   if (accept(period))
                then parseInteger()
                else null;

        value exponent
            =   if (accept(exponentCharacter))
                then "e" + parseInteger()
                else null;

        if (!fractionalPart exists && !exponent exists) {
            switch (i = Integer.parse(wholePart))
            case (is Integer) {
                return i;
            }
            else {
                throw error(firstToken, i.message);
            }
        }
        else {
            value floatString
                =   wholePart
                    + "." + (fractionalPart else "0")
                    + (exponent else "");
            switch (f = Float.parse(floatString))
            case (is Float) {
                return f;
            }
            else {
                throw error(firstToken, f.message);
            }
        }
    }

    shared Integer | Float parse() { // | Date
        if (check(eof)) {
            throw error(peek(), "expected a value");
        }

        if (check(plus, minus)) {
            return parseNumber();
        }

        value leadingDigits = consume(digits, "expected digits");

        switch (peek().type)
        case (underscore | exponentCharacter) {
            return parseNumber(null, leadingDigits);
        }
        case (colon) {
            // return parseLocalTime(leadingDigits);
            throw error(peek(), "times are not yet supported");
        }
        case (minus) {
            // return parseDate(leadingDigits);
            throw error(peek(), "dates are not yet supported");
        }
        else {
            // it's an integer
            return parseNumber(null, leadingDigits);
        }
    }
}
