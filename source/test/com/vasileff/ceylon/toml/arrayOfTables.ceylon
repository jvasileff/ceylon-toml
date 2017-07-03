import ceylon.test {
    test, assertEquals
}
import com.vasileff.ceylon.toml {
    parseToml
}

shared object arrayOfTables {
    // TODO tests for errors

    shared test void empty() {
        assertEquals {
            actual = parseToml {
                 """[[table_1]]""";
            };
            expected = map {
                "table_1" -> [map {}]
            };
        };

        assertEquals {
            actual = parseToml {
                 """[[table_1]]
                    [[table_1]]
                 """;
            };
            expected = map {
                "table_1" -> [map {}, map {}]
            };
        };
    }

    shared test void notEmpty() {
        assertEquals {
            actual = parseToml {
                 """[[table]]
                    t11 = 11
                    t12 = 12
                    [[table]]
                    t21 = 21
                    t22 = 22
                 """;
            };
            expected = map {
                "table" -> [
                    map {
                        "t11" -> 11,
                        "t12" -> 12
                    },
                    map {
                        "t21" -> 21,
                        "t22" -> 22
                    }
                ]
            };
        };
    }

    shared test void twoArraysMixedOrder() {
        assertEquals {
            actual = parseToml {
                 """[[table_a]]
                    ta11 = 11
                    ta12 = 12

                    [[table_b]]
                    tb11 = 11
                    tb12 = 12

                    [[table_a]]
                    ta21 = 21
                    ta22 = 22

                    [[table_b]]
                    tb21 = 21
                    tb22 = 22
                 """;
            };
            expected = map {
                "table_a" -> [
                    map {
                        "ta11" -> 11,
                        "ta12" -> 12
                    },
                    map {
                        "ta21" -> 21,
                        "ta22" -> 22
                    }
                ],
                "table_b" -> [
                    map {
                        "tb11" -> 11,
                        "tb12" -> 12
                    },
                    map {
                        "tb21" -> 21,
                        "tb22" -> 22
                    }
                ]
            };
        };
    }

    shared test void nested() {
        assertEquals {
            actual = parseToml {
                 """[outer]
                    o = 0

                    [[outer.table_a]]
                    ta11 = 11
                    ta12 = 12

                    [[outer.table_a]]
                    ta21 = 21
                    ta22 = 22
                 """;
            };
            expected = map {
                "outer" -> map {
                    "o" -> 0,
                    "table_a" -> [
                        map {
                            "ta11" -> 11,
                            "ta12" -> 12
                        },
                        map {
                            "ta21" -> 21,
                            "ta22" -> 22
                        }
                    ]
                }
            };
        };
    }

    shared test void nestedArrayFirst() {
        assertEquals {
            actual = parseToml {
                 """[[outer.table_a]]
                    ta11 = 11
                    ta12 = 12

                    [outer]
                    o = 0

                    [[outer.table_a]]
                    ta21 = 21
                    ta22 = 22
                 """;
            };
            expected = map {
                "outer" -> map {
                    "o" -> 0,
                    "table_a" -> [
                        map {
                            "ta11" -> 11,
                            "ta12" -> 12
                        },
                        map {
                            "ta21" -> 21,
                            "ta22" -> 22
                        }
                    ]
                }
            };
        };
    }
}
