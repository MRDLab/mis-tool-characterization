function [ ] = SaveNNArray( NN )
% Save a series of Neural Net objects to .mat files

nn_folder=['Neural_Nets/'];
for ii=1:size(NN,1)
    for depVar=1:size(NN,2)
        for jj=1:size(NN,3)
            if ~isempty(NN{ii,depVar,jj})
                NN_Out=NN{ii,depVar,jj};
                save([nn_folder 'Paper2_NN_' num2str(ii) '_' num2str(depVar) '_' num2str(jj) '.mat'],'NN_Out');
            end
        end
    end
end

end

