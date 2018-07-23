function str = initialize_var_cpp(var,suffix,var_type,str)
VarName = (inputname(1));
str=sprintf('%s    %s %s%s = %.17g\n',str,var_type,VarName,suffix,var);