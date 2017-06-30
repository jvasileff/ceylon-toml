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
}
