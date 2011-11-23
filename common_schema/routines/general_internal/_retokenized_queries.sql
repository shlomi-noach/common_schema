-- 
-- Assume the given text is a list of queries, seperated by semicolons. This function replaces
-- semicolons with internal tokens, exteremely unlikely to appear in a normal text.
-- The function recognizes semicolons which may appear within quoted text, and ignores them.
--

DELIMITER $$

DROP FUNCTION IF EXISTS _retokenized_queries $$
CREATE FUNCTION _retokenized_queries(queries TEXT CHARSET utf8) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Retokenizes input queries with special token'

begin
  declare current_pos INT UNSIGNED DEFAULT 1;
  declare query_start_pos INT UNSIGNED DEFAULT 1;
  declare terminating_quote_found BOOL DEFAULT FALSE;
  declare terminating_quote_pos INT UNSIGNED DEFAULT 0;
  declare terminating_quote_escape_char CHAR(1) CHARSET utf8;
  declare current_char CHAR(1) CHARSET utf8;
  declare quoting_char CHAR(1) CHARSET utf8;
  declare no_ansi_quotes BOOL DEFAULT find_in_set('ANSI_QUOTES', @@sql_mode) = FALSE;
  declare retokenized_query TEXT CHARSET utf8 DEFAULT '';
  declare internal_token VARCHAR(32) CHARSET utf8 DEFAULT '[\0_cs_::;::\0]';

  while current_pos <= CHAR_LENGTH(queries) + 1 do
    if current_pos = CHAR_LENGTH(queries) + 1 then
      -- make sure a semicolon exists at the end of queries, so as to gracefully parse
      -- the last query in list.
      set current_char := ';';
    else
      set current_char := SUBSTRING(queries, current_pos, 1);
    end if;
    if current_char = '''' or (no_ansi_quotes and current_char = '"') or current_char = '`' then
      -- going into string state: search for terminating quote.
      set quoting_char := current_char;
      set terminating_quote_found := false;
      while not terminating_quote_found do
        set terminating_quote_pos := LOCATE(quoting_char, queries, current_pos + 1);
        if terminating_quote_pos = 0 then
          -- This is an error: non-terminated string!
          return NULL;
        end if;
        if terminating_quote_pos = current_pos + 1 then
          -- an empty text
          set terminating_quote_found := true;
        else
          -- We've gone some distance to find a possible terminating character. Is it really teminating,
          -- or is it escaped?
          set terminating_quote_escape_char := SUBSTRING(queries, terminating_quote_pos - 1, 1);
          if (terminating_quote_escape_char = quoting_char) or (terminating_quote_escape_char = '\\') then
            -- This isn't really a quote end: the quote is escaped. 
            -- We do nothing; just a trivial assignment.
            set terminating_quote_found := false;        
          else
            set terminating_quote_found := true;            
          end if;
        end if;
        set current_pos := terminating_quote_pos;
      end while;
    elseif current_char = ';' then
      -- This is a query teminating text!
      -- Replace with internal token:
      if CHAR_LENGTH(retokenized_query) > 0 then
        set retokenized_query := CONCAT(retokenized_query, internal_token);
      end if;
      set retokenized_query := CONCAT(retokenized_query, SUBSTRING(queries, query_start_pos, current_pos - query_start_pos));
      set query_start_pos := current_pos + 1;
    end if;
    set current_pos := current_pos + 1;
  end while;
  return retokenized_query;
end $$

DELIMITER ;
