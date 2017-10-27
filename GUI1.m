function varargout = GUI1(varargin)
% 目前为止大部分需要的功能基本能够实现，还不能实现的功能：
% 1、打开子窗口后，父窗口的功能应给会被锁死，控制权无法移交给子窗口；
% 2、cut按钮按下时，没有办法将图片的位置指定，前提是图片的大小不变，为了更清晰；
% 3、关于dirt表示的含义，要不要再减去均值的考虑；
% 4、原本的圆拟合会使得半径变小，特别是在圆的面区趋于直线时，这种变化最明显；
% 5、关于圆和直线在连通时确定连通点数目时，用x,还是y的问题，最需要好好考虑；
% 6、将GUI转化为可执行的exe文件，并且可以在没有安装MATLAB的计算机上运行。
%  write in 5.29/2016

warning off;
gui_Singleton=1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI1_OpeningFcn, ...
    'gui_OutputFcn',  @GUI1_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback=str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}]=gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function GUI1_OpeningFcn(hObject, ~, handles, varargin)
handles.output=hObject;
set(gcf,'name','表面参数');
movegui(handles.figure1, 'east');                                          %将产生的GUI放置在屏幕最东面
ax=axes('units','pixels', 'position',[0 0 500 400],'xtick',[],'ytick',[]);
img=imread([pwd,'\内部文件\MATLAB.jpg']);                                   %pwd表示当前文件的路径
image(img);
txtposition={[55,309,40,22],[40,169,75,23],[330,304,51,22]};
txtname={'参数','图片名称','亮度'};
for i=1:length(txtname)
    frame=getframe(ax,txtposition{i});
    parameter=uicontrol('style','push','units','pix','position',txtposition{i},'string',txtname{i},'fontsize',12);
    set(parameter,'cdata',frame.cdata, 'foregroundc',[1 1 1]);
end
set(ax,'handlevisibility','off','visible','off');
global ck0; global ck1; global ck2;
ck0=0; ck1=0; ck2=0;                                                       %对于全局变量开始赋初值
guidata(hObject, handles);


function varargout=GUI1_OutputFcn(~, ~, handles)
varargout{1}=handles.output;


%------------------初始化--------------------------
function initialize_Callback(hObject, ~, handles)  
fid=fopen([pwd,'\内部文件\参数.txt'],'r');
warning off;
[handles.basetype,handles.colortype,handles.openFile,handles.saveFile]=getParameter(fid);
fclose(fid);
set(handles.displaypara,'string',[handles.basetype,'  ',handles.colortype]);

filein=fopen([pwd,'\内部文件\颜色.txt'],'r');
while ~feof(filein)
    array=regexp(fgetl(filein),'\t','split');
    if array{1}==handles.colortype
        handles.color=array{2};
        break;
    end
end
fclose(filein);

datan=now;
handles.strd=datestr(datan,29);
handles.filedir=[handles.saveFile,'\',handles.strd];                       %默认保存处理后图片及参数特性文件夹
file_exist=exist(handles.filedir,'file');
if file_exist==0
    mkdir(handles.filedir);                                                %新建与日期同名的文件夹
end
file_xls=[handles.filedir, '\', handles.strd,'.xlsx'];
title={'图片编号','RMS','sk','ku','p'};
xlswrite(file_xls, title, handles.basetype);
guidata(hObject, handles);


%------------------浏览控件----------------------
function browse_Callback(hObject, ~, handles)                              %浏览控件的作用将路径写入path1的动态文本框中
global ck0;                                                                %ck0,ck1,ck2为触发开关，用来提示用户的下一次操作的
if isempty(get(handles.displaypara,'string'))
    msgbox('初次使用您必须先初始化', '错误', 'error');
    return;
end

[handles.openFile,handles.fpath,handles.picname,handles.allPictureName,handles.pictureNum] =...
        browseAndSort (handles.openFile,handles.path1,handles.basetype,handles.colortype,handles.saveFile);     %函数实现的是浏览选择的图片和将图片名排序的操作
 if strcmp(handles.fpath,'selectNone')               %当在浏览中没选择任何内容的时候，会返回一个selectNone的标志符，这样再从函数中退出
     return;
 end
    
handles.dn=100/recognitionSEM(handles.fpath);
set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);

[handles.b,handles.screensize]=picturePreview(handles.fpath);
ck0 = 1;

guidata(hObject, handles);


%------------------二值化--------------------------
function binaryzation_Callback(hObject, ~, handles)                        
global ck0;
global ck1;
global ck2;

if ck0==0
    msgbox('您必须先指定图片路径,请选择浏览！', '错误', 'error');
    return;
end

% handles.bteq=adapthisteq(handles.b);                                           %直方图均衡化，为了增加图片的高对比度
handles.bteq=handles.b;
filter=fspecial('gaussian');
handles.bteq = imfilter(handles.bteq,filter);                                      %加上了一个滤波装置

br1=get(handles.brightness, 'string');                                     %将指定图像叠加常数，调整亮度,默认为20

if isempty(br1)
    handles.br=20;
else
    handles.br=str2double(br1);
end
I=imadd(handles.bteq, handles.br);
I0=im2bw(I);
I1=imfill(I0, 'holes');                                                    %填充二值图像中的空洞区域
handles.bw=bwperim(I1);                                                    %查找二值图像的边缘
[~,column]=size(handles.bw);
f2=figure(2);
set(f2,'NumberTitle', 'off','name','二值化', 'Position', [35,handles.screensize(4)/9,handles.screensize(3)/1.8,handles.screensize(3)/1.8*3/4]);
axis normal;
imshow(handles.bw,'initialmagnification','fit','Border','tight');
hold on;

xlist=[1,column];
for k=1:2
    [xnew,ynew,button(k)]=ginScan(1,'hand');
    if button(k)==1
        handles.xy(k,:)=round([xnew,ynew]);
    else
        handles.xy(k,:)=round([xlist(k),ynew]);
    end
    plot(handles.xy(k,1),handles.xy(k,2),'go');
    hold on;
end

if max(button)>1
    handles.noEdge=1;
    ck2=1;
else
    handles.noEdge=0;
end

ck1 = 1;
guidata(hObject, handles);


%------------------裁剪----------------------------
function cut_Callback(hObject, ~, handles)                                 
global ck1;
global ck2;
if ck1==0
    msgbox('您必须先进行二值化处理!','错误','error');
    return;
end
handles.y01=min(handles.xy(:,2));
handles.x01=min(handles.xy(:,1));
y02=max(handles.xy(:,2));
x02=max(handles.xy(:,1));
handles.B6=handles.bw(handles.y01:y02, handles.x01:x02);
f3=figure(3);
set(f3,'NumberTitle', 'off','name','裁剪图片');
imshow(handles.B6,'Border','tight');
hold on;

[col0(1),col0(2),button]=ginScan(1,'left');
if button~=1
    col0(1)=1;
else
    col0(1)=round(col0(1));
end
plot(col0(1),col0(2),'yo');
handles.col=col0(1);
ck2=1;
handles.noEdge=0;
guidata(hObject, handles);


%------------------计算并保存----------------------
function calculate_Callback(~, ~, handles)                                 
global ck2;
if  ck2==0
    msgbox('你必须先进行裁剪处理!','错误','error');
    return;
end
if handles.noEdge==1
    handles.col=1;
    handles.x01=1;
    handles.y01=min(handles.xy(:,2));
    handles.B6=handles.bw(handles.y01: max(handles.xy(:,2)), 1:end);
end
row=find(handles.B6(:,handles.col), 1);                                    %边界起始点的行
connectivity=8;                                                            %连通性为8，为后续bwtraceboundary函数定义参数
num_points=3000;                                                           %边界点的个数
contour=bwtraceboundary(handles.B6,[row,handles.col],'N',connectivity,num_points);     %边界跟踪函数
x=contour(:,2)+handles.x01;
y=contour(:,1)+handles.y01;                                                %先是行坐标，后返回的是列坐标
%     if strcmpi(handles.basetype,'直线');
%         z=x;                                                             
%     else
%         z=y;                                                             
%     end
z=x;
N=1;
while z(N)~=max(z)
    N=N+1;
end                                                                        %N表示截取的像素点的个数

x(N+1:end,:)=[];
y(N+1:end,:)=[];
f4=figure(4);                                                              %显示源图像
imshow(handles.b,'initialmagnification','fit','Border','tight');
set(f4,'NumberTitle', 'off','name','处理后图片','Position',[60,handles.screensize(4)/9,handles.screensize(3)/1.8,handles.screensize(3)/1.8*3/4]);
hold on;
plot(x,y,handles.color,'LineWidth',2);                                     %在源图像上面显示设置中颜色的边界
saveas(gcf, [handles.filedir,'\' ,handles.picname,'.tif']);                %保存显示边界的图以原来图的名称存储在日期命名的文件夹中
if strcmpi(handles.basetype,'直线');                                       %对直线利用最小二乘法拟合，并表示出图像
    b=polyfit(x,y,1);
    yy=polyval(b,x);                                                       %最小二乘法拟合的多项式值
    theta=atan(b(1))*180/pi;
    dist=(y-yy)*cos(pi*abs(theta)/180);                                    %点到拟合线的距离
else                                                                       %对左边圆弧操作，找圆心，拟合圆
    C=N*sum(x.^2)-sum(x)^2;
    D=N*x'*y-sum(x)*sum(y);
    E=N*sum(x.^3)+N*x'*y.^2-sum(x.^2+y.^2)*sum(x);
    G=N*sum(y.^2)-sum(y)^2;
    H=N*(x.^2)'*y+N*sum(y.^3)-sum(x.^2+y.^2)*sum(y);
    a=(H*D-E*G)/(C*G-D^2);
    b=(H*C-E*D)/(D^2-G*C);
    c=-(sum(x.^2+y.^2)+a*sum(x)+b*sum(y))/N;
    A=-a/2;                                                                %圆心坐标
    B=-b/2;
    R=sqrt(a^2+b^2-4*c)/2;                                                 %最小二乘圆半径
    dist=sqrt((x-A).^2+(y-B).^2)-R;                                        %dist是列向量
end

dist=dist*handles.dn;                                                      %利用SEM的放大比例，换算为实际的尺寸(单位:nm)
ra=sum(dist)/N;
RMS=sqrt(sum(dist.^2)/N);                                                  %分别计算的是均值、标准差、偏斜度、峰度,这种计算与工具包里的计算不一样，意思dist中已经将均值减掉了
z1=dist.^3;
z2=dist.^4;
sk=sum(z1(:,1))/(N*((RMS)^3));
ku=sum(z2(:,1))/(N*((RMS)^4));

c=xcorr(dist','coeff');                                                    %自相关函数plot，coeff为0延时的正规化序列的自相关计算
d=N:1:2*N-1;                                                               %取一半，长度由C决定
e=c(d);
x=0:1:N-1;
x=x*handles.dn;
f=@(p,x)exp(-x/p);
p=lsqcurvefit(f,1,x,e);

tlines=[RMS,sk,ku,p];                                                      %最终输出的参数
t_cell=mat2cell(tlines, ones(1,1), ones(4,1));                             %将data切割成m*n的cell矩阵
picnamestr={handles.picname};
result1=[picnamestr,t_cell];
file_xls=[handles.filedir,'\',handles.strd,'.xlsx'];
[~, ~, raw] = xlsread(file_xls,handles.basetype);
[rowN, ~]=size(raw);
xlsRange=['A',num2str(rowN+1)];
xlswrite(file_xls,result1,handles.basetype,xlsRange);                      %将指定输出的参数保存到excel表格中

hWaitbar=waitbar(0,'请等待...','Name','数据保存中','WindowStyle','modal');  %用一个进度条作为延时5秒，防止提前复位导致存储的数据丢失
for i=1:100
    waitbar(i/100,hWaitbar,['已完成',num2str(i),'%']);
    pause(0.03);
end
delete(hWaitbar);
clear hWaitbar;


%------------------复位-------------------------
function reset_Callback(~, ~, handles)
set(handles.brightness,'String','');
set(handles.SEM,'String','');
close(setdiff(findobj('menubar','figure','-or','menubar','none'),gcf))
global ck0; global ck1; global ck2;
ck0=0; ck1=0; ck2=0;                                                       %将所有的全局变量设为初值0
clc;


%------------------设置------------------------
function Setting_Callback(~, ~, ~)
Setting;
set(0,'currentfigure',Setting);


%------------------查看------------------------
function Check_Callback(~, ~, handles)
if isempty(get(handles.displaypara,'string'))
    msgbox('初次使用您必须先初始化', '错误', 'error');
    return;
end
winopen(handles.filedir);


%------------------帮助------------------------
function Help_Callback(~, ~, ~)
winopen([pwd,'\内部文件\帮助.txt']);


%------------------关于------------------------
function About_Callback(~, ~, ~)
screensize=get(0,'screensize');
h=dialog('Name','关于','Position',[(screensize(3)-200)/2 (screensize(4)-120)/2 200 120]);
uicontrol('Style','text','Units','pixels','Position',[35 55 130 40],'FontSize',10,'Parent',h,'String',' 欢迎使用GUI 由Xuzhipeng编写');
uicontrol('Units','pixels','Position',[80 20 50 20],'FontSize',10,'Parent',h,'String','确定','Callback','delete(gcf)');
uiwait(h);


%------------------退出------------------------
function Exit_Callback(hObject,eventdata,handles)
figure1_CloseRequestFcn(hObject,eventdata,handles);


%------------------关闭------------------------
function figure1_CloseRequestFcn(hObject,eventdata,handles)
if  isequal(questdlg('确定退出吗?','退出:','是','否', '是'), '是')
   reset_Callback(hObject,eventdata,handles);
   closereq;
end




%------------------显示前一张图片------------------------
function previous_Callback(hObject, eventdata, handles)
global ck0;
if ck0==0
    msgbox('您必须先指定图片路径,请选择浏览！', '错误', 'error');
    return;
end

reset_Callback(hObject,eventdata,handles);
handles=guidata(hObject);
if (handles.pictureNum>1)
    handles.pictureNum=handles.pictureNum-1;
    filename=handles.allPictureName{handles.pictureNum};
    handles.fpath=fullfile(handles.openFile, filename);
    [~, handles.picname,~]=fileparts(handles.fpath); 
    set(handles.path1, 'String', handles.picname);
    
    handles.dn=100/recognitionSEM(handles.fpath);
    set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);
    
    [handles.b,handles.screensize]=picturePreview(handles.fpath);
    ck0 = 1;
else
    if  isequal(questdlg('已经是第一张，打开新的文件夹？','友情提示','确定','取消', '确定'), '确定')
        [handles.openFile,handles.fpath,handles.picname,handles.allPictureName,handles.pictureNum] =...
            browseAndSort (handles.openFile,handles.path1,handles.basetype,handles.colortype,handles.saveFile);    %函数实现的是浏览选择的图片和将图片名排序的操作
        
        if strcmp(handles.fpath,'selectNone')               %当在浏览中没选择任何内容的时候，会返回一个selectNone的标志符，这样再从函数中退出
            return;
        end
        
        handles.dn=100/recognitionSEM(handles.fpath);
        set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);
        
        [handles.b,handles.screensize]=picturePreview(handles.fpath);
        ck0 = 1;
    end
end
guidata(hObject,handles);


%------------------显示后一张图片------------------------
function next_Callback(hObject, eventdata, handles)
global ck0;
if ck0==0
    msgbox('您必须先指定图片路径,请选择浏览！', '错误', 'error');
    return;
end

reset_Callback(hObject,eventdata,handles);
handles=guidata(hObject);
if (handles.pictureNum<length(handles.allPictureName))
    handles.pictureNum=handles.pictureNum+1;
    filename=handles.allPictureName{handles.pictureNum};
    handles.fpath=fullfile(handles.openFile, filename);
    [~, handles.picname,~]=fileparts(handles.fpath); 
    set(handles.path1, 'String', handles.picname);
    
    handles.dn=100/recognitionSEM(handles.fpath);
    set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);
    
    [handles.b,handles.screensize]=picturePreview(handles.fpath);
    ck0 = 1;
else
    if  isequal(questdlg('已经是最后一张，打开新的文件夹？','友情提示','确定','取消', '确定'), '确定')
        [handles.openFile,handles.fpath,handles.picname,handles.allPictureName,handles.pictureNum] =...
            browseAndSort (handles.openFile,handles.path1,handles.basetype,handles.colortype,handles.saveFile);    %函数实现的是浏览选择的图片和将图片名排序的操作
        
        if strcmp(handles.fpath,'selectNone')               %当在浏览中没选择任何内容的时候，会返回一个selectNone的标志符，这样再从函数中退出
            return;
        end
        
        handles.dn=100/recognitionSEM(handles.fpath);
        set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);
        
        [handles.b,handles.screensize]=picturePreview(handles.fpath);
        ck0 = 1;
    end
end
guidata(hObject,handles);
