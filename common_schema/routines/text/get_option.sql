-- 
-- 
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS get_option $$
CREATE FUNCTION get_option(options TEXT CHARSET utf8, key_name VARCHAR(255) CHARSET utf8) 
  RETURNS TEXT CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return value of option in JS options format'

begin
  declare options_delimiter VARCHAR(64) CHARSET ascii DEFAULT NULL;
  declare num_options INT UNSIGNED DEFAULT 0;
  declare options_counter INT UNSIGNED DEFAULT 0;
  declare current_option TEXT CHARSET utf8 DEFAULT ''; 
  declare current_option_delimiter VARCHAR(64) CHARSET ascii DEFAULT NULL;
  declare current_key TEXT CHARSET utf8 DEFAULT ''; 
  declare current_value TEXT CHARSET utf8 DEFAULT ''; 
  
  set options := trim_wspace(options);
  if not options RLIKE '^{.*}$' then
    return NULL;
  end if;
  -- parse options into key:value pairs
  set options := _retokenized_text(unwrap(options), ',', '\'"`', TRUE, 'error');
  set options_delimiter := @common_schema_retokenized_delimiter;
  
  set key_name := unquote(key_name);
  
  set num_options := get_num_tokens(options, options_delimiter);
  set options_counter := 1;
  while options_counter <= num_options do
    -- per option, parse key:value pair into key, value
    set current_option := split_token(options, options_delimiter, options_counter);
    set current_option = _retokenized_text(current_option, ':', '\'"`', TRUE, 'error');

    set current_option_delimiter := @common_schema_retokenized_delimiter;
    if (get_num_tokens(current_option, current_option_delimiter) != 2) then
      return NULL;
    end if;
    set current_key := split_token(current_option, current_option_delimiter, 1);
    set current_key := unquote(current_key);
    if current_key = key_name then
      set current_value := split_token(current_option, current_option_delimiter, 2);
      if current_value = 'NULL' then
        return NULL;
      end if;
      set current_value := unquote(current_value);
      return current_value;
    end if;
    set options_counter := options_counter + 1;
  end while;    
  return NULL;
end $$

DELIMITER ;
