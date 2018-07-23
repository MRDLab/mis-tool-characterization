function str = initialize_array_cpp(Array,suffix,var_type,str)
ArrayName = (inputname(1));
str=sprintf('%s    %s %s%s [%d] = {',str,var_type,ArrayName,suffix,length(Array));
for ii=1:length(Array)
    str=sprintf('%s%.17g',str,Array(ii));
    if ii<length(Array)
        str=sprintf('%s,\t',str);
    end
end
str=sprintf('%s};\n',str);