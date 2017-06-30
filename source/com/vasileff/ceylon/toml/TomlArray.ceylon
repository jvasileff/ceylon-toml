import ceylon.collection {
    MutableList, ArrayList
}

shared class TomlArray() satisfies MutableList<TomlValue> {
    value delegate = ArrayList<TomlValue>();

    lastIndex => delegate.lastIndex;
    set(Integer index, TomlValue element) => delegate.set(index, element);
    add(TomlValue element) => delegate.add(element);
    getFromFirst(Integer index) => delegate.getFromFirst(index);
    insert(Integer index, TomlValue element) => delegate.insert(index, element);
    delete(Integer index) => delegate.delete(index);

    iterator() => delegate.iterator();
    clone() => delegate.clone();
    clear() => clear();
    equals(Object other) => delegate.equals(other);
    hash => delegate.hash;
}
