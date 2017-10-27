function [openFile,fpath,picname,allPictureName,pictureNum] =browseAndSort (openFile,path1,basetype,colortype,saveFile)
%browseAndSort函数实现的是将浏览选择的图片，并且将图片的图片名进行排序方便后面的previous和next的实现
%考虑还是欠妥，程序在非正常返回时，其他变量未赋值，利用了一个'selectNone'的标志进非正常的返回，在主程序中避免报错
    [filename, openFile]=uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp', 'All Image Files' }, '选择需处理的图片',  openFile);    %默认打开的需要处理图片的路径
    fpath='selectNone'; picname=''; allPictureName=''; pictureNum='';
    if isequal(filename,0) || isequal(openFile,0)                              %如果点了“取消”
        return;
    else
       fpath=fullfile(openFile, filename);
        [~, picname, typename]=fileparts(fpath);                   %获取图片的名字
        set(path1, 'String', picname);
    end
    
    fid=fopen([pwd,'\内部文件\参数.txt'],'wt');                             %将设置的参数保存为文件
    fprintf(fid,'%s\n',basetype);
    fprintf(fid,'%s\n',colortype);
    fprintf(fid,'%s\n',openFile);
    fprintf(fid,'%s\n',saveFile);
    fclose(fid);
    
    allPicture=dir(fullfile(openFile,['*',typename]));
    allPictureName=sortnat({allPicture(1:length(allPicture)).name});
    finger = ismember(allPictureName,filename);
    pictureNum=find(finger,1);