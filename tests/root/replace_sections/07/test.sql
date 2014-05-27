SELECT 
  replace_sections('quick %%%%%brown%%%%% fox jumps over a %%%%%dog%%%%%', '<<', '>>', 'hen') 
    = 'quick %%%%%brown%%%%% fox jumps over a %%%%%dog%%%%%';