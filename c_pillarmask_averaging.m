 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % NAME:   
% %     c_pillarmask_averaging
% % PURPOSE: 
% %     A movie processing software package with a graphic user interface.
% % CATEGORY:
% %     Image processing.
% % CALLING SEQUENCE:
% %     c_pillarmask_averaging
% % INPUTS:
% %     Put in various parameters according to the intruction.
% % OUTPUS:
% %     Play a movie.
% %     Save a movie into avi format.
% %     Calculate background.
% %     Calculate sumdata.
% % COMMENTS:
% %     none.
% % HISTORY:
% %     Written by Bianxiao Cui on June 20, 2006.
% %     Modified by Bianxiao Cui on Feb. 1st to read .aisf file.
% %     Commented by Bianxiao Cui on Feb. 25, 2008.
% %     Add the second axis by Bianxiao Cui on March 2nd, 2008.
% %     Add the 2D gaussian fitting function to c_feature program by
% %     Bianxiao Cui on Nov. 25, 2008.
% %     Modified by Bianxiao Cui on July 15th, 2009
% %     Modified by Lindsey Hanson on May 24th, 2013
% %     Modified by Hsinya Lou on Augest 18th, 2016
% %     Modified by Hsinya Lou on April 1st, 2017
% %     Modified by Zhuang Yinyin on June 18th, 2018 for KRAS project
% %     Modified by Zhuang Yinyin on December 18th, 2018 for GNBs
% %     Modified by Zhuang Yinyin on May 13th, 2019 for GNB analysis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = c_pillarmask_averaging(varargin)
% C_PILLARMASK_AVERAGING M-file for c_pillarmask_averaging.fig
%      C_PILLARMASK_AVERAGING, by itself, creates a new C_PILLARMASK_AVERAGING or raises the existing
%      singleton*.
%
%      H = C_PILLARMASK_AVERAGING returns the handle to a new C_PILLARMASK_AVERAGING or the handle to
%      the existing singleton*.
%
%      C_PILLARMASK_AVERAGING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in C_PILLARMASK_AVERAGING.M with the given input arguments.
%
%      C_PILLARMASK_AVERAGING('Property','Value',...) creates a new C_PILLARMASK_AVERAGING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before c_cdf_process_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to c_pillarmask_averaging_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help c_pillarmask_averaging

% Last Modified by GUIDE v2.5 03-Mar-2018 16:27:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @c_pillarmask_averaging_OpeningFcn, ...
                   'gui_OutputFcn',  @c_pillarmask_averaging_OutputFcn, ...
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

% --- Executes just before c_pillarmask_averaging is made visible.
function c_pillarmask_averaging_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to c_pillarmask_averaging (see VARARGIN)

    axes(handles.axes1);            % make the existing axes1 the current axes.
    cla;                            % clear current axes
    set(gcf,'Units','pixels');
    [x,map]=imread('yxz.tif');
    imshow(x(:,:,:),map);


handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = c_pillarmask_averaging_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(~, ~, ~)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1

%%%%%%%%%%%%%%%%%%%%%%%%%%% OPEN FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in OpenGreen.
function OpenGreen_Callback(hObject, ~, handles)
% hObject    handle to OpenGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global movieon;
    fclose all;
   [datafile,datapath]=uigetfile('*GFP*','Choose a Green TIF movie file');

    if datafile==0, return; end
    cd(datapath);
    
    fileinfo=imfinfo(datafile);
    NumFrames=numel(fileinfo);
    imagesizex=fileinfo(1).Height;
    imagesizey=fileinfo(1).Width;
    
    Data=zeros(imagesizex,imagesizey,NumFrames);
    for k=1:NumFrames
        Data(:,:,k)=imread(datafile,k,'Info',fileinfo);
    end
    set(handles.FileName,'String',[datafile '   -   ' num2str(NumFrames) ' frames']);
    
    image_t=squeeze(Data(:,:,1));
    low=min(min(image_t));
    high=max(max(image_t));
    high=ceil(high*1.5);
    handles.ColorRange=[low high];
    set(handles.ColorSlider,'min',low);
    set(handles.ColorSlider,'max',high);
    set(handles.ColorSlider,'value',floor((low+high)/2));
    set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
    
    if NumFrames>1
        set(handles.FrameSlider,'min',1);
        set(handles.FrameSlider,'max',NumFrames);
        set(handles.FrameSlider,'value',1);
        set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
    end

    axes(handles.axes1);
    handles.image_t=image_t;
    handles.imagehandle=imshow(image_t',[low high]); %%transposed matrix when plotting
    colormap(gray);

    handles.greenfilename=datafile;
    handles.greendatapath=datapath;
    handles.imagesizex=imagesizex;
    handles.imagesizey=imagesizey;
    handles.greenNumFrames=NumFrames;
    handles.greenData=Data;
    handles.filename=handles.greenfilename;
    handles.Data=handles.greenData;
    handles.NumFrames=handles.greenNumFrames;
    handles.axrange=axis(handles.axes1);
    
    guidata(hObject,handles);
    
    movieon=0;

% --- Executes on button press in OpneRed.
function OpenRed_Callback(hObject, ~, handles)
% hObject    handle to OpneRed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global movieon;
    fclose all;
   [datafile,datapath]=uigetfile('*TXR*','Choose a Red TIF movie file');

    if datafile==0, return; end
    cd(datapath);
    
    fileinfo=imfinfo(datafile);
    NumFrames=numel(fileinfo);
    imagesizex=fileinfo(1).Height;
    imagesizey=fileinfo(1).Width;
    
    Data=zeros(imagesizex,imagesizey,NumFrames);
    for k=1:NumFrames
        Data(:,:,k)=imread(datafile,k,'Info',fileinfo);
    end
    set(handles.FileName,'String',[datafile '   -   ' num2str(NumFrames) ' frames']);
    
    image_t=squeeze(Data(:,:,1));
    low=min(min(image_t));
    high=max(max(image_t));
    high=ceil(high*1.5);
    handles.ColorRange=[low high];
    set(handles.ColorSlider,'min',low);
    set(handles.ColorSlider,'max',high);
    set(handles.ColorSlider,'value',floor((low+high)/2));
    set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
    
    if NumFrames>1
        set(handles.FrameSlider,'min',1);
        set(handles.FrameSlider,'max',NumFrames);
        set(handles.FrameSlider,'value',1);
        set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
    end

    axes(handles.axes1);
    handles.image_t=image_t;
    handles.imagehandle=imshow(image_t',[low high]); %%transposed matrix when plotting
    colormap(gray);

    handles.redfilename=datafile;
    handles.reddatapath=datapath;
    handles.imagesizex=imagesizex;
    handles.imagesizey=imagesizey;
    handles.redNumFrames=NumFrames;
    handles.redData=Data;
    handles.filename=handles.redfilename;
    handles.Data=handles.redData;
    handles.NumFrames=handles.redNumFrames;
    handles.axrange=axis(handles.axes1);
    
    guidata(hObject,handles);
    movieon=0;

% --- Executes on button press in OpenBrightfield
function OpenBrightfield_Callback(hObject, ~, handles)
% hObject    handle to Z_Projection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global movieon;

    [datafile,datapath]=uigetfile('*BF*','Choose a matching brightfield file');
    if datafile==0, return; end
    
    fileinfo=imfinfo(datafile);
    NumFrames=numel(fileinfo);
    imagesizex=fileinfo(1).Height;
    imagesizey=fileinfo(1).Width;
    
    Data=zeros(imagesizex,imagesizey,NumFrames);
    for k=1:NumFrames
        Data(:,:,k)=imread(datafile,k,'Info',fileinfo);
    end
    set(handles.FileName,'String',[datafile '   -   ' num2str(NumFrames) ' frames']);
    
    image_t=squeeze(Data(:,:,1));
    low=min(min(image_t));
    high=max(max(image_t));
    high=ceil(high*1.5);
    handles.ColorRange=[low high];
    set(handles.ColorSlider,'min',low);
    set(handles.ColorSlider,'max',high);
    set(handles.ColorSlider,'value',floor((low+high)/2));
    set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
    
    if NumFrames>1
        set(handles.FrameSlider,'min',1);
        set(handles.FrameSlider,'max',NumFrames);
        set(handles.FrameSlider,'value',1);
        set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
    end

    axes(handles.axes1);
    handles.image_t=image_t;
    handles.imagehandle=imshow(image_t',[low high]);
    colormap(gray);

    handles.brightfieldfilename=datafile;
    handles.brightfielddatapath=datapath;
    handles.imagesizex=imagesizex;
    handles.imagesizey=imagesizey;
    handles.brightfieldNumFrames=NumFrames;
    handles.brightfieldData=Data;
    handles.filename=handles.brightfieldfilename;
    handles.Data=handles.brightfieldData;
    handles.NumFrames=handles.brightfieldNumFrames;
    handles.axrange=axis(handles.axes1);
    
    guidata(hObject,handles);
    movieon=0;

function FileName_Callback(~, ~, ~)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of FileName as text
%        str2double(get(hObject,'String')) returns contents of FileName as a double

% --- Executes during object creation, after setting all properties.
function FileName_CreateFcn(hObject, ~, ~)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SelectFile.
function SelectFile_Callback(hObject, ~, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFile

val = get(hObject,'Value');
switch val
    case 2  %green channel
        handles.filename=handles.greenfilename;
        handles.Data=handles.greenData;
        handles.NumFrames=handles.greenNumFrames;
        NumFrames = handles.NumFrames;
        set(handles.FileName,'String',[handles.filename '   -   ' num2str(handles.NumFrames) ' frames']);
        image_t = handles.Data(:,:,1);
        low=min(min(image_t));
        high=max(max(image_t));
        high=ceil(high*1.5);
        handles.ColorRange=[low high];
        set(handles.ColorSlider,'min',low);
        set(handles.ColorSlider,'max',high);
        set(handles.ColorSlider,'value',floor((low+high)/2));
        set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
        set(handles.imagehandle,'CData',image_t');
        drawnow;
        if NumFrames>1
            set(handles.FrameSlider,'min',1);
            set(handles.FrameSlider,'max',NumFrames);
            set(handles.FrameSlider,'value',1);
            set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
        end
        ax=handles.axes1;
        axis(ax,handles.axrange);
        guidata(hObject,handles);
    case 3  %red channel
        handles.filename=handles.redfilename;
        handles.Data=handles.redData;
        handles.NumFrames=handles.redNumFrames;
        NumFrames = handles.NumFrames;
        set(handles.FileName,'String',[handles.filename '   -   ' num2str(handles.NumFrames) ' frames']);
        image_t = handles.Data(:,:,1);
        low=min(min(image_t));
        high=max(max(image_t));
        high=ceil(high*1.5);
        handles.ColorRange=[low high];
        set(handles.ColorSlider,'min',low);
        set(handles.ColorSlider,'max',high);
        set(handles.ColorSlider,'value',floor((low+high)/2));
        set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
        set(handles.imagehandle,'CData',image_t');
        drawnow;
        if NumFrames>1
            set(handles.FrameSlider,'min',1);
            set(handles.FrameSlider,'max',NumFrames);
            set(handles.FrameSlider,'value',1);
            set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
        end
        ax=handles.axes1;
        axis(ax,handles.axrange);
        guidata(hObject,handles);
    case 4 %Brightfield channel
        handles.filename=handles.brightfieldfilename;
        handles.Data=handles.brightfieldData;
        handles.NumFrames=handles.brightfieldNumFrames;
        NumFrames = handles.NumFrames;
        set(handles.FileName,'String',[handles.filename '   -   ' num2str(handles.NumFrames) ' frames']);
        image_t = handles.Data(:,:,1);
        low=min(min(image_t));
        high=max(max(image_t));
        high=ceil(high*1.5);
        handles.ColorRange=[low high];
        set(handles.ColorSlider,'min',low);
        set(handles.ColorSlider,'max',high);
        set(handles.ColorSlider,'value',floor((low+high)/2));
        set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
        set(handles.imagehandle,'CData',image_t');
        drawnow;
        if NumFrames>1
            set(handles.FrameSlider,'min',1);
            set(handles.FrameSlider,'max',NumFrames);
            set(handles.FrameSlider,'value',1);
            set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
        end
        ax=handles.axes1;
        axis(ax,handles.axrange);
        guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function SelectFile_CreateFcn(hObject, ~, ~)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PlayMovie.
function PlayMovie_Callback(hObject, ~, handles)
% hObject    handle to PlayMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global movieon;
    if movieon==0
        movieon=1;
        set(hObject,'String','Stop Movie');
        
        for k=1:handles.NumFrames,
            temp=handles.Data(:,:,k);
            set(handles.imagehandle,'CData',temp'); %%transposed matrix when plotting
            set(handles.DisplayText,'String',['Frame ' int2str(k)]);
            drawnow;
            if movieon==0 break; end
        end
        movieon=0;
        set(hObject,'String','Play Movie');
    elseif movieon==1
        movieon=0;
        set(hObject,'String','Play Movie');
    end
       
% --- Executes on slider movement.
function ColorSlider_Callback(~, ~, handles)
% hObject    handle to ColorSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%set(handles.axes2,'CDatamapping','scaled');
    set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
    set(handles.DisplayText,'String',{['colormap min: ' num2str(get(handles.ColorSlider,'min'))];...
            ['colormap max:' num2str(get(handles.ColorSlider,'value'))]});

% --- Executes during object creation, after setting all properties.
function ColorSlider_CreateFcn(hObject, ~, ~)
% hObject    handle to ColorSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function FrameSlider_Callback(~, ~, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
if  size(size(handles.Data), 2) == 3
    frame_no = round(get(handles.FrameSlider,'value'));
    temp = handles.Data(:,:,frame_no);
    set(handles.imagehandle,'CData',temp');
    drawnow;
    set(handles.FrameSlider,'value',frame_no);
    set(handles.DisplayText,'String',['Frame number: ' num2str(frame_no)]);
end
    
% --- Executes during object creation, after setting all properties.
function FrameSlider_CreateFcn(hObject, ~, ~)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function DisplayText_Callback(~, ~, ~)
% hObject    handle to DisplayText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of DisplayText as text
%        str2double(get(hObject,'String')) returns contents of DisplayText as a double

% --- Executes during object creation, after setting all properties.
function DisplayText_CreateFcn(hObject, ~, ~)
% hObject    handle to DisplayText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%% END of OPEN FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Mask Construction %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in SelectPoint.
function SelectPoint_Callback(hObject, ~, handles)
% hObject    handle to SelectPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    h=impixelinfo;  
    delete(h);
    
    ax=handles.axes1;
    cax=axis(ax);
    
    set(handles.DisplayText,'String','Select a point using left button');
        [xi,yi,but] = ginput(1);    %Graphical input from a mouse or cursor
        if but == 1
            pointx = round(xi);
            pointy = round(yi);
            ln = line(pointx,pointy,'marker','o','color','g',...
                'LineStyle','none');
            drawnow;
            daxX = (cax(2)-cax(1))/4/2; %%zoom in for 4 times
            daxY = (cax(4)-cax(3))/4/2; %%zoom in for 4 times
            axis(ax,[pointx+[-1 1]*daxX pointy+[-1 1]*daxY]);
        end
        
    while but ~= 3
        set(handles.DisplayText,'String',but);
        [~,~,but] = ginput(1);
        if but == 28
            delete(ln);
            pointx=pointx-1;
            ln = line(pointx,pointy,'marker','o','color','g',...
                'LineStyle','none');
            drawnow;
        elseif but == 30
            delete(ln);
            pointy=pointy-1;
            ln = line(pointx,pointy,'marker','o','color','g',...
                'LineStyle','none');
            drawnow;
        elseif but == 29
            delete(ln);
            pointx=pointx+1;
            ln = line(pointx,pointy,'marker','o','color','g',...
                'LineStyle','none');
            drawnow;
        elseif but == 31
            delete(ln);
            pointy=pointy+1;
             ln = line(pointx,pointy,'marker','o','color','g',...
                'LineStyle','none');
            drawnow;
        end
    end
    set(gcf,'Pointer','arrow'); 
    axis(ax,cax);  
    
    if isfield(handles,'nSelectedPoints')
        handles.nSelectedPoints=handles.nSelectedPoints+1;
        handles.SelectedPoints(1,handles.nSelectedPoints)=pointx;
        handles.SelectedPoints(2,handles.nSelectedPoints)=pointy;
    else
        handles.nSelectedPoints=1;
        handles.SelectedPoints(1,handles.nSelectedPoints)=pointx;
        handles.SelectedPoints(2,handles.nSelectedPoints)=pointy;
    end
    set(handles.DisplayText,'String',[num2str(handles.nSelectedPoints) ' points selected']);
    guidata(hObject,handles);

function Distance_Callback(~, ~, ~)
% hObject    handle to Distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Distance as text
%        str2double(get(hObject,'String')) returns contents of Distance as a double

% --- Executes during object creation, after setting all properties.
function Distance_CreateFcn(hObject, ~, ~)
% hObject    handle to Distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end   
   
% --- Executes on button press in ca l.
function CalMask_Callback(hObject, ~, handles)
% hObject    handle to CalMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    npoints=handles.nSelectedPoints;
    points=handles.SelectedPoints;
    set(handles.DisplayText,'String',['Selected    ',num2str(npoints),'   points']);
    switch npoints
        case 1  %only one point selected
            p1=points(:,1);
            pointx = p1(1);
            pointy = p1(2);
            MaskPoints=[pointy;pointx;1];
            handles.MaskPoints=MaskPoints;
            handles.allMaskPoints = MaskPoints;
        case 2  %two points selected
            p1=points(:,1);
            p2=points(:,2);
            dis = sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2);
            interdistance = str2double(get(handles.Distance,'String'));
            nfeatures = round(dis/interdistance);
            prompt = {'#Features in the line'}; 
            dlg_title = 'Number of repeated features';
            num_lines= 1;
            def     = {num2str(nfeatures)};
            answer  = inputdlg(prompt,dlg_title,num_lines,def); 
            NumFeatures_x = sscanf(answer{1},'%d');

            hslope=(p2(2)-p1(2))/(p2(1)-p1(1));
            hintercept=p1(2)-hslope*p1(1);
            hinterdis_x=((p2(1)-p1(1)))/NumFeatures_x;
            MaskPoints=zeros(3, NumFeatures_x+1);
            for h=1:NumFeatures_x+1
                pointx = p1(1) + hinterdis_x*(h-1);
                pointy = hslope*pointx+hintercept;
                line(pointx,pointy,'marker','o','color','w','LineStyle','none');
                MaskPoints(:,h)=[pointy;pointx;1]; %%it's important to note that x and y are transposed in the array and in display
            end
            handles.MaskPoints=MaskPoints;
            handles.allMaskPoints = MaskPoints;
            
        case 3  %3 points selected
            % it is important the the line between p1 and p2 are defined as the line direction.
            p1=points(:,1);
            p2=points(:,2);
            p3=points(:,3);
            prompt = {'#Features between 1-2 point','#Features between 2-3 points'}; 
            dlg_title = 'Number of repeated features in between points';
            num_lines= 1;
            dis12 = sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2);
            dis23 = sqrt((p3(1)-p2(1))^2+(p3(2)-p2(2))^2);
            
            interdistance = str2double(get(handles.Distance,'String'));
            
            nfeatures12 = round(dis12/interdistance);
            nfeatures23 = round(dis23/interdistance);
            def     = {num2str(nfeatures12),num2str(nfeatures23)};
            answer  = inputdlg(prompt,dlg_title,num_lines,def); 
            NumFeatures_x = sscanf(answer{1},'%d');
            NumFeatures_y = sscanf(answer{2},'%d');

            interdis =(dis12/NumFeatures_x+dis23/NumFeatures_y)/2;
            hslope=(p2(2)-p1(2))/(p2(1)-p1(1));
            hintercept=p1(2)-hslope*p1(1);
            hinterdis_x=((p2(1)-p1(1)))/NumFeatures_x;
            vslope=(p3(2)-p2(2))/(p3(1)-p2(1));
            vinterdis_y=((p3(2)-p2(2)))/NumFeatures_y;

            MaskPoints=[];
            n=0;
            
            for h=1:NumFeatures_x+1
                toppointx = p1(1) + hinterdis_x*(h-1);
                toppointy = hslope*toppointx+hintercept;
                for v=1:NumFeatures_y+1
                pointy = toppointy + vinterdis_y*(v-1);
                pointx = (pointy-toppointy)/vslope+toppointx;
                n = n+1;
                %line(pointx,pointy,'marker','o','color','w','LineStyle','none');               
                MaskPoints(:,n)=[pointy;pointx;v]; %%it's important to note that x and y are transposed in the array and in display
                end
            end
            set(handles.DisplayText,'String','Complete!');
            set(handles.Distance,'String',num2str(interdis));
            guidata(handles.Distance, num2str(interdis));
            handles.MaskPoints=MaskPoints;
            handles.allMaskPoints = MaskPoints;
            
       case 4  %4 points selected
            % it is important the the line between p1 and p2 are defined as the line direction.
            p1=points(:,1);
            p2=points(:,2);
            p3=points(:,3);
            p4=points(:,4);
            
            prompt = {'#Features between 1-2 point','#Features between 2-3 points'}; 
            dlg_title = 'Number of repeated features in between points';
            num_lines= 1;
            dis12 = sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2);
            dis23 = sqrt((p3(1)-p2(1))^2+(p3(2)-p2(2))^2);
            interdistance = str2double(get(handles.Distance,'String'));
            nfeatures12 = round(dis12/interdistance);
            nfeatures23 = round(dis23/interdistance);
            def     = {num2str(nfeatures12),num2str(nfeatures23)};
            answer  = inputdlg(prompt,dlg_title,num_lines,def); 
            NumFeatures_x = sscanf(answer{1},'%d');
            NumFeatures_y = sscanf(answer{2},'%d');
 
            interdis =(dis12/NumFeatures_x+dis23/NumFeatures_y)/2;
 
            MaskPoints=[];
            n=0;
            for h=1:NumFeatures_x+1
                toppointx = p1(1) + (h-1)*(p2(1)-p1(1))/NumFeatures_x;
                toppointy = p1(2) + (h-1)*(p2(2)-p1(2))/NumFeatures_x;
                bottompointx = p4(1) + (h-1)*(p3(1)-p4(1))/NumFeatures_x;
                bottompointy = p4(2) + (h-1)*(p3(2)-p4(2))/NumFeatures_x;
                for v=1:NumFeatures_y+1
                    leftpointx = p2(1) + (v-1)*(p3(1)-p2(1))/NumFeatures_y;
                    leftpointy = p2(2) + (v-1)*(p3(2)-p2(2))/NumFeatures_y;
                    rightpointx = p1(1) + (v-1)*(p4(1)-p1(1))/NumFeatures_y;
                    rightpointy = p1(2) + (v-1)*(p4(2)-p1(2))/NumFeatures_y;
                    
                    pointx1 = toppointx + (v-1)*(bottompointx-toppointx)/NumFeatures_y;
                    pointy1 = toppointy + (v-1)*(bottompointy-toppointy)/NumFeatures_y;
                    pointx2 = rightpointx + (h-1)*(leftpointx-rightpointx)/NumFeatures_x;
                    pointy2 = rightpointy + (h-1)*(leftpointy-rightpointy)/NumFeatures_x;
                    pointx = (pointx1+pointx2)/2;
                    pointy = (pointy1+pointy2)/2;
                    n = n+1;
                    %ln = line(pointx,pointy,'marker','o','color','w','LineStyle','none');
                    %MaskPoints(:,n)=[pointy;pointx;v]; % For img with 100nm %it's important to note that x and y are transposed in the array and in display 
                    
                    MaskPoints(:,n)=[pointy;pointx;v+2]; %it's important to note that x and y are transposed in the array and in display
                end
 
            end
%             set(handles.Distance,'String',num2str(interdis));
%             handles.MaskPoints=MaskPoints;
%             handles.Distance=interdis;
            set(handles.DisplayText,'String','Complete!');
            set(handles.Distance,'String',num2str(interdis));
            guidata(handles.Distance, num2str(interdis));
            handles.MaskPoints=MaskPoints;
            handles.allMaskPoints = MaskPoints;

            
    end   
    guidata(hObject,handles);
   
function CircleSize_Callback(~, ~, ~)
% hObject    handle to CircleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of CircleSize as text
%        str2double(get(hObject,'String')) returns contents of CircleSize as a double

% --- Executes during object creation, after setting all properties.
function CircleSize_CreateFcn(hObject, ~, ~)
% hObject    handle to CircleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RemovePoint.
function RemovePoint_Callback(hObject, ~, handles)
% hObject    handle to RemovePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.DisplayText,'String','Select a point using left button');
    [xi,yi,but] = ginput(1);    %Graphical input from a mouse or cursor
    
    if but == 1
        pointx = xi;
        pointy = yi;
    end
    
    circlesize = str2double(get(handles.CircleSize,'String'));    
    MaskPoints = handles.MaskPoints;    %%it's important to note that x and y are switched when saved into MaskPoints
    n_MaskPoints = numel(MaskPoints(1,:));
    MaskPoints_x = MaskPoints(2,:);
    MaskPoints_y = MaskPoints(1,:);

    for i=1:n_MaskPoints
        dis_ij=sqrt((MaskPoints_x(1,i)-pointx)^2+(MaskPoints_y(1,i)-pointy)^2);
            if dis_ij < circlesize/2
                RemovePoint = i;
            end
    end
    
    MaskPoints(:,RemovePoint)=[];
    handles.MaskPoints = MaskPoints;
    guidata(hObject,handles);
    
    image_t = get(handles.imagehandle,'CData');
    axes(handles.axes1);
    handles.imagehandle=imshow(image_t);
    set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
    colormap(gray);
    guidata(hObject,handles);
    MaskPoints=handles.MaskPoints;
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String'));
    for p=1:NumPoints
        line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
            'MarkerSize',circlesize,'LineWidth',circlesize/10);
    end

% --- Executes on button press in ShiftMask.
function ShiftMask_Callback(hObject, ~, handles)
% hObject    handle to ShiftMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    str = get(handles.ShiftPosition,'String'); %str is cell type.
    shift_x = str2double(char(str(1)));     %convert to char then to number
    shift_y = str2double(char(str(2)));

    MaskPoints = handles.MaskPoints;    %%it's important to note that x and y are switched when saved into MaskPoints
    n_MaskPoints = numel(MaskPoints(1,:));
    MaskPoints_x = MaskPoints(2,:);
    MaskPoints_y = MaskPoints(1,:);
    
    NewMaskPoints = MaskPoints;
    for i=1:n_MaskPoints
        NewMaskPoints(2,i)=MaskPoints_x(i)+shift_x;
        NewMaskPoints(1,i)=MaskPoints_y(i)+shift_y;
    end
    handles.MaskPoints = NewMaskPoints;
    guidata(hObject,handles);
    
    image_t = get(handles.imagehandle,'CData');
    axes(handles.axes1);
    handles.imagehandle=imshow(image_t);
    set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
    colormap(gray);
    guidata(hObject,handles);
    MaskPoints=handles.MaskPoints;
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String'));
for p=1:NumPoints
    line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
        'MarkerSize',circlesize,'LineWidth',circlesize/10);
end

function ShiftPosition_Callback(~, ~, ~)
% hObject    handle to ShiftPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ShiftPosition as text
%        str2double(get(hObject,'String')) returns contents of ShiftPosition as a double

% --- Executes during object creation, after setting all properties.
function ShiftPosition_CreateFcn(hObject, ~, ~)
% hObject    handle to ShiftPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ShowMask.
function ShowMask_Callback(~, ~, handles)
% hObject    handle to ShowMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if  handles.nSelectedPoints > 0
    MaskPoints=handles.MaskPoints;
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String'));
    for p=1:NumPoints
        line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
             'MarkerSize',circlesize,'LineWidth',circlesize/10);
    end
else
    set(handles.DisplayText,'String','No Mask!');
end

% --- Executes on button press in HideMask.
function HideMask_Callback(hObject, ~, handles)
% hObject    handle to HideMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    image_t = get(handles.imagehandle,'CData');
    axes(handles.axes1);
    handles.imagehandle=imshow(image_t);
    set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
    colormap(gray);
    guidata(hObject,handles);

% --- Executes on button press in ResetMask.
function ResetMask_Callback(hObject, ~, handles)
% hObject    handle to ResetMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.nSelectedPoints=0;
handles.SelectedPoints=[];
handles.MaskPoints=[];
handles.allMaskPoints = [];

image_t = get(handles.imagehandle,'CData');
axes(handles.axes1);
handles.imagehandle=imshow(image_t);
set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
set(handles.DisplayText,'String','Mask reset!');
colormap(gray);
    
guidata(hObject,handles);
         
% --- Executes on button press in AllMask.
function AllMask_Callback(hObject, ~, handles)
% hObject    handle to AllMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if  handles.nSelectedPoints > 0
    handles.MaskPoints = handles.allMaskPoints;
    image_t = get(handles.imagehandle,'CData');
    axes(handles.axes1);
    handles.imagehandle=imshow(image_t);
    set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
    colormap(gray);
    guidata(hObject,handles);
    MaskPoints=handles.MaskPoints;
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String'));

    for p=1:NumPoints
        line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
            'MarkerSize',circlesize,'LineWidth',circlesize/10);
    end
else
    set(handles.DisplayText,'String','No Mask!');    
end

% --- Executes on button press in SaveMask.
function SaveMask_Callback(~, ~, handles)
% hObject    handle to SaveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    NameInfo=strrep(handles.filename,'.TIF','.txt');
    [filename,pathname]=uiputfile('.txt','Save all Mask Points ',['Mask-',NameInfo]);
    cd(pathname);
    fileID = fopen(filename,'w');
    fprintf(fileID,'%d %d %d\n',uint16(handles.MaskPoints));
    fclose(fileID);
    
% --- Executes on button press in OpenMask.
function OpenMask_Callback(hObject, ~, handles)
% hObject    handle to OpenMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [filename,pathname]=uigetfile('.txt','Load Mask Points');
    cd(pathname);
    fileID = fopen(filename,'r');
    MaskPoints=fscanf(fileID,'%d %d %d', [3 inf]);
    fclose(fileID);

    NumPoints=numel(MaskPoints(1,:));
    fprintf('%d\n', NumPoints);
    circlesize = str2double(get(handles.CircleSize,'String'));
    for p=1:NumPoints
        line(MaskPoints(2,p),MaskPoints(1,p),'marker','o','color','y','LineStyle','none',...
            'MarkerSize',circlesize,'LineWidth',circlesize/10);
    end
    handles.MaskPoints=MaskPoints;
    handles.nSelectedPoints = 3;
    
    handles.allMaskPoints = MaskPoints;
    
    guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%% END of Mask Construction %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% START of Mask Modification %%%%%%%%%%%%%%%%%%%%%%%%%

function Threshhold_Callback(~, ~, ~)
% hObject    handle to Threshhold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Threshhold as text
%        str2double(get(hObject,'String')) returns contents of Threshhold as a double

% --- Executes during object creation, after setting all properties.
function Threshhold_CreateFcn(hObject, ~, ~)
% hObject    handle to Threshhold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end   

% --- Executes on button press in InsideCell.
function InsideCell_Callback(hObject, ~, handles)
% hObject    handle to InsideCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image_t = get(handles.imagehandle,'CData');

if handles.nSelectedPoints > 0    
    % use the all mask
    MaskPoints = handles.allMaskPoints;
    goodpoints=0;
    goodMaskPoints=[];
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String')); 
    halfrange = round(circlesize/2);
    Threshhold_value = str2double(get(handles.Threshhold,'String'));

    for p=1:NumPoints
        xpos = round(MaskPoints(1,p));
        ypos = round(MaskPoints(2,p));
        lineNumber = MaskPoints(3,p);
        
        if xpos>=halfrange+1 && xpos<=handles.imagesizey-halfrange && ...
           ypos>=halfrange+1 && ypos<=handles.imagesizex-halfrange 
       
            subimg = double(image_t(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
            % choose masks that are totally in the cells
            if min(subimg(:))> Threshhold_value
               goodpoints=goodpoints+1;
               goodMaskPoints(:,goodpoints)=[xpos;ypos; lineNumber];
            end
        end
    end
    
    if isempty(goodMaskPoints)
        set(handles.DisplayText,'String','No points remain! Reselect the thereshold!'); 
    else    
        handles.MaskPoints = goodMaskPoints;
    
        image_t = get(handles.imagehandle,'CData');
        axes(handles.axes1);
        handles.imagehandle=imshow(image_t);
        set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
        colormap(gray);
        guidata(hObject,handles);
        MaskPoints=goodMaskPoints;
        NumPoints=numel(MaskPoints(1,:));
        circlesize = str2double(get(handles.CircleSize,'String'));
        for p=1:NumPoints
            line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
                'MarkerSize',circlesize,'LineWidth',circlesize/10);
        end
    end
end

guidata(hObject,handles);

% --- Executes on button press in OutsideCell.
function OutsideCell_Callback(hObject, ~, handles)
% hObject    handle to OutsideCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image_t = get(handles.imagehandle,'CData');
if handles.nSelectedPoints > 0
    MaskPoints = handles.allMaskPoints;
    goodpoints=0;
    goodMaskPoints=[];
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    Threshhold_value = str2double(get(handles.Threshhold,'String'));

    for p=1:NumPoints
        xpos=round(MaskPoints(1,p));
        ypos=round(MaskPoints(2,p));
        lineNumber = MaskPoints(3,p);
        if xpos>=halfrange+1 && xpos<=handles.imagesizey-halfrange &&...
           ypos>=halfrange+1 && ypos<=handles.imagesizex-halfrange 
       
            subimg = double(image_t(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
            if min(subimg(:)) <= Threshhold_value
               goodpoints=goodpoints+1;
               goodMaskPoints(:,goodpoints)=[xpos;ypos;lineNumber];
            end
        end
    end
    
    if isempty(goodMaskPoints)
        set(handles.DisplayText,'String','No points remain! Reselect the thereshold!'); 
    else    
        handles.MaskPoints = goodMaskPoints;
    
        image_t = get(handles.imagehandle,'CData');
        axes(handles.axes1);
        handles.imagehandle=imshow(image_t);
        set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
        colormap(gray);
        guidata(hObject,handles);
        MaskPoints=goodMaskPoints;
        NumPoints=numel(MaskPoints(1,:));
        circlesize = str2double(get(handles.CircleSize,'String'));
        for p=1:NumPoints
            line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
                'MarkerSize',circlesize,'LineWidth',circlesize/10);
        end
    end
end 

guidata(hObject,handles);

function UpperThreshold_Callback(~, ~, ~)
% hObject    handle to UpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of UpperThreshold as text
%        str2double(get(hObject,'String')) returns contents of UpperThreshold as a double

% --- Executes during object creation, after setting all properties.
function UpperThreshold_CreateFcn(hObject, ~, ~)
% hObject    handle to UpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RemoveAboveThreshold.
function RemoveAboveThreshold_Callback(hObject, ~, handles)
% hObject    handle to RemoveAboveThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image_t = get(handles.imagehandle,'CData');

if handles.nSelectedPoints > 0  
    MaskPoints = handles.MaskPoints;
    goodpoints=0;
    goodMaskPoints=[];
    NumPoints=numel(MaskPoints(1,:));
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    Threshhold_value = str2double(get(handles.UpperThreshold,'String'));

    for p=1:NumPoints
        xpos=round(MaskPoints(1,p));
        ypos=round(MaskPoints(2,p));
        lineNumber = MaskPoints(3,p);
        if xpos>=halfrange+1 && xpos<=handles.imagesizey-halfrange &&...
           ypos>=halfrange+1 && ypos<=handles.imagesizex-halfrange 
            subimg = double(image_t(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
            if max(subimg(:)) < Threshhold_value
                goodpoints=goodpoints+1;
                goodMaskPoints(:,goodpoints)=[xpos;ypos;lineNumber];
            end
        end
    end
    
    if isempty(goodMaskPoints)
        set(handles.DisplayText,'String','No points remain! Reselect the thereshold!'); 
    else    
        handles.MaskPoints = goodMaskPoints;
    
        image_t = get(handles.imagehandle,'CData');
        axes(handles.axes1);
        handles.imagehandle=imshow(image_t);
        set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
        colormap(gray);
        guidata(hObject,handles);
        MaskPoints=goodMaskPoints;
        NumPoints=numel(MaskPoints(1,:));
        circlesize = str2double(get(handles.CircleSize,'String'));
        for p=1:NumPoints
            line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
                'MarkerSize',circlesize,'LineWidth',circlesize/10);
        end
    end
end

guidata(hObject,handles);

% --- Executes on button press in MaskAverage.
function MaskAverage_Callback(hObject, ~, handles)
% hObject    handle to MaskAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image_t = get(handles.imagehandle,'CData');
MaskPoints=handles.MaskPoints;
NumPoints=numel(MaskPoints(1,:));
circlesize = str2double(get(handles.CircleSize,'String'));
halfrange = round(circlesize/2);
masksize = halfrange*2+1;
MaskAvg=zeros(masksize,masksize);
for p=1:NumPoints
    xpos=round(MaskPoints(1,p));
    ypos=round(MaskPoints(2,p));
    if xpos>=halfrange+1 && ypos<=handles.imagesizex-halfrange &&...
       ypos>=halfrange+1 && xpos<=handles.imagesizey-halfrange 
       MaskAvg = MaskAvg + image_t(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);
    end
end

axes(handles.axes1);
handles.imagehandle=imshow(MaskAvg/NumPoints);
set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
colormap(gray);
        
handles.MaskAverage = uint16(MaskAvg/NumPoints);
guidata(hObject,handles);

% --- Executes on button press in SaveAverage.
function SaveAverage_Callback(~, ~, handles)
% hObject    handle to SaveAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'MaskAverage')
    NameInfo=handles.filename;
    maskavg = handles.MaskAverage;
    [filename,pathname]=uiputfile('.tif','Save Mask Average ',['MaskAverage-',NameInfo]);
    cd(pathname);
    imwrite(maskavg,filename,'tiff');
end

% --- Executes on button press in calibration.
function calibration_Callback(~, ~, handles)
% hObject    handle to calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo = dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    cd(datapath);    
    circlesize = 60;
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;

% 2. Select the other bar end to calculate the vector
    % Set the position of the other bar end (Bar length: 2um -> 15.3 pixels)
    h=impixelinfo;  
    delete(h);       
    ax=handles.axes1;
    cax=axis(ax);      
    maskname = fileinfo(1).name; % loading the first mask file
    fileID = fopen(maskname,'r');
    MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
    fclose(fileID);
    tempX = MaskPoints(2,1); % select the first mask point
    tempY = MaskPoints(1,1);
    daxX = (cax(2)-cax(1))/6/2; %%zoom in for 12 times
    daxY = (cax(4)-cax(3))/6/2; %%zoom in for 12 times
    ln = line(tempX,tempY,'marker','o','color','g','LineStyle','none');
    axis(ax,[tempX+[-1 1]*daxX tempY+[-1 1]*daxY]);
    
    set(handles.DisplayText,'String','Select a point using left button');
    [xi,yi,but] = ginput(1);    %Graphical input from a mouse or cursor
    
    if but == 1 % 1 = left click
       anotherX = round(xi);
       anotherY = round(yi);
       ln = line(anotherX,anotherY,'marker','o','color','r','LineStyle','none');
    end
    
    while but ~= 3 % 3 = right click
        set(handles.DisplayText,'String',but);
        [~,~,but] = ginput(1);    %Graphical input from a mouse or cursor

        if but == 28
            delete(ln);
            anotherX=anotherX-1;
            ln = line(anotherX,anotherY,'marker','o','color','r','LineStyle','none');
        elseif but == 30
            delete(ln);
            anotherY=anotherY-1;
            ln = line(anotherX,anotherY,'marker','o','color','r','LineStyle','none');
        elseif but == 29
            delete(ln);
            anotherX=anotherX+1;
            ln = line(anotherX,anotherY,'marker','o','color','r','LineStyle','none');
        elseif but == 31
            delete(ln);
            anotherY=anotherY+1;
             ln = line(anotherX,anotherY,'marker','o','color','r','LineStyle','none');
        end
    end
    
    vectorX = anotherX - tempX;
    vectorY = anotherY - tempY;
    
    axis(ax,cax);   %zoom out to the original scale    
    
% 3. For all masks and related peaks file (ngood point)

    MaskAvg_TXR = zeros(masksize,masksize, nfiles);
    MaskAvg_GFP = zeros(masksize,masksize, nfiles);

    for i=1:nfiles
        maskname = fileinfo(i).name;
        
        TXRname = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF') ;
        GFPname = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF') ;

        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        TXRimage = imread(TXRname);
        GFPimage = imread(GFPname);
                
        sz = size(TXRimage);
        ysize = sz(1);
        xsize = sz(2);
            
        NumPoints = numel(MaskPoints(1,:));       
        ngoodpoints = 0;
        for p = 1:NumPoints
            xpos = round(MaskPoints(2,p));
            ypos = round(MaskPoints(1,p));
            if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange                 
               MaskAvg_TXR(:, :, i) = MaskAvg_TXR(:, :, i) + double(TXRimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
               MaskAvg_GFP(:, :, i) = MaskAvg_GFP(:, :, i) + double(GFPimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
               ngoodpoints=ngoodpoints+1;
            end
        end
        MaskAvg_TXR(:, :, i)  = MaskAvg_TXR(:, :, i)/ngoodpoints;
        MaskAvg_GFP(:, :, i)  = MaskAvg_GFP(:, :, i)/ngoodpoints;
    end 
    
% 4. Set up calibration file

    caliMaskAvg = zeros(8, nfiles);    
    for i = 1: nfiles
        TXRimage = MaskAvg_TXR(:, :, i);
        GFPimage = MaskAvg_GFP(:, :, i);
        centerTXR = TXRimage(halfrange-4:halfrange+4, halfrange-4:halfrange+4); % 9*9 matrix
        centerGFP = GFPimage(halfrange-4:halfrange+4, halfrange-4:halfrange+4);
        anotherTXR = TXRimage(halfrange-4+vectorX:halfrange+4+vectorX, ...
                              halfrange-4+vectorY:halfrange+4+vectorY);
        anotherGFP = GFPimage(halfrange-4+vectorX:halfrange+4+vectorX, ...
                              halfrange-4+vectorY:halfrange+4+vectorY);
        [~, txrIdx] = max(centerTXR(:));
        [~, gfpIdx] = max(centerGFP(:));
        [~, txrAnoIdx] = max(anotherTXR(:));
        [~, gfpAnoIdx] = max(anotherGFP(:));       
        [txrX, txrY] = ind2sub(size(centerTXR), round(txrIdx));
        [gfpX, gfpY] = ind2sub(size(centerGFP), round(gfpIdx));
        [txrAnoX, txrAnoY] = ind2sub(size(anotherTXR), round(txrAnoIdx));
        [gfpAnoX, gfpAnoY] = ind2sub(size(anotherGFP), round(gfpAnoIdx));        
        caliMaskAvg(:, i) = [txrX-5 txrY-5 ...
                             txrAnoX-5+vectorX txrAnoY-5+vectorY ...
                             gfpX-5 gfpY-5 ...
                             gfpAnoX-5+vectorX gfpAnoY-5+vectorY];     
    end
    
    fileID = fopen('calibration.txt','w');
    fprintf(fileID,'%d %d %d %d %d %d %d %d\n',caliMaskAvg(1:8, :));
    fclose(fileID);
    fileID = fopen('barend.txt', 'w');
    fprintf(fileID,'%d %d', [vectorX vectorY]);
    fclose(fileID);

function Bar_Cali_Callback(~, ~, handles)
% hObject    handle to Bar_Cali (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. Find mask files
    h=impixelinfo;  
    delete(h);       
    ax=handles.axes1;
    cax=axis(ax);      
    
    position = zeros(8,1);
    
    for i = 1:4
    
    set(handles.DisplayText,'String','Select a point using left button');
    [xi,yi,but] = ginput(1);    %Graphical input from a mouse or cursor
    
    if but == 1 % 1 = left click
       anotherX = round(xi);
       anotherY = round(yi);
       ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
    end
    
    while but ~= 3 % 3 = right click
        set(handles.DisplayText,'String',but);
        [~,~,but] = ginput(1);    %Graphical input from a mouse or cursor

        if but == 28
            delete(ln);
            anotherX=anotherX-1;
            ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        elseif but == 30
            delete(ln);
            anotherY=anotherY-1;
            ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        elseif but == 29
            delete(ln);
            anotherX=anotherX+1;
            ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        elseif but == 31
            delete(ln);
            anotherY=anotherY+1;
             ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        end
    end
        
    position(2*i-1, 1) = anotherX-30;
    position(2*i, 1) = anotherY-30;
    end

    disp(position);
    
    axis(ax,cax);   %zoom out to the original scale

% Pillar Gradient Process   
function cal_squ_mask_Callback(hObject, ~, handles)
% hObject    handle to cal_squ_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    npoints=handles.nSelectedPoints;
    points=handles.SelectedPoints;
    set(handles.DisplayText,'String',['Selected    ',num2str(npoints),'   points']);
    if npoints == 3
        %it is important the the line between p1 and p2 are defined as the line direction.
        p1=points(:,1);
        p2=points(:,2);
        p3=points(:,3);
            
        prompt = {'#Features between 1-2 point', '#Features between 2-3 point', '#Wanted Features between 2-3 point'}; 
        dlg_title = 'Number of repeated features in between points';        
        num_lines= 1;
        dis12 = sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2);
        dis23 = sqrt((p3(1)-p2(1))^2+(p3(2)-p2(2))^2);
        interdistance = str2num(get(handles.Distance,'String'));
        nfeatures12 = round(dis12/interdistance);
        nfeatures23 = round(dis23/interdistance);
        def     = {num2str(nfeatures12),num2str(nfeatures23),'32'};
        answer  = inputdlg(prompt,dlg_title,num_lines,def); 
        NumFeatures_x = sscanf(answer{1},'%d');
        NumFeatures_y = sscanf(answer{2},'%d');
        NumFeatures_y_want = sscanf(answer{3},'%d');

        interdis =(dis12/NumFeatures_x+dis23/NumFeatures_y)/2;
        hslope=(p2(2)-p1(2))/(p2(1)-p1(1));
        hintercept=p1(2)-hslope*p1(1);
        hinterdis_x=((p2(1)-p1(1)))/NumFeatures_x;
        vslope=(p3(2)-p2(2))/(p3(1)-p2(1));
        vinterdis_y=((p3(2)-p2(2)))/NumFeatures_y;
         
        MaskPoints=[];
        n=0;
        for h=1:NumFeatures_x+1
            toppointx = p1(1) + hinterdis_x*(h-1);
            toppointy = hslope*toppointx+hintercept;
            for v=1:NumFeatures_y_want+1
                pointy = toppointy + vinterdis_y*(v-1);
                pointx = (pointy-toppointy)/vslope+toppointx;
                n = n+1;
                line(pointx,pointy,'marker','o','color','w','LineStyle','none');
                MaskPoints(:,n)=[pointy;pointx;v]; %%it's important to note that x and y are transposed in the array and in display
            end
        end
        set(handles.Distance,'String',num2str(interdis));
        guidata(handles.Distance, num2str(interdis));
        handles.MaskPoints=MaskPoints;
        guidata(hObject,handles);        
    else
        set(handles.DisplayText,'String',['Need 3 points but ',num2str(npoints)]);
    end

% --- Executes on button press in ratio_filter.
function ratio_filter_Callback(hObject, ~, handles)
% hObject    handle to ratio_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Filter thresthold:', 'Pillar range:', 'Bkgd range:'}; 
dlg_title = 'Ratio Filter';        
num_lines= 1;
def     = {'1', '3', '3'};
answer  = inputdlg(prompt,dlg_title,num_lines,def); 
Threshhold_value = str2double(answer{1});
pillarRange = str2double(answer{2});
backRange = str2double(answer{3});
  
image_t = get(handles.imagehandle,'CData');
if isfield(handles,'allMaskPoints') && ~isempty(handles.allMaskPoints)
    MaskPoints=handles.allMaskPoints;
else
    MaskPoints = handles.MaskPoints;
    handles.allMaskPoints = MaskPoints;
end

goodpoints=0;
goodMaskPoints=[];
NumPoints=numel(MaskPoints(1,:));

circlesize = str2double(get(handles.CircleSize,'String')); 
halfrange = round(circlesize/2);
masksize = 2*halfrange + 1;
center = halfrange + 1;

for p=1:NumPoints
    xpos = round(MaskPoints(1,p));
    ypos = round(MaskPoints(2,p));
    lineNumber = MaskPoints(3,p);
    if xpos>=halfrange+1 && xpos<=handles.imagesizey-halfrange &&...
       ypos>=halfrange+1 && ypos<=handles.imagesizex-halfrange 
       subimg = double(image_t(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
       % choose masks that are totally in the cells
       pillar = sum(sum(subimg(  center-pillarRange : center+pillarRange , ...
                                 center-pillarRange : center+pillarRange )));
       bkgd = [subimg(1:backRange,1:masksize-backRange), subimg(1:masksize-backRange,masksize-backRange+1:masksize).', ...
               subimg(backRange+1:masksize,1:backRange).' subimg(masksize-backRange+1:masksize,backRange+1:masksize)];
       bkgd_avg = mean(bkgd(:)) * (pillarRange*2+1)^2;
       if pillar/bkgd_avg > Threshhold_value
           goodpoints=goodpoints+1;
           goodMaskPoints(:,goodpoints)=[xpos;ypos; lineNumber];
       end
    end
end

handles.insideMaskPoints=goodMaskPoints;
handles.MaskPoints = handles.insideMaskPoints;

image_t = get(handles.imagehandle,'CData');
axes(handles.axes1);
handles.imagehandle=imshow(image_t);
set(handles.axes1,'CLim',[get(handles.ColorSlider,'min') get(handles.ColorSlider,'value')]);
colormap(gray);
guidata(hObject,handles);
MaskPoints=handles.insideMaskPoints;
NumPoints=numel(MaskPoints(1,:));
circlesize = str2double(get(handles.CircleSize,'String'));
for p=1:NumPoints
    line(round(MaskPoints(2,p)),round(MaskPoints(1,p)),'marker','o','color','y','LineStyle','none',...
        'MarkerSize',circlesize,'LineWidth',circlesize/10);
end

guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%% END of Mask Modification %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% Nuclear PROCESS START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Batch_processing_Callback(~, ~, ~)
% hObject    handle to Batch_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Batch_MaskAvg_Callback(~, ~, handles)
% hObject    handle to Batch_MaskAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. Find mask files
    fclose all;
    %cdirec = cd;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo = dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    mkdir('Deformation average');
    cd(datapath);   
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;
 
% 2. For all masks and related peaks file (ngood point)
    for i=1:nfiles
        maskname = fileinfo(i).name;
        
        %For Lin Microscope
        laminAname = strrep(strrep(maskname,'Mask-',''),'.txt','-laminA-smooth-peaks-getgfc.tiff');
        laminBname = strrep(strrep(maskname,'Mask-',''),'.txt','-laminB-smooth-peaks-getgfc.tiff');        
        dirname = 'Deformation average';

        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        laminAImage = imread(laminAname);
        laminBImage = imread(laminBname);
                
        sz = size(laminAImage);
        ysize = sz(1);
        xsize = sz(2);
        
        MaskAvg_laminA = zeros(masksize,masksize);
        MaskAvg_laminB = zeros(masksize,masksize);
            
        NumPoints = numel(MaskPoints(1,:));
        
        if NumPoints > 0
            ngoodpoints = 0;
            for p = 1:NumPoints
                xpos = round(MaskPoints(2,p));
                ypos = round(MaskPoints(1,p));
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange                 
                   MaskAvg_laminA = MaskAvg_laminA + double(laminAImage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   MaskAvg_laminB = MaskAvg_laminB + double(laminBImage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   ngoodpoints=ngoodpoints+1;
                end
            end
            if ngoodpoints >= 1
               MaskAvg_laminA  = uint16(MaskAvg_laminA/ngoodpoints);
               MaskAvg_laminB  = uint16(MaskAvg_laminB/ngoodpoints);
            end
        end
        cd(dirname);
        imwrite(MaskAvg_laminA,['MaskAvg-' strrep(laminAname, 'smooth-peaks-getgfc.tiff', '') sprintf('%02d-',ngoodpoints) 'smooth-peaks-getgfc.tiff'],'Compression','none');
        imwrite(MaskAvg_laminB,['MaskAvg-' strrep(laminBname, 'smooth-peaks-getgfc.tiff', '') sprintf('%02d-',ngoodpoints) 'smooth-peaks-getgfc.tiff'],'Compression','none');
        cd(datapath);  
    end 
    
% 3. the last step is to go into each folder and creat an averaged image %%%%

    cd(datapath);
    maskinfo = dir('Mask-*.txt');
    cd(dirname);

    %For Lin Microscope
    fileAinfo = dir('MaskAvg*laminA*.tiff');
    fileBinfo = dir('MaskAvg*laminB*.tiff');
    
    nfiles=numel(fileAinfo);
       
    if nfiles>1
        
        MaskAvg_laminA = zeros(masksize,masksize);
        MaskAvg_laminB = zeros(masksize,masksize);
        total_pillars = 0;

        for i=1:nfiles
            laminAname = fileAinfo(i).name;
            laminBname = fileBinfo(i).name;
            
            cd(datapath);
            maskname = maskinfo(i).name;
            fileID = fopen(maskname,'r');
            MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
            fclose(fileID);           
            nump = numel(MaskPoints(1,:));
            total_pillars = total_pillars + nump;
            
            cd(dirname);
            laminAImage = imread(laminAname);
            laminBImage = imread(laminBname);
                
            MaskAvg_laminA = MaskAvg_laminA + double(laminAImage)*nump;
            MaskAvg_laminB = MaskAvg_laminB + double(laminBImage)*nump;

        end
            Mat_laminA = MaskAvg_laminA/total_pillars;
            Mat_laminB = MaskAvg_laminB/total_pillars;
            MaskAvg_laminA = uint16(Mat_laminA);
            MaskAvg_laminB = uint16(Mat_laminB);
            
            imwrite(MaskAvg_laminA,['All_MaskAvg-' int2str(total_pillars) '-laminA.tif']);
            imwrite(MaskAvg_laminB,['All_MaskAvg-' int2str(total_pillars) '-laminB.tif']);    
            save(['All_MaskAvg-' int2str(total_pillars) '-laminA.mat'], 'Mat_laminA');
            save(['All_MaskAvg-' int2str(total_pillars) '-laminB.mat'], 'Mat_laminB');
    end
        
    cd(datapath); 
    
% --------------------------------------------------------------------
function Batch_LaminAB1_Intensity_Callback(~, ~, handles)
% hObject    handle to Batch_LaminAB1_Intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in OutsideCell.

% Goal: Calculating average intensity of LaminA and LaminB1 with given
% masks of multiple cells

% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo = dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    mkdir('Intensity average');
    cd(datapath);
    
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;
    
% 2. For all masks and related peaks file (ngood point)
    for i=1:nfiles
        maskname = fileinfo(i).name;

        %For Lin Microscope
        laminAname = strrep(strrep(maskname,'Mask-',''),'.txt','-laminA-bot.tif');
        laminBname = strrep(strrep(maskname,'Mask-',''),'.txt','-laminB-bot.tif');  
        
        dirname = 'Intensity average';

        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        laminAImage = imread(laminAname);
        laminBImage = imread(laminBname);
                
        sz = size(laminAImage);
        ysize = sz(1);
        xsize = sz(2);
        
        MaskAvg_laminA = zeros(masksize,masksize);
        MaskAvg_laminB = zeros(masksize,masksize);
            
        NumPoints = numel(MaskPoints(1,:));
        
        if NumPoints > 0
            ngoodpoints = 0;
            for p = 1:NumPoints
                xpos = round(MaskPoints(2,p));
                ypos = round(MaskPoints(1,p));
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange                 
                   MaskAvg_laminA = MaskAvg_laminA + double(laminAImage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   MaskAvg_laminB = MaskAvg_laminB + double(laminBImage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   ngoodpoints=ngoodpoints+1;
                end
            end
            if ngoodpoints >= 1
               MaskAvg_laminA  = uint16(MaskAvg_laminA/ngoodpoints);
               MaskAvg_laminB  = uint16(MaskAvg_laminB/ngoodpoints);
            end
        end
        cd(dirname);
        imwrite(MaskAvg_laminA,['MaskAvg-' strrep(laminAname, 'laminA-bot.tif', '') sprintf('%02d-',ngoodpoints) 'laminA-bot.tif'],'Compression','none');
        imwrite(MaskAvg_laminB,['MaskAvg-' strrep(laminBname, 'laminB-bot.tif', '') sprintf('%02d-',ngoodpoints) 'laminB-bot.tif'],'Compression','none');
        cd(datapath);  
    end 
    

% 3. the last step is to go into each folder and creat an averaged image %%%%

    cd(datapath);
    maskinfo = dir('Mask-*.txt');
    cd(dirname);
    fileAinfo = dir('MaskAvg*A-bot.tif');
    fileBinfo = dir('MaskAvg*B-bot.tif');
    nfiles=numel(fileAinfo);
       
    if nfiles>1
        
        MaskAvg_laminA = zeros(masksize,masksize);
        MaskAvg_laminB = zeros(masksize,masksize);
        total_pillars = 0;

        for i=1:nfiles
            laminAname = fileAinfo(i).name;
            laminBname = fileBinfo(i).name;
            
            cd(datapath);
            maskname = maskinfo(i).name;
            fileID = fopen(maskname,'r');
            MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
            fclose(fileID);           
            nump = numel(MaskPoints(1,:));
            total_pillars = total_pillars + nump;
            
            cd(dirname);
            laminAImage = imread(laminAname);
            laminBImage = imread(laminBname);
                
            MaskAvg_laminA = MaskAvg_laminA + double(laminAImage)*nump;
            MaskAvg_laminB = MaskAvg_laminB + double(laminBImage)*nump;

        end

            MaskAvg_laminA = uint16(MaskAvg_laminA/total_pillars);
            MaskAvg_laminB = uint16(MaskAvg_laminB/total_pillars);
            
            imwrite(MaskAvg_laminA,['All_MaskAvg-' int2str(total_pillars) '-laminA-bot.tif']);
            imwrite(MaskAvg_laminB,['All_MaskAvg-' int2str(total_pillars) '-laminB-bot.tif']);      
    end
        
    cd(datapath); 

% --------------------------------------------------------------------
function Batch_MaskAvg_ratio_Callback(~, ~, handles)
% hObject    handle to Batch_MaskAvg_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
% Goal: Calculating average ratio of LaminA and LaminB1 with given
% masks of multiple cells

% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo = dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    mkdir('Ratio average');
    cd(datapath);
    
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;
    
% 2. For all masks and related peaks file (ngood point)
    for i=1:nfiles
        maskname = fileinfo(i).name;
        ratioName = strrep(strrep(maskname,'Mask-',''),'.txt','-ratio-bot.tif');
        
        dirname = 'Ratio average';

        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        ratioImage = imread(ratioName);
                
        sz = size(ratioImage);
        ysize = sz(1);
        xsize = sz(2);
        
        MaskAvg_ratio = zeros(masksize,masksize);
            
        NumPoints = numel(MaskPoints(1,:));
        
        if NumPoints > 0
            ngoodpoints = 0;
            for p = 1:NumPoints
                xpos = round(MaskPoints(2,p));
                ypos = round(MaskPoints(1,p));
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange                 
                   MaskAvg_ratio = MaskAvg_ratio + double(ratioImage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   ngoodpoints=ngoodpoints+1;
                end
            end
            if ngoodpoints >= 1
               MaskAvg_ratio  = uint16(MaskAvg_ratio/ngoodpoints);
            end
        end
        cd(dirname);
        imwrite(MaskAvg_ratio,['MaskAvg-' strrep(ratioName, 'ratio-bot.tif', '') sprintf('%02d-',ngoodpoints) 'ratio-bot.tif'],'Compression','none');
        cd(datapath);  
    end 
    
% 3. the last step is to go into each folder and creat an averaged image %%%%

    cd(datapath);
    maskinfo = dir('Mask-*.txt');
    cd(dirname);
    fileRinfo = dir('MaskAvg*ratio-bot.tif');
    nfiles=numel(fileRinfo);
       
    if nfiles>1
        
        MaskAvg_ratio = zeros(masksize,masksize);
        total_pillars = 0;

        for i=1:nfiles
            ratioName = fileRinfo(i).name;
            
            cd(datapath);
            maskname = maskinfo(i).name;
            fileID = fopen(maskname,'r');
            MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
            fclose(fileID);           
            nump = numel(MaskPoints(1,:));
            total_pillars = total_pillars + nump;
            
            cd(dirname);
            ratioImage = imread(ratioName);
                
            MaskAvg_ratio = MaskAvg_ratio + double(ratioImage)*nump;
        end

            MaskAvg_ratio = uint16(MaskAvg_ratio/total_pillars);
            imwrite(MaskAvg_ratio,['All_MaskAvg-' int2str(total_pillars) '-ratio-bot.tif']);   
    end
        
    cd(datapath); 

% --------------------------------------------------------------------
function Actin_intensity_Callback(~, ~, handles)
% hObject    handle to Actin_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles=numel(fileinfo);
    
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    center = halfrange + 1;
    dirname = 'Ratio average';
    
    prompt = {'Enter analysis range (Pillar area):'};
    dlg_title = 'Ratio average';
    num_lines = 1;
    def = {'5'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    range = str2double(answer{1}); % depend on different pillar size
    intensity(1).data = [];

% 2. For all masks and related peaks file
    for i=1:nfiles
        maskname=fileinfo(i).name;
        actinName = strrep(strrep(maskname,'Mask-',''),'.txt','-actin-sum.mat');
        
        %open mask and peak files
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        load(actinName); %The mat name is img
        
% 3. For every peak in the mat files
        NumPoints = numel(MaskPoints(1,:));
        if NumPoints>0
            for p=1:NumPoints   
                
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p);
                
                temp = intensity(1).data;
                % Take out the masked area, which is one of the peaks
                sumMat = img(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);                                       
                cenA = sum(sum(sumMat(center-range:center+range, center-range:center+range)));
                intensity(1).data = [temp; cenA];
            end
        end
    end 
    cd(dirname);
    save('Actin_Intensity.mat','intensity');
    cd(datapath);

% --------------------------------------------------------------------
function Batch_RatioCalc_Callback(~, ~, handles)
% hObject    handle to Batch_RatioCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles=numel(fileinfo);
    
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;
    center = halfrange + 1;
    dirname = 'Ratio average';
    
    prompt = {'Enter laminA X shift:','Enter laminA Y shift:', 'Enter laminB X shift:','Enter laminB Y shift:'};
    dlg_title = 'Position Calibration for LaminA and LaminB';
    num_lines = 1;
    def = {'0','0','0','0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    caliXA = str2double(answer{1});
    caliYA = str2double(answer{2});
    caliXB = str2double(answer{3});
    caliYB = str2double(answer{4});
    
    prompt = {'Enter analysis range:'};
    dlg_title = 'Ratio average';
    num_lines = 1;
    def = {'5'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    range = str2double(answer{1}); % depend on different pillar size
    bkgdrange = range + 1;
    
    % 1: laminA, 2: laminB 3: ratio
    % Center, Background
    intensitydata(3).intensity = []; % what the data should be
    
% 2. For all masks and related peaks file
    for i=1:nfiles
        maskname=fileinfo(i).name;
        intAname = strrep(strrep(maskname,'Mask-',''),'.txt','-laminA-bot.tif');
        intBname = strrep(strrep(maskname,'Mask-',''),'.txt','-laminB-bot.tif');
        
        %open mask and peak files
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        intAmat = double(imread(intAname));
        intBmat = double(imread(intBname));      
        
        sz = size(intAmat);
        xsize = sz(2);
        ysize = sz(1);
        
% 3. For every peak in the mat files
        NumPoints = numel(MaskPoints(1,:));
        if NumPoints>0
            for p=1:NumPoints
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p);
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange
                    
                    Aint = intensitydata(1).intensity;
                    Bint = intensitydata(2).intensity;
                    Rint = intensitydata(3).intensity;
                    
                    % Take out the masked area, which is one of the peaks
                    wkA = intAmat(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);
                    wkB = intBmat(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange); 
                    
                    bkgdA = [wkA(1:bkgdrange,1:masksize-bkgdrange), wkA(1:masksize-bkgdrange,masksize-bkgdrange+1:masksize).', ...
                             wkA(bkgdrange+1:masksize,1:bkgdrange).', wkA(masksize-bkgdrange+1:masksize,bkgdrange+1:masksize)];
                    bkgdB = [wkB(1:bkgdrange,1:masksize-bkgdrange), wkB(1:masksize-bkgdrange,masksize-bkgdrange+1:masksize).', ...
                             wkB(bkgdrange+1:masksize,1:bkgdrange).', wkB(masksize-bkgdrange+1:masksize,bkgdrange+1:masksize)];                       
                    
                    cenA = mean(mean(wkA(center-range+caliYA:center+range+caliYA, center-range+caliXA:center+range+caliXA)));
                    cenB = mean(mean(wkB(center-range+caliYB:center+range+caliYB, center-range+caliXB:center+range+caliXB)));
                    
                    cenR = cenA/cenB;
                    bkgdR = mean(mean(bkgdA))/mean(mean(bkgdB));                              
                    
                    intensitydata(1).intensity = [Aint; cenA mean(mean(bkgdA))];
                    intensitydata(2).intensity = [Bint; cenB mean(mean(bkgdB))];   
                    intensitydata(3).intensity = [Rint; cenR bkgdR];                      
                end
            end
        end
    end 
    mkdir(dirname);
    cd(dirname);
    save('Ratio_Analysis.mat','intensitydata');
    cd(datapath);
    
%%%%%%%%%%%%%%%%%%%%%%%%%% Nuclear PROCESS END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%% Actin PROCESS START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Actin_process_Callback(~, ~, ~)
% hObject    handle to Actin_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Intensity_processing_Callback(~, ~, handles)
% hObject    handle to Intensity_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles=numel(fileinfo);
    
    circlesize = str2double(get(handles.CircleSize,'String'));
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;
    center = halfrange + 1;
    
    %areaOfPixel = 0.017161; % (0.131um)^2 (Leica2 bin2*2, 100x oil)
    % Set center area and bkgd area
    prompt = {'Enter center area:', 'Enter pillar area:', 'Enter background range:'};
    dlg_title = 'Analysis area';
    num_lines = 1;
    def = {'0', '3', '3'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);    
    pillarRange = str2double(answer{1}); % depend on different pillar size
    surRange = str2double(answer{2});
    backRange = str2double(answer{3});      

    TXR_intensity = [];
    GFP_intensity = [];

% 2. For all masks and related peaks file
    for i=1:nfiles
        maskname=fileinfo(i).name;
        TXRname = strrep(strrep(maskname, 'Mask-', ''),'.txt','_w2TXR.TIF');
        GFPname = strrep(strrep(maskname, 'Mask-', ''),'.txt','_w3GFP.TIF');
        
        %open mask and peak files
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        TXRimage = double(imread(TXRname));
        GFPimage = double(imread(GFPname));
        
% 3. For every peak in the mat files
        NumPoints = numel(MaskPoints(1,:));
        if NumPoints>0
            for p=1:NumPoints   
                
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p); 
                TXR_temp = TXR_intensity;
                GFP_temp = GFP_intensity;
                
                % Take out the masked area, which is one of the peaks
                TXR_mask = TXRimage(xpos-halfrange : xpos+halfrange , ypos-halfrange : ypos+halfrange);
                GFP_mask = GFPimage(xpos-halfrange : xpos+halfrange , ypos-halfrange : ypos+halfrange);
                
                if pillarRange > -1
                    TXR_center = sum(sum(TXR_mask( center-pillarRange : center+pillarRange, ...
                                                   center-pillarRange : center+pillarRange)));
                    TXR_pillar = sum(sum(TXR_mask( center-pillarRange-surRange : center+pillarRange+surRange, ...
                                                   center-pillarRange-surRange : center+pillarRange+surRange)));
                    TXR_surround = (TXR_pillar - TXR_center) / ((2*pillarRange+1+2*surRange)^2 - (2*pillarRange+1)^2);
                    
                    GFP_center = sum(sum(GFP_mask( center-pillarRange : center+pillarRange, ...
                                                   center-pillarRange : center+pillarRange )));
                    GFP_pillar = sum(sum(GFP_mask( center-pillarRange-surRange : center+pillarRange+surRange, ...
                                                   center-pillarRange-surRange : center+pillarRange+surRange)));
                    GFP_surround = (GFP_pillar - GFP_center) / ((2*pillarRange+1+2*surRange)^2 - (2*pillarRange+1)^2);
                else
                    TXR_pillar = sum(sum(TXR_mask( center-surRange : center+surRange, ...
                                                   center-surRange : center+surRange)));        
                    TXR_surround = TXR_pillar / (2*surRange+1)^2;
                    
                    GFP_pillar = sum(sum(GFP_mask( center-surRange : center+surRange, ...
                                                   center-surRange : center+surRange)));        
                    GFP_surround = GFP_pillar / (2*surRange+1)^2;                   
                end
                
                TXR_bkgd = [TXR_mask(1:backRange,1:masksize-backRange), TXR_mask(1:masksize-backRange,masksize-backRange+1:masksize).', ...
                            TXR_mask(backRange+1:masksize,1:backRange).' TXR_mask(masksize-backRange+1:masksize,backRange+1:masksize)];
                TXR_background = mean(mean(TXR_bkgd));             
         	    TXR_ratio = TXR_surround/TXR_background;
                
                GFP_bkgd = [GFP_mask(1:backRange,1:masksize-backRange), GFP_mask(1:masksize-backRange,masksize-backRange+1:masksize).', ...
                            GFP_mask(backRange+1:masksize,1:backRange).' GFP_mask(masksize-backRange+1:masksize,backRange+1:masksize)];
                GFP_background = mean(mean(GFP_bkgd));             
         	    GFP_ratio = GFP_surround/GFP_background;  
                
                TXR_intensity = [TXR_temp; TXR_surround TXR_background TXR_ratio];
                GFP_intensity = [GFP_temp; GFP_surround GFP_background GFP_ratio];
                
            end
        end
    end 
    save('TXR_result', 'TXR_intensity');
    save('GFP_result', 'GFP_intensity');
    
function Lifecell_processing_Callback(~, ~, handles)
% hObject    handle to Lifecell_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. Select TXR stack file, mask file, and fitting area.
    fclose all;
    stackfile = uigetfile('*_stack.tif', 'Choose a TXR stack file');
    if stackfile==0, return; end    
    
    maskfile = uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if maskfile==0, return; end
    
    prompt = {'Enter center area:', 'Enter pillar area:', 'Enter background range:'};
    dlg_title = 'Ratio average';
    num_lines = 1;
    def = {'-1', '3', '3'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);    
    pillarRange = str2double(answer{1}); % depend on different pillar size
    surRange = str2double(answer{2});
    backRange = str2double(answer{3});    
    
    circlesize = 40;
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;
    center = halfrange + 1;
    
    if pillarRange > -1
        resultName = [strrep(stackfile, '.tif', '_') answer{1} '-' answer{2} '-' answer{3} '-ratio.mat'];
        intensityName = [strrep(stackfile, '.tif', '_') answer{1} '-' answer{2} '-' answer{3} '-intensity.mat'];
    else
        resultName = [strrep(stackfile, '.tif', '_') 'N-' answer{2} '-' answer{3} '-ratio.mat'];
        intensityName = [strrep(stackfile, '.tif', '_') answer{1} '-' answer{2} '-' answer{3} '-intensity.mat'];
    end
  
% 2. Import maskpoints and crease Actin_Average_Stack name
    stackinfo = imfinfo(stackfile);
    num_tif = numel(stackinfo);
    
    fileID = fopen(maskfile,'r');
    MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
    NumPoints = numel(MaskPoints(1,:));
    if NumPoints == 0, return; end
    fclose(fileID);
    
    actinstack = strrep(stackfile,'.tif','_avg.tif');

% 3. For every frame, culaulate the average actin intensity, and save the Actin_Average_Stack.
    for i=1:num_tif       
        MaskAvg = zeros(masksize,masksize);
        Image_t = double(imread(stackfile, i));     
        for p=1:NumPoints
            xpos = MaskPoints(2,p);
            ypos = MaskPoints(1,p);
            area = Image_t(xpos-halfrange:xpos+halfrange,...
                           ypos-halfrange:ypos+halfrange);
            MaskAvg = MaskAvg + area;    
        end
        MaskAvg = uint16(MaskAvg/NumPoints);
        imwrite(MaskAvg, actinstack,'WriteMode','append','Compression','none');
    end

% 4. Read the actinstack and create califile    
    califile = strrep(maskfile,'.txt','-cali.txt');
    avginfo = imfinfo(actinstack);
    num_tif = numel(avginfo);
    sizeXY = size(imread(actinstack,1),1);  
    centerX = round(sizeXY/2);
    centerY = round(sizeXY/2);
    caliCenterX = centerX;
    caliCenterY = centerY;
    caliXY = zeros(2, num_tif);
    
    for i = 1:num_tif
        image_avg = imread(actinstack, i);
        centerArea = image_avg(caliCenterX-1:caliCenterX+1, caliCenterY-1:caliCenterY+1);
        if pillarRange > -1 % use max or min?
            [~, idx] = min(centerArea(:));
        else 
            [~, idx] = max(centerArea(:));
        end
        [cenX, cenY] = ind2sub(size(centerArea), round(idx));
        % minX-3, minY-3 is the position of the local min
        caliXY(:,i) = [caliCenterX-centerX+cenX-2 caliCenterY-centerY+cenY-2];
        caliCenterX = caliCenterX+cenX-2;
        caliCenterY = caliCenterY+cenY-2;
    end

    fileID = fopen(califile,'w');
    fprintf(fileID,'%d %d\n',caliXY(1:2, :));
    fclose(fileID);
    
% 5. Calculate the actin accumulation in every frame and every maskpoint  
    ratioresult = zeros(num_tif, NumPoints);
    intenresult = zeros(num_tif, NumPoints);
    
    for i=1:num_tif       
        actinImage = imread(stackfile, i); 
        for p=1:NumPoints                
            xpos = MaskPoints(2,p);
            ypos = MaskPoints(1,p);            
            caliX = caliXY(1,i);
            caliY = caliXY(2,i);
            % Take out the masked area, which is one of the peaks
            maskArea = actinImage(xpos-halfrange : xpos+halfrange , ypos-halfrange : ypos+halfrange);
            if pillarRange > -1
               centerArea = sum(sum(maskArea( center-pillarRange+caliX : center+pillarRange+caliX, ...
                                              center-pillarRange+caliY : center+pillarRange+caliY )));
               pillarArea = sum(sum(maskArea( center-pillarRange-surRange+caliX : center+pillarRange+surRange+caliX, ...
                                              center-pillarRange-surRange+caliY : center+pillarRange+surRange+caliY )));
               surroundArea = (pillarArea - centerArea) / ((2*pillarRange+1+2*surRange)^2 - (2*pillarRange+1)^2);                                               
            else
               pillarArea = sum(sum(maskArea( center-surRange+caliX : center+surRange+caliX, ...
                                              center-surRange+caliY : center+surRange+caliY )));        
               surroundArea = pillarArea / (1+2*surRange)^2;
            end
            background = [maskArea(1:backRange,1:masksize-backRange), maskArea(1:masksize-backRange,masksize-backRange+1:masksize).', ...
                          maskArea(backRange+1:masksize,1:backRange).' maskArea(masksize-backRange+1:masksize,backRange+1:masksize)];
            backgroundAverage = mean(mean(background));
            ratio = surroundArea/backgroundAverage;
            ratioresult(i, p) = ratio;
            intenresult(i, p) = surroundArea;
        end       
    end 
    save(resultName,'ratioresult');
    save(intensityName,'intenresult');
   
function nanobar_analysis_Callback(~, ~, ~)
% hObject    handle to nanobar_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    
    circlesize = 50;
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;    
    %areaOfPixel = 0.017161; 
    % (63.89microns)^2 (Zeiss LSM800 512*512, 100x oil)  
    endwidth = 3; % Bar end square width = 2*endwidth + 1
    maxpixel = 9;
   
    prompt = {'0: No Calibration, 1: Calibration'};
    dlg_title = 'With Calibration?';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    cali_bool = str2double(answer{1});
    
% 2. declare main data structure   
    % barData -> nFiles
    %            masksize
    %            barInfo  -->  maskName
    %                          nbar
    %                          maskPoint
    %                          data      --> {TXR, GFP} -->  subImage
    %                                                        position
    %                                                        end1
    %                                                        end2
    %                                                        center
    %                                                        bkgd    
    barData.nFiles = nfiles;
    barData.masksize = masksize;
    barData.barInfo = repmat(struct('maskName',[], 'nbar', [], 'maskPoint', [], 'data', []), nfiles,1);

    rawDataGFP = [];
    rawDataTXR = [];
    
    % read the calibration file
    if cali_bool == 1
        fileID = fopen('calibration.txt','r');
        position = fscanf(fileID,'%d %d %d %d %d %d %d %d', [8 inf]);
        fclose(fileID);
    else
        fileID = fopen('barend.txt','r');
        barend = fscanf(fileID,'%d %d', [2 inf]);
        fclose(fileID);
        position = transpose(repmat([0 0 barend(1, 1) barend(2, 1) 0 0 barend(1, 1) barend(2, 1)], nfiles, 1));
    end
    
% 3. For all masks and related peaks file
    for i=1:nfiles
        
        % define image name
        maskname = fileinfo(i).name;
        txrName = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF');
        gfpName = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF');
        
        % read mask file
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        nBar = size(MaskPoints, 2);
        
        % read image files
        txrImage = double(imread(txrName));
        gfpImage = double(imread(gfpName));
        
        % input information
        barData.barInfo(i).maskName = maskname;
        barData.barInfo(i).nbar = nBar;
        barData.barInfo(i).maskPoint = MaskPoints;
        
        % declear detail information
        barData.barInfo(i).data.TXR = repmat(struct('subImage',[], 'position',[], 'end1', [], ...
                                                   'end2', [], 'center', [], 'bkgd', [], 'barArea', [], 'end1area', [], 'end2area', [], 'centerarea', [], 'maxend1area', [], 'maxend2area', []),nBar,1);
        barData.barInfo(i).data.GFP = repmat(struct('subImage',[], 'position',[], 'end1', [], ...
                                                    'end2', [], 'center', [], 'bkgd', [], 'barArea', [], 'end1area', [], 'end2area', [], 'centerarea', [], 'maxend1area', [], 'maxend2area', []),nBar,1);
        
        txrX = position(1, i); txrY = position(2, i);
        txrAnoX = position(3, i); txrAnoY = position(4, i);
        gfpX = position(5, i); gfpY = position(6, i);
        gfpAnoX = position(7, i); gfpAnoY = position(8, i);        
                                                
% 4. For every peak in the mat files
        NumPoints = nBar;
        if NumPoints>0
            for p=1:NumPoints   
                
                % Three points, two ends and the center               
                xend1 = MaskPoints(2,p);
                yend1 = MaskPoints(1,p);
                if xend1 * yend1 ~= 0
                % Take out the masked area and save
                txrArea = txrImage(xend1-halfrange+txrX : xend1+halfrange+txrX, ...
                                   yend1-halfrange+txrY : yend1+halfrange+txrY);
                                    
                
                gfpArea = gfpImage(xend1-halfrange+gfpX: xend1+halfrange+gfpX, ...
                                   yend1-halfrange+gfpY : yend1+halfrange+gfpY);
                                    
                barData.barInfo(i).data.TXR(p).subImage = txrArea;
              
                barData.barInfo(i).data.TXR(p).position = [xend1 yend1];
                
              
                barData.barInfo(i).data.GFP(p).subImage = gfpArea;
                
                barData.barInfo(i).data.GFP(p).position = [xend1 yend1];
                
                 
                
                % calculate the end position
                txr_xend1 = halfrange + 1; txr_yend1 = halfrange + 1;
                gfp_xend1 = halfrange + 1; gfp_yend1 = halfrange + 1;               
                
                txr_xend2 = txr_xend1 + txrAnoX + txrX; txr_yend2 = txr_yend1 + txrAnoY + txrY ;
                gfp_xend2 = gfp_xend1 + gfpAnoX + gfpX; gfp_yend2 = gfp_yend1 + gfpAnoY + gfpY;
                
                txr_xcen = round((txr_xend1 + txr_xend2)/2); 
                txr_ycen = round((txr_yend1 + txr_yend2)/2);
                gfp_xcen = round((gfp_xend1 + gfp_xend2)/2);
                gfp_ycen = round((gfp_yend1 + gfp_yend2)/2);
               
                
                
                % define the area of bar, end1, end2, center and calculate the mean reaction intensity and bkgd (reaction area: 3*3)
                
                bartxrArea = txrArea(txr_xend1-endwidth+txrX : txr_xend2+endwidth+txrX, ...
                                        txr_yend1-endwidth+txrY : txr_yend2+endwidth+txrY);
                                    
                bargfpArea = gfpArea(gfp_xend1-endwidth+gfpX : gfp_xend2+endwidth+gfpX, ...
                                        gfp_yend1-endwidth+gfpY : gfp_yend2+endwidth+gfpY);
                
                TXRend1area = txrArea(txr_xend1-endwidth : txr_xend1+endwidth,...
                                          txr_yend1-endwidth : txr_yend1+endwidth);
                                      
                TXRend2area = txrArea(txr_xend2-endwidth : txr_xend2+endwidth,...
                                          txr_yend2-endwidth : txr_yend2+endwidth);
                                      
                %TXRcenterarea = txrArea(txr_xcen-endwidth : txr_xcen+endwidth,...
                                            %txr_ycen-1 : txr_ycen+1); %%matlab竖着的bar时run
                                        
                TXRcenterarea = txrArea(txr_xcen-1 : txr_xcen+1,...
                                            txr_ycen-endwidth : txr_ycen+endwidth);%%matlab横着的bar时run
                
                %sort the row elements of max 9 pixel in end1, end2 area
                
                [TXRend1Sorted(:,1),TXRend1Sorted(:,2)] = sort(TXRend1area(:), 'descend');
                
                [TXRend2Sorted(:,1),TXRend2Sorted(:,2)] = sort(TXRend2area(:), 'descend');
                
                TXRend1Maxelements = TXRend1Sorted(1:maxpixel,:);
                
                TXRend2Maxelements = TXRend2Sorted(1:maxpixel,:);
                
                
                                        
                GFPend1area = gfpArea(gfp_xend1-endwidth : gfp_xend1+endwidth,...
                                          gfp_yend1-endwidth : gfp_yend1+endwidth);
                                      
                GFPend2area = gfpArea(gfp_xend2-endwidth : gfp_xend2+endwidth,...
                                          gfp_yend2-endwidth : gfp_yend2+endwidth);
                                      
                %GFPcenterarea = gfpArea(gfp_xcen-endwidth : gfp_xcen+endwidth,...
                                            %gfp_ycen-1 : gfp_ycen+1);%%竖着的bar时run
                                        
                GFPcenterarea = gfpArea(gfp_xcen-1 : gfp_xcen+1,...
                                            gfp_ycen-endwidth : gfp_ycen+endwidth);%%横着的bar时run
                                            
                [GFPend1Sorted(:,1),GFPend1Sorted(:,2)] = sort(GFPend1area(:), 'descend');
                
                [GFPend2Sorted(:,1),GFPend2Sorted(:,2)] = sort(GFPend2area(:), 'descend');
                
                GFPend1Maxelements = GFPend1Sorted(1:maxpixel,:);
                
                GFPend2Maxelements = GFPend2Sorted(1:maxpixel,:);
                
                
                
                RTXRend1 = reshape(txrArea(txr_xend1-endwidth : txr_xend1+endwidth,...
                                          txr_yend1-endwidth : txr_yend1+endwidth),[1,49]);
                
                RTXRend2 = reshape(txrArea(txr_xend2-endwidth : txr_xend2+endwidth,...
                                          txr_yend2-endwidth : txr_yend2+endwidth),[1,49]);
                                      
                %RTXRcenter = reshape(txrArea(txr_xcen-endwidth : txr_xcen+endwidth,...
                                            %txr_ycen-1 : txr_ycen+1),[1,21]); %%竖着的bar时run   
                
                RTXRcenter = reshape(txrArea(txr_xcen-1 : txr_xcen+1,...
                                            txr_ycen-endwidth : txr_ycen+endwidth),[1,21]); %%横着的bar时run 
                                      
                RGFPend1 = reshape(gfpArea(gfp_xend1-endwidth : gfp_xend1+endwidth,...
                                          gfp_yend1-endwidth : gfp_yend1+endwidth),[1,49]);
                
                RGFPend2 = reshape(gfpArea(gfp_xend2-endwidth : gfp_xend2+endwidth,...
                                          gfp_yend2-endwidth : gfp_yend2+endwidth),[1,49]);
                                      
                %RGFPcenter = reshape(gfpArea(gfp_xcen-endwidth : gfp_xcen+endwidth,...
                                            %gfp_ycen-1 : gfp_ycen+1),[1,21]);%%竖着的bar时run
                                        
                RGFPcenter = reshape(gfpArea(gfp_xcen-1 : gfp_xcen+1,...
                                            gfp_ycen-endwidth : gfp_ycen+endwidth),[1,21]);%%横着的bar时run
                                     
                                        
                STXRend1 = sort(RTXRend1,'descend');
                
                STXRend2 = sort(RTXRend2,'descend');
                                      
                STXRcenter = sort(RTXRcenter,'descend');                                                     
                                      
                SGFPend1 = sort(RGFPend1,'descend');
                
                SGFPend2 = sort(RGFPend2,'descend');
                                      
                SGFPcenter = sort(RGFPcenter,'descend');
                
                
                
                TXRend1 = mean(STXRend1(1:9));
                
                TXRend2 = mean(STXRend2(1:9));
                                      
                TXRcenter = mean(STXRcenter(1:9));                                                     
                                      
                GFPend1 = mean(SGFPend1(1:9));
                
                GFPend2 = mean(SGFPend2(1:9));
                                      
                GFPcenter = mean(SGFPcenter(1:9));
                
                % calculate the background
               
                TXRbkgd = (sum(sum(txrArea(:)))-sum(sum(bartxrArea(:))))/((2 * halfrange + 1) ^2 - ((txrAnoX + txrX + 8) * (txrAnoY + txrY + 8)));  
                GFPbkgd = (sum(sum(gfpArea(:)))-sum(sum(bargfpArea(:))))/((2 * halfrange + 1) ^2 - ((gfpAnoX + gfpX + 8) * (gfpAnoY + gfpY + 8)));
                                                                                        
                % save the data
                barData.barInfo(i).data.TXR(p).end1 = TXRend1;
                barData.barInfo(i).data.TXR(p).end2 = TXRend2;
                barData.barInfo(i).data.TXR(p).center = TXRcenter;
                barData.barInfo(i).data.TXR(p).bkgd = TXRbkgd;
                barData.barInfo(i).data.TXR(p).barArea = bartxrArea;
                
                
                barData.barInfo(i).data.GFP(p).end1 = GFPend1;
                barData.barInfo(i).data.GFP(p).end2 = GFPend2;
                barData.barInfo(i).data.GFP(p).center = GFPcenter;
                barData.barInfo(i).data.GFP(p).bkgd = GFPbkgd;
                barData.barInfo(i).data.GFP(p).barArea = bargfpArea;
                
                
                barData.barInfo(i).data.TXR(p).end1area = TXRend1area;
                barData.barInfo(i).data.TXR(p).end2area = TXRend2area;
                barData.barInfo(i).data.TXR(p).centerarea = TXRcenterarea;
                barData.barInfo(i).data.TXR(p).maxend1area = TXRend1Maxelements;
                barData.barInfo(i).data.TXR(p).maxend2area = TXRend2Maxelements;
                
                barData.barInfo(i).data.GFP(p).end1area = GFPend1area;
                barData.barInfo(i).data.GFP(p).end2area = GFPend2area;
                barData.barInfo(i).data.GFP(p).centerarea = GFPcenterarea;
                barData.barInfo(i).data.GFP(p).maxend1area = GFPend1Maxelements;
                barData.barInfo(i).data.GFP(p).maxend2area = GFPend2Maxelements;
                
                
                rawDataTXR = [rawDataTXR; TXRend1 TXRcenter TXRend2 TXRbkgd];
                rawDataGFP = [rawDataGFP; GFPend1 GFPcenter GFPend2 GFPbkgd];
                end
            end
        end
    end 
    save('BarData', 'barData');
    save('RawTXR', 'rawDataTXR');
    save('RawGFP', 'rawDataGFP');
    clc;clear;
    
function Bar_MaskAvg_Callback(~, ~, ~)
% hObject    handle to Bar_MaskAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);    
    fileinfo=dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    mkdir('image average');
    cd(datapath);
    
    circlesize = 60;
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;    
    %areaOfPixel = 0.017161; 
    % (0.131um)^2 (Leica2 bin2*2, 100x oil)  
    
    prompt = {'0: No Calibration, 1: Calibration'};
    dlg_title = 'With Calibration?';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    cali_bool = str2double(answer{1});
    
    % read the calibration file
    if cali_bool == 1
        fileID = fopen('calibration.txt','r');
        position = fscanf(fileID,'%d %d %d %d %d %d %d %d', [8 inf]);
        fclose(fileID);
    else
        position = transpose(repmat([0 0 0 0 0 0 0 0], nfiles, 1));
    end
    
% 2. For all masks and related peaks file (ngood point)

    for i=1:nfiles
        maskname = fileinfo(i).name;
        
        BFname = strrep(strrep(maskname,'Mask-',''),'.txt','_w1BF.TIF') ;
        TXRname = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF') ;
        GFPname = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF') ;
        
        dirname = 'image average';

        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        BFimage = imread(BFname);
        TXRimage = imread(TXRname);
        GFPimage = imread(GFPname);
                
        sz = size(TXRimage);
        ysize = sz(1);
        xsize = sz(2);
        
        MaskAvg_BF = zeros(masksize,masksize);
        MaskAvg_TXR = zeros(masksize,masksize);
        MaskAvg_GFP = zeros(masksize,masksize);
            
        NumPoints = numel(MaskPoints(1,:));
        
        txrX = position(1, i); txrY = position(2, i);
        gfpX = position(5, i); gfpY = position(6, i);
        
        if NumPoints > 0
            ngoodpoints = 0;
            for p = 1:NumPoints
                xpos = round(MaskPoints(2,p));
                ypos = round(MaskPoints(1,p));
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange                 
                   MaskAvg_BF = MaskAvg_BF + double(BFimage(xpos-halfrange : xpos+halfrange, ypos-halfrange : ypos+halfrange));
                   MaskAvg_TXR = MaskAvg_TXR + double(TXRimage(xpos-halfrange+txrX : xpos+halfrange+txrX, ypos-halfrange+txrY : ypos+halfrange+txrY));
                   MaskAvg_GFP = MaskAvg_GFP + double(GFPimage(xpos-halfrange+gfpX : xpos+halfrange+gfpX, ypos-halfrange+gfpY : ypos+halfrange+gfpY));
                   ngoodpoints=ngoodpoints+1;
                end
            end
            if ngoodpoints >= 1
               MaskAvg_BF  = uint16(MaskAvg_BF/ngoodpoints);
               MaskAvg_TXR  = uint16(MaskAvg_TXR/ngoodpoints);
               MaskAvg_GFP  = uint16(MaskAvg_GFP/ngoodpoints);             
            end
        end
        cd(dirname);
        imwrite(MaskAvg_BF,['MaskAvg-' strrep(BFname, '_w1BF.TIF', '') sprintf('-%d-',ngoodpoints) 'w1BF.tif'],'Compression','none');
        imwrite(MaskAvg_TXR,['MaskAvg-' strrep(TXRname, '_w2TXR.TIF', '') sprintf('-%d-',ngoodpoints) 'w2TXR.tif'],'Compression','none');
        imwrite(MaskAvg_GFP,['MaskAvg-' strrep(GFPname, '_w3GFP.TIF', '') sprintf('-%d-',ngoodpoints) 'w3GFP.tif'],'Compression','none'); 
        cd(datapath);
    end 
    
    
% 3. the last step is to go into each folder and creat an averaged image    
    maskinfo = dir('Mask-*.txt');
    cd(dirname);
    fileinfo = dir('MaskAvg*w1BF.tif');
    nfiles=numel(fileinfo);
       
    if nfiles>1
        
        MaskAvg_BF = zeros(masksize,masksize);
        MaskAvg_TXR = zeros(masksize,masksize);
        MaskAvg_GFP = zeros(masksize,masksize);
        total_pillars = 0;

        for i=1:nfiles

            BFname = fileinfo(i).name;
            TXRname = strrep(BFname, 'w1BF','w2TXR');
            GFPname = strrep(BFname, 'w1BF','w3GFP');
            
            cd(datapath);
            maskname = maskinfo(i).name;
            fileID = fopen(maskname,'r');
            MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
            fclose(fileID);           
            nump = numel(MaskPoints(1,:));
            total_pillars = total_pillars + nump;
            
            cd(dirname);
            BFimage = imread(BFname);
            TXRimage = imread(TXRname);
            GFPimage = imread(GFPname);
                
            MaskAvg_BF = MaskAvg_BF + double(BFimage)*nump;
            MaskAvg_TXR = MaskAvg_TXR + double(TXRimage)*nump;
            MaskAvg_GFP = MaskAvg_GFP + double(GFPimage)*nump;

        end

            MaskAvg_BF = uint16(MaskAvg_BF/total_pillars);
            MaskAvg_TXR = uint16(MaskAvg_TXR/total_pillars);
            MaskAvg_GFP = uint16(MaskAvg_GFP/total_pillars);
            
            imwrite(MaskAvg_BF,['All_MaskAvg-' int2str(total_pillars) '-w1BF.tif']);    
            imwrite(MaskAvg_TXR,['All_MaskAvg-' int2str(total_pillars) '-w2TXR.tif']);    
            imwrite(MaskAvg_GFP,['All_MaskAvg-' int2str(total_pillars) '-w3GFP.tif']);    
    end

    cd(datapath); 
    clc;clear;

function bar_gra_avg_Callback(~, ~, ~)
% hObject    handle to bar_gra_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo = dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    mkdir('image average');
    cd(datapath);    
    circlesize = 50;
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;
    temp_bar_count = zeros(10, 1);
    
 %declare main data structure
        barImage = repmat(struct('diameter',[], 'TXR', [], 'GFP', []), 10, 1);
    
    for i = 1:10
        
        barImage(i).diameter = 100*i;
        
        barImage(i).TXR = repmat(struct('position',[], 'rawImage',[], 'imagebkgd', [], 'subimage',[]),100,1);
        barImage(i).GFP = repmat(struct('position',[], 'rawImage',[], 'imagebkgd', [], 'subimage',[]),100,1);
        
        
    end    

% 2. For all masks and related peaks file (ngood point)
    %bar_bucket = zeros(10, 1);%两列是同一个size时run
    %bar_avg_BF = zeros(masksize, masksize, 10);%两列是同一个size时run
    %bar_avg_TXR = zeros(masksize, masksize, 10);%两列是同一个size时run
    %bar_avg_GFP = zeros(masksize, masksize, 10);%两列是同一个size时run
    
    bar_bucket = zeros(20, 1);%每一列是一个size时run
    %bar_avg_BF = zeros(masksize, masksize, 20);%每一列是一个size时run
    bar_avg_TXR = zeros(masksize, masksize, 20);%每一列是一个size时run
    bar_avg_GFP = zeros(masksize, masksize, 20);%每一列是一个size时run
    
    for i=1:nfiles
        maskname = fileinfo(i).name;
        
        %BFname = strrep(strrep(maskname,'Mask-',''),'.txt','_w1BF.TIF') ;
        TXRname = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF') ;
        GFPname = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF') ;
        
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        NumPoints = numel(MaskPoints(1,:));   
        
        if NumPoints > 0        
        %BFimage = imread(BFname);
        TXRimage = imread(TXRname);
        GFPimage = imread(GFPname);
               
        sz = size(TXRimage);
        ysize = sz(1);
        xsize = sz(2);            
            for p = 1:NumPoints
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p);
                barcode = ceil(MaskPoints(3,p)/2);
                temp_bar_count(barcode, 1) = temp_bar_count(barcode, 1) + 1;
                bar = temp_bar_count(barcode, 1);
                
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange
                    
                   %take out masked area and do local bkgd sub
                  
                   txrArea=TXRimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);
                   gfpArea=GFPimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange);
                   
                   barImage(barcode).TXR(bar).rawImage = txrArea;
                   barImage(barcode).TXR(bar).position = [xpos ypos];
                   barImage(barcode).GFP(bar).rawImage = gfpArea;
                   barImage(barcode).GFP(bar).position = [xpos ypos];    
                   
                   %caculate bkgd
                   txrArea_bkg=mean(mean([txrArea(1:15,1:51) txrArea(37:51,1:51)]));
                   gfpArea_bkg=mean(mean([gfpArea(1:15,1:51) gfpArea(37:51,1:51)]));
                   
                  
                   
                   txrArea_sub=txrArea-txrArea_bkg;
                   gfpArea_sub=gfpArea-gfpArea_bkg;
                   
                   
                   barImage(barcode).TXR(bar).subimage = txrArea_sub;
                   barImage(barcode).GFP(bar).subimage = gfpArea_sub;
                                      
                   
                   bar_avg_TXR(:, :, barcode) = bar_avg_TXR(:, :, barcode) + double(txrArea_sub);
                   bar_avg_GFP(:, :, barcode) = bar_avg_GFP(:, :, barcode) + double(gfpArea_sub);
                   bar_bucket(barcode, 1) = bar_bucket(barcode, 1) + 1;
                      
                   
                end
            end
        end
    end 
    cd('image average');
%     for i = 1:10 %两列是同一个size时run
      for i = 1:20 %每一列是一个size时run
        if bar_bucket(i,1) > 0 
            
            MaskAvg_TXR = uint16(bar_avg_TXR(:, :, i)/bar_bucket(i,1)); 
            MaskAvg_GFP = uint16(bar_avg_GFP(:, :, i)/bar_bucket(i,1)); 
           
            imwrite(MaskAvg_TXR,['MaskAvg-' sprintf('bar-0%d_%d_', i, bar_bucket(i,1)) 'w2TXR.tif'],'Compression','none'); 
            imwrite(MaskAvg_GFP,['MaskAvg-' sprintf('bar-0%d_%d_', i, bar_bucket(i,1)) 'w3GFP.tif'],'Compression','none'); 
       
        end
    end 
    
    
    cd(datapath);
    fileID = fopen('bar_count.txt','w');
    fprintf(fileID,'%d %d %d %d %d %d %d %d %d %d\n',bar_bucket(:,1));
    fclose(fileID);
    save('barImage', 'barImage');
    clc;clear;

function Bar_Gra_Ratio_Callback(~, ~, ~)
% hObject    handle to Bar_Gra_Ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to nanobar_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    
    circlesize = 50;
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1; 
    
    %prompt = {'Enter endwidth','Enter max', 'Enter maxcen'};
    %dlg_title = 'pixel selection for curvature analysis';
    %num_lines = 1;
    %def = {'0','0','0','0'};
    %answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    %endwidth = str2double(answer{1});
    %max = str2double(answer{2});
    %maxcen = str2double(answer{3});
    
    %areaOfPixel = 0.017161; 
    % (0.131um)^2 (Leica2 bin2*2, 100x oil)  
    % Bar end square width = 2*endwidth + 1

    %pixel = (2*endwidth+1)^2;
    
% 2. declare main data structure   
    % barData -> nFiles
    %            masksize
    %            bar info      -->  diameter
    %                               nbar
    %                               {TXR, GFP} -->  filename
    %                                               subImage
    %                                               position
    %                                               end1
    %                                               end2
    %                                               center
    %                                               bkgd    
    
    % rawDataTXR/rawDataGFP -> diameter
    %                       -> data
    barData.nFiles = nfiles;
    barData.masksize = masksize;
    barData.barInfo = repmat(struct('diameter',[], 'nbar', [], 'maskPoint', [], 'TXR', [], 'GFP', []), 10, 1);
    
%     %rawDataTXR = repmat(struct('diameter', [], 'data', []), 10, 1);%两列是同一个size时run
%     %rawDataGFP = repmat(struct('diameter', [], 'data', []), 10, 1);%两列是同一个size时run
%     processData = repmat(struct('diameter', [], 'ratio',[]), 10, 1);%两列是同一个size时run
    
    rawDataTXR = repmat(struct('diameter', [], 'data', []), 20, 1);%每一列是一个size时run
    rawDataGFP = repmat(struct('diameter', [], 'data', []), 20, 1);%每一列是一个size时run
    processData = repmat(struct('diameter', [], 'ratio',[]), 20, 1);%每一列是一个size时run
    
    fileID = fopen('bar_count.txt','r');
%     bar_count = fscanf(fileID,'%d %d %d %d %d %d %d %d %d %d', [10 inf]);%两列是同一个size时run
    bar_count = fscanf(fileID,'%d %d %d %d %d %d %d %d %d %d', [20 inf]);%每一列是一个size时run
    fclose(fileID);
    
%     temp_bar_count = zeros(10, 1);%两列是同一个size时run
    temp_bar_count = zeros(20, 1);%每一列是一个size时run
    
%     for i = 1:10 %两列是同一个size时run
    for i = 1:20 %每一列是一个size时run  
        barData.barInfo(i).diameter = 1000-100*(i-1);
        barData.barInfo(i).nbar = bar_count(i, 1);
        barData.barInfo(i).TXR = repmat(struct('subImage',[], 'position',[], 'end1', [], ...
                                                   'end2', [], 'center1', [], 'center2', [], 'bkgd', [], 'end1area', [], 'end2area', [], 'cen1area', [], 'cen2area', [], 'bkgdarea', []), bar_count(i, 1), 1);
        barData.barInfo(i).GFP = repmat(struct('subImage',[], 'position',[], 'end1', [], ...
                                                    'end2', [], 'center1', [], 'center2', [], 'bkgd', [], 'end1area', [], 'end2area', [], 'cen1area', [], 'cen2area', [], 'bkgdarea', []),bar_count(i, 1), 1);
        %rawDataTXR(i).diameter = 1000-100*(i-1);
        %rawDataTXR(i).data = zeros(bar_count(i, 1), 4);
        %rawDataTXR(i).ratio = zeros(bar_count(i, 1), 2);
        %rawDataGFP(i).diameter = 1000-100*(i-1);
        %rawDataGFP(i).data = zeros(bar_count(i, 1), 4);
        %rawDataGFP(i).ratio = zeros(bar_count(i, 1), 2);
        processData(i).diameter = 1000-100*(i-1);
        processData(i).ratio = zeros(bar_count(i, 1), 1);
        
    end

    load('BarGraCaliGFP.mat');
    load('BarGraCaliTXR.mat');
    load('BarGraRadius.mat');
    
    
% 3. For all masks and related peaks file
    for i=1:nfiles        
        % define image name
        maskname = fileinfo(i).name;
        txrName = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF');
        gfpName = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF');
        
        % read mask file
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        % read image files
        txrImage = double(imread(txrName));
        gfpImage = double(imread(gfpName));      
                                                
% 4. For every peak in the mat files
        NumPoints = size(MaskPoints, 2);
        if NumPoints>0
            for p=1:NumPoints   
                
                % Three points, two ends and the center                
                xend1 = MaskPoints(2,p);
                yend1 = MaskPoints(1,p);
                
                bar_n = ceil(MaskPoints(3,p)/2);
                temp_bar_count(bar_n, 1) = temp_bar_count(bar_n, 1) + 1;
                bar = temp_bar_count(bar_n, 1);
                caliTXR = BarGraCaliTXR(:,bar_n);
                caliGFP = BarGraCaliGFP(:,bar_n);
                
                BarRadius = BarGraRadius(:,bar_n);
               
                           
                % Take out the masked area and save
                txrArea = txrImage(xend1-halfrange : xend1+halfrange, ...
                                   yend1-halfrange : yend1+halfrange);
                gfpArea = gfpImage(xend1-halfrange: xend1+halfrange, ...
                                   yend1-halfrange : yend1+halfrange);
                
                barData.barInfo(bar_n).TXR(bar).subImage = txrArea;
                barData.barInfo(bar_n).TXR(bar).position = [xend1 yend1];
                barData.barInfo(bar_n).GFP(bar).subImage = gfpArea;
                barData.barInfo(bar_n).GFP(bar).position = [xend1 yend1];               
                 
              

                % calculate the end position
                txr_xend1 = halfrange + caliTXR(1, 1); txr_yend1 = halfrange + caliTXR(2, 1);
                gfp_xend1 = halfrange + caliGFP(1, 1); gfp_yend1 = halfrange + caliGFP(2, 1);               
                
                txr_xend2 = halfrange + caliTXR(3, 1); txr_yend2 = halfrange + caliTXR(4, 1);
                gfp_xend2 = halfrange + caliGFP(3, 1); gfp_yend2 = halfrange + caliGFP(4, 1);
                
                %txr_xcen1 = halfrange + caliTXR(5, 1); txr_ycen1 = halfrange + caliTXR(6, 1);
                %gfp_xcen1 = halfrange + caliGFP(5, 1); gfp_ycen1 = halfrange + caliGFP(6, 1);
                
                %txr_xcen2 = halfrange + caliTXR(7, 1); txr_ycen2 = halfrange + caliTXR(8, 1);
                %gfp_xcen2 = halfrange + caliGFP(7, 1); gfp_ycen2 = halfrange + caliGFP(8, 1);
                
                % define the area of end1, end2, center, bkgd and calculate the total intensity 
              
              
                radius = BarRadius (1,1);
                %maxcen = maxp (2,1);
                %max = maxp (3,1);
                %pixel = (2*endwidth+1)^2;
           
                TXRend1area = txrArea(txr_xend1-radius : txr_xend1+radius,...
                                          txr_yend1 : txr_yend1+radius);
                                      
                TXRend2area = txrArea(txr_xend2-radius : txr_xend2+radius,...
                                          txr_yend2-radius : txr_yend2);
                                      
                %TXRcenter1area = txrArea(txr_xcen1-1 : txr_xcen1+1,...
                                            %txr_ycen1-1 : txr_ycen1+1);
                                        
                %TXRcenter2area = txrArea(txr_xcen2-1 : txr_xcen2+1,...
                                            %txr_ycen2-1 : txr_ycen2+1);
                                        
                GFPend1area = gfpArea(gfp_xend1-radius : gfp_xend1+radius,...
                                          gfp_yend1 : gfp_yend1+radius);
                                      
                GFPend2area = gfpArea(gfp_xend2-radius : gfp_xend2+radius,...
                                          gfp_yend2-radius : gfp_yend2);
                                      
                %GFPcenter1area = gfpArea(gfp_xcen1-1 : gfp_xcen1+1,...
                                            %gfp_ycen1-1 : gfp_ycen1+1);
                                        
                %GFPcenter2area = gfpArea(gfp_xcen2-1 : gfp_xcen2+1,...
                                            %gfp_ycen2-1 : gfp_ycen2+1);                        
                                        
                %RTXRend1 = reshape(txrArea(txr_xend1-endwidth : txr_xend1+endwidth,...
                                          %txr_yend1-endwidth : txr_yend1+endwidth),[1,pixel]);
                
                %RTXRend2 = reshape(txrArea(txr_xend2-endwidth : txr_xend2+endwidth,...
                                          %txr_yend2-endwidth : txr_yend2+endwidth),[1,pixel]);
                                      
                %RTXRcen1 = reshape(txrArea(txr_xcen1-endwidth : txr_xcen1+endwidth,...
                                           %txr_ycen1-endwidth : txr_ycen1+endwidth),[1,pixel]);  
                                        
                %RTXRcen2 = reshape(txrArea(txr_xcen2-endwidth : txr_xcen2+endwidth,...
                                            %txr_ycen2-endwidth : txr_ycen2+endwidth),[1,pixel]);                                         
                                      
                %RGFPend1 = reshape(gfpArea(gfp_xend1-endwidth : gfp_xend1+endwidth,...
                                          %gfp_yend1-endwidth : gfp_yend1+endwidth),[1,pixel]);
                
                %RGFPend2 = reshape(gfpArea(gfp_xend2-endwidth : gfp_xend2+endwidth,...
                                          %gfp_yend2-endwidth : gfp_yend2+endwidth),[1,pixel]);
                                      
                %RGFPcen1 = reshape(gfpArea(gfp_xcen1-endwidth : gfp_xcen1+endwidth,...
                                           %gfp_ycen1-endwidth : gfp_ycen1+endwidth),[1,pixel]);

                %RGFPcen2 = reshape(gfpArea(gfp_xcen2-endwidth : gfp_xcen2+endwidth,...
                                            %gfp_ycen2-endwidth : gfp_ycen2+endwidth),[1,pixel]);
                                  
                %STXRend1 = sort(RTXRend1,'descend');
               
                %STXRend2 = sort(RTXRend2,'descend');
                                      
                %STXRcen1 = sort(RTXRcen1,'descend');
                
                %STXRcen2 = sort(RTXRcen2, 'descend');
                                      
                %SGFPend1 = sort(RGFPend1,'descend');
                
                %SGFPend2 = sort(RGFPend2,'descend');
                                      
                %SGFPcen1 = sort(RGFPcen1,'descend');
                
                %SGFPcen2 = sort(RGFPcen2,'descend');
                
               
                
                TXRend1 = sum(sum(TXRend1area(:)));
                
                TXRend2 = sum(sum(TXRend2area(:)));
                                      
                %TXRcen1 = mean(STXRcen1(1:maxcen));
                
                %TXRcen2 = mean(STXRcen2(1:maxcen));
                                      
                GFPend1 = sum(sum(GFPend1area(:)));
                
                GFPend2 = sum(sum(GFPend2area(:)));
                                      
                %GFPcen1 = mean(SGFPcen1(1:maxcen));
                
                %GFPcen2 = mean(SGFPcen2(1:maxcen));
                
                
                % calculate the background
                
                TXRbkgd_x = halfrange - 15;
                
                TXRbkgd_y = halfrange - 15;
                
                GFPbkgd_x = halfrange - 15;
                
                GFPbkgd_y = halfrange - 15;
                
                TXRbkgdarea = txrArea(TXRbkgd_x - 4 : TXRbkgd_x + 4,...
                                            TXRbkgd_y - 4 : TXRbkgd_y + 4);
                                        
                GFPbkgdarea = gfpArea(GFPbkgd_x - 4 : GFPbkgd_x + 4,...
                                            GFPbkgd_y - 4 : GFPbkgd_y + 4);
                                        
                TXRbkgd = (sum(sum(TXRbkgdarea(:))));
                GFPbkgd = (sum(sum(GFPbkgdarea(:))));                  
                                        
                % save the data
                barData.barInfo(bar_n).TXR(bar).end1 = TXRend1;
                barData.barInfo(bar_n).TXR(bar).end2 = TXRend2;
                %barData.barInfo(bar_n).TXR(bar).center1 = TXRcen1-TXRbkgd;
                %barData.barInfo(bar_n).TXR(bar).center2 = TXRcen2-TXRbkgd;
                barData.barInfo(bar_n).TXR(bar).bkgd = TXRbkgd;
                barData.barInfo(bar_n).TXR(bar).end1area = TXRend1area;
                barData.barInfo(bar_n).TXR(bar).end2area = TXRend2area;
                %barData.barInfo(bar_n).TXR(bar).cen1area = TXRcenter1area;
                %barData.barInfo(bar_n).TXR(bar).cen2area = TXRcenter2area;
                barData.barInfo(bar_n).TXR(bar).bkgdarea = TXRbkgdarea;
                
                
                
                barData.barInfo(bar_n).GFP(bar).end1 = GFPend1;
                barData.barInfo(bar_n).GFP(bar).end2 = GFPend2;
                %barData.barInfo(bar_n).GFP(bar).center1 = GFPcen1-GFPbkgd;
                %barData.barInfo(bar_n).GFP(bar).center2 = GFPcen2-GFPbkgd;
                barData.barInfo(bar_n).GFP(bar).bkgd = GFPbkgd;
                barData.barInfo(bar_n).GFP(bar).end1area = GFPend1area;
                barData.barInfo(bar_n).GFP(bar).end2area = GFPend2area;
                %barData.barInfo(bar_n).GFP(bar).cen1area = GFPcenter1area;
                %barData.barInfo(bar_n).GFP(bar).cen2area = GFPcenter2area;
                barData.barInfo(bar_n).GFP(bar).bkgdarea = GFPbkgdarea;
                
                %rawDataTXR(bar_n).data(bar,:) = [TXRend1-TXRbkgd (TXRcen1+TXRcen2)/2-TXRbkgd TXRend2-TXRbkgd TXRbkgd];
                %rawDataTXR(bar_n).ratio(bar,:) = [abs((TXRend1-TXRbkgd))/(abs(TXRcen1-TXRbkgd)) (abs(TXRend2-TXRbkgd))/(abs(TXRcen1-TXRbkgd))];
                %rawDataGFP(bar_n).data(bar,:) = [GFPend1-GFPbkgd (GFPcen1+GFPcen2)/2-GFPbkgd GFPend2-GFPbkgd GFPbkgd];
                %rawDataGFP(bar_n).ratio(bar,:) = [abs((GFPend1-GFPbkgd))/(abs(GFPcen1-GFPbkgd)) (abs(GFPend2-GFPbkgd))/(abs(GFPcen1-GFPbkgd))];
                processData (bar_n).ratio(bar,:) = ((GFPend1+GFPend2)/2)/((TXRend1+TXRend2)/2);
               
            end
        end
    end
      
    save('BarData', 'barData');
    %save('RawTXR', 'rawDataTXR');
    %save('RawGFP', 'rawDataGFP');
    save('processData','processData');
    clc;clear;

function pillar_gra_avg_Callback(~, ~, ~)
% hObject    handle to pillar_gra_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo = dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    mkdir('image average');
    cd(datapath);    
    circlesize = 50;
    halfrange = round(circlesize/2);
    masksize = halfrange*2+1;

% 2. For all masks and related peaks file (ngood point)
    pillar_bucket = zeros(33, 1);
    pillar_avg_BF = zeros(masksize, masksize, 33);
    pillar_avg_TXR = zeros(masksize, masksize, 33);
    pillar_avg_GFP = zeros(masksize, masksize, 33);
    for i=1:nfiles
        maskname = fileinfo(i).name;
        
        BFname = strrep(strrep(maskname,'Mask-',''),'.txt','_w1BF.TIF') ;
        TXRname = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF') ;
        GFPname = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF') ;
        
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        NumPoints = numel(MaskPoints(1,:));   
        
        if NumPoints > 0        
        BFimage = imread(BFname);
        TXRimage = imread(TXRname);
        GFPimage = imread(GFPname);
               
        sz = size(TXRimage);
        ysize = sz(1);
        xsize = sz(2);            
            for p = 1:NumPoints
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p);
                barcode = MaskPoints(3,p);
                if xpos>=halfrange+1 && xpos<=ysize-halfrange && ypos>=halfrange+1 && ypos<=xsize-halfrange                 
                   pillar_avg_BF(:, :, barcode) = pillar_avg_BF(:, :, barcode) + double(BFimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   pillar_avg_TXR(:, :, barcode) = pillar_avg_TXR(:, :, barcode) + double(TXRimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   pillar_avg_GFP(:, :, barcode) = pillar_avg_GFP(:, :, barcode) + double(GFPimage(xpos-halfrange:xpos+halfrange,ypos-halfrange:ypos+halfrange));
                   pillar_bucket(barcode, 1) = pillar_bucket(barcode, 1) + 1;
                end
            end
        end
    end 
    cd('image average');
    for i = 1:33
        if pillar_bucket(i,1) > 0
            MaskAvg_BF = uint16(pillar_avg_BF(:, :, i)/pillar_bucket(i,1));
            MaskAvg_TXR = uint16(pillar_avg_TXR(:, :, i)/pillar_bucket(i,1));
            MaskAvg_GFP = uint16(pillar_avg_GFP(:, :, i)/pillar_bucket(i,1));
            imwrite(MaskAvg_BF,['MaskAvg-' sprintf('bar-%d_%d_', i, pillar_bucket(i,1)) 'w1Brightfield.tif'],'Compression','none');
            imwrite(MaskAvg_TXR,['MaskAvg-' sprintf('bar-%d_%d_', i, pillar_bucket(i,1)) 'w2TXR.tif'],'Compression','none');
            imwrite(MaskAvg_GFP,['MaskAvg-' sprintf('bar-%d_%d_', i, pillar_bucket(i,1)) 'w3GFP.tif'],'Compression','none'); 
        end
    end 
    cd(datapath);
    fileID = fopen('pillar_count.txt','w');
    fprintf(fileID,'%d %d %d\n',pillar_bucket(:,1));
    fclose(fileID);
    clc;clear;

function piller_gra_inten_Callback(~, ~, ~)
% hObject    handle to piller_gra_inten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles=numel(fileinfo);
    
    circlesize = 30;
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;
    center = halfrange + 1;
    
    %areaOfPixel = 0.017161; % (0.131um)^2 (Leica2 bin2*2, 100x oil)

    
    pillarRange_GFP = [6 6 6 6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 4 4 4 4];
    pillarRange = [6 6 6 6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 4 4 4 4];
    caliTXR = [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1  2  2; ...
                -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1  0  0  0  1  1  1  1  1  1  1  1  1  2  2];
    caliGFP = [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1  1  1  1  1; ...
                1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2];
    backRange = 4;      
    
    fileID = fopen('pillar_count.txt','r');
    pillar_count = fscanf(fileID,'%d %d %d', [3 inf]);
    fclose(fileID);
    
    pillar_count = reshape(pillar_count, [], 1);
    pillar_count_temp = zeros(33, 1);
    
    rawData = repmat(struct('diameter', [], 'TXR', [], 'GFP', [], 'ratio', [], 'TXRi', [], 'GFPi', []), 33, 1);
    
    for i = 1:33
        rawData(i).diameter = round(1000-(900/32*(i-1)));
        rawData(i).TXR = zeros(pillar_count(i, 1), 2);
        rawData(i).GFP = zeros(pillar_count(i, 1), 2);
        rawData(i).ratio = zeros(pillar_count(i, 1), 3);
    end
    
% 2. For all masks and related peaks file
    for i=1:nfiles
        maskname=fileinfo(i).name;
        TXRname = strrep(strrep(maskname, 'Mask-', ''),'.txt','_w2TXR.TIF');
        GFPname = strrep(strrep(maskname, 'Mask-', ''),'.txt','_w3GFP.TIF');
        
        %open mask and peak files
        fileID = fopen(maskname,'r');
        MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
        fclose(fileID);
        
        TXRimage = double(imread(TXRname));
        GFPimage = double(imread(GFPname));
        
% 3. For every peak in the mat files
        NumPoints = numel(MaskPoints(1,:));
        if NumPoints>0
            for p=1:NumPoints   
                
                xpos = MaskPoints(2,p);
                ypos = MaskPoints(1,p); 
                pillar_n = MaskPoints(3,p);
                pillar_count_temp(pillar_n, 1) = pillar_count_temp(pillar_n, 1) + 1;
                pillar = pillar_count_temp(pillar_n, 1);
                
                %caliTXR_X = caliTXR(1, pillar_n); caliTXR_Y = caliTXR(2, pillar_n);
                %caliGFP_X = caliGFP(1, pillar_n); caliGFP_Y = caliGFP(2, pillar_n);
                %pillarRange_n = pillarRange(1, pillar_n);
                %pillarRange_nGFP = pillarRange_GFP(1, pillar_n);
                caliTXR_X = 0; caliTXR_Y = 0;
                caliGFP_X = 0; caliGFP_Y = 0;                
                
                % 13pixel
                pillarRange_n = 6;
                pillarRange_nGFP = 6; 
                
                % Take out the masked area, which is one of the peaks
                TXR_mask = TXRimage( xpos-halfrange+caliTXR_X : xpos+halfrange+caliTXR_X ,...
                                     ypos-halfrange+caliTXR_Y : ypos+halfrange+caliTXR_Y );
                GFP_mask = GFPimage( xpos-halfrange+caliGFP_X : xpos+halfrange+caliGFP_X ,...
                                     ypos-halfrange+caliGFP_Y : ypos+halfrange+caliGFP_Y );
                
                TXRParea = TXR_mask( center-pillarRange_n : center+pillarRange_n , ...
                                               center-pillarRange_n : center+pillarRange_n ); 
                                           
                GFPParea = GFP_mask( center-pillarRange_nGFP : center+pillarRange_nGFP , ...
                                               center-pillarRange_nGFP : center+pillarRange_nGFP );

                TXR_pillar = sum(sum(TXR_mask( center-pillarRange_n : center+pillarRange_n , ...
                                               center-pillarRange_n : center+pillarRange_n )));        
                    
                GFP_pillar = sum(sum(GFP_mask( center-pillarRange_nGFP : center+pillarRange_nGFP , ...
                                               center-pillarRange_nGFP : center+pillarRange_nGFP )));                         
                              
                TXR_bkgd = [TXR_mask(1:backRange,1:masksize-backRange), TXR_mask(1:masksize-backRange,masksize-backRange+1:masksize).', ...
                            TXR_mask(backRange+1:masksize,1:backRange).' TXR_mask(masksize-backRange+1:masksize,backRange+1:masksize)];
                TXR_background = median(TXR_bkgd(:)) * (2*pillarRange_n+1)^2;
         	    TXR_cali = TXR_pillar/TXR_background;
                
                GFP_bkgd = [GFP_mask(1:backRange,1:masksize-backRange), GFP_mask(1:masksize-backRange,masksize-backRange+1:masksize).', ...
                            GFP_mask(backRange+1:masksize,1:backRange).' GFP_mask(masksize-backRange+1:masksize,backRange+1:masksize)];
                GFP_background = median(GFP_bkgd(:)) * (2*pillarRange_n+1)^2;
         	    GFP_cali = GFP_pillar/GFP_background;  
                
                rawData(pillar_n).TXRi(pillar).TXRbkgd = TXR_bkgd;
                rawData(pillar_n).TXRi(pillar).TXRpillar = TXRParea;
                rawData(pillar_n).GFPi(pillar).GFPbkgd = GFP_bkgd;
                rawData(pillar_n).GFPi(pillar).GFPpillar = GFPParea;
                rawData(pillar_n).TXR(pillar, :) = [TXR_pillar TXR_background];
                rawData(pillar_n).GFP(pillar, :) = [GFP_pillar GFP_background];
                rawData(pillar_n).ratio(pillar, :) = [TXR_cali GFP_cali GFP_cali/TXR_cali];               
            end
        end
    end 
    save('rawData', 'rawData');
    
%%%%%%%%%%%%%%%%%%%%%%%%% Actin PROCESS END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
function nanobar_analysis_ver2_Callback(hObject, eventdata, handles)
% hObject    handle to nanobar_analysis_ver2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the avg image
    cur_folder = cd;
    cd('image average');
    [datafile,~]=uigetfile('All_MaskAvg*.tif','Choose a avg-mask tif file');
    if datafile==0, return; end
    
    prompt = {'0: TXR, 1: GFP'};
    dlg_title = 'Which channel?';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    channel_answer = str2double(answer{1});
    
    fileinfo=imfinfo(datafile);
    NumFrames=numel(fileinfo);
    imagesizex=fileinfo(1).Height;
    imagesizey=fileinfo(1).Width;
    
    Data=zeros(imagesizex,imagesizey,NumFrames);
    for k=1:NumFrames
        Data(:,:,k)=imread(datafile,k,'Info',fileinfo);
    end
    set(handles.FileName,'String',[datafile '   -   ' num2str(NumFrames) ' frames']);
    
    image_t=squeeze(Data(:,:,1));
    low=min(min(image_t));
    high=max(max(image_t));
    high=ceil(high*1.5);
    handles.ColorRange=[low high];
    set(handles.ColorSlider,'min',low);
    set(handles.ColorSlider,'max',high);
    set(handles.ColorSlider,'value',floor((low+high)/2));
    set(handles.ColorSlider,'SliderStep',[(high-low)/high/100 0.1]);
    
    if NumFrames>1
        set(handles.FrameSlider,'min',1);
        set(handles.FrameSlider,'max',NumFrames);
        set(handles.FrameSlider,'value',1);
        set(handles.FrameSlider,'SliderStep',[1/(NumFrames-1) 0.1]);
    end

    axes(handles.axes1);
    handles.image_t=image_t;
    handles.imagehandle=imshow(image_t',[low high]); %%transposed matrix when plotting
    colormap(gray);
    
    cd(cur_folder);
    
% Set the side area     
    position = zeros(1, 8);
    
    for i = 1:4 % 1,2 for two ends, 3, 4 for two sidesfor two side
    
    set(handles.DisplayText,'String','Select a point using left button');
    [xi,yi,but] = ginput(1);    %Graphical input from a mouse or cursor
    
    if but == 1 % 1 = left click
       anotherX = round(xi);
       anotherY = round(yi);
       ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
    end
    
    while but ~= 3 % 3 = right click
        set(handles.DisplayText,'String',but);
        [~,~,but] = ginput(1);    %Graphical input from a mouse or cursor

        if but == 28
            delete(ln);
            anotherX=anotherX-1;
            ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        elseif but == 30
            delete(ln);
            anotherY=anotherY-1;
            ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        elseif but == 29
            delete(ln);
            anotherX=anotherX+1;
            ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        elseif but == 31
            delete(ln);
            anotherY=anotherY+1;
             ln = line(anotherX,anotherY,'marker','s','MarkerSize', 60,'color','r','LineStyle','none');
        end
    end
        
    position(1, 2*i-1) = anotherX-30;
    position(1, 2*i) = anotherY-30;
    end
    
    if channel_answer == 0
        fileID = fopen('TXR_position.txt','w');    
    else
        fileID = fopen('GFP_position.txt','w'); 
    end
    
    fprintf(fileID,'%d %d %d %d %d %d %d %d\n',position(1, :));
    fclose(fileID);
    
    disp(position);
    
    % 1. Find mask files
    fclose all;
    [datafile,datapath]=uigetfile('Mask-*.txt','Choose a 2D Mask file');
    if datafile==0, return; end
    cd(datapath);
    fileinfo=dir('Mask-*.txt');
    nfiles = numel(fileinfo);
    
    circlesize = 60;
    halfrange = round(circlesize/2);
    masksize = 2*halfrange + 1;    
    %areaOfPixel = 0.017161; 
    % (0.131um)^2 (Leica2 bin2*2, 100x oil)  
    endwidth = 3; % Bar end square width = 2*endwidth + 1
    
    prompt = {'0: No Calibration, 1: Calibration'};
    dlg_title = 'With Calibration?';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    cali_bool = str2double(answer{1});

    
    
    
    % read the calibration file
    if cali_bool == 1
        fileID = fopen('calibration.txt','r');
        cali_position = fscant(fileID,'%d %d %d %d %d %d %d %d', [8 inf]);
        fclose(fileID);
    else
        fileID = fopen('barend.txt','r');
        barend = fscant(fileID,'%d %d', [2 inf]);
        fclose(fileID);
        cali_position = transpose(repmat([0 0 barend(1, 1) barend(2, 1) 0 0 barend(1, 1) barend(2, 1)], nfiles, 1));
    end
    
% 3. For all masks and related peaks file
    cali_xend1 = position(1, 1); cali_yend1 = position(1, 2);
    cali_xend2 = position(1, 3); cali_yend2 = position(1, 4);
    cali_xside1 = position(1, 5); cali_yside1 = position(1, 6);
    cali_xside2 = position(1, 7); cali_yside2 = position(1, 8);  
    
    if channel_answer == 0
        rawDataTXR = [];
        for i=1:nfiles
            maskname = fileinfo(i).name;
            txrName = strrep(strrep(maskname,'Mask-',''),'.txt','_w2TXR.TIF');
            
            fileID = fopen(maskname,'r');
            MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
            fclose(fileID);
            nBar = size(MaskPoints, 2);
            
            txrImage = double(imread(txrName));           
            txrX = cali_position(1, i); txrY = cali_position(2, i);
            
            NumPoints = nBar;
            if NumPoints>0
                for p=1:NumPoints  
                    xend1 = MaskPoints(2,p);
                    yend1 = MaskPoints(1,p);
                    if xend1 * yend1 ~= 0                      
                        txrArea = txrImage(xend1-halfrange+txrX : ...
                                           xend1+halfrange+txrX, ...
                                           yend1-halfrange+txrY : ...
                                           yend1+halfrange+txrY);
                        txr_xend1 = halfrange + cali_xend1; 
                        txr_yend1 = halfrange + cali_yend1;
                        txr_xend2 = halfrange + cali_xend2;
                        txr_yend2 = halfrange + cali_yend2;
                        txr_xside1 = halfrange + cali_xside1;
                        txr_yside1 = halfrange + cali_yside1;
                        txr_xside2 = halfrange + cali_xside2;
                        txr_yside2 = halfrange + cali_yside2;
                        txr_xcenter = round((txr_xend1 + txr_xend2)/2);
                        txr_ycenter = round((txr_yend1 + txr_yend2)/2);
                        
                        TXRend1 = sum(sum(txrArea(txr_xend1-endwidth : txr_xend1+endwidth,...
                                          txr_yend1-endwidth : txr_yend1+endwidth)));                
                        TXRend2 = sum(sum(txrArea(txr_xend2-endwidth : txr_xend2+endwidth,...
                                          txr_yend2-endwidth : txr_yend2+endwidth)));
                        TXRside1 = sum(sum(txrArea(txr_xside1-endwidth : txr_xside1+endwidth,...
                                          txr_yside1-endwidth : txr_yside1+endwidth)));                
                        TXRside2 = sum(sum(txrArea(txr_xside2-endwidth : txr_xside2+endwidth,...
                                          txr_yside2-endwidth : txr_yside2+endwidth)));
                        TXRcenter = sum(sum(txrArea(txr_xcenter-endwidth : txr_xcenter+endwidth,...
                                          txr_ycenter-endwidth : txr_ycenter+endwidth)));
                        rawDataTXR = [rawDataTXR; TXRend1 (TXRside1+TXRside2)/2 TXRend2 TXRcenter];
                    end
                end
            end
        end
        save('NewRawTXR', 'rawDataTXR');
    else
        rawDataGFP = [];
        for i=1:nfiles
            maskname = fileinfo(i).name;
            gfpName = strrep(strrep(maskname,'Mask-',''),'.txt','_w3GFP.TIF');
            
            fileID = fopen(maskname,'r');
            MaskPoints = fscanf(fileID,'%d %d %d', [3 inf]);
            fclose(fileID);
            nBar = size(MaskPoints, 2);
            
            gfpImage = double(imread(gfpName));
            gfpX = cali_position(5, i); gfpY = cali_position(6, i);
            
            NumPoints = nBar;
            if NumPoints>0
                for p=1:NumPoints  
                    xend1 = MaskPoints(2,p);
                    yend1 = MaskPoints(1,p);
                    if xend1 * yend1 ~= 0
                        gfpArea = gfpImage(xend1-halfrange+gfpX : ...
                                           xend1+halfrange+gfpX, ...
                                           yend1-halfrange+gfpY : ...
                                           yend1+halfrange+gfpY);
                        gfp_xend1 = halfrange + cali_xend1; 
                        gfp_yend1 = halfrange + cali_yend1;
                        gfp_xend2 = halfrange + cali_xend2;
                        gfp_yend2 = halfrange + cali_yend2;
                        gfp_xside1 = halfrange + cali_xside1;
                        gfp_yside1 = halfrange + cali_yside1;
                        gfp_xside2 = halfrange + cali_xside2;
                        gfp_yside2 = halfrange + cali_yside2;
                        gfp_xcenter = round((gfp_xend1 + gfp_xend2)/2);
                        gfp_ycenter = round((gfp_yend1 + gfp_yend2)/2);
                        
                        GFPend1 = sum(sum(gfpArea(gfp_xend1-endwidth : gfp_xend1+endwidth,...
                                          gfp_yend1-endwidth : gfp_yend1+endwidth)));
                        GFPend2 = sum(sum(gfpArea(gfp_xend2-endwidth : gfp_xend2+endwidth,...
                                          gfp_yend2-endwidth : gfp_yend2+endwidth)));
                        GFPside1 = sum(sum(gfpArea(gfp_xside1-endwidth : gfp_xside1+endwidth,...
                                          gfp_yside1-endwidth : gfp_yside1+endwidth)));
                        GFPside2 = sum(sum(gfpArea(gfp_xside2-endwidth : gfp_xside2+endwidth,...
                                          gfp_yside2-endwidth : gfp_yside2+endwidth)));
                        GFPcenter = sum(sum(gfpArea(gfp_xcenter-endwidth : gfp_xcenter+endwidth,...
                                          gfp_ycenter-endwidth : gfp_ycenter+endwidth)));
                        rawDataGFP = [rawDataGFP; GFPend1 (GFPside1+GFPside2)/2 GFPend2 GFPcenter];
                    end
                end
            end
        end
        save('NewRawGFP', 'rawDataGFP');
    end
    clc;clear;
                                                
    
    
