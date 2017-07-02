Boolean isWordCharacter(Character c)
    =>     c.letter
        || c.digit
        || c in "_-+:.";

Boolean isBasicUnescapedCharacter(Character c)
    =>     c in '\{#20}'..'\{#21}'
        || c in '\{#23}'..'\{#5b}'
        || c in '\{#5d}'..'\{#10ffff}';

Boolean isCommentCharacter(Character c)
    =>     c in '\{#20}'..'\{#10ffff}'
        || c == '\t';

Boolean isLiteralCharacter(Character c)
    =>     c in '\{#20}'..'\{#26}'
        || c in '\{#28}'..'\{#10ffff}'
        || c == '\t';


Boolean isDigit(Character c)
    =>     c in '0'..'9';

Boolean isHexDigit(Character c)
    =>     c in '0'..'9'
        || c in 'A'..'F';
