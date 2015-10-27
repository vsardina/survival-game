function DirectionInputF(hObject,eventdata, handles)
% function DirectionInputF(hObject,eventdata, handles)
%   Takes keyboard inputs to determine direction

%% Set Parameters

load('parameters')
load('walldata')
load('raddata')
load('positiondata')
load('directiondata')

kbrin = eventdata.Key;

%% Determine Direction

switch kbrin
    case 'leftarrow'
        player = imread('playerL.jpg');    
        direction='left';
    case 'rightarrow'
        player = imread('playerR.jpg');
        direction='right';
    case 'uparrow'
        player = imread('playerF.jpg');
        direction='up';
    case 'downarrow'
        player = imread('playerD.jpg');
        direction='down';
    % Stops player    
    case 'space'
        direction='none';
    % Toggles graphics (graphics off runs faster and smoother)    
    case 'g'
        load('graphics')
        graphics=~graphics;
        handles.GraphicCheck.Value=~handles.GraphicCheck.Value;
        save('graphics','graphics')
end

save('directiondata','direction','player')
