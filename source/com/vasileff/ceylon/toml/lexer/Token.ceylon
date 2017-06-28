shared class Token(type, text, position, line, column) {
    shared TokenType type;
    shared String text;
    shared Integer position;
    shared Integer line;
    shared Integer column;

    string => "Token(``type.string``)";
}
