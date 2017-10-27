function [basetype,colortype,openFile,saveFile] = getParameter(fid)
%getParaqmeter函数主要是为了从打开的文件夹中得到参数列表中的多参数
i=1;                                                                      
nonblank=cell(4);
while ~feof(fid)
    linestr=fgetl(fid);
    if(strcmpi(linestr,'')||strcmpi(linestr,' '))
        continue;
    else
        nonblank{i}=strtrim(linestr);
        i=i+1;
    end
end
basetype=nonblank{1};
colortype=nonblank{2};
openFile=nonblank{3};
saveFile=nonblank{4};