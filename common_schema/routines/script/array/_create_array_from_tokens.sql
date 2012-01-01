--
--

delimiter //

drop procedure if exists _create_array_from_tokens //

create procedure _create_array_from_tokens(
   in   tokens text charset utf8,
   in   delimiter text charset utf8,
   out  array_id VARCHAR(16) charset ascii
) 
comment 'Creates a populated array, returning its ID'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  
  declare num_tokens int unsigned;
  declare token_index int unsigned default 1;

  call _create_array(array_id);
  set num_tokens := get_num_tokens(tokens, delimiter);
  while token_index <= num_tokens do
    call _push_array_element(array_id, split_token(tokens, delimiter, token_index));
    set token_index := token_index + 1;
  end while;
end;
//

delimiter ;
