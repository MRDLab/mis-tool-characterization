function [ Table ] = compileMetrics( Table, allAbsolute_err, out_test, percentile, rownum, depVar, BoxPlotN, Spearman_RHO, Pearson_R )
%compileMetrics Take dataset and store metrics in table format
%   Store in Table data struct

rmse=sqrt(mean(allAbsolute_err.^2));
allAbsolute_err=abs(allAbsolute_err);
Table{depVar}.AbsoluteError(rownum) =mean(allAbsolute_err);
Table{depVar}.stdAbsError(rownum)   =std(allAbsolute_err);
Table{depVar}.PctAbsError(rownum)   =prctile(allAbsolute_err,percentile);
Table{depVar}.RMSError(rownum)      =rmse;
Table{depVar}.Range(rownum)         =range(out_test);
Table{depVar}.Average(rownum)       =mean(out_test);
Table{depVar}.BoxPlotN(rownum)      =BoxPlotN;
Table{depVar}.Spearman_RHO(rownum)  =Spearman_RHO;
Table{depVar}.Pearson_R(rownum)     =Pearson_R;

end

