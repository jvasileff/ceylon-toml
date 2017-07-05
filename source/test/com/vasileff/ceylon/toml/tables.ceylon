import ceylon.test {
    test, assertEquals
}
import com.vasileff.ceylon.toml {
    parseToml
}

shared object tables {
    // TODO tests for errors, like redefining tables

    shared test void empty() {
        assertEquals {
            actual = parseToml {
                 """[table_1]""";
            };
            expected = map {
                "table_1" -> map {}
            };
        };
    }

    shared test void oneTable() {
        assertEquals {
            actual = parseToml {
                 """[table_1]
                    t1k1 = 11
                    t1k2 = 12
                 """;
            };
            expected = map {
                "table_1" -> map {
                    "t1k1" -> 11,
                    "t1k2" -> 12
                }
            };
        };
    }

    shared test void twoTables() {
        assertEquals {
            actual = parseToml {
                 """[table_1]
                    t1k1 = 11
                    t1k2 = 12

                    [table_2]
                    t2k1 = 21
                    t2k2 = 22
                 """;
            };
            expected = map {
                "table_1" -> map {
                    "t1k1" -> 11,
                    "t1k2" -> 12
                },
                "table_2" -> map {
                    "t2k1" -> 21,
                    "t2k2" -> 22
                }
            };
        };
    }

    shared test void nestedTable() {
        assertEquals {
            actual = parseToml {
                 """[table_1]
                    t1k1 = 11

                    [table_1.sub1]
                    t11k1 = 111

                    [table_1.sub2]
                    t12k1 = 121
                 """;
            };
            expected = map {
                "table_1" -> map {
                    "t1k1" -> 11,
                    "sub1" -> map {
                        "t11k1" -> 111
                    },
                    "sub2" -> map {
                        "t12k1" -> 121
                    }
                }
            };
        };
    }

    shared test void nestedTableSubFirst() {
        assertEquals {
            actual = parseToml {
                 """[table_1.sub1]
                    t11k1 = 111

                    [table_1]
                    t1k1 = 11

                    [table_1.sub2]
                    t12k1 = 121
                 """;
            };
            expected = map {
                "table_1" -> map {
                    "t1k1" -> 11,
                    "sub1" -> map {
                        "t11k1" -> 111
                    },
                    "sub2" -> map {
                        "t12k1" -> 121
                    }
                }
            };
        };
    }

    shared test void nestedTable3Deep() {
        assertEquals {
            actual = parseToml {
                 """[table_1]
                    t1k1 = 11

                    [table_1.sub1]
                    t11k1 = 111

                    [table_1.sub1.subsub1]
                    t111k1 = 1111
                 """;
            };
            expected = map {
                "table_1" -> map {
                    "t1k1" -> 11,
                    "sub1" -> map {
                        "t11k1" -> 111,
                        "subsub1" -> map {
                            "t111k1" -> 1111
                        }
                    }
                }
            };
        };
    }

    shared void test() {
        empty();
        oneTable();
        twoTables();
        nestedTable();
        nestedTableSubFirst();
        nestedTable3Deep();
    }
}
