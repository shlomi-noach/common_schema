--
--
--

delimiter //

drop procedure if exists _expect_nothing //

create procedure _expect_nothing(
   in   id_from      int unsigned,
   in   id_to      int unsigned
) 
comment 'Expect nothing or whitespace only'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare consumed_to_id int unsigned;
  declare token_has_matched tinyint unsigned;

  call _skip_spaces(id_from, id_to);
  if id_from > id_to then
    -- Nothing more here, all is well
    leave main_body;
  end if;
  -- Still stuff here: we only allow the statement delimiter:
  call _consume_if_exists(id_from, id_to, consumed_to_id, NULL, 'statement delimiter|start', token_has_matched, @_common_schema_dummy);
  if not token_has_matched then
    call _throw_script_error(id_from, 'Nothing more expected');
  end if;
end;
//

delimiter ;
