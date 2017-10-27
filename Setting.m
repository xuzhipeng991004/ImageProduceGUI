function varargout = Setting(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Setting_OpeningFcn, ...
    'gui_OutputFcn',  @Setting_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function Setting_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
set(gcf,'name','����');
set(hObject,'Units','pixels');
figuresize=get(hObject,'Position');
screensize=get(0,'screensize');
set(gcf,'position',[(screensize(3)-figuresize(3))/3,(screensize(4)-figuresize(4))/2,figuresize(3),figuresize(4)]);

fid=fopen([pwd,'\�ڲ��ļ�\����.txt'],'r');
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
fclose(fid);

handles.basetype=strtrim(nonblank{1});
if strcmpi(handles.basetype,'ֱ��')
    numtype=1;
else
    numtype=2;
end
set(handles.baseType,'value',numtype);

handles.color=strtrim(nonblank{2});
filein=fopen([pwd,'\�ڲ��ļ�\��ɫ.txt'],'r');
colortype=1;
while ~feof(filein)
    array=regexp(fgetl(filein), '\t', 'split');                            %��Tab���Ʊ�������ַ������зֿ�������ƥ��ķֱ��ʵı���ת��Ϊ��������
    if strcmpi(array{1},handles.color)
        break;
    else
        colortype=colortype+1;
    end
end
fclose(filein);
set(handles.backColor,'value',colortype);

set(handles.openFile,'string',nonblank{3});
set(handles.saveFile,'string',nonblank{4});

guidata(hObject, handles);


function varargout = Setting_OutputFcn(~, ~, handles)
varargout{1} = handles.output;


%------------------��������----------------------
function baseType_Callback(hObject, ~, handles)
contents = cellstr(get(hObject, 'String'));                                %��ȡ���еĻ��������б�
handles.basetype=contents{get(hObject, 'Value')};                          %ȡ����ѡ�����һ��
guidata(hObject, handles);


% ------------------��ɫ------------------------
function backColor_Callback(hObject, ~, handles)
contents = cellstr(get(hObject, 'String'));                                %�ֻ�ȡ���е���ɫ�����б�
handles.color = contents{get(hObject, 'Value')};                           %ȡ����ѡ�����һ��
guidata(hObject, handles);


%------------------���ļ�----------------------
function browseOpen_Callback(hObject, ~, handles)
filePath = uigetdir('D:\','ѡ��򿪵�·��');
if isequal(filePath,0)                                                     %������ˡ�ȡ����
    return;
else
    set(handles.openFile, 'String', filePath);
end
guidata(hObject, handles);


%------------------�����ļ�----------------------
function browseSave_Callback(hObject, ~, handles)
filePath = uigetdir('D:\','ѡ�񱣴��·��');
if isequal(filePath,0)                                                     %������ˡ�ȡ����
    return;
else
    set(handles.saveFile, 'String', filePath);
end
guidata(hObject, handles);


%------------------ȷ��----------------------
function determine_Callback(~, ~, handles)
if isempty(get(handles.saveFile,'string')) || isempty(get(handles.openFile,'string'))
    msgbox('�������������ļ�·��', '����', 'error');
else
    fid=fopen([pwd,'\�ڲ��ļ�\����.txt'],'wt');                             %�����õĲ�������Ϊ�ļ�������GUI1����
    str={handles.basetype,handles.color,strtrim(get(handles.openFile,'string')),strtrim(get(handles.saveFile,'string'))};
    for i=1:length(str)
        fprintf(fid,'%s\n',str{i});
    end
    fclose(fid);
    delete(gcf);
end
