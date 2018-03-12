function varargout = Exec(varargin)
% EXEC MATLAB code for Exec.fig
%      EXEC, by itself, creates a new EXEC or raises the existing
%      singleton*.
%
%      H = EXEC returns the handle to a new EXEC or the handle to
%      the existing singleton*.
%
%      EXEC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXEC.M with the given input arguments.
%
%      EXEC('Property','Value',...) creates a new EXEC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Exec_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Exec_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Exec

% Last Modified by GUIDE v2.5 19-Jan-2013 07:49:27

% Begin initialization code - DO NOT EDIT


%Guide main function starts from here

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Exec_OpeningFcn, ...
                   'gui_OutputFcn',  @Exec_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before Exec is made visible.
function Exec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Exec (see VARARGIN)

% Choose default command line output for Exec
handles.output = hObject;
handles.obj = videoinput('winvideo', 1,'RGB24_640x480');
set(handles.obj, 'SelectedSourceName', 'input1')
handles.obj.ReturnedColorspace='grayscale';
src_obj = getselectedsource(handles.obj);
get(src_obj)
preview(handles.obj);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Exec wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Exec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.frame = getsnapshot(handles.obj);
handles.frame = imresize(handles.frame,[640 NaN]);
%handles.frame = imresize(im2bw(handles.frame),[640 NaN]);
axes(handles.axes1);
imshow(handles.frame);
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
name = get(handles.edit1,'String');
name = char(strcat(name,'.pgm'));
imwrite(handles.frame,'testavtar.pgm');
%[num, im3] = match(name,'testavtar.pgm');

[im1, des1, loc1] = sift(name);
[im2, des2, loc2] = sift('testavtar.pgm');
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end
im3 = appendimages(im1,im2);

num = sum(match > 0);


% Show a figure with lines joining the accepted matches.
axes(handles.axes1);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
for i = 1: size(des1,1)
  if (match(i) > 0)
    line([loc1(i,2) loc2(match(i),2)+cols1],[loc1(i,1) loc2(match(i),1)], 'Color', 'c');
  end
end
hold off;
[m,n]=size(im3);
z1=0;z2=0;z3=0;z4=0;

for i = 1: size(des1,1)
if (match(i) >0)
    if loc2(match(i),1)< m/2 && loc1(i,1)< n/2
        z1=z1+1;
    end
    if loc2(match(i),1)< m/2 && loc1(i,1)> n/2
        z2=z2+1;
    end
    if loc2(match(i),1)> m/2 && loc1(i,1)< n/2
        z3=z3+1;
    end
    if loc2(match(i),1)> m/2 && loc1(i,1)> n/2
        z4=z4+1;
    end
end
end


% for ii = 1:length(loc2)
%     point = loc2(ii,1:2);
%     if point(2)<m/2 && point(1) < n/2
%     z1=z1+1;
%     end
%     if point(2)<m/2 && point(1) > n/2
%     z3=z3+1;
%     end
%     if point(2)>m/2 && point(1) < n/2
%     z2=z2+1;
%     end
%     if point(2)>m/2 && point(1) > n/2
%     z4=z4+1;
%     end
% end

z1
z2
z3
z4

[~,pos] = max([z1 z2 z3 z4]);
if pos == 1
       disp('zone1');
   zonar=' one';
   end
      
if pos == 2
    disp('zone2');
    zonar=' two';
end
if pos == 3
    disp('zone3');
    zonar=' three';
end
if pos == 4
    disp('zone4');
    zonar=' four';
end

if z1==0 && z2==0 && z3==0 && z4==0
    disp('zone 0');
    zonar=' none';
    tts('object is not present in the image');
end
speech= get(handles.edit1,'String');
speech = char(strcat(speech,' is located in zone'));
speech = char(strcat(speech,zonar));
speech
tts(speech);
guidata(hObject, handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.obj);
