--
--
--

delimiter //

drop procedure if exists _skip_spaces //

create procedure _skip_spaces(
   inout   id_from      int unsigned,
   in   id_to      int unsigned
)
comment 'Skips whitespace tokens'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare first_state text;
  
    statement_loop: while id_from <= id_to do
      SELECT state FROM _sql_tokens WHERE id = id_from INTO first_state;
      case
        when first_state in ('whitespace', 'single line comment', 'multi line comment', 'start') then begin
	        -- Ignore whitespace
	        set id_from := id_from + 1;
	        iterate statement_loop;
	      end;
	    else leave statement_loop;
	  end case;
	end while;
end;
//

delimiter ;
