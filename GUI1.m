function varargout = GUI1(varargin)
% ĿǰΪֹ�󲿷���Ҫ�Ĺ��ܻ����ܹ�ʵ�֣�������ʵ�ֵĹ��ܣ�
% 1�����Ӵ��ں󣬸����ڵĹ���Ӧ���ᱻ����������Ȩ�޷��ƽ����Ӵ��ڣ�
% 2��cut��ť����ʱ��û�а취��ͼƬ��λ��ָ����ǰ����ͼƬ�Ĵ�С���䣬Ϊ�˸�������
% 3������dirt��ʾ�ĺ��壬Ҫ��Ҫ�ټ�ȥ��ֵ�Ŀ��ǣ�
% 4��ԭ����Բ��ϻ�ʹ�ð뾶��С���ر�����Բ����������ֱ��ʱ�����ֱ仯�����ԣ�
% 5������Բ��ֱ������ͨʱȷ����ͨ����Ŀʱ����x,����y�����⣬����Ҫ�úÿ��ǣ�
% 6����GUIת��Ϊ��ִ�е�exe�ļ������ҿ�����û�а�װMATLAB�ļ���������С�
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
set(gcf,'name','�������');
movegui(handles.figure1, 'east');                                          %��������GUI��������Ļ���
ax=axes('units','pixels', 'position',[0 0 500 400],'xtick',[],'ytick',[]);
img=imread([pwd,'\�ڲ��ļ�\MATLAB.jpg']);                                   %pwd��ʾ��ǰ�ļ���·��
image(img);
txtposition={[55,309,40,22],[40,169,75,23],[330,304,51,22]};
txtname={'����','ͼƬ����','����'};
for i=1:length(txtname)
    frame=getframe(ax,txtposition{i});
    parameter=uicontrol('style','push','units','pix','position',txtposition{i},'string',txtname{i},'fontsize',12);
    set(parameter,'cdata',frame.cdata, 'foregroundc',[1 1 1]);
end
set(ax,'handlevisibility','off','visible','off');
global ck0; global ck1; global ck2;
ck0=0; ck1=0; ck2=0;                                                       %����ȫ�ֱ�����ʼ����ֵ
guidata(hObject, handles);


function varargout=GUI1_OutputFcn(~, ~, handles)
varargout{1}=handles.output;


%------------------��ʼ��--------------------------
function initialize_Callback(hObject, ~, handles)  
fid=fopen([pwd,'\�ڲ��ļ�\����.txt'],'r');
warning off;
[handles.basetype,handles.colortype,handles.openFile,handles.saveFile]=getParameter(fid);
fclose(fid);
set(handles.displaypara,'string',[handles.basetype,'  ',handles.colortype]);

filein=fopen([pwd,'\�ڲ��ļ�\��ɫ.txt'],'r');
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
handles.filedir=[handles.saveFile,'\',handles.strd];                       %Ĭ�ϱ��洦���ͼƬ�����������ļ���
file_exist=exist(handles.filedir,'file');
if file_exist==0
    mkdir(handles.filedir);                                                %�½�������ͬ�����ļ���
end
file_xls=[handles.filedir, '\', handles.strd,'.xlsx'];
title={'ͼƬ���','RMS','sk','ku','p'};
xlswrite(file_xls, title, handles.basetype);
guidata(hObject, handles);


%------------------����ؼ�----------------------
function browse_Callback(hObject, ~, handles)                              %����ؼ������ý�·��д��path1�Ķ�̬�ı�����
global ck0;                                                                %ck0,ck1,ck2Ϊ�������أ�������ʾ�û�����һ�β�����
if isempty(get(handles.displaypara,'string'))
    msgbox('����ʹ���������ȳ�ʼ��', '����', 'error');
    return;
end

[handles.openFile,handles.fpath,handles.picname,handles.allPictureName,handles.pictureNum] =...
        browseAndSort (handles.openFile,handles.path1,handles.basetype,handles.colortype,handles.saveFile);     %����ʵ�ֵ������ѡ���ͼƬ�ͽ�ͼƬ������Ĳ���
 if strcmp(handles.fpath,'selectNone')               %���������ûѡ���κ����ݵ�ʱ�򣬻᷵��һ��selectNone�ı�־���������ٴӺ������˳�
     return;
 end
    
handles.dn=100/recognitionSEM(handles.fpath);
set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);

[handles.b,handles.screensize]=picturePreview(handles.fpath);
ck0 = 1;

guidata(hObject, handles);


%------------------��ֵ��--------------------------
function binaryzation_Callback(hObject, ~, handles)                        
global ck0;
global ck1;
global ck2;

if ck0==0
    msgbox('��������ָ��ͼƬ·��,��ѡ�������', '����', 'error');
    return;
end

% handles.bteq=adapthisteq(handles.b);                                           %ֱ��ͼ���⻯��Ϊ������ͼƬ�ĸ߶Աȶ�
handles.bteq=handles.b;
filter=fspecial('gaussian');
handles.bteq = imfilter(handles.bteq,filter);                                      %������һ���˲�װ��

br1=get(handles.brightness, 'string');                                     %��ָ��ͼ����ӳ�������������,Ĭ��Ϊ20

if isempty(br1)
    handles.br=20;
else
    handles.br=str2double(br1);
end
I=imadd(handles.bteq, handles.br);
I0=im2bw(I);
I1=imfill(I0, 'holes');                                                    %����ֵͼ���еĿն�����
handles.bw=bwperim(I1);                                                    %���Ҷ�ֵͼ��ı�Ե
[~,column]=size(handles.bw);
f2=figure(2);
set(f2,'NumberTitle', 'off','name','��ֵ��', 'Position', [35,handles.screensize(4)/9,handles.screensize(3)/1.8,handles.screensize(3)/1.8*3/4]);
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


%------------------�ü�----------------------------
function cut_Callback(hObject, ~, handles)                                 
global ck1;
global ck2;
if ck1==0
    msgbox('�������Ƚ��ж�ֵ������!','����','error');
    return;
end
handles.y01=min(handles.xy(:,2));
handles.x01=min(handles.xy(:,1));
y02=max(handles.xy(:,2));
x02=max(handles.xy(:,1));
handles.B6=handles.bw(handles.y01:y02, handles.x01:x02);
f3=figure(3);
set(f3,'NumberTitle', 'off','name','�ü�ͼƬ');
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


%------------------���㲢����----------------------
function calculate_Callback(~, ~, handles)                                 
global ck2;
if  ck2==0
    msgbox('������Ƚ��вü�����!','����','error');
    return;
end
if handles.noEdge==1
    handles.col=1;
    handles.x01=1;
    handles.y01=min(handles.xy(:,2));
    handles.B6=handles.bw(handles.y01: max(handles.xy(:,2)), 1:end);
end
row=find(handles.B6(:,handles.col), 1);                                    %�߽���ʼ�����
connectivity=8;                                                            %��ͨ��Ϊ8��Ϊ����bwtraceboundary�����������
num_points=3000;                                                           %�߽��ĸ���
contour=bwtraceboundary(handles.B6,[row,handles.col],'N',connectivity,num_points);     %�߽���ٺ���
x=contour(:,2)+handles.x01;
y=contour(:,1)+handles.y01;                                                %���������꣬�󷵻ص���������
%     if strcmpi(handles.basetype,'ֱ��');
%         z=x;                                                             
%     else
%         z=y;                                                             
%     end
z=x;
N=1;
while z(N)~=max(z)
    N=N+1;
end                                                                        %N��ʾ��ȡ�����ص�ĸ���

x(N+1:end,:)=[];
y(N+1:end,:)=[];
f4=figure(4);                                                              %��ʾԴͼ��
imshow(handles.b,'initialmagnification','fit','Border','tight');
set(f4,'NumberTitle', 'off','name','�����ͼƬ','Position',[60,handles.screensize(4)/9,handles.screensize(3)/1.8,handles.screensize(3)/1.8*3/4]);
hold on;
plot(x,y,handles.color,'LineWidth',2);                                     %��Դͼ��������ʾ��������ɫ�ı߽�
saveas(gcf, [handles.filedir,'\' ,handles.picname,'.tif']);                %������ʾ�߽��ͼ��ԭ��ͼ�����ƴ洢�������������ļ�����
if strcmpi(handles.basetype,'ֱ��');                                       %��ֱ��������С���˷���ϣ�����ʾ��ͼ��
    b=polyfit(x,y,1);
    yy=polyval(b,x);                                                       %��С���˷���ϵĶ���ʽֵ
    theta=atan(b(1))*180/pi;
    dist=(y-yy)*cos(pi*abs(theta)/180);                                    %�㵽����ߵľ���
else                                                                       %�����Բ����������Բ�ģ����Բ
    C=N*sum(x.^2)-sum(x)^2;
    D=N*x'*y-sum(x)*sum(y);
    E=N*sum(x.^3)+N*x'*y.^2-sum(x.^2+y.^2)*sum(x);
    G=N*sum(y.^2)-sum(y)^2;
    H=N*(x.^2)'*y+N*sum(y.^3)-sum(x.^2+y.^2)*sum(y);
    a=(H*D-E*G)/(C*G-D^2);
    b=(H*C-E*D)/(D^2-G*C);
    c=-(sum(x.^2+y.^2)+a*sum(x)+b*sum(y))/N;
    A=-a/2;                                                                %Բ������
    B=-b/2;
    R=sqrt(a^2+b^2-4*c)/2;                                                 %��С����Բ�뾶
    dist=sqrt((x-A).^2+(y-B).^2)-R;                                        %dist��������
end

dist=dist*handles.dn;                                                      %����SEM�ķŴ����������Ϊʵ�ʵĳߴ�(��λ:nm)
ra=sum(dist)/N;
RMS=sqrt(sum(dist.^2)/N);                                                  %�ֱ������Ǿ�ֵ����׼�ƫб�ȡ����,���ּ����빤�߰���ļ��㲻һ������˼dist���Ѿ�����ֵ������
z1=dist.^3;
z2=dist.^4;
sk=sum(z1(:,1))/(N*((RMS)^3));
ku=sum(z2(:,1))/(N*((RMS)^4));

c=xcorr(dist','coeff');                                                    %����غ���plot��coeffΪ0��ʱ�����滯���е�����ؼ���
d=N:1:2*N-1;                                                               %ȡһ�룬������C����
e=c(d);
x=0:1:N-1;
x=x*handles.dn;
f=@(p,x)exp(-x/p);
p=lsqcurvefit(f,1,x,e);

tlines=[RMS,sk,ku,p];                                                      %��������Ĳ���
t_cell=mat2cell(tlines, ones(1,1), ones(4,1));                             %��data�и��m*n��cell����
picnamestr={handles.picname};
result1=[picnamestr,t_cell];
file_xls=[handles.filedir,'\',handles.strd,'.xlsx'];
[~, ~, raw] = xlsread(file_xls,handles.basetype);
[rowN, ~]=size(raw);
xlsRange=['A',num2str(rowN+1)];
xlswrite(file_xls,result1,handles.basetype,xlsRange);                      %��ָ������Ĳ������浽excel�����

hWaitbar=waitbar(0,'��ȴ�...','Name','���ݱ�����','WindowStyle','modal');  %��һ����������Ϊ��ʱ5�룬��ֹ��ǰ��λ���´洢�����ݶ�ʧ
for i=1:100
    waitbar(i/100,hWaitbar,['�����',num2str(i),'%']);
    pause(0.03);
end
delete(hWaitbar);
clear hWaitbar;


%------------------��λ-------------------------
function reset_Callback(~, ~, handles)
set(handles.brightness,'String','');
set(handles.SEM,'String','');
close(setdiff(findobj('menubar','figure','-or','menubar','none'),gcf))
global ck0; global ck1; global ck2;
ck0=0; ck1=0; ck2=0;                                                       %�����е�ȫ�ֱ�����Ϊ��ֵ0
clc;


%------------------����------------------------
function Setting_Callback(~, ~, ~)
Setting;
set(0,'currentfigure',Setting);


%------------------�鿴------------------------
function Check_Callback(~, ~, handles)
if isempty(get(handles.displaypara,'string'))
    msgbox('����ʹ���������ȳ�ʼ��', '����', 'error');
    return;
end
winopen(handles.filedir);


%------------------����------------------------
function Help_Callback(~, ~, ~)
winopen([pwd,'\�ڲ��ļ�\����.txt']);


%------------------����------------------------
function About_Callback(~, ~, ~)
screensize=get(0,'screensize');
h=dialog('Name','����','Position',[(screensize(3)-200)/2 (screensize(4)-120)/2 200 120]);
uicontrol('Style','text','Units','pixels','Position',[35 55 130 40],'FontSize',10,'Parent',h,'String',' ��ӭʹ��GUI ��Xuzhipeng��д');
uicontrol('Units','pixels','Position',[80 20 50 20],'FontSize',10,'Parent',h,'String','ȷ��','Callback','delete(gcf)');
uiwait(h);


%------------------�˳�------------------------
function Exit_Callback(hObject,eventdata,handles)
figure1_CloseRequestFcn(hObject,eventdata,handles);


%------------------�ر�------------------------
function figure1_CloseRequestFcn(hObject,eventdata,handles)
if  isequal(questdlg('ȷ���˳���?','�˳�:','��','��', '��'), '��')
   reset_Callback(hObject,eventdata,handles);
   closereq;
end




%------------------��ʾǰһ��ͼƬ------------------------
function previous_Callback(hObject, eventdata, handles)
global ck0;
if ck0==0
    msgbox('��������ָ��ͼƬ·��,��ѡ�������', '����', 'error');
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
    if  isequal(questdlg('�Ѿ��ǵ�һ�ţ����µ��ļ��У�','������ʾ','ȷ��','ȡ��', 'ȷ��'), 'ȷ��')
        [handles.openFile,handles.fpath,handles.picname,handles.allPictureName,handles.pictureNum] =...
            browseAndSort (handles.openFile,handles.path1,handles.basetype,handles.colortype,handles.saveFile);    %����ʵ�ֵ������ѡ���ͼƬ�ͽ�ͼƬ������Ĳ���
        
        if strcmp(handles.fpath,'selectNone')               %���������ûѡ���κ����ݵ�ʱ�򣬻᷵��һ��selectNone�ı�־���������ٴӺ������˳�
            return;
        end
        
        handles.dn=100/recognitionSEM(handles.fpath);
        set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);
        
        [handles.b,handles.screensize]=picturePreview(handles.fpath);
        ck0 = 1;
    end
end
guidata(hObject,handles);


%------------------��ʾ��һ��ͼƬ------------------------
function next_Callback(hObject, eventdata, handles)
global ck0;
if ck0==0
    msgbox('��������ָ��ͼƬ·��,��ѡ�������', '����', 'error');
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
    if  isequal(questdlg('�Ѿ������һ�ţ����µ��ļ��У�','������ʾ','ȷ��','ȡ��', 'ȷ��'), 'ȷ��')
        [handles.openFile,handles.fpath,handles.picname,handles.allPictureName,handles.pictureNum] =...
            browseAndSort (handles.openFile,handles.path1,handles.basetype,handles.colortype,handles.saveFile);    %����ʵ�ֵ������ѡ���ͼƬ�ͽ�ͼƬ������Ĳ���
        
        if strcmp(handles.fpath,'selectNone')               %���������ûѡ���κ����ݵ�ʱ�򣬻᷵��һ��selectNone�ı�־���������ٴӺ������˳�
            return;
        end
        
        handles.dn=100/recognitionSEM(handles.fpath);
        set(handles.SEM, 'String', [num2str(recognitionSEM(handles.fpath)),'K']);
        
        [handles.b,handles.screensize]=picturePreview(handles.fpath);
        ck0 = 1;
    end
end
guidata(hObject,handles);
