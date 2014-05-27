SELECT 
  replace_sections('quick [brown] fox [jumps] over', '[', ']', '<\\0>') 
    = 'quick <brown> fox <jumps> over';