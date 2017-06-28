shared abstract class TokenType(shared String type) {
    string => type;
}

"Tab (`#09`) or space (`#20`)"
shared object whitespace extends TokenType("whitespace") {}

"LF (`#0A`) or CRLF (`#0D0A`)"
shared object newline extends TokenType("newline") {}

 """A hash symbol (`#`) and the remaining line

       # This is a full-line comment
       key = "value" # This is a comment at the end of a line
 """
shared object comment extends TokenType("comment") {}

 """A group of characters that are not separated by a space. Allowed characters:

    - [A-Za-z0-9_-] # used in bareKeys
    - [+:.] # used in numbers and dates

    Depending on the context, an instance could be a bare key or a value, and for
    values, one of:

    - Boolean
    - Integer
    - Float
    - LocalTime
    - LocalDate
    - LocalDateTime
    - OffsetDateTime
 """
shared object word extends TokenType("word") {}

"""Characters surrounded by quotation marks. The contents may be any Unicode character
   except quotation mark, backslash, and the control characters (U+0000 to U+001F) which
   must be escaped.
 
   The following escape sequences may be used:
 
       \b         - backspace       (U+0008)
       \t         - tab             (U+0009)
       \n         - linefeed        (U+000A)
       \f         - form feed       (U+000C)
       \r         - carriage return (U+000D)
       \"         - quote           (U+0022)
       \\         - backslash       (U+005C)
       \uXXXX     - unicode         (U+XXXX)
       \UXXXXXXXX - unicode         (U+XXXXXXXX)
"""
shared object basicString extends TokenType("basicString") {}

"Multi-line basic strings are surrounded by three quotation marks on each side and allow
 newlines. A newline immediately following the opening delimiter will be trimmed. All
 other whitespace and newline characters remain intact.
 
 If the last character in a line is `\\`, subsequent newline characters will be ignored.

 Any character may be used except backslash and the control characters (U+0000 to U+001F).
 ion marks need not be escaped unless their presence would create a premature closing
 delimiter."
shared object multilineBasicString extends TokenType("multilineBasicString") {}

"Literal strings are surrounded by single quotes, must appear on a single line, and do
 not support escaping."
shared object literalString extends TokenType("literalString") {}

"Multi-line literal strings are surrounded by three single quotes on each side and allow
 newlines. There is no escaping. A newline immediately following the opening delimiter
 will be trimmed."
shared object multilineLiteralString extends TokenType("multilineLiteralString") {}

"One or more digits"
shared object digits extends TokenType("digits") {}

"The character '+'"
shared object plus extends TokenType("plus") {}

"The character '-'"
shared object minus extends TokenType("minus") {}

"The character '_'"
shared object underscore extends TokenType("underscore") {}

"The character ':'"
shared object colon extends TokenType("colon") {}

"The character '.'"
shared object period extends TokenType("period") {}

"The characters '[['"
shared object doubleOpenBracket extends TokenType("doubleOpenBracket") {}

"The characters ']]'"
shared object doubleCloseBracket extends TokenType("doubleCloseBracket") {}

"The character '['"
shared object openBracket extends TokenType("openBracket") {}

"The character ']'"
shared object closeBracket extends TokenType("closeBracket") {}

"The character '{'"
shared object openBrace extends TokenType("openBrace") {}

"The character '}'"
shared object closeBrace extends TokenType("closeBrace") {}

"The character ','"
shared object comma extends TokenType("comma") {}

"The `=` character"
shared object equal extends TokenType("equals") {}

"The character 'e' or 'E'"
shared object exponentCharacter extends TokenType("exponentCharacter") {}

"The character 'z' or 'Z'"
shared object zuluCharacter extends TokenType("zuluCharacter") {}

"End of file token"
shared object eof extends TokenType("eof") {}

"An unexpected token"
shared object error extends TokenType("error") {}
