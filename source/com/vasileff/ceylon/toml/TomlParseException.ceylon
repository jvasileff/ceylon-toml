shared class TomlParseException(
        shared [String+] errors,
        shared TomlTable partialResult)
        extends Exception("``errors.first`` (``errors.size`` total errors)") {}
