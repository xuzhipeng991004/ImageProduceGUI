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
set(gcf,'name','设置');
set(hObject,'Units','pixels');
figuresize=get(hObject,'Position');
screensize=get(0,'screensize');
set(gcf,'position',[(screensize(3)-figuresize(3))/3,(screensize(4)-figuresize(4))/2,figuresize(3),figuresize(4)]);

fid=fopen([pwd,'\内部文件\参数.txt'],'r');
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
if strcmpi(handles.basetype,'直线')
    numtype=1;
else
    numtype=2;
end
set(handles.baseType,'value',numtype);

handles.color=strtrim(nonblank{2});
filein=fopen([pwd,'\内部文件\颜色.txt'],'r');
colortype=1;
while ~feof(filein)
    array=regexp(fgetl(filein), '\t', 'split');                            %以Tab（制表符）将字符串进行分开，并将匹配的分辨率的比例转化为数据类型
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


%------------------基底类型----------------------
function baseType_Callback(hObject, ~, handles)
contents = cellstr(get(hObject, 'String'));                                %获取所有的基底类型列表
handles.basetype=contents{get(hObject, 'Value')};                          %取出所选择的那一个
guidata(hObject, handles);


% ------------------颜色------------------------
function backColor_Callback(hObject, ~, handles)
contents = cellstr(get(hObject, 'String'));                                %现获取所有的颜色类型列表
handles.color = contents{get(hObject, 'Value')};                           %取出所选择的那一个
guidata(hObject, handles);


%------------------打开文件----------------------
function browseOpen_Callback(hObject, ~, handles)
filePath = uigetdir('D:\','选择打开的路径');
if isequal(filePath,0)                                                     %如果点了“取消”
    return;
else
    set(handles.openFile, 'String', filePath);
end
guidata(hObject, handles);


%------------------保存文件----------------------
function browseSave_Callback(hObject, ~, handles)
filePath = uigetdir('D:\','选择保存的路径');
if isequal(filePath,0)                                                     %如果点了“取消”
    return;
else
    set(handles.saveFile, 'String', filePath);
end
guidata(hObject, handles);


%------------------确定----------------------
function determine_Callback(~, ~, handles)
if isempty(get(handles.saveFile,'string')) || isempty(get(handles.openFile,'string'))
    msgbox('您必须先设置文件路径', '错误', 'error');
else
    fid=fopen([pwd,'\内部文件\参数.txt'],'wt');                             %将设置的参数保存为文件，便于GUI1调用
    str={handles.basetype,handles.color,strtrim(get(handles.openFile,'string')),strtrim(get(handles.saveFile,'string'))};
    for i=1:length(str)
        fprintf(fid,'%s\n',str{i});
    end
    fclose(fid);
    delete(gcf);
end
