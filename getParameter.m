function [basetype,colortype,openFile,saveFile] = getParameter(fid)
%getParaqmeter������Ҫ��Ϊ�˴Ӵ򿪵��ļ����еõ������б��еĶ����
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