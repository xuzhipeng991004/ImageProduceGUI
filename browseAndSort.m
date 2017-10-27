function [openFile,fpath,picname,allPictureName,pictureNum] =browseAndSort (openFile,path1,basetype,colortype,saveFile)
%browseAndSort����ʵ�ֵ��ǽ����ѡ���ͼƬ�����ҽ�ͼƬ��ͼƬ���������򷽱�����previous��next��ʵ��
%���ǻ���Ƿ�ף������ڷ���������ʱ����������δ��ֵ��������һ��'selectNone'�ı�־���������ķ��أ����������б��ⱨ��
    [filename, openFile]=uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp', 'All Image Files' }, 'ѡ���账���ͼƬ',  openFile);    %Ĭ�ϴ򿪵���Ҫ����ͼƬ��·��
    fpath='selectNone'; picname=''; allPictureName=''; pictureNum='';
    if isequal(filename,0) || isequal(openFile,0)                              %������ˡ�ȡ����
        return;
    else
       fpath=fullfile(openFile, filename);
        [~, picname, typename]=fileparts(fpath);                   %��ȡͼƬ������
        set(path1, 'String', picname);
    end
    
    fid=fopen([pwd,'\�ڲ��ļ�\����.txt'],'wt');                             %�����õĲ�������Ϊ�ļ�
    fprintf(fid,'%s\n',basetype);
    fprintf(fid,'%s\n',colortype);
    fprintf(fid,'%s\n',openFile);
    fprintf(fid,'%s\n',saveFile);
    fclose(fid);
    
    allPicture=dir(fullfile(openFile,['*',typename]));
    allPictureName=sortnat({allPicture(1:length(allPicture)).name});
    finger = ismember(allPictureName,filename);
    pictureNum=find(finger,1);