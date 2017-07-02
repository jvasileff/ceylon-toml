import com.vasileff.ceylon.toml.lexer {
    tomlTokenStream
}
import com.vasileff.ceylon.toml.parser {
    parse
}

shared void run() {
    value result = parseToml(
         """
            # testing
            key1 = "someValue1" # x y
            # testing
            key2 = "someValue2"
            itstrue = true
            itsnottrue = false
            someValues = [ "a", "b", "c" ]
            moreValues = [ true, false ]
            valuesWithLines = [
   
                true 

                ,

                false

                ,

            ]
            valuesWithComments = [
                #comment
                true #comment
                #comment
                , #comment
                #comment
                false #comment
                #comment
                , #comment
                #comment
            ]
            valuesWithComments-and-new_lines = [

                #comment

                true #comment

                #comment

                , #comment

                #comment

                false #comment

                #comment

                , #comment

                #comment

            ]
            mixedValues = [ true, false, "hello" ] # should be illegal !
            array-of-arrays = [ [ true, false ], [ "apples", "oranges" ] ]
            inlinetable = { "one" = "1", "two" = "2" }
            someInt0 = 10
            someInt1 = +11
            someInt2 = -12
            someFloat0 = 10.0
            someFloat1 = 11e0
            someFloat2 = +12.0
            someFloat3 = -13.0
            someFloat4 = 1_3.0_1
            someFloat5 = 1_3.0_1

            [first-Table .    second . "adsf"]
            subKey="subValue"

            [first-Table .    second]
            secondEntry = true

            [first-Table]
            firstEntry = true

            [first-Table] # error
            firstEntry2 = false

            [mixedValues] # error value already exists
            oops = "oops"

            [[firstArrayOfTables]]
            someValue1 = "1"

            [[firstArrayOfTables]]
            someValue2 = "2"

            [[first-Table.someArray]]
            val1 = "z"

            [[first-Table.someArray]]
            val2 = "y"

            [multiline-literal]
            single = '''some text'''
            lines2 = '''line 1
                        line2'''

            [multilinetests]
         """ +
           "
            single = \"\"\"some text\"\"\"
            lines2 = \"\"\"line1
                        line2\"\"\" \
            ");

    if (is TomlTable result) {
        print(result);
    }
    else {
        printAll {
            separator = "\n";
            result.errors.map((e) => "error: ``e``");
        };
        print("\n``result.errors.size`` errors\n");
        print(result.partialResult);
    }
}
