function [ header_str, function_str, test_str ] = generate_nn_cpp( net, suffix, var_type, x_test )
%  Convert NN to real-time runnable C code
%  This function is only programmed to work with a narrow subset of NN 
%  objects. If you want to do more complicated NN's you will either have to
%  extend this function, or switch to an automated Matlab->C++ tool.
%
%  This script should be able to function without the Neural Network 
%  Toolbox.
%
%  The code generated only needs iostream for the test function, if you
%  want to avoid the test function you can remove the iostream include.
% 
%  For NN's of the size ~30 nodes, this should execute very fast and not
%  need optimization, but note that this code is designed to be simple, not
%  fast.

if (~exist('cpp', 'dir')); mkdir('cpp'); end%if

IW=net.IW{1};
LW=net.LW{2};
b1=net.b{1};
b2=net.b{2};
out_size=size(LW,1);
if(net.numLayers>2)
    LW2=net.LW{3,2};
    b3=net.b{3};
    out_size=size(LW2,1);
end

xrange=net.inputs{1}.range;
yrange=net.outputs{end,end}.range;

%%# manually simulate network
%# map input to [-1,1] range
P=(xrange(:,2)-xrange(:,1));
Q=(xrange(:,2)+xrange(:,1));
R=(yrange(:,2)-yrange(:,1));
S=(yrange(:,2)+yrange(:,1));

header_str=sprintf('#include <iostream>\n#include <math.h>\n\n');
header_str=initialize_matrix_cpp(IW,suffix,var_type,header_str);
header_str=initialize_matrix_cpp(LW,suffix,var_type,header_str);
if(net.numLayers>2)
    header_str=initialize_matrix_cpp(LW2,suffix,var_type,header_str);
end
header_str=initialize_array_cpp(b1,suffix,var_type,header_str);
header_str=initialize_array_cpp(b2,suffix,var_type,header_str);
if(net.numLayers>2)
    header_str=initialize_array_cpp(b3,suffix,var_type,header_str);
end
header_str=initialize_array_cpp(P,suffix,var_type,header_str);
header_str=initialize_array_cpp(Q,suffix,var_type,header_str);
header_str=initialize_array_cpp(R,suffix,var_type,header_str);
header_str=initialize_array_cpp(S,suffix,var_type,header_str);

function_str=sprintf('void neural_net%s(%s x[%d],%s out[%d]){\n',suffix,var_type,size(IW,2),var_type,out_size);

function_str=sprintf('%s    %s in[%d];\n',function_str,var_type,size(IW,2));
function_str=sprintf('%s    for(int ii=0;ii<%d;ii++){\n',function_str,size(IW,2));
function_str=sprintf('%s        in[ii] = (x[ii] * 2.0 - Q%s[ii] ) / P%s[ii];\n',function_str,suffix,suffix);
function_str=sprintf('%s    }\n',function_str);
function_str=sprintf('%s    %s hid[%d];\n',function_str,var_type,size(IW,1));
function_str=sprintf('%s    for(int jj=0;jj<%d;jj++){\n',function_str,size(IW,1));
function_str=sprintf('%s        hid[jj]=b1%s[jj];\n',function_str,suffix);
function_str=sprintf('%s        for(int ii=0;ii<%d;ii++){\n',function_str,size(IW,2));
function_str=sprintf('%s            hid[jj]=hid[jj]+IW%s[jj][ii] * in[ii];\n',function_str,suffix);
function_str=sprintf('%s        }\n',function_str);
if(strcmp(net.layers{1}.transferFcn,'tansig'))
    function_str=sprintf('%s        hid[jj] = (2.0 / (1.0 + exp(-2.0 * hid[jj])) - 1.0);\n',function_str);
elseif(strcmp(net.layers{1}.transferFcn,'logsig'))
    function_str=sprintf('%s        hid[jj] = (1.0 / (1.0 + exp(-hid[jj])));\n',function_str);
end
function_str=sprintf('%s    }\n',function_str);

%str=sprintf('%s    %s out[%d];\n',str,var_type,size(LW,1));

if(net.numLayers>2)
    function_str=sprintf('%s    %s hid2[%d];\n',function_str,var_type,size(LW,1));
    function_str=sprintf('%s    for(int jj=0;jj<%d;jj++){\n',function_str,size(LW,1));
    function_str=sprintf('%s        hid2[jj]=b2%s[jj];\n',function_str,suffix);
    function_str=sprintf('%s        for(int ii=0;ii<%d;ii++){\n',function_str,size(LW,2));
    function_str=sprintf('%s            hid2[jj] += LW%s[jj][ii] * hid[ii];\n',function_str,suffix);
    function_str=sprintf('%s        }\n',function_str);
    if(strcmp(net.layers{2}.transferFcn,'tansig'))
        function_str=sprintf('%s        hid2[jj] = (2.0 / (1.0 + exp(-2.0*(hid2[jj]))) - 1.0);\n',function_str);
    elseif(strcmp(net.layers{2}.transferFcn,'logsig'))
        function_str=sprintf('%s        hid2[jj] = (1.0 / (1.0 + exp(-hid2[jj])));\n',function_str);
    end
    function_str=sprintf('%s    }\n',function_str);
    
    function_str=sprintf('%s    for(int ii=0;ii<%d;ii++){\n',function_str,size(LW2,1));
    function_str=sprintf('%s        out[ii] = b3%s[ii];\n',function_str,suffix);
    function_str=sprintf('%s        for(int jj=0;jj<%d;jj++){\n',function_str,size(LW2,2));
    function_str=sprintf('%s            out[ii] += LW2%s[ii][jj] * hid2[jj];\n',function_str,suffix);
    function_str=sprintf('%s        }\n',function_str);
    function_str=sprintf('%s    }\n',function_str);
else
    function_str=sprintf('%s    for(int ii=0;ii<%d;ii++){\n',function_str,size(LW,1));
    function_str=sprintf('%s        out[ii] = b2%s[ii];\n',function_str,suffix);
    function_str=sprintf('%s        for(int jj=0;jj<%d;jj++){\n',function_str,size(LW,2));
    function_str=sprintf('%s            out[ii] += LW%s[ii][jj] * hid[jj];\n',function_str,suffix);
    function_str=sprintf('%s        }\n',function_str);
    function_str=sprintf('%s    }\n',function_str);
end


function_str=sprintf('%s    for(int ii=0;ii<%d;ii++){\n',function_str,out_size);
if(strcmp(net.layers{end}.transferFcn,'tansig'))
    function_str=sprintf('%s        out[ii] = (2.0 / (1.0 + exp(-2.0*(out[ii]))) - 1.0);\n',function_str);
elseif(strcmp(net.layers{end}.transferFcn,'logsig'))
    function_str=sprintf('%s        out[ii] = (1.0 / (1.0 + exp(-out[ii])));\n',function_str);
end
function_str=sprintf('%s        out[ii] = out[ii] * R%s[ii] / 2.0 + S%s[ii] / 2.0;',function_str,suffix,suffix);
function_str=sprintf('%s    }\n',function_str);
function_str=sprintf('%s}\n',function_str);



% If we have actual test data, use that
if nargin<4
    % Otherwise choose a random vector.
    % Warning! This will possibly be out of sample, since it doesn't take
    % ranges into account! This will still check our maths though.
    x_test=rand(size(IW,2),1);
end
if exist('trainNetwork')>0
    % We have the neural net toolbox, so we can use it
    y_correct=net(x_test);
else
    y_correct=sim_net_manual(net,x_test);
end

test_str=sprintf('%s test_neural_net%s(void){\n',var_type,suffix);
test_str=initialize_array_cpp(x_test,suffix,var_type,test_str);
test_str=initialize_array_cpp(y_correct,suffix,var_type,test_str);
test_str=sprintf('%s    %s error_sum%s=0.0;\n',test_str,var_type,suffix);
test_str=sprintf('%s    %s y_test%s[%d];\n',test_str,var_type,suffix,size(y_correct,1));
test_str=sprintf('%s    neural_net%s(x_test%s,y_test%s);\n',test_str,suffix,suffix,suffix);
test_str=sprintf('%s    for(int ii=0;ii<%d;ii++){\n',test_str,size(y_correct,1));
test_str=sprintf('%s        error_sum%s += fabs( y_correct%s[ii] - y_test%s[ii] );\n',test_str,suffix,suffix,suffix);
            
test_str=sprintf('%s        std::cout << y_correct%s[ii] << ",   " << y_test%s[ii] << ",   " << y_correct%s[ii] - y_test%s[ii] << std::endl;\n',test_str,suffix,suffix,suffix,suffix);
test_str=sprintf('%s    }\n',test_str);
test_str=sprintf('%s    std::cout << "Error Sum = " << error_sum%s << std::endl;\n',test_str,suffix);
test_str=sprintf('%s    return error_sum%s;\n',test_str,suffix);
test_str=sprintf('%s}\n',test_str);

filename=sprintf('cpp/nn%s.h',suffix);
fh=fopen(filename,'w');
fprintf(fh,'%s\n\n%s\n\n%s\n',header_str,function_str,test_str);

end

