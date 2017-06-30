import ceylon.collection {
    MutableMap, HashMap
}

shared class TomlTable() satisfies MutableMap<String, TomlValue> {
    value delegate = HashMap<String, TomlValue>();

    remove(String key) => delegate.remove(key);
    put(String key, TomlValue item) => delegate.put(key, item);
    defines(Object key) => delegate.defines(key);
    get(Object key) => delegate.get(key);

    iterator() => delegate.iterator();
    clone() => delegate.clone();
    clear() => clear();
    equals(Object other) => delegate.equals(other);
    hash => delegate.hash;

    "Returns a [[TomlTable]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[TomlTable]]";
    }
    shared TomlTable getTomlTable(String key) {
        "Expecting a TomlTable"
        assert (is TomlTable val = get(key));
        return val;
    }

    "Returns a [[TomlTable]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[TomlTable]]";
    }
    shared TomlTable? getTomlTableOrNull(String key) {
        "Expecting a TomlTable or Null"
        assert (is TomlTable? val = get(key));
        return val;
    }

    "Returns a [[TomlArray]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[TomlArray]]";
    }
    shared TomlArray getTomlArray(String key) {
        "Expecting a TomlArray"
        assert (is TomlArray val = get(key));
        return val;
    }

    "Returns a [[TomlArray]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[TomlArray]]";
    }
    shared TomlArray? getTomlArrayOrNull(String key) {
        "Expecting a TomlTable or Null"
        assert (is TomlArray? val = get(key));
        return val;
    }

    "Returns a [[TomlDateTime]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[TomlDateTime]]";
    }
    shared TomlDateTime getTomlDateTime(String key) {
        "Expecting a TomlDateTime"
        assert (is TomlDateTime val = get(key));
        return val;
    }

    "Returns a [[TomlDateTime]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[TomlDateTime]]";
    }
    shared TomlArray? getTomlDateTimeOrNull(String key) {
        "Expecting a TomlDateTime or Null"
        assert (is TomlArray? val = get(key));
        return val;
    }

    "Returns a [[Boolean]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[Boolean]]";
    }
    shared Boolean getBoolean(String key) {
        "Expecting a Boolean"
        assert (is Boolean val = get(key));
        return val;
    }

    "Returns a [[Boolean]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[Boolean]]";
    }
    shared Boolean? getBooleanOrNull(String key) {
        "Expecting a Boolean or Null"
        assert (is Boolean? val = get(key));
        return val;
    }

    "Returns a [[Float]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[Float]]";
    }
    shared Float getFloat(String key) {
        "Expecting a Float"
        assert (is Float val = get(key));
        return val;
    }

    "Returns a [[Float]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[Float]]";
    }
    shared Float? getFloatOrNull(String key) {
        "Expecting a Float or Null"
        assert (is Float? val = get(key));
        return val;
    }

    "Returns a [[Integer]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[Integer]]";
    }
    shared Integer getInteger(String key) {
        "Expecting a Integer"
        assert (is Integer val = get(key));
        return val;
    }

    "Returns a [[Integer]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[Integer]]";
    }
    shared Integer? getIntegerOrNull(String key) {
        "Expecting a Integer or Null"
        assert (is Integer? val = get(key));
        return val;
    }

    "Returns a [[String]]."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[String]]";
    }
    shared String getString(String key) {
        "Expecting a String"
        assert (is String val = get(key));
        return val;
    }

    "Returns a [[String]], or [[null]] if the [[key]] does not exist."
    throws {
        `class AssertionError`;
        "if the key does not exist or points to a type that is not [[String]]";
    }
    shared String? getStringOrNull(String key) {
        "Expecting a Integer or Null"
        assert (is String? val = get(key));
        return val;
    }
}
