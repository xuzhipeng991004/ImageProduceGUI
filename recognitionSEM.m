function [ SEMtype ] = recognitionSEM( filePath )
%recognitionSEM函数用来识别图片的放大倍数，要用到内部的字模数据'myData'
%输入的是图片文件位置，包括图片名，包括'.tif'
%输出的是图片的放大倍数SEMtype
myData=load('myData.mat');
digitalData=myData.digitalData;
ix=myData.ix;
idot=myData.idot;
width=16;
length=26;


% filePath='D:\科研\电化学沉积\SEM图片\17_m003';                     %文件的位置，日后需要修改的位置，保存的excel文件也位于这个位置
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

flag=0;                                                               %flag表示是否有数字与之匹配
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

