-- 
-- Accepts input text and delimiter characters, and retokenizes text such that:
-- - original delimiters replaced with new delimiter
-- - new delimiter is known to be non-existent in original text
-- - quoted text is not tokenized (quoting characters are given)
--
-- The function:
-- - returns a retokenized text
-- - sets the @common_schema_retokenized_delimiter to the new delimiter
-- - sets the @common_schema_retokenized_count to number of tokens
-- variable to note the new delimiter.
-- Tokenizing result text by this delimiter is safe, and no further tests for quotes are required.
--
-- Paramaters:
-- - input_text: original text to be retokenized
-- - delimiters: one or more characters tokenizing the original text
-- - quoting characters: characters to be considered as quoters: this function will ignore
--   delimiters found within quoted text
-- - trim_tokens: A boolean. If TRUE, this function will trim white spaces from tokens
-- - empty_tokens_behavior: 
--   - if 'allow', empty tokens are returned. 
--   - if 'skip', empty tokens are silently discarded. 
--   - if 'error', empty tokens result with the function returning NULL 
--

DELIMITER $$

DROP FUNCTION IF EXISTS _retokenized_text $$
CREATE FUNCTION _retokenized_text(
  input_text TEXT CHARSET utf8, 
  delimiters VARCHAR(16) CHARSET utf8, 
  quoting_characters VARCHAR(16) CHARSET utf8,
  trim_tokens BOOL,
  empty_tokens_behavior enum('allow', 'skip', 'error')
) RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Retokenizes input_text with special token'

begin
  declare current_pos INT UNSIGNED DEFAULT 1;
  declare token_start_pos INT UNSIGNED DEFAULT 1;
  declare terminating_quote_found BOOL DEFAULT FALSE;
  declare terminating_quote_pos INT UNSIGNED DEFAULT 0;
  declare terminating_quote_escape_char CHAR(1) CHARSET utf8;
  declare current_char VARCHAR(1) CHARSET utf8;
  declare quoting_char VARCHAR(1) CHARSET utf8;
  declare current_token TEXT CHARSET utf8 DEFAULT '';
  declare result_text TEXT CHARSET utf8 DEFAULT '';
  declare delimiter_template VARCHAR(64) CHARSET ascii DEFAULT '\0[\n}\b+-\t|%&{])/\r~:;&"%`@>?=<_common_schema_unlikely_token_';
  declare internal_delimiter_length TINYINT UNSIGNED DEFAULT 0;
  declare internal_delimiter VARCHAR(64) CHARSET utf8 DEFAULT '';
  
  -- Resetting result delimiter; In case of error we want this to be an indicator
  set @common_schema_retokenized_delimiter := NULL;
  set @common_schema_retokenized_count := NULL;

  -- Detect a prefix of delimiter_template which can serve as a delimiter in the retokenized text,
  -- i.e. find a shortest delimiter which does not appear in the input text at all (hence can serve as
  -- a strictly tokenizing text, regardless of quotes)
  _evaluate_internal_delimiter_loop: while internal_delimiter_length < CHAR_LENGTH(delimiter_template) do
  	set internal_delimiter_length := internal_delimiter_length + 1;
  	set internal_delimiter := LEFT(delimiter_template, internal_delimiter_length);
  	if LOCATE(internal_delimiter, input_text) = 0 then
  	  leave _evaluate_internal_delimiter_loop;
  	end if;
  end while;

  while current_pos <= CHAR_LENGTH(input_text) + 1 do
    if current_pos = CHAR_LENGTH(input_text) + 1 then
      -- make sure a delimiter "exists" at the end of input_text, so as to gracefully parse
      -- the last token in list.
      set current_char := LEFT(delimiters, 1);
    else
      set current_char := SUBSTRING(input_text, current_pos, 1);
    end if;
    if LOCATE(current_char, quoting_characters) > 0 then
      -- going into string state: search for terminating quote.
      set quoting_char := current_char;
      set terminating_quote_found := false;
      while not terminating_quote_found do
        set terminating_quote_pos := LOCATE(quoting_char, input_text, current_pos + 1);
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
          set terminating_quote_escape_char := SUBSTRING(input_text, terminating_quote_pos - 1, 1);
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
    elseif LOCATE(current_char, delimiters) > 0 then
      -- Found a delimiter (outside of quotes).
      set current_token := SUBSTRING(input_text, token_start_pos, current_pos - token_start_pos);
      if trim_tokens then
        set current_token := trim_wspace(current_token);
      end if;
      -- What of this token?
      if ((CHAR_LENGTH(current_token) = 0) and (empty_tokens_behavior = 'error')) then
        -- select `ERROR: _retokenized_text(): found empty token` FROM DUAL INTO @common_schema_error;
        return NULL;
      end if;
      if ((CHAR_LENGTH(current_token) > 0) or (empty_tokens_behavior = 'allow')) then
        -- Replace with internal token:
        if CHAR_LENGTH(result_text) > 0 then
          set result_text := CONCAT(result_text, internal_delimiter);
        end if;
        -- Finally, we note down the token:
        set result_text := CONCAT(result_text, current_token);
        set @common_schema_retokenized_count := 1 + IFNULL(@common_schema_retokenized_count, 0);
      end if;
      set token_start_pos := current_pos + 1;
    end if;
    set current_pos := current_pos + 1;
  end while;
  -- Unfortunately we cannot return two values from a function. One goes as
  -- user defined variable.
  -- @common_schema_retokenized_delimiter must be checked by calling code so
  -- as to determine how to further split text.
  set @common_schema_retokenized_delimiter := internal_delimiter;
  return result_text;
end $$

DELIMITER ;
