USE test_cs;
drop table if exists json_data;
create table json_data (
  id tinyint unsigned PRIMARY KEY,
  json_text text charset utf8
);

insert into json_data values (1, '
{
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
            "is_public": true,
            "year_published": 2012,
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
					"Acronym": "SGML",
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "XML"]
                    },
					"GlossSee": "markup"
                }
            }
        }
    }
}
');
insert into json_data values (2, '
{
  "menu": {
    "id": "file",
    "value": "File",
    "popup": {
      "menuitem": [
        {"value": "New", "onclick": "CreateNewDoc()"},
        {"value": "Open", "onclick": "OpenDoc()"},
        {"value": "Close", "onclick": "CloseDoc()"}
      ]
    }
  }
}
');
