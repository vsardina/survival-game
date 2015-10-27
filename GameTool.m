function varargout = GameTool(varargin)
% GAMETOOL MATLAB code for GameTool.fig
%      GAMETOOL, by itself, creates a new GAMETOOL or raises the existing
%      singleton*.
%
%      H = GAMETOOL returns the handle to a new GAMETOOL or the handle to
%      the existing singleton*.
%
%      GAMETOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMETOOL.M with the given input arguments.
%
%      GAMETOOL('Property','Value',...) creates a new GAMETOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GameTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GameTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GameTool

% Last Modified by GUIDE v2.5 21-Apr-2015 14:33:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GameTool_OpeningFcn, ...
    'gui_OutputFcn',  @GameTool_OutputFcn, ...
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


% --- Executes just before GameTool is made visible.
function GameTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GameTool (see VARARGIN)
SetParameters(handles)
set(0,'RecursionLimit',5000) % Allows many loops to run uninterrupted
 
handles.text3.Visible='off'; % Hides number of simulation text, human play is default
handles.SimText.Visible='off';
axis (handles.HBar,'off') % Hides unneeded axes until game starts
axis (handles.ProgressAxes,'off')

rng('shuffle') % Shuffles random number generator

stop=0; % Allows games to run, stop when 'stop' is true
save('stopdata','stop')

% Load opener
axis(handles.PlotAxes, [-50,-40,-50,-40]); % Away from rest of game, avoids overlap
axis(handles.PlotAxes,'off')
opening = imread('Opener.jpg');
openerImage = image('CData', opening,'Parent',handles.PlotAxes);
openerImage.XData = [-50,-40];
openerImage.YData = [-40,-50];
% Choose default command line output for GameTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GameTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GameTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function TimeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlayerPopUp.
function PlayerPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to PlayerPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlayerPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlayerPopUp
if handles.PlayerPopUp.Value==2
    handles.text3.Visible='on'; % Visible when computer mode
    handles.SimText.Visible='on';
elseif handles.PlayerPopUp.Value==1
    handles.text3.Visible='off'; % Invisible when human mode
    handles.SimText.Visible='off';
end

% --- Executes during object creation, after setting all properties.
function PlayerPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlayerPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DifficultyPopUp.
function DifficultyPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to DifficultyPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DifficultyPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DifficultyPopUp
handles.FebButton.Value=0;
handles.ShoesButton.Value=0;
handles.MedButton.Value=0;
handles.GeigerButton.Value=0;


% --- Executes during object creation, after setting all properties.
function DifficultyPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DifficultyPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GeigerButton.
function GeigerButton_Callback(hObject, eventdata, handles)
% hObject    handle to GeigerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GeigerButton
if handles.DifficultyPopUp.Value==1 % Resets items if too many selected
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>2
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
elseif handles.DifficultyPopUp.Value==2
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>1
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
end



% --- Executes on button press in MedButton.
function MedButton_Callback(hObject, eventdata, handles)
% hObject    handle to MedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MedButton
if handles.DifficultyPopUp.Value==1 % Resets items if too many selected
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>2
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
elseif handles.DifficultyPopUp.Value==2
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>1
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
end

% --- Executes on button press in FebButton.
function FebButton_Callback(hObject, eventdata, handles)
% hObject    handle to FebButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FebButton
if handles.DifficultyPopUp.Value==1 % Resets items if too many selected
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>2
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
elseif handles.DifficultyPopUp.Value==2
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>1
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
end

% --- Executes on button press in ShoesButton.
function ShoesButton_Callback(hObject, eventdata, handles)
% hObject    handle to ShoesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShoesButton
if handles.DifficultyPopUp.Value==1 % Resets items if too many selected
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>2
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
elseif handles.DifficultyPopUp.Value==2
    if handles.FebButton.Value+handles.ShoesButton.Value+handles.MedButton.Value+...
            handles.GeigerButton.Value>1
        handles.FebButton.Value=0;
        handles.ShoesButton.Value=0;
        handles.MedButton.Value=0;
        handles.GeigerButton.Value=0;
    end
end

function SimText_Callback(hObject, eventdata, handles)
% hObject    handle to SimText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SimText as text
%        str2double(get(hObject,'String')) returns contents of SimText as a double

% --- Executes during object creation, after setting all properties.
function SimText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SimText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoButton.
function GoButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% HumanPlayF(hObject,eventdata,handles)
ClearGame % Deletes workspace files
stop=0;
save('stopdata','stop')
handles.statPanel.Visible='off';
handles.GoButton.Value=1; % Allows button to be pressed again to restart
handles.EndButton.Value=0; % Turns end button off
handles.HText.String='0%'; % Initializes before game starts
handles.TimeText.String=0;
if handles.GoButton.Value==1 && handles.PlayerPopUp.Value == 2
    human=0;
    save('humanchoice','human')
    ComputerSimulationF(handles)
elseif handles.GoButton.Value==1 && handles.PlayerPopUp.Value == 1
    handles.StatPanel.Visible='off';
    human=1;
    save('humanchoice','human')
    SetParameters(handles)
    HumanPlayF(hObject,eventdata,handles)
end

% --- Executes on button press in EndButton.
function EndButton_Callback(hObject, eventdata, handles)
% hObject    handle to EndButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.EndButton.Value=1;
stop=1; % Loaded in HumanPlayF.m and ComputerSimulationF.m, stops game
save('stopdata','stop')
handles.GoButton.Value=0;

% --- Executes on button press in GraphicCheck.
function GraphicCheck_Callback(hObject, eventdata, handles)
% hObject    handle to GraphicCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GraphicCheck\
if handles.GraphicCheck.Value
    graphics=1;
else
    graphics=0;
end
save('graphics','graphics')


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
load('alivedata')
load('stopdata')
if ~stop && alive
    load('timedata')
    t=t+Z;
    save('timedata','t','Z')
    DirectionInputF(hObject, eventdata, handles)
    while true
        load('alivedata')
        load('stopdata')
        if stop || ~alive
            handles.TimeText.Visible='off';
            break
        end
        HumanPlayF(hObject,eventdata,handles)
        load('timedata')
        t=t+Z;
        if stop || ~alive
            handles.TimeText.Visible='off';
            break
        end
        handles.TimeText.String=['Time: ',num2str(round(t,2))];
        pause(.01)
        save('timedata','t','Z')
    end
end

handles.GoButton.Value=0; % Prepares for next game
healthBar=0;
bar(healthBar,'r','Parent',handles.HBar)
cla(handles.HBar)
handles.HBar.Visible='off';
handles.HText.Visible='off';
cla(handles.ProgressAxes)
axis(handles.ProgressAxes,'off')

% Sets post-game axis
axis(handles.PlotAxes, [-50,-40,-50,-40]);
handles.PlotAxes.XTick=[];
handles.PLotAxes.YTick=[];
if alive && ~handles.EndButton.Value
    win = imread('WinClose.jpg');
    winImage = image('CData', win);
    winImage.XData = [-50,-40];
    winImage.YData = [-40,-50];
elseif ~handles.EndButton.Value
    lose = imread('LoseClose.jpg');
    loseImage = image('CData', lose);
    loseImage.XData = [-50,-40];
    loseImage.YData = [-40,-50];
else
    opening = imread('Opener.jpg');
    openerImage = image('CData', opening);
    openerImage.XData = [-50,-40];
    openerImage.YData = [-40,-50];
end
