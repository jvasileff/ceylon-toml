import ceylon.time {
    Time, Date, DateTime
}

shared alias TomlValue
    =>  TomlTable | TomlArray | Time | Date | DateTime
            | Boolean | Float | Integer | String;
