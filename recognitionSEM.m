function [ SEMtype ] = recognitionSEM( filePath )
%recognitionSEM��������ʶ��ͼƬ�ķŴ�����Ҫ�õ��ڲ�����ģ����'myData'
%�������ͼƬ�ļ�λ�ã�����ͼƬ��������'.tif'
%�������ͼƬ�ķŴ���SEMtype
myData=load('myData.mat');
digitalData=myData.digitalData;
ix=myData.ix;
idot=myData.idot;
width=16;
length=26;


% filePath='D:\����\�绯ѧ����\SEMͼƬ\17_m003';                     %�ļ���λ�ã��պ���Ҫ�޸ĵ�λ�ã������excel�ļ�Ҳλ�����λ��
ipicture=imread(filePath);
% ipicture=im2bw(ipicture);
[m,n]=size(ipicture);
% disp(m);
% disp(n);
iipicture=zeros(m,n);
for i =1:m
    for j=1:n
        if ipicture(i,j)<255
            iipicture(i,j)=0;
        else
            iipicture(i,j)=255;
        end
    end
end

a=918;
b=397;
str='';
while 1
    ifX=iipicture(a:a+length,b:b+17);
    if ifX==ix
        b=b+17+1;
        break;
    else
        b=b+1;
    end
end

flag=0;                                                               %flag��ʾ�Ƿ���������֮ƥ��
for digitalNum=1:2
    while 1
        sample=iipicture(a:a+length,b:b+width);
        for num=1:10
            tmp=digitalData(:,:,num);
            if sample ==tmp
                str=[str,num2str(mod(num,10))];
                flag =1;
                break;
            end
        end
        if flag==1;
            break;
        else
            b=b+1;
        end
    end
    b=b+width;
    flag=0;
end
SEMtype=str2num(str);
end

