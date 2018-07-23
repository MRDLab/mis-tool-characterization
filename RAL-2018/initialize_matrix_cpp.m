function str = initialize_matrix_cpp(Array,suffix,var_type,str)
ArrayName = (inputname(1));
str=sprintf('%s    %s %s%s [%d][%d] =\n    {\n',str,var_type,ArrayName,suffix,size(Array,1),size(Array,2));
for ii=1:size(Array,1)
    str=sprintf('%s        {',str);
    for jj=1:size(Array,2)
        str=sprintf('%s%.17g',str,Array(ii,jj));
        if jj<size(Array,2)
            str=sprintf('%s,\t',str);
        end
    end
    str=sprintf('%s}',str);
    if ii<size(Array,1)
        str=sprintf('%s,',str);
    end
    str=sprintf('%s\n',str);
end
str=sprintf('%s    };\n',str);