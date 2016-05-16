function varargout = GUI(varargin)
% Enter "GUI" (without quotes) at the Matlab prompt to run the Graphical User Interface of the package CPMC-Lab
% NOTE: This GUI (but not other files in the CPMC-Lab package) is only compatible with Matlab release R2010b and above.
%
% Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang
% ©2014 v1.0
% Package homepage: http://cpmc-lab.wm.edu
% Distributed under the <a href="matlab: web('http://cpc.cs.qub.ac.uk/licence/licence.html')">Computer Physics Communications Non-Profit Use License</a>
% Any publications resulting from either applying or building on the present package 
%   should cite the following journal article (in addition to the relevant literature on the method):
% "CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations" Comput. Phys. Commun. (2014)

    warning off MATLAB:uitabgroup:OldVersion;
    global stopSignal;
    stopSignal = 0;
    global energyPlotPanel walkerPanel densityPanel weightPlotPanel energyPlot weightPlot;
    global currentLxValue currentLyValue currentLzValue;
    handles.MIN_VERSION=8.1; %Minimum compatible matlab version
    GUI_POSITION=[20 20 1300 750];

    %properties of parameter text labels:
    PARA_LABEL_TOP_Y_COORD=11/12;
    PARA_LABEL_LEFT_X_COORD=0.05;
    PARA_LABEL_FONT_SIZE=13;
    PARA_LABEL_HEIGHT=1/12*.7;
    PARA_LABEL_WIDTH=0.3;
    PARA_LABEL_VERT_DISTANCE=1/12;

    %properties of parameber input fields:
    PARA_EDIT_TOP_Y_COORD=11/12+0.02;
    PARA_EDIT_LEFT_X_COORD=0.55;
    PARA_EDIT_HEIGHT=1/12*.7;
    PARA_EDIT_WIDTH=0.3;
    PARA_EDIT_VERT_DISTANCE=1/12; %vertical distance between two paramter labels

    %default values for parameters:
    handles.DFLT_LX=4;
    handles.DFLT_LY=1;
    handles.DFLT_LZ=1;
    handles.DFLT_NUP=2;
    handles.DFLT_NDN=1;
    handles.DFLT_KX=0;
    handles.DFLT_KY=0;
    handles.DFLT_KZ=0;
    handles.DFLT_U=4;
    handles.DFLT_TX=1;
    handles.DFLT_TY=1;
    handles.DFLT_TZ=1;
    handles.DFLT_DELTAU=0.01;
    handles.DFLT_NWLK=5;
    handles.DFLT_NBLKSTEPS=10;
    handles.DFLT_NEQBLK=2;
    handles.DFLT_NBLK=15;
    handles.DFLT_ITVMODSVD=5;
    handles.DFLT_ITVPC=5;
    handles.DFLT_ITVEM=10;

    %initiate the GUI and tab structure
    handles.guiHndl = figure('Name','CPMC-Lab','Visible','off','Position',GUI_POSITION,'Resize','on','Units','pixels','MenuBar','None','Toolbar','none','Color','white','NumberTitle','off');

    if getversion < handles.MIN_VERSION %to supress the warning messages user might see in the Matlab console 
        handles.hTabGroup = uitabgroup('v0',handles.guiHndl,'BackgroundColor','white'); drawnow;
        handles.tab1Handle = uitab('v0',handles.hTabGroup, 'title','Settings');
        handles.tab2Handle = uitab('v0',handles.hTabGroup, 'title','Run and Results');
    else
        handles.hTabGroup = uitabgroup(handles.guiHndl,'BackgroundColor','white'); drawnow;
        handles.tab1Handle = uitab(handles.hTabGroup, 'title','Settings');
        handles.tab2Handle = uitab(handles.hTabGroup, 'title','Run and Results');
    end

    % two panels on the first tab
    uicontrol(handles.tab1Handle,'style','text','HorizontalAlignment','left','Units','normalized','Position',[0.0 0.35 0.3 0.6],'FontSize',13,'BackgroundColor','white','String',...
        { 'Mouse over each component for explanation.','','Set the parameters for the here, then switch to the "Run and Results" tab to initiate a CPMC run.','','You can sequentially cycle through all parameter inputs by pressing Tab.'});
    systemParameterPanel=uipanel(handles.tab1Handle,'Position',[0.35 0.1 0.25 0.9],'Title','System parameters','BackgroundColor','white');
    runParameterPanel=uipanel(handles.tab1Handle,'Position',[0.70 0.1 0.25 0.9],'Title','Run parameters','BackgroundColor','white');

    %panels on the second tab:
    uicontrol(handles.tab2Handle,'style','text','HorizontalAlignment','left','Units','normalized','Position',[0.4 0.9 0.2 0.1],'FontSize',13,'BackgroundColor','white','String','Click "Start" to begin.');
    handles.simulationControlpanel=uipanel(handles.tab2Handle,'Position',[0.7 0.9 0.3 0.1],'Title','Simulation control','BackgroundColor','white');
    handles.simulationStatusPanel=uipanel(handles.tab2Handle,'Position',[0 0.65 0.34 0.35],'Title','Event log','BackgroundColor','white');
    handles.statusHndl=uicontrol('parent',handles.simulationStatusPanel,'Units','normalized','Position',[0 0 1 1],'style','edit','BackgroundColor','white','HorizontalAlignment','left','Max',2,'String','Welcome to CPMC-Lab! The latest simulation events will appear at the top of this log.');
    handles.startBttnHndl=uicontrol('parent',handles.simulationControlpanel,'Style','pushbutton','String','Start','Units','normalized','Position',[0.02 0.1 0.2 .8],'Enable','on');
    handles.pauseBttnHndl=uicontrol('parent',handles.simulationControlpanel,'Style','togglebutton','String','Pause','Units','normalized','Position',[0.27 0.1 0.2 .8],'Enable','off');
    handles.stopBttnHndl=uicontrol('parent',handles.simulationControlpanel,'Style','pushbutton','String','Stop','Units','normalized','Position',[0.52 0.1 0.2 .8],'Enable','off');
    handles.resetBttnHndl=uicontrol('parent',handles.simulationControlpanel,'Style','pushbutton','String','Reset','Units','normalized','Position',[.77 0.1 0.2 .8],'Enable','off');
    
    energyPlotPanel=uipanel(handles.tab2Handle,'Position',[0 0 0.34 0.3],'Title','Energy vs imaginary time','BackgroundColor','white');
    weightPlotPanel=uipanel(handles.tab2Handle,'Position',[0 0.32 0.34 0.3],'Title','Total weight vs imaginary time','BackgroundColor','white');
    walkerPanel=uipanel(handles.tab2Handle,'Position',[.35 .45 .65 .45],'Title','Orbital Structure of Random Walkers','BackgroundColor','White');
    densityPanel=uipanel(handles.tab2Handle,'Position',[.35 0 .65 .45],'Title','Electronic Density','BackgroundColor','White');
    energyPlot=axes('parent',energyPlotPanel);
    weightPlot=axes('parent',weightPlotPanel);  

    % non-editable labels for the parameter input:
    lxLabel=uicontrol(systemParameterPanel,'Style','text','String','Lx','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-0*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    lyLabel=uicontrol(systemParameterPanel,'Style','text','String','Ly','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-1*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    lzLabel=uicontrol(systemParameterPanel,'Style','text','String','Lz','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-2*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    nUpLabel=uicontrol(systemParameterPanel,'Style','text','String','N_up','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-3*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    nDnLabel=uicontrol(systemParameterPanel,'Style','text','String','N_dn','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-4*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    kxLabel=uicontrol(systemParameterPanel,'Style','text','String','kx','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-5*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    kyLabel=uicontrol(systemParameterPanel,'Style','text','String','ky','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-6*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    kzLabel=uicontrol(systemParameterPanel,'Style','text','String','kz','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-7*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    uLabel=uicontrol(systemParameterPanel,'Style','text','String','U','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-8*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    txLabel=uicontrol(systemParameterPanel,'Style','text','String','tx','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-9*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    tyLabel=uicontrol(systemParameterPanel,'Style','text','String','ty','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-10*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    tzLabel=uicontrol(systemParameterPanel,'Style','text','String','tz','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-11*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    
    currentLxValue=handles.DFLT_LX;
    currentLyValue=handles.DFLT_LY;
    currentLzValue=handles.DFLT_LZ;
    
    deltauLabel=uicontrol(runParameterPanel,'Style','text','String','deltau','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-0*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    nWlkLabel=uicontrol(runParameterPanel,'Style','text','String','N_wlk','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-1*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    nBlkstepsLabel=uicontrol(runParameterPanel,'Style','text','String','N_blksteps','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-2*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    nEqblkLabel=uicontrol(runParameterPanel,'Style','text','String','N_eqblk','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-3*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    nBlkLabel=uicontrol(runParameterPanel,'Style','text','String','N_blk','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-4*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    itvModsvdLabel=uicontrol(runParameterPanel,'Style','text','String','itv_modsvd','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-5*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    itvPcLabel=uicontrol(runParameterPanel,'Style','text','String','itv_pc','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-6*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    itvEmLabel=uicontrol(runParameterPanel,'Style','text','String','itv_Em','Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_LABEL_TOP_Y_COORD-7*PARA_LABEL_VERT_DISTANCE PARA_LABEL_WIDTH PARA_LABEL_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');    

    % parameter input text fields:
        % first panel
    handles.lxHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_LX),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-0*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.lyHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_LY),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-1*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.lzHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_LZ),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-2*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.nUpHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_NUP),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-3*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.nDnHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_NDN),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-4*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.kxHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_KX),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-5*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.kyHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_KY),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-6*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.kzHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_KZ),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-7*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.uHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_U),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-8*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.txHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_TX),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-9*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.tyHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_TY),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-10*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.tzHndl=uicontrol(systemParameterPanel,'Style','edit','String',num2str(handles.DFLT_TZ),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-11*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
        % second panel
    handles.deltauHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_DELTAU),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-0*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.nWlkHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_NWLK),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-1*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.nBlkstepsHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_NBLKSTEPS),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-2*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.nEqblkHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_NEQBLK),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-3*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.nBlkHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_NBLK),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-4*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.itvModsvdHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_ITVMODSVD),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-5*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.itvPcHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_ITVPC),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-6*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.itvEmHndl=uicontrol(runParameterPanel,'Style','edit','String',num2str(handles.DFLT_ITVEM),'Units','normalized','Position',[PARA_EDIT_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-7*PARA_EDIT_VERT_DISTANCE PARA_EDIT_WIDTH PARA_EDIT_HEIGHT],'BackgroundColor','White');
    handles.visualizeWalkerChkBx=uicontrol(runParameterPanel,'Style','checkbox','String','Visualize amplitude of walkers?','Value',1,'Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-8*PARA_EDIT_VERT_DISTANCE 0.9 PARA_EDIT_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    handles.visualizeDensityChkBx=uicontrol(runParameterPanel,'Style','checkbox','String','Visualize density?','Value',1,'Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-9*PARA_EDIT_VERT_DISTANCE 0.9 PARA_EDIT_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');
    handles.randomizeRandSeedChkBx=uicontrol(runParameterPanel,'Style','checkbox','String','Randomize rand seed?','Value',1,'Units','normalized','Position',[PARA_LABEL_LEFT_X_COORD PARA_EDIT_TOP_Y_COORD-10*PARA_EDIT_VERT_DISTANCE 0.9 PARA_EDIT_HEIGHT],'FontSize',PARA_LABEL_FONT_SIZE,'BackgroundColor','white');

    % %set tooltips
        % for the labels:
    set(lxLabel,'TooltipString','The number of lattice sites in the x direction.');
    set(lyLabel,'TooltipString','The number of lattice sites in the y direction. Set Ly=Lz=1 for a 1-D lattice; Ly>1 and Lz=1 for a 2-D lattice.');
    set(lzLabel,'TooltipString','The number of lattice sites in the z direction. Set Ly=Lz=1 for a 1-D lattice; Ly>1 and Lz=1 for a 2-D lattice.');
    set(nUpLabel,'TooltipString','The number of spin up electrons.');
    set(nDnLabel,'TooltipString','The number of down electrons.');
    set(kxLabel,'TooltipString','The x component of the twist angle in the twist-averaged boundary conditions.');
    set(kyLabel,'TooltipString','The y component of the twist angle in the twist-averaged boundary conditions.');
    set(kzLabel,'TooltipString','The z component of the twist angle in the twist-averaged boundary conditions.');
    set(uLabel,'TooltipString','The on-site repulsion strength in the Hubbard Hamiltonian');
    set(txLabel,'TooltipString','The hopping amplitude between nearest-neighbor sites in the x direction');
    set(tyLabel,'TooltipString','The hopping amplitude between nearest-neighbor sites in the y direction');
    set(tzLabel,'TooltipString','The hopping amplitude between nearest-neighbor sites in the z direction');
    set(deltauLabel,'TooltipString','The imaginary time step.');
    set(nWlkLabel,'TooltipString','The number of random walkers.');
    set(nBlkstepsLabel,'TooltipString','The number of random walk steps within each block.');
    set(nEqblkLabel,'TooltipString','The number of blocks used to equilibrate the random walk before energy measurement takes place.');
    set(nBlkLabel,'TooltipString','The number of blocks used in the measurement phase.');
    set(itvModsvdLabel,'TooltipString','The interval between two adjacent modified Gram-Schmidt re-orthonormalization of the random walkers.');
    set(itvPcLabel,'TooltipString','The interval between two adjacent population controls.');
    set(itvEmLabel,'TooltipString','The interval between two adjacent energy measurements.');
        %for the controls
    set(handles.lxHndl,'TooltipString','The number of lattice sites in the x direction.');
    set(handles.lyHndl,'TooltipString','The number of lattice sites in the y direction. Set Ly=Lz=1 for a 1-D lattice; Ly>1 and Lz=1 for a 2-D lattice.');
    set(handles.lzHndl,'TooltipString','The number of lattice sites in the z direction. Set Ly=Lz=1 for a 1-D lattice; Ly>1 and Lz=1 for a 2-D lattice.');
    set(handles.nUpHndl,'TooltipString','The number of spin up electrons.');
    set(handles.nDnHndl,'TooltipString','The number of down electrons.');
    set(handles.kxHndl,'TooltipString','The x component of the twist angle in the twist-averaged boundary conditions.');
    set(handles.kyHndl,'TooltipString','The y component of the twist angle in the twist-averaged boundary conditions.');
    set(handles.kzHndl,'TooltipString','The z component of the twist angle in the twist-averaged boundary conditions.');
    set(handles.uHndl,'TooltipString','The on-site repulsion strength in the Hubbard Hamiltonian');
    set(handles.txHndl,'TooltipString','The hopping amplitude between nearest-neighbor sites in x direction');
    set(handles.tyHndl,'TooltipString','The hopping amplitude between nearest-neighbor sites in y direction');
    set(handles.tzHndl,'TooltipString','The hopping amplitude between nearest-neighbor sites in z direction');
    set(handles.deltauHndl,'TooltipString','The imaginary time step.');
    set(handles.nWlkHndl,'TooltipString','The number of random walkers.');
    set(handles.nBlkstepsHndl,'TooltipString','The number of random walk steps within each block.');
    set(handles.nEqblkHndl,'TooltipString','The number of blocks used to equilibrate the random walk before energy measurement takes place.');
    set(handles.nBlkHndl,'TooltipString','The number of blocks used in the measurement phase.');
    set(handles.itvModsvdHndl,'TooltipString','The interval between two adjacent modified Gram-Schmidt re-orthonormalization of the random walkers.');
    set(handles.itvPcHndl,'TooltipString','The interval between two adjacent population controls.');
    set(handles.itvEmHndl,'TooltipString','The interval between two adjacent energy measurements.');
    set(handles.visualizeWalkerChkBx,'TooltipString',sprintf('Do you want too see the orbital structure of the walker?\nThe squared amplitude of each spin up electron is represented by a red line and that of each spin down electron by a blue line.\nDifferent types of line (solid, dotted, dashed and dash-dot) represent different electrons of the same spin.'));
    set(handles.visualizeDensityChkBx,'TooltipString',sprintf('Do you want to see the overall electronic density of the walkers?\nThe density of all spin up electrons is represented by a red line and that of all spin down electrons by a blue line.'));
    set(handles.randomizeRandSeedChkBx,'TooltipString','Do you want to randomize the seed of the random number generator? (uncheck to obtain identical runs)');

    % set callbacks:
    set(handles.lxHndl,'Callback',{@lxHndl_Callback,handles});
    set(handles.lyHndl,'Callback',{@lyHndl_Callback,handles});
    set(handles.lzHndl,'Callback',{@lzHndl_Callback,handles});
    set(handles.nUpHndl,'Callback',{@nUpHndl_Callback,handles});
    set(handles.nDnHndl,'Callback',{@nDnHndl_Callback,handles});
    set(handles.kxHndl,'Callback',{@kxHndl_Callback,handles});
    set(handles.kyHndl,'Callback',{@kyHndl_Callback,handles});
    set(handles.kzHndl,'Callback',{@kzHndl_Callback,handles});
    set(handles.uHndl,'Callback',{@uHndl_Callback,handles});
    set(handles.txHndl,'Callback',{@txHndl_Callback,handles});
    set(handles.tyHndl,'Callback',{@tyHndl_Callback,handles});
    set(handles.tzHndl,'Callback',{@tzHndl_Callback,handles});
    set(handles.deltauHndl,'Callback',{@deltauHndl_Callback,handles});
    set(handles.nWlkHndl,'Callback',{@nWlkHndl_Callback,handles});
    set(handles.nBlkHndl,'Callback',{@nBlkHndl_Callback,handles});
    set(handles.nBlkstepsHndl,'Callback',{@nBlkstepsHndl_Callback,handles});
    set(handles.nEqblkHndl,'Callback',{@nEqblkHndl_Callback,handles});
    set(handles.itvModsvdHndl,'Callback',{@itvModsvdHndl_Callback,handles});
    set(handles.itvPcHndl,'Callback',{@itvPcHndl_Callback,handles});
    set(handles.itvEmHndl,'Callback',{@itvEmHndl_Callback,handles});
    set(handles.visualizeWalkerChkBx,'Callback',{@visualizeWalkerChckBxHndl_Callback,handles});
    set(handles.visualizeDensityChkBx,'Callback',{@visualizeDensityChckBxHndl_Callback,handles});
    set(handles.startBttnHndl,'Callback',{@startBttnHndl_Callback,handles});
    set(handles.pauseBttnHndl,'Callback',{@pauseBttnHndl_Callback,handles});
    set(handles.stopBttnHndl,'Callback',{@stopBttnHndl_Callback,handles});
    set(handles.resetBttnHndl,'Callback',{@resetBttnHndl_Callback,handles});

    %finally make GUI visible
    set(handles.guiHndl,'visible','on');

    if getversion < handles.MIN_VERSION %warn user of incompatibility
        errordlg(sprintf('This graphical interface is NOT fully compatible with the version of Matlab you are using.\nSome control elements will not work.\nEspecially, the "Resume" and "Stop" buttons do NOT work properly.\nPlease UPGRADE to at least Matlab release R2010b (version 7.11) to have full compatibility.\nThis message does NOT apply to other files in the CPMC-Lab package.\nClick OK to acknowledge this incompatibility.'),'Incompatibility Warning','modal')
    end

end

function visualizeWalkerChckBxHndl_Callback(varargin)
    elems=varargin{3};
    Lz=str2double(get(elems.lzHndl,'String'));
    N_wlk=str2double(get(elems.nWlkHndl,'String'));
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    
    if Lz > 1
       warndlg('Because walkers cannot visualized for a 3 dimensional lattice, the "Visualize walker" checkbox will be unchecked.','Warning'); 
       set(elems.visualizeWalkerChkBx,'Value',0);     
    elseif N_wlk > 10
        warndlg('For performance reason, no more than 10 walkers can be visualized in this interface. The "visualize walkers" checkbox will be unchecked.','Warning');
        set(elems.visualizeWalkerChkBx,'Value',0); 
    elseif N_up > 4 || N_dn > 4
        warndlg('The walker visualization will get very cluttered. Keep the number of electrons of each spin no greater than 4 for optimal viewing experience');
    end
    
    drawPanels(elems);
end

function visualizeDensityChckBxHndl_Callback(varargin)
    elems=varargin{3};
    Lz=str2double(get(elems.lzHndl,'String'));
    N_wlk=str2double(get(elems.nWlkHndl,'String'));
    
    if Lz > 1
       warndlg('Because walkers cannot visualized for a 3 dimensional lattice, the "Visualize walker" checkbox will be unchecked.','Warning'); 
       set(elems.visualizeDensityChkBx,'Value',0);  
    elseif N_wlk > 10
        warndlg('For performance reason, no more than 10 walkers can be visualized in this interface. The "visualize density" checkbox will be unchecked.','Warning');
        set(elems.visualizeDensityChkBx,'Value',0);
    end
    
    drawPanels(elems);
end

function lxHndl_Callback(varargin)
    elems=varargin{3};
    global currentLxValue;
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    Lz=str2double(get(elems.lzHndl,'String'));
    noOfSites=floor(Lx*Ly*Lz);
    seeWalker=get(elems.visualizeWalkerChkBx,'Value'); 
    seeDensity=get(elems.visualizeDensityChkBx,'Value'); 

    if mod(Lx,1)~=0 || Lx <=0
        if (N_up + N_dn) <= 2* ( elems.DFLT_LX*Ly*Lz )
            errordlg('Lx must be a positive integer! Now set to default value','Invalid input');
            set(elems.lxHndl,'String',num2str(elems.DFLT_LX));
            currentLxValue=elems.DFLT_LX;
        else
            valToBeAssigned=ceil((N_up+N_dn)/(2*Ly*Lz));
            errordlg('Lx must be a positive integer! Now set to a reasonable value.','Invalid input');
            set(elems.lxHndl,'String',num2str(valToBeAssigned));
            currentLxValue=valToBeAssigned;
        end
    elseif (N_up + N_dn) > 2*noOfSites
        errordlg('There are not enough lattice sites to accommodate all the electrons. Lx will be reset to the previous value.','Invalid input');
        set(elems.lxHndl,'String',num2str(currentLxValue));
    else %if Lx input is all valid
        if Ly == 1 && (seeWalker == 1 || seeDensity == 1)
            if Lx > 15
                warndlg('For this large value of Lx, the visualizations might get very cluttered. For a one-dimensional lattice, keep the number of sites to less than 15 for optimal viewing.','Warning');
            end
        elseif Ly > 1 && (seeWalker == 1 || seeDensity == 1)
            if Lx > 5 
                warndlg('For this large value of Lx and Ly, the visualizations might get very cluttered. For a two-dimensional lattice, keep Lx less than 5 and Ly less than 3 for optimal viewing.','Warning');
            end
        end   
        currentLxValue=Lx;
    end    
end

function lyHndl_Callback(varargin)
    elems=varargin{3};
    seeWalker=get(elems.visualizeWalkerChkBx,'Value'); 
    seeDensity=get(elems.visualizeDensityChkBx,'Value'); 
    global currentLyValue;
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    Lz=str2double(get(elems.lzHndl,'String'));
    noOfSites=floor(Lx*Ly*Lz);
    
    if mod(Ly,1)~=0 || Ly <=0
        if (N_up + N_dn) <= 2* ( Lx*elems.DFLT_LY*Lz )
            errordlg('Ly must be a positive integer! Now set to default value','Invalid input');
            set(elems.lyHndl,'String',num2str(elems.DFLT_LY));
            currentLyValue=elems.DFLT_LY;
        else
            valToBeAssigned=ceil((N_up+N_dn)/(2*Lx*Lz));
            errordlg('Ly must be a positive integer! Now set to a reasonable value.','Invalid input');
            set(elems.lyHndl,'String',num2str(valToBeAssigned));
            currentLyValue=valToBeAssigned;
        end 
    elseif (N_up + N_dn) > 2*noOfSites
        errordlg('There are not enough lattice sites to accommodate all the electrons. Ly will be reset to the previous value.','Invalid input');
        set(elems.lyHndl,'String',num2str(currentLyValue));
    else %if Lx input is all valid
        if Ly > 1 && (seeWalker == 1 || seeDensity == 1) 
            if Lx > 5 || Ly > 3
                warndlg('For this large value of Lx and Ly, the visualizations might get very cluttered. For a two-dimensional lattice, keep Lx less than 5 and Ly less than 3 for optimal viewing.','Warning');
            end
        end
        currentLyValue=Ly;
    end  
end

function lzHndl_Callback(varargin)
    elems=varargin{3};
    global currentLzValue;
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    Lz=str2double(get(elems.lzHndl,'String'));
    noOfSites=floor(Lx*Ly*Lz);
    seeWalker=get(elems.visualizeWalkerChkBx,'Value'); 
    seeDensity=get(elems.visualizeDensityChkBx,'Value'); 

    if mod(Lz,1)~=0 || Lz <=0
        if (N_up + N_dn) <= 2* ( Lx*Ly*elems.DFLT_LZ )
            errordlg('Lz must be a positive integer! Now set to default value','Invalid input');
            set(elems.lzHndl,'String',num2str(elems.DFLT_LZ));
            currentLzValue=elems.DFLT_LZ;
        else
            valToBeAssigned=ceil((N_up+N_dn)/(2*Lx*Ly));
            errordlg('Ly must be a positive integer! Now set to a reasonable value.','Invalid input');
            set(elems.lzHndl,'String',num2str(valToBeAssigned));
            currentLzValue=valToBeAssigned;
        end 
    elseif Lz > 1 && (seeWalker == 1 || seeDensity == 1) && (N_up + N_dn <= 2*noOfSites)
        errordlg('Walkers and electronic density cannot be visualized for a 3 dimensional lattice. The "visualize walkers" and "visualize density" checkboxes will be unchecked.','Warning');
        set(elems.visualizeWalkerChkBx,'Value',0);  
        set(elems.visualizeDensityChkBx,'Value',0);
        currentLzValue=Lz;
        drawPanels(elems);
    elseif (N_up + N_dn) > 2*noOfSites
        errordlg('There are not enough lattice sites to accommodate all the electrons. Lz will be reset to the previous value.','Invalid input');
        set(elems.lzHndl,'String',num2str(currentLzValue));
    else
        currentLzValue=Lz;
    end
end

function nUpHndl_Callback(varargin)
    elems=varargin{3};
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    Lz=str2double(get(elems.lzHndl,'String'));
    noOfSites=floor(Lx*Ly*Lz);
    seeWalker=get(elems.visualizeWalkerChkBx,'Value'); 

    if mod(N_up,1)~=0 || N_up <0    
        if (elems.DFLT_NUP + N_dn) <= 2* ( Lx*Ly*Lz )
            errordlg('N_up must be a non-negative integer! Now set to default value','Invalid input');
            set(elems.nUpHndl,'String',num2str(elems.DFLT_NUP));
        else
            valToBeAssigned=floor(2*Lx*Ly*Lz)-N_dn;
            errordlg('N_up must be a non-negative integer! Now set to a reasonable value','Invalid input');
            set(elems.nUpHndl,'String',num2str(valToBeAssigned));
        end 
    elseif N_up > noOfSites
        errordlg('The total number of spin up electrons cannot exceed the total number of lattice sites. Now set to be equal to the number of lattice sites.','Invalid input');
        set(elems.nUpHndl,'String',noOfSites);    
    elseif N_up > 4 && seeWalker == 1
       warndlg('The walker visualization will get very cluttered. Keep N_up no greater than 4 for an optimal viewing experience.','Warning');
    end 
end

function nDnHndl_Callback(varargin)
    elems=varargin{3};
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    Lz=str2double(get(elems.lzHndl,'String'));
    noOfSites=floor(Lx*Ly*Lz);
    seeWalker=get(elems.visualizeWalkerChkBx,'Value'); 

    if mod(N_dn,1)~=0 || N_dn <0    
        if (elems.DFLT_NDN + N_up) <= 2* ( Lx*Ly*Lz )
            errordlg('N_dn must be a non-negative integer! Now set to default value','Invalid input');
        set(elems.nDnHndl,'String',num2str(elems.DFLT_NDN));
        else
            valToBeAssigned=floor(2*Lx*Ly*Lz)-N_up;
            errordlg('N_dn must be a non-negative integer! Now set to a reasonable value','Invalid input');
            set(elems.nDnHndl,'String',num2str(valToBeAssigned));
        end  
    elseif N_dn > noOfSites
        errordlg('The total number of spin down electrons cannot exceed the total number of lattice sites. Now set to be equal to the number of lattice sites.','Invalid input');
        set(elems.nDnHndl,'String',noOfSites);    
    elseif N_up > 4 && seeWalker == 1
       warndlg('The walker visualization will get very cluttered. Keep N_dn no greater than 4 for an optimal viewing experience.','Warning');
    end  
end

function kxHndl_Callback(varargin)
    elems=varargin{3};
    kx=str2double(get(elems.kxHndl,'String'));
    
    if kx <= -1 || kx > 1
        errordlg('kx must be a number in the interval (-1,1] ! Now set to default value','Invalid input');
        set(elems.kxHndl,'String',num2str(elems.DFLT_KX));
    end
end
function kyHndl_Callback(varargin)
    elems=varargin{3};
    ky=str2double(get(elems.kyHndl,'String'));
    
    if ky <= -1 || ky > 1
        errordlg('ky must be a number in the interval (-1,1] ! Now set to default value','Invalid input');
        set(elems.kyHndl,'String',num2str(elems.DFLT_KY));
    end 
end

function kzHndl_Callback(varargin)
    elems=varargin{3};
    kz=str2double(get(elems.kzHndl,'String'));
    
    if kz <= -1 || kz > 1
        errordlg('kz must be a number in the interval (-1,1] ! Now set to default value','Invalid input');
        set(elems.kzHndl,'String',num2str(elems.DFLT_KZ));
    end 
end

function uHndl_Callback(varargin)
    elems=varargin{3};
    U=str2double(get(elems.uHndl,'String'));
    
    if U < 0
        errordlg('U must be non-negative in the repulsive Hubbard model! Now set to the default value','Invalid input');
        set(elems.uHndl,'String',num2str(elems.DFLT_U));
    end 
end

function txHndl_Callback(varargin)
    elems=varargin{3};
    tx=str2double(get(elems.txHndl,'String'));
    
    if tx < 0
        errordlg('tx must be non-negative! Now set to the default value','Invalid input');
        set(elems.txHndl,'String',num2str(elems.DFLT_TX));
    end 
end

function tyHndl_Callback(varargin)
    elems=varargin{3};
    ty=str2double(get(elems.tyHndl,'String'));
    
    if ty < 0
        errordlg('ty must be non-negative! Now set to the default value','Invalid input');
        set(elems.tyHndl,'String',num2str(elems.DFLT_TY));
    end 
end

function tzHndl_Callback(varargin)
    elems=varargin{3};
    tz=str2double(get(elems.tzHndl,'String'));
    
    if tz < 0
        errordlg('tz must be non-negative! Now set to the default value','Invalid input');
        set(elems.tzHndl,'String',num2str(elems.DFLT_TZ));
    end 
end

function deltauHndl_Callback(varargin)
    elems=varargin{3};
    deltau=str2double(get(elems.deltauHndl,'String'));
    
    if deltau <= 0
        errordlg('deltau must be positive! Now set to default value','Invalid input');
        set(elems.deltauHndl,'String',num2str(elems.DFLT_DELTAU));
    elseif deltau > 1
        warndlg('The imaginary time step might be too large.','Warning');        
    end
end

function nWlkHndl_Callback(varargin)
    elems=varargin{3};
    N_wlk=str2double(get(elems.nWlkHndl,'String'));
    seeWalker=get(elems.visualizeWalkerChkBx,'Value');
    seeDensity=get(elems.visualizeDensityChkBx,'Value');

    if mod(N_wlk,1)~=0 || N_wlk <=0
        errordlg('N_wlk must be a positive integer! Now set to default value','Invalid input');
        set(elems.nWlkHndl,'String',num2str(elems.DFLT_NWLK));
    elseif N_wlk > 10 && (seeWalker ==1 || seeDensity == 1)
        errordlg('For performance reason, no more than 10 walkers can be visualized in this interface. The "visualize walkers" and "visualize density" checkboxes will be unchecked.','Warning');
        set(elems.visualizeWalkerChkBx,'Value',0);  
        set(elems.visualizeDensityChkBx,'Value',0); 
        drawPanels(elems);
    end 
end

function nBlkstepsHndl_Callback(varargin)
    elems=varargin{3};
    N_blksteps=str2double(get(elems.nBlkstepsHndl,'String'));
    itv_Em=str2double(get(elems.itvEmHndl,'String'));
    itv_modsvd=str2double(get(elems.itvModsvdHndl,'String'));
    itv_pc=str2double(get(elems.itvPcHndl,'String'));

    if mod(N_blksteps,1)~=0 || N_blksteps <=0
        if elems.DFLT_NBLKSTEPS >= itv_Em
            errordlg('N_blksteps must be a positive integer! Now set to default value','Invalid input');
            set(elems.nBlkstepsHndl,'String',num2str(elems.DFLT_NBLKSTEPS));
        else
            errordlg('N_blksteps must be a positive integer no less than itv_Em! Now set to itv_Em','Invalid input');
            set(elems.nBlkstepsHndl,'String',num2str(itv_Em));
        end 
    elseif itv_Em > N_blksteps
        errordlg('N_blksteps must be no less than itv_Em! Now set to be equal to itv_Em','Invalid input');
        set(elems.nBlkstepsHndl,'String',num2str(itv_Em));  
    else 
        if itv_modsvd > N_blksteps && itv_pc > N_blksteps
            warndlg ('Because itv_modsvd and itv_pc are both greater than N_blksteps, no population control and re-orthogonalization will take place.','Warning')
        elseif itv_modsvd > N_blksteps && itv_pc < N_blksteps
            warndlg('itv_modsvd is greater than N_blksteps. The walkers will not be periodically re-orthogonalized.','Warning');
        elseif itv_modsvd < N_blksteps && itv_pc > N_blksteps
            warndlg('itv_pc is greater than N_blksteps. There will be no population control.','Warning');
        end
    end 
end

function itvEmHndl_Callback(varargin)
    elems=varargin{3};
    itv_Em=str2double(get(elems.itvEmHndl,'String'));
    N_blksteps=str2double(get(elems.nBlkstepsHndl,'String'));
    
    if mod(itv_Em,1)~=0 || itv_Em <=0 
        if elems.DFLT_ITVEM <= N_blksteps    
            errordlg('itv_Em must be a positive integer no greater than N_blksteps! Now set to default value.','Invalid input');
            set(elems.itvEmHndl,'String',num2str(elems.DFLT_ITVEM));
        else
            errordlg('itv_Em must be a positive integer no greater than N_blksteps! Now set to N_blksteps.','Invalid input');
            set(elems.itvEmHndl,'String',num2str(N_blksteps));
        end
    elseif itv_Em > N_blksteps
        errordlg('itv_Em must be no greater than N_blksteps! Now set to be equal to N_blksteps','Invalid input');
        set(elems.itvEmHndl,'String',num2str(get(elems.nBlkstepsHndl,'String')));
    end
end

function nEqblkHndl_Callback(varargin)
    elems=varargin{3};
    N_eqblk=str2double(get(elems.nEqblkHndl,'String'));
    
    if mod(N_eqblk,1)~=0 || N_eqblk <0
        errordlg('N_eqblk must be a non-negative integer! Now set to default value','Invalid input');
        set(elems.nEqblkHndl,'String',num2str(elems.DFLT_NEQBLK));
    end 
end

function nBlkHndl_Callback(varargin)
    elems=varargin{3};
    N_blk=str2double(get(elems.nBlkHndl,'String'));
    
    if mod(N_blk,1)~=0 || N_blk <=0
        errordlg('N_blk must be a positive integer! Now set to default value','Invalid input');
        set(elems.nBlkHndl,'String',num2str(elems.DFLT_NBLK));
    end 
end

function itvModsvdHndl_Callback(varargin)
    elems=varargin{3};
    itv_modsvd=str2double(get(elems.itvModsvdHndl,'String'));
    N_blksteps=str2double(get(elems.nBlkstepsHndl,'String'));
    
    if mod(itv_modsvd,1)~=0 || itv_modsvd <=0
        if elems.DFLT_ITVMODSVD <= N_blksteps    
            errordlg('itv_modsvd must be a positive integer! Now set to default value.','Invalid input');
            set(elems.itvModsvdHndl,'String',num2str(elems.DFLT_ITVMODSVD));
        else
            errordlg('itv_modsvd must be a positive integer! Now set to default value. Because the default value is greater than N_blksteps, the walkers will not be periodically re-orthogonalized.','Invalid input');
            set(elems.itvModsvdHndl,'String',num2str(elems.DFLT_ITVMODSVD));
        end
    elseif itv_modsvd > N_blksteps
        warndlg('itv_modsvd is greater than N_blksteps. The walkers will not be periodically re-orthogonalized.','Warning');
    end 
end

function itvPcHndl_Callback(varargin)
    elems=varargin{3};
    itv_pc=str2double(get(elems.itvPcHndl,'String'));
    N_blksteps=str2double(get(elems.nBlkstepsHndl,'String'));
    
    if mod(itv_pc,1)~=0 || itv_pc <=0
        if elems.DFLT_ITVPC <= N_blksteps
            errordlg('itv_pc must be a positive integer! Now set to default value.','Invalid input');
            set(elems.itvPcHndl,'String',num2str(elems.DFLT_ITVPC));
        else
            errordlg('itv_pc must be a positive integer! Now set to default value. Because the default value is greater than N_blksteps, there will be no population control.','Invalid input');
            set(elems.itvPcHndl,'String',num2str(elems.DFLT_ITVPC));
        end
    elseif itv_pc > N_blksteps
        warndlg('itv_pc is greater than N_blksteps. There will be no population control.','Warning');
    end 
end

function stopBttnHndl_Callback(varargin)
    global stopSignal;
    elems=varargin{3};

    %set the control buttons to the correct state:
    set(elems.pauseBttnHndl,'Enable','off');
    set(elems.resetBttnHndl,'Enable','off');
    set(elems.pauseBttnHndl,'Enable','off');
    announce('Requesting stop. Please wait...',elems);
    stopSignal=1;
end

function resetBttnHndl_Callback(varargin)
    handles=varargin{3};
    global stopSignal;
    stopSignal = 0;
    global walkerPanel;
    global walkerAxes;
    global densityAxes;
    global densityPanel;
    walkerAxes=subplot(1,1,1,'replace','Parent',walkerPanel,'Color','w');
    densityAxes=subplot(1,1,1,'replace','Parent',densityPanel,'Color','w'); 

    set(handles.pauseBttnHndl,'Enable','off');
    set(handles.resetBttnHndl,'Enable','off');

    %enable the input fields again
    set(handles.lxHndl,'Enable','on');
    set(handles.lyHndl,'Enable','on');
    set(handles.lzHndl,'Enable','on');
    set(handles.nUpHndl,'Enable','on');
    set(handles.nDnHndl,'Enable','on');
    set(handles.kxHndl,'Enable','on');
    set(handles.kyHndl,'Enable','on');
    set(handles.kzHndl,'Enable','on');
    set(handles.uHndl,'Enable','on');
    set(handles.txHndl,'Enable','on');
    set(handles.tyHndl,'Enable','on');
    set(handles.tzHndl,'Enable','on');
    set(handles.deltauHndl,'Enable','on');
    set(handles.nWlkHndl,'Enable','on');
    set(handles.nBlkHndl,'Enable','on');
    set(handles.nBlkstepsHndl,'Enable','on');
    set(handles.nEqblkHndl,'Enable','on');
    set(handles.itvModsvdHndl,'Enable','on');
    set(handles.itvPcHndl,'Enable','on');
    set(handles.itvEmHndl,'Enable','on');
    set(handles.visualizeWalkerChkBx,'Enable','on');
    set(handles.visualizeDensityChkBx,'Enable','on');
    set(handles.randomizeRandSeedChkBx,'Enable','on');

    %redraw the panels on the tab:
    drawPanels(handles);

    %set the control buttons to the correct state:
    set(handles.startBttnHndl,'Enable','on');
end
function pauseBttnHndl_Callback(varargin)
    elems=varargin{3};
    buttonState = get(elems.pauseBttnHndl,'Value');
    
    if buttonState == get(elems.pauseBttnHndl,'Max')
        set(elems.pauseBttnHndl,'String','Resume');
        set(elems.stopBttnHndl,'Enable','off');
        announce('Simulation paused.',elems);
        uiwait();
    elseif buttonState == get(elems.pauseBttnHndl,'Min')
        set(elems.pauseBttnHndl,'String','Pause');
        set(elems.stopBttnHndl,'Enable','on');
        announce('Simulation resumed.',elems);
        uiresume();
    end
end
function startBttnHndl_Callback(varargin)
    elems=varargin{3};
    global stopSignal;
    stopSignal = 0;
    global walkerPanel;
    global densityPanel;
    global walkerAxes;
    global densityAxes;
    drawPanels(elems);
    set(elems.startBttnHndl,'Enable','off');
    set(elems.stopBttnHndl,'Enable','on');
    set(elems.pauseBttnHndl,'Enable','on');
    announce('Starting simulation...',elems);

    %disable input fields 
    set(elems.lxHndl,'Enable','off');
    set(elems.lyHndl,'Enable','off');
    set(elems.lzHndl,'Enable','off');
    set(elems.nUpHndl,'Enable','off');
    set(elems.nDnHndl,'Enable','off');
    set(elems.kxHndl,'Enable','off');
    set(elems.kyHndl,'Enable','off');
    set(elems.kzHndl,'Enable','off');
    set(elems.uHndl,'Enable','off');
    set(elems.txHndl,'Enable','off');
    set(elems.tyHndl,'Enable','off');
    set(elems.tzHndl,'Enable','off');
    set(elems.deltauHndl,'Enable','off');
    set(elems.nWlkHndl,'Enable','off');
    set(elems.nBlkHndl,'Enable','off');
    set(elems.nBlkstepsHndl,'Enable','off');
    set(elems.nEqblkHndl,'Enable','off');
    set(elems.itvModsvdHndl,'Enable','off');
    set(elems.itvPcHndl,'Enable','off');
    set(elems.itvEmHndl,'Enable','off');
    set(elems.visualizeWalkerChkBx,'Enable','off');
    set(elems.visualizeDensityChkBx,'Enable','off');
    set(elems.randomizeRandSeedChkBx,'Enable','off');

    %get parameters from input fields
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    Lz=str2double(get(elems.lzHndl,'String'));
    N_up=str2double(get(elems.nUpHndl,'String'));
    N_dn=str2double(get(elems.nDnHndl,'String'));
    kx=str2double(get(elems.kxHndl,'String'));
    ky=str2double(get(elems.kyHndl,'String'));
    kz=str2double(get(elems.kzHndl,'String'));
    U=str2double(get(elems.uHndl,'String'));
    tx=str2double(get(elems.txHndl,'String'));
    ty=str2double(get(elems.tyHndl,'String'));
    tz=str2double(get(elems.tzHndl,'String'));
    deltau=str2double(get(elems.deltauHndl,'String'));
    N_wlk=str2double(get(elems.nWlkHndl,'String'));
    N_blk=str2double(get(elems.nBlkHndl,'String'));
    N_blksteps=str2double(get(elems.nBlkstepsHndl,'String'));
    N_eqblk=str2double(get(elems.nEqblkHndl,'String'));
    itv_modsvd=str2double(get(elems.itvModsvdHndl,'String'));
    itv_pc=str2double(get(elems.itvPcHndl,'String'));
    itv_Em=str2double(get(elems.itvEmHndl,'String'));
    addfilename= datestr(now,'_yymmdd_HHMMSS');

    if Lz > 1 
        set(elems.visualizeWalkerChkBx,'Value',0);  
        drawPanels(elems);
    end
    if Lz > 1
        set(elems.visualizeDensityChkBx,'Value',0);  
        drawPanels(elems);
    end
    announce('Simulation begins.',elems);

    %initialize the walker and density axes:
    for plotCount=1:N_wlk
        walkerAxes(plotCount)=subplot(1,N_wlk,plotCount,'Parent',walkerPanel,'Color','w'); 
        densityAxes(plotCount)=subplot(1,N_wlk,plotCount,'Parent',densityPanel,'Color','w'); 
    end

    if getversion < elems.MIN_VERSION %warn user of incompatibility
        errordlg(sprintf('This GUI is NOT fully compatible with the version of Matlab you are using.\nEspecially, the "Resume" and "Stop" buttons do not work properly.\nPlease UPGRADE to at least Matlab release R2010b (version 7.11).\nClick the "close" button to the left to dismiss this message.'),'Incompatibility');
    end

    %calls main function:
    [E_ave,E_err,sampledatafile]=CPMC_Lab(Lx,Ly,Lz,N_up,N_dn,kx,ky,kz,U,tx,ty,tz,deltau,N_wlk,N_blksteps,N_eqblk,N_blk,itv_modsvd,itv_pc,itv_Em, addfilename,elems);
    clearvars -except sampledatafile;
    load (sampledatafile);
    clearvars sampledatafile;
end

function [E_ave,E_err,fileToSave]=CPMC_Lab(Lx,Ly,Lz,N_up,N_dn,kx,ky,kz,U,tx,ty,tz,deltau,N_wlk,N_blksteps,N_eqblk,N_blk,itv_modsvd,itv_pc,itv_Em, addfilename,elems)
% Perform a CPMC calculation
% See documentation for function CPMC_Lab in the main package directory

    global stopSignal;
    global Phi;
    Phi=0;
    
    announce('"CPMC_Lab" is the main function that carries out the simulation.',elems);
    announce('"CPMC_Lab" calls "initialization" to form the trial wave function.',elems);
    announce('"initialization" calls "validation" to validate user inputs.',elems);
    announce('"initialization calls H_K to form the one-body kinetic Hamiltonian.',elems);

    % initialize internal quantities
    N_sites=Lx*Ly*Lz;
    N_par=N_up+N_dn;

    H_k=H_K(Lx, Ly,Lz, kx, ky,kz, tx, ty,tz,elems);
    [psi_nonint,E_nonint_m] = eig(H_k);
    E_nonint_v=diag(E_nonint_m);
    Proj_k_half = expm(-0.5*deltau*H_k);

    Phi_T=horzcat(psi_nonint(:,1:N_up),psi_nonint(:,1:N_dn));
    E_K=sum(E_nonint_v(1:N_up))+sum(E_nonint_v(1:N_dn));
    n_r_up=diag(Phi_T(:,1:N_up)*(Phi_T(:,1:N_up))');
    n_r_dn=diag(Phi_T(:,N_up+1:N_par)*(Phi_T(:,N_up+1:N_par))');
    E_V=U*n_r_up'*n_r_dn;
    E_T = E_K+E_V;


    Phi=repmat(Phi_T, [1 1 N_wlk]); 

    w=ones(N_wlk,1);
    O=w;
    E_blk=zeros(N_blk,1);
    W_blk=zeros(N_blk,1);

    fac_norm=(real(E_T)-0.5*U*N_par)*deltau;
    gamma=acosh(exp(0.5*deltau*U));
    aux_fld=zeros(2,2);
    
    for i=1:2
        for j=1:2
            aux_fld(i,j)=exp(gamma*(-1)^(i+j));
        end
    end

    fileToSave=strcat(int2str(Lx),'x',int2str(Ly),'x',int2str(Lz),'_',int2str(N_up),'u',int2str(N_dn),'d_U',num2str(U, '%4.2f'),'_kx',num2str(kx,'%+7.4f'),'_ky',num2str(ky,'%+7.4f'),'_kz',num2str(kz,'%+7.4f'),'_Nwlk_',int2str(N_wlk),addfilename,'.mat');
    randSeed=get(elems.randomizeRandSeedChkBx,'Value');
    
    if randSeed == 1
        rand('twister',sum(100*clock));
    else
        rand('twister', 5489);
    end

    seeWalker=get(elems.visualizeWalkerChkBx,'Value');
    seeDensity=get(elems.visualizeDensityChkBx,'Value');

    flag_mea=0;
    E=0;
    W=0;
    statusString='Equilibration';

    if N_eqblk > 0
        announce('Start of equilibration phase.',elems);
    end

    tic; 

    for i_blk=1:N_eqblk
        announce('At every step within a block, "CPMC_Lab" calls "stepwlk" to perform one step of the random walk.',elems);
        announce('"stepwlk" then calls "halfK", "V" and "halfV" again to perform the kinetic and potential propagators.',elems);
        
        if seeWalker == 0 && seeDensity == 0
            announce('No energy and weight output during equilibration.',elems);
        end
        
        for j_step=1:N_blksteps

            if stopSignal == 1;break; end;
            announce(sprintf( '%s block %03d, step %03d.', statusString, i_blk,j_step ),elems);
            if stopSignal == 1;break; end;
            [w, O, E, W] = stepwlk(N_wlk, N_sites, w, O, E, W, H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld,elems,i_blk,j_step,statusString);
            if stopSignal == 1;break; end;
            
            if mod(j_step,itv_modsvd)==0
                announce(sprintf( '%s block %03d: "CPMC_Lab" calls "stblz" re-orthogonalize all walkers.',statusString, i_blk ),elems);
                [O] = stblz(N_wlk, O, N_up, N_par,elems);
                pause(0.001);
                if seeWalker==1
                    plotWalkerEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
                if seeDensity==1
                    plotDensityEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
            end
            
            if stopSignal == 1;break; end;
            
            if mod(j_step,itv_pc)==0
                announce(sprintf( '%s block %03d: "CPMC_Lab" calls "pop_cntrl" to do population control.',statusString, i_blk ),elems);
                [w, O]=pop_cntrl( w, O, N_wlk, N_sites, N_par,elems);
                pause(0.001);
                if seeWalker==1
                    plotWalkerEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
                if seeDensity==1
                    plotDensityEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
            end
            
            if stopSignal == 1;break; end;
        end
        
        if stopSignal == 1;break; end;
    end

    if N_eqblk > 0 && stopSignal == 0
        announce('End of equilibration phase.',elems);
    end

    if N_blk > 0 && stopSignal == 0
        announce('Start of measurement phase.',elems);
    end

    statusString='Measurement';

    for i_blk=1:N_blk

        if stopSignal == 1;break; end;
        announce('At every step within a block, "CPMC_Lab" calls "stepwlk" to perform one step of the random walk.',elems);
        if stopSignal == 1;break; end;

        for j_step=1:N_blksteps
            if stopSignal == 1;break; end;
            announce(sprintf( '%s block %03d: step %03d.', statusString, i_blk,j_step ),elems);
            if stopSignal == 1;break; end;
            
            if mod(j_step,itv_Em)==0
                flag_mea=1;
            else
                flag_mea=0;
            end

            if stopSignal == 1;break; end;
            [ w, O, E_blk(i_blk), W_blk(i_blk)] = stepwlk( N_wlk, N_sites, w, O, E_blk(i_blk), W_blk(i_blk), H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld,elems,i_blk,j_step,statusString);
            if stopSignal == 1;break; end;

            if mod(j_step,itv_modsvd)==0
                announce(sprintf( '%s block %03d: "CPMC_Lab" calls "stblz" re-orthogonalize all walkers.',statusString, i_blk ),elems);
                [ O] = stblz( N_wlk, O, N_up, N_par,elems);
                pause(0.001);
                if seeWalker==1
                    plotWalkerEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
                if seeDensity==1
                    plotDensityEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
            end

            if stopSignal == 1;break; end;

            if mod(j_step,itv_pc)==0
                announce(sprintf( '%s block %03d: "CPMC_Lab" calls "pop_cntrl" to do population control.',statusString, i_blk ),elems);
                [ w, O]=pop_cntrl( w, O, N_wlk, N_sites, N_par,elems);
                pause(0.001);
                if seeWalker==1
                    plotWalkerEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
                if seeDensity==1
                    plotDensityEnsemble(N_wlk, N_up, N_par, elems,Lx,Ly);
                end
            end

            if stopSignal == 1;break; end;

            if mod(j_step, itv_Em)==0
                fac_norm=(real(E_blk(i_blk)/W_blk(i_blk))-0.5*U*N_par)*deltau;
            end
            if stopSignal == 1;break; end;
        end

        if stopSignal == 1;break; end;

        E_blk(i_blk)=E_blk(i_blk)/W_blk(i_blk);
        plotWeight(i_blk, deltau, real(W_blk(1:i_blk)), elems,N_blksteps);
        plotEnergy(i_blk, deltau, real(E_blk(1:i_blk)), elems,N_blksteps);
        announce(sprintf( '%s block %03d: Energy for this block is %0.5g.', statusString, i_blk,real(E_blk(i_blk)) ),elems);
        announce(sprintf( '%s block %03d: Total weight of walkers for this block is %0.5g.', statusString, i_blk,real(W_blk(i_blk)) ),elems);

        if stopSignal == 1;break; end;
    end

    if N_blk > 0 && stopSignal == 0
        announce('End of measurement phase.',elems);
    end

    E=real(E_blk);
    E_ave=mean(E);
    E_err=std(E)/sqrt(N_blk);
    E_psite=E_ave/N_sites;
    time=toc(); 
    if stopSignal == 1
        fileToSave=strcat(fileToSave(1:end-4),'_stopped.mat');
        announce('Simulation stopped by user',elems);
        set(elems.stopBttnHndl,'Enable','off');
        set(elems.resetBttnHndl,'Enable','on');
        set(elems.pauseBttnHndl,'Enable','off');
        set(elems.pauseBttnHndl,'String','Pause');
    end

    announce(sprintf('Data is saved in "%s"',fileToSave),elems);
    announce(sprintf('Final result: total computational time =%.5g seconds',time),elems);
    announce(sprintf('Final result: total energy E_ave=%.5g',E_ave),elems);
    announce(sprintf('Final result: error in energy E_err=%.5g',E_err),elems);
    announce(sprintf('Final result: energy per site E_psite=%.5g',E_psite),elems);

    if stopSignal == 1
        announce('Warning: Because simulation was stopped abruptly, saved data file (identified by the suffix "stopped") may not be reliable.',elems);

    end

    save (fileToSave, 'E', 'E_ave', 'E_err', 'time');
    save (fileToSave, '-append', 'Lx', 'Ly','Lz', 'N_up', 'N_dn', 'kx', 'ky','kz', 'U', 'tx', 'ty','tz');
    save (fileToSave, '-append', 'deltau', 'N_wlk', 'N_blksteps', 'N_eqblk', 'N_blk', 'itv_pc','itv_modsvd','itv_Em');
    save (fileToSave, '-append', 'H_k', 'E_nonint_v', 'Phi_T');

    set(elems.stopBttnHndl,'Enable','off');
    set(elems.pauseBttnHndl,'Enable','off');
    set(elems.resetBttnHndl,'Enable','on');
end
function H=H_K(Lx,Ly,Lz,kx,ky,kz,tx,ty,tz,elems)
% Form the one-body kinetic Hamiltonian
% See documentation for function H_K in the main package directory

    r=0;
    N_sites=Lx*Ly*Lz;
    kx=sqrt(-1)*pi*kx;
    ky=sqrt(-1)*pi*ky;
    kz=sqrt(-1)*pi*kz;
    H=zeros(N_sites,N_sites);
    
    for mz=1:Lz
        for iy=1:Ly
            for jx=1:Lx
                r=r+1;      % r=(iy-1)*Lx+jx;
                if Lx~=1
                    if jx==1
                        H(r,r+Lx-1)=H(r,r+Lx-1)-tx*exp(kx);
                        H(r,r+1)=H(r,r+1)-tx;
                    elseif jx==Lx
                        H(r,r-1)=H(r,r-1)-tx;
                        H(r,r+1-Lx)=H(r,r+1-Lx)-tx*exp(-kx);
                    else
                        H(r,r-1)=-tx;
                        H(r,r+1)=-tx;
                    end
                end

                if Ly~=1
                    if iy==1
                        H(r,r+(Ly-1)*Lx)=H(r,r+(Ly-1)*Lx)-ty*exp(ky);
                        H(r,r+Lx)=H(r,r+Lx)-ty;
                    elseif iy==Ly
                        H(r,r-Lx)=H(r,r-Lx)-ty;
                        H(r,r-(Ly-1)*Lx)=H(r,r-(Ly-1)*Lx)-ty*exp(-ky);
                    else
                        H(r,r-Lx)=-ty;
                        H(r,r+Lx)=-ty;
                    end
                end

                if Lz~=1
                    if mz==1
                        H(r,r+(Lz-1)*Lx*Ly) = H(r,r+(Lz-1)*Lx*Ly) - tz*exp(kz);
                        H(r,r+Lx*Ly)= H(r,r+Lx*Ly) - tz;
                    elseif mz==Lz
                        H(r,r-Lx*Ly) = H(r,r-Lx*Ly) - tz;
                        H(r,r-(Lz-1)*Lx*Ly) = H(r,r-(Lz-1)*Lx*Ly) - tz*exp(-kz);
                    else
                        H(r,r-Lx*Ly)=-tz;
                        H(r,r+Lx*Ly)=-tz;
                    end
                end
            end
        end
    end
end

function [phi, w, O, invO_matrix_up, invO_matrix_dn] = halfK(phi, w, O, Proj_k_half, Phi_T, N_up, N_par,elems)
% Propagate a walker by the kinetic energy propagator
% See documentation for function halfK in the main package directory

    phi=Proj_k_half*phi;
    invO_matrix_up=inv(Phi_T(:,1:N_up)'*phi(:,1:N_up));
    invO_matrix_dn=inv(Phi_T(:,N_up+1:N_par)'*phi(:,N_up+1:N_par));
    O_new=1/(det(invO_matrix_up)*det(invO_matrix_dn));
    O_ratio=O_new/O;

    if O_ratio>0
        O=O_new;
        w=w*real(O_ratio);
    else
        w=0;
    end
end

function [E,W] = measure(H_k, phi, Phi_T, w, E, W, invO_matrix_up, invO_matrix_dn, N_up, N_par, U,elems)
% Calculate the mixed estimator for the ground state energy
% See documentation for function measure in the main package directory

    temp_up=phi(:,1:N_up)*invO_matrix_up;
    temp_dn=phi(:,N_up+1:N_par)*invO_matrix_dn;
    G_up=temp_up*Phi_T(:,1:N_up)';
    G_dn=temp_dn*Phi_T(:,N_up+1:N_par)';
    n_int=(diag(G_up)).'*diag(G_dn);
    e=n_int*U+sum(sum(H_k.'.*(G_up+G_dn)));
    E=E+e*w;
    W=W+w;
end

function [ w, O]=pop_cntrl( w, O, N_wlk, N_sites, N_par,elems)
% Perform population control by the simple "combing" method
% See documentation of function pop_cntrl in the main package directory

    global Phi;
    Phi_tmp=zeros(N_sites, N_par, N_wlk);
    O_tmp=zeros(N_wlk,1);
    d=N_wlk/sum(w);
    sum_w=-rand;
    n_wlk=0;
    
    for i_wlk=1:N_wlk
        sum_w=sum_w+w(i_wlk)*d;
        n=ceil(sum_w);
        for j=(n_wlk+1):n
            Phi_tmp(:,:,j)=Phi(:,:,i_wlk);
            O_tmp(j)=O(i_wlk);
        end
        n_wlk=n;
    end
    
    Phi=Phi_tmp;
    O=O_tmp;
    w=ones(N_wlk,1);
end

function [ O] = stblz(N_wlk, O, N_up, N_par,elems)
% Perform the Gram-Schmidt orthogonalization to stabilize the walker
% See documentation of function stlbz in the main package directory

    global Phi;
    seeDensity=get(elems.visualizeDensityChkBx,'Value');
    seeWalker=get(elems.visualizeWalkerChkBx,'Value');
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    
    for i_wlk=1:N_wlk
        [Phi(:,1:N_up,i_wlk),R_up]=qr(Phi(:,1:N_up,i_wlk),0);
        [Phi(:,N_up+1:N_par,i_wlk),R_dn]=qr(Phi(:,N_up+1:N_par,i_wlk),0);
        O(i_wlk)=O(i_wlk)/det(R_up)/det(R_dn);
        if seeWalker == 1
            plotWalkers(N_wlk, N_up, N_par, elems,i_wlk,Lx,Ly);
        end
        if seeDensity ==1
            plotDensity(N_wlk, N_up, N_par,  elems, i_wlk, Lx, Ly);
        end
    end
end

function [w, O, E, W] = stepwlk(N_wlk, N_sites, w, O, E, W, H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld,elems,i_blk,j_step,statusString)
% Carry out one step of the random walk.
% See documentation of function stepwlk in the main package directory

    global stopSignal;
    global Phi;
    Lx=str2double(get(elems.lxHndl,'String'));
    Ly=str2double(get(elems.lyHndl,'String'));
    seeWalker=get(elems.visualizeWalkerChkBx,'Value');
    seeDensity=get(elems.visualizeDensityChkBx,'Value');
    
    for i_wlk=1:N_wlk
        if stopSignal == 1;break; end;
        if w(i_wlk)>0
            w(i_wlk)=w(i_wlk)*exp(fac_norm);            
            [Phi(:,:,i_wlk), w(i_wlk), O(i_wlk), invO_matrix_up, invO_matrix_dn]=halfK(Phi(:,:,i_wlk), w(i_wlk), O(i_wlk), Proj_k_half, Phi_T, N_up, N_par,elems);            
            pause(0.001);
            if seeWalker == 1
                plotWalkers(N_wlk, N_up, N_par, elems,i_wlk,Lx,Ly);
            end
            if seeDensity ==1
                plotDensity(N_wlk, N_up, N_par,  elems, i_wlk, Lx, Ly);
            end
            
            if w(i_wlk)>0                   
                for j_site=1:N_sites                    
                    if w(i_wlk)>0                        
                        [Phi(j_site,:,i_wlk), O(i_wlk), w(i_wlk), invO_matrix_up, invO_matrix_dn]=V(Phi(j_site,:,i_wlk), Phi_T(j_site,:), N_up, N_par, O(i_wlk), w(i_wlk), invO_matrix_up, invO_matrix_dn, aux_fld);                        
                        pause(0.001);
                        
                        if seeWalker == 1
                            plotWalkers(N_wlk, N_up, N_par, elems,i_wlk,Lx,Ly);
                        end
                        
                        if seeDensity ==1
                            plotDensity(N_wlk, N_up, N_par,  elems, i_wlk, Lx, Ly);
                        end      
                        
                    end
                end
            end
            
            if w(i_wlk)>0                
                [Phi(:,:,i_wlk), w(i_wlk), O(i_wlk), invO_matrix_up, invO_matrix_dn]=halfK(Phi(:,:,i_wlk), w(i_wlk), O(i_wlk), Proj_k_half, Phi_T, N_up, N_par,elems);                
                pause(0.001);                
                if seeWalker == 1
                    plotWalkers(N_wlk, N_up, N_par, elems,i_wlk,Lx,Ly);
                end
                
                if seeDensity ==1
                    plotDensity(N_wlk, N_up, N_par,  elems, i_wlk, Lx, Ly);
                end
                
                if w(i_wlk)>0
                    if flag_mea==1                                   
                        [E, W]=measure(H_k, Phi(:,:,i_wlk), Phi_T, w(i_wlk), E, W, invO_matrix_up, invO_matrix_dn, N_up, N_par, U);                        
                    end
                end
            end
        end

    end  
    
    if flag_mea==1    
        announce(sprintf( '%s block %03d: "stepwlk" calls "measure" to measure the energy of each walker.',statusString, i_blk ),elems);      
    end
end

function [phi, O, w, invO_matrix_up, invO_matrix_dn] = V(phi, phi_T, N_up, N_par, O, w, invO_matrix_up, invO_matrix_dn, aux_fld,elems)
% Propagate the walker by the potential energy propagator.
% See documentation of the function V in the main package directory

    Gii=zeros(2,1);
    RR=ones(2,2);
    matone=RR;

    temp1_up=phi(1:N_up)*invO_matrix_up;
    temp1_dn=phi(N_up+1:N_par)*invO_matrix_dn;
    temp2_up=invO_matrix_up*phi_T(1:N_up)';
    temp2_dn=invO_matrix_dn*phi_T(N_up+1:N_par)';
    Gii(1)=temp1_up*phi_T(1:N_up)';
    Gii(2)=temp1_dn*phi_T(N_up+1:N_par)';
    RR=(aux_fld-matone).*horzcat(Gii,Gii)+matone;
    O_ratio_temp=RR(1,:).*RR(2,:);
    O_ratio_temp_real=max(real(O_ratio_temp),zeros(1,2));
    sum_O_ratio_temp_real=O_ratio_temp_real(1)+O_ratio_temp_real(2);
    
    if sum_O_ratio_temp_real<=0
        w=0;
    end
    
    if w>0
        w=w*0.5*sum_O_ratio_temp_real;

        if O_ratio_temp_real(1)/sum_O_ratio_temp_real>=rand
            x_spin=1;
        else
            x_spin=2;
        end

        phi(1:N_up)=phi(1:N_up)*aux_fld(1,x_spin);
        phi(N_up+1:N_par)=phi(N_up+1:N_par)*aux_fld(2,x_spin);

        O=O*O_ratio_temp(x_spin);
        invO_matrix_up=invO_matrix_up+(1-aux_fld(1,x_spin))/RR(1,x_spin)*temp2_up*temp1_up;
        invO_matrix_dn=invO_matrix_dn+(1-aux_fld(2,x_spin))/RR(2,x_spin)*temp2_dn*temp1_dn;
    end
end

function plotWalkerEnsemble(N_wlk, N_up, N_par, handles,Lx,Ly)
% draw the amplitudes of the walkers

    global  walkerPanel;
    global Phi;
    global walkerAxes;
    width=2.5;
    
    if (Lx==1)||(Ly==1)%if the lattice is only 1-dimensional
        if Lx==1
            dimens=Ly;        
        else
            dimens=Lx;
        end  

        for i=1:N_wlk
            current=walkerAxes(i);
            set(current,'XLim',[1 dimens]);        
            cla(current);
            for j=1:N_up
                switch mod(j,4) % to determine what kind of line style to draw the amplitude:
                    case 1
                        plot(current,Phi(:,j,i).*conj(Phi(:,j,i)),'-r','LineWidth',width);
                        hold(current,'on');
                    case 2
                        plot(current,Phi(:,j,i).*conj(Phi(:,j,i)),':r','LineWidth',width);
                        hold(current,'on');
                    case 3
                        plot(current,Phi(:,j,i).*conj(Phi(:,j,i)),'--r','LineWidth',width);
                        hold(current,'on');
                    case 0
                        plot(current,Phi(:,j,i).*conj(Phi(:,j,i)),'-.r','LineWidth',width);
                        hold(current,'on');
                    otherwise
                        disp('Exception in lineSpec');
                end
                hline(0,'k');
            end
            
            hold(current,'on');
            
            for k = N_up+1:N_par
                switch mod(k-N_up,4)
                    case 1
                        plot(current,Phi(:,k,i).*conj(Phi(:,k,i)),'-b','LineWidth',width);
                        hold(current,'on');
                    case 2
                        plot(current,Phi(:,k,i).*conj(Phi(:,k,i)),':b','LineWidth',width);
                        hold(current,'on');
                    case 3
                        plot(current,Phi(:,k,i).*conj(Phi(:,k,i)),'--b','LineWidth',width);
                        hold(current,'on');
                    case 0
                        plot(current,Phi(:,k,i).*conj(Phi(:,k,i)),'-.b','LineWidth',width);
                        hold(current,'on');
                    otherwise
                        disp('Exception in lineSpec');
                end
            end
        end
        current=walkerAxes(N_wlk);
        set(current,'XLimMode','manual','Color','y');
        
    else   %otherwise if it's 2 dimensional   
        noOfSites = Lx * Ly;
        xVector = 1:Lx;%for plotting: xVector = [1 2 3 ... Lx]
        for  currentWalker=1:N_wlk
            current=walkerAxes(currentWalker);
            set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
            cla(current);
            planarForm = zeros(Lx,Ly,N_par); %the array that will store the 2-dimensional lattice amplitude
            
            for j = 1:N_up %for each electron
                linearForm = Phi(:,j,currentWalker);%extract the amplitudes over all sites for one particular electron into a 1-dimensional array
                counter=1;
                for y=1:Ly
                    for x = 1:Lx
                        planarForm(x,y,j)=linearForm(counter);
                        counter = counter+1;
                    end
                end
            end

            for j = N_up+1:N_par
                linearForm = Phi(:,j,currentWalker);%extract the amplitudes over all sites for one particular electron into a 1-dimensional array
                counter=1;
                for y=1:Ly
                    for x = 1:Lx
                        planarForm(x,y,j)=linearForm(counter);
                        counter = counter+1;
                    end
                end
            end
            
            %plot the result
            cla(current);

            for j = 1:N_up
                switch mod(j,4)
                    case 1
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-r','LineWidth',width);
                            set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                            hold(current,'on');
                        end
                    case 2
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),':r','LineWidth',width);
                            set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                            hold(current,'on');
                        end
                    case 3
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'--r','LineWidth',width);
                            set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                            hold(current,'on');
                        end
                    case 0
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-.r','LineWidth',width);
                            set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                            hold(current,'on');
                        end
                    otherwise
                        disp('Exception in lineSpec');
                end
            end
            
            for j = N_up+1:N_par
                switch mod(j-N_up,4)
                    case 1
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-b','LineWidth',width);
                            hold(current,'on');
                        end
                    case 2
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),':b','LineWidth',width);
                            hold(current,'on');
                        end
                    case 3
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'--b','LineWidth',width);
                            hold(current,'on');
                        end
                    case 0
                        for m = 1:Ly
                            yVector = repmat(m,1,Lx);
                            plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-.b','LineWidth',width);
                            hold(current,'on');
                        end
                    otherwise
                        disp('Exception in lineSpec');
                end
            end
        end
    end
end

function plotWalkers(N_wlk, N_up, N_par, handles,currentWalker,Lx,Ly)
% draw the amplitudes of the walkers

    global  walkerPanel    ;
    global Phi;
    global walkerAxes;
    width=2.5;
    if (Lx==1)||(Ly==1)%if the lattice is only 1-dimensional
        if Lx==1
            dimens=Ly;        
        else
            dimens=Lx;
        end  
        previous=walkerAxes( mod(currentWalker+N_wlk-2,N_wlk)+1   );
        set(previous,'Color','w');
        current=walkerAxes(currentWalker);    
        set(current,'XLimMode','manual','Color','y');        
        set(current,'XLim',[1 dimens]);
        cla(current);
        
        for j=1:N_up
            switch mod(j,4) % to determine what kind of line style to draw the amplitude:
                case 1
                    plot(current,Phi(:,j,currentWalker).*conj(Phi(:,j,currentWalker)),'-r','LineWidth',width);
                    set(current,'Color','y'); 
                    hold(current,'on');
                case 2
                    plot(current,Phi(:,j,currentWalker).*conj(Phi(:,j,currentWalker)),':r','LineWidth',width);
                    set(current,'Color','y'); 
                    hold(current,'on');
                case 3
                    plot(current,Phi(:,j,currentWalker).*conj(Phi(:,j,currentWalker)),'--r','LineWidth',width);
                    set(current,'Color','y'); 
                    hold(current,'on');
                case 0
                    plot(current,Phi(:,j,currentWalker).*conj(Phi(:,j,currentWalker)),'-.r','LineWidth',width);
                    set(current,'Color','y'); 
                    hold(current,'on');
                otherwise
                    disp('Exception in lineSpec');
            end
            hline(0,'k');
        end
        
        hold(current,'on');
        set(current,'Color','y');  
        
        for k = N_up+1:N_par
            switch mod(k-N_up,4)
                case 1
                    plot(current,Phi(:,k,currentWalker).*conj(Phi(:,k,currentWalker)),'-b','LineWidth',width);
                    hold(current,'on');
                case 2
                    plot(current,Phi(:,k,currentWalker).*conj(Phi(:,k,currentWalker)),':b','LineWidth',width);
                    hold(current,'on');
                case 3
                    plot(current,Phi(:,k,currentWalker).*conj(Phi(:,k,currentWalker)),'--b','LineWidth',width);
                    hold(current,'on');
                case 0
                    plot(current,Phi(:,k,currentWalker).*conj(Phi(:,k,currentWalker)),'-.b','LineWidth',width);
                    hold(current,'on');
                otherwise
                    disp('Exception in lineSpec');
            end        
        end        
        
    else   %otherwise if it's 2 dimensional   
        noOfSites = Lx * Ly;
        xVector = 1:Lx;%for plotting: xVector = [1 2 3 ... Lx]
        current=walkerAxes(currentWalker);
        set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);     
        cla(current);    
        planarForm = zeros(Lx,Ly,N_par); %the array that will store the 2-dimensional lattice amplitude
        for j = 1:N_up %for each electron        
            linearForm = Phi(:,j,currentWalker);%extract the amplitudes over all sites for one particular electron into a 1-dimensional array
            counter=1;
            
            for y=1:Ly
                for x = 1:Lx
                    planarForm(x,y,j)=linearForm(counter);
                    counter = counter+1;
                end
            end
        end

        for j = N_up+1:N_par
            linearForm = Phi(:,j,currentWalker);%extract the amplitudes over all sites for one particular electron into a 1-dimensional array
            counter=1;
            
            for y=1:Ly
                for x = 1:Lx
                    planarForm(x,y,j)=linearForm(counter);
                    counter = counter+1;
                end
            end
        end    
        %plot the result
        cla(current);    

        for j = 1:N_up
            switch mod(j,4)
                case 1
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-r','LineWidth',width);
                        set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                        hold(current,'on');
                    end
                case 2
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),':r','LineWidth',width);
                        set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                        hold(current,'on');
                    end
                case 3
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'--r','LineWidth',width);
                        set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                        hold(current,'on');
                    end
                case 0
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-.r','LineWidth',width);
                        set(current,'XLimMode','manual','XLim',[1 Lx],'YLim',[1 Ly]);
                        hold(current,'on');
                    end
                otherwise
                    disp('Exception in lineSpec');
            end
        end
        for j = N_up+1:N_par   
            switch mod(j-N_up,4)
                case 1
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-b','LineWidth',width);
                        hold(current,'on');
                    end
                case 2
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),':b','LineWidth',width);
                        hold(current,'on');
                    end
                case 3
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'--b','LineWidth',width);
                        hold(current,'on');
                    end
                case 0
                    for m = 1:Ly
                        yVector = repmat(m,1,Lx);
                        plot3(current,xVector,yVector,planarForm(:,m,j).*conj(planarForm(:,m,j)),'-.b','LineWidth',width);
                        hold(current,'on');
                    end
                otherwise
                    disp('Exception in lineSpec');
            end
        end 
    end
end
function plotDensity(N_wlk, N_up, N_par,  handles, currentWalker, Lx, Ly)
% draw the electronic density of each walker

    global   densityPanel   ;
    global Phi;
    global densityAxes;
    width=3;
    
    if (Lx==1)||(Ly==1)%if the lattice is only 1-dimensional
        if Lx==1
            dimens=Ly;        
        else
            dimens=Lx;
        end

        previous=densityAxes( mod(currentWalker+N_wlk-2,N_wlk)+1   );
        set(previous,'Color','w');
        current=densityAxes(currentWalker);    
        set(current,'XLimMode','manual','Color','y');        
        set(current,'XLim',[1 dimens]);    

        up = zeros(dimens,1);
        down = zeros(dimens,1);
        cla(current);
        
        for j = 1:dimens
            for k = 1:N_up
                up(j) = up(j) + abs(Phi(j,k,currentWalker))^2;
            end

            for k = N_up+1:N_par
                down(j) = down(j) + (abs(Phi(j,k,currentWalker)))^2;
            end
        end
        
        up=up/sum(up);
        down=down/sum(down);
        plot(current,up,'-r','LineWidth',width);
        set(current,'Color','y'); 
        hold(current,'on');
        plot(current,down,'-b','LineWidth',width);
        set(current,'Color','y');   

    else % 2D lattice
        noOfSites=Lx*Ly;
        xVector = 1:Lx;
            up = zeros(noOfSites,1);
            down = zeros(noOfSites,1);
            current=densityAxes(currentWalker);
            set(current,'XLim',[1 Lx],'YLim',[1 Ly]);
            cla(current);
            
            for j = 1:noOfSites
                for k = 1:N_up
                    up(j) = up(j) + abs(Phi(j,k,currentWalker))^2;
                end

                for k = N_up+1:N_par
                    down(j) = down(j) + (abs(Phi(j,k,currentWalker)))^2;
                end
            end
            up=up/sum(up);
            down=down/sum(down);
            
            %put into a 2-dimensional array
            planarForm = zeros(Lx,Ly,2);
            counter=1;
            
            for y=1:Ly
               for x = 1:Lx
                   planarForm(x,y,1)=up(counter);
                   counter = counter+1;
               end
            end
            
            counter=1;
            
            for y=1:Ly
               for x = 1:Lx
                   planarForm(x,y,2)=down(counter);
                   counter = counter+1;
               end
            end        

            for m = 1:Ly
                yVector = repmat(m,1,Lx);
                plot3(current,xVector,yVector,planarForm(:,m,1),'-r','LineWidth',width);
                hold(current,'on');
                plot3(current,xVector,yVector,planarForm(:,m,2),'-b','LineWidth',width);
            end      
    end
end

function plotDensityEnsemble(N_wlk, N_up, N_par,  handles, Lx, Ly)
% draw the electronic density of each walker

    global   densityPanel   ;
    global Phi;
    global densityAxes;
    width=3;
    
    if (Lx==1)||(Ly==1)%if the lattice is only 1-dimensional
        if Lx==1
            dimens=Ly;        
        else
            dimens=Lx;
        end

        for currentWalker=1:N_wlk     
            current=densityAxes(currentWalker);
            set(current,'XLimMode','manual');        
            set(current,'XLim',[1 Lx]);        

            up = zeros(dimens,1);
            down = zeros(dimens,1);        
            cla(current);
            
            for j = 1:dimens
                for k = 1:N_up
                    up(j) = up(j) + abs(Phi(j,k,currentWalker))^2;
                end
                for k = N_up+1:N_par
                    down(j) = down(j) + (abs(Phi(j,k,currentWalker)))^2;
                end
            end
            up=up/sum(up);
            down=down/sum(down);
            plot(current,up,'-r','LineWidth',width);
            hold(current,'on');
            plot(current,down,'-b','LineWidth',width);
        end
        current=densityAxes(N_wlk);
        set(current,'Color','y');
    else % 2D lattice
        noOfSites=Lx*Ly;
        xVector = 1:Lx;
        
        for currentWalker=1:N_wlk
            up = zeros(noOfSites,1);
            down = zeros(noOfSites,1);
            current=densityAxes(currentWalker);
            set(current,'XLim',[1 Lx],'YLim',[1 Ly]);
            cla(current);
            
            for j = 1:noOfSites
                for k = 1:N_up
                    up(j) = up(j) + abs(Phi(j,k,currentWalker))^2;
                end
                for k = N_up+1:N_par
                    down(j) = down(j) + (abs(Phi(j,k,currentWalker)))^2;
                end
            end
            up=up/sum(up);
            down=down/sum(down);
            %put into a 2-dimensional array
            planarForm = zeros(Lx,Ly,2);
            counter=1;
            
            for y=1:Ly
               for x = 1:Lx
                   planarForm(x,y,1)=up(counter);
                   counter = counter+1;
               end
            end
            
            counter=1;
            
            for y=1:Ly
               for x = 1:Lx
                   planarForm(x,y,2)=down(counter);
                   counter = counter+1;
               end
            end    
            
            for m = 1:Ly
                yVector = repmat(m,1,Lx);
                plot3(current,xVector,yVector,planarForm(:,m,1),'-r','LineWidth',width);
                hold(current,'on');
                plot3(current,xVector,yVector,planarForm(:,m,2),'-b','LineWidth',width);  
            end      
        end
    end
end

function hhh=hline(y,in1,in2)
% function h=hline(y, linetype, label)
% 
% Draws a horizontal line on the current axes at the location specified by 'y'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = hline(42,'g','The Answer')
%
% returns a handle to a green horizontal line on the current axes at y=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% hline also supports vector inputs to draw multiple lines at once.  For example,
%
% hline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001

    if length(y)>1  % vector input
        for I=1:length(y)
            switch nargin
            case 1
                linetype='r:';
                label='';
            case 2
                if ~iscell(in1)
                    in1={in1};
                end
                if I>length(in1)
                    linetype=in1{end};
                else
                    linetype=in1{I};
                end
                label='';
            case 3
                if ~iscell(in1)
                    in1={in1};
                end
                if ~iscell(in2)
                    in2={in2};
                end
                if I>length(in1)
                    linetype=in1{end};
                else
                    linetype=in1{I};
                end
                if I>length(in2)
                    label=in2{end};
                else
                    label=in2{I};
                end
            end
            h(I)=hline(y(I),linetype,label);
        end
    else
        switch nargin
        case 1
            linetype='r:';
            label='';
        case 2
            linetype=in1;
            label='';
        case 3
            linetype=in1;
            label=in2;
        end   
        g=ishold(gca);
        hold on

        x=get(gca,'xlim');
        h=plot(x,[y y],linetype);
        if ~isempty(label)
            yy=get(gca,'ylim');
            yrange=yy(2)-yy(1);
            yunit=(y-yy(1))/yrange;
            if yunit<0.2
                text(x(1)+0.02*(x(2)-x(1)),y+0.02*yrange,label,'color',get(h,'color'))
            else
                text(x(1)+0.02*(x(2)-x(1)),y-0.02*yrange,label,'color',get(h,'color'))
            end
        end

        if g==0
        hold off
        end
        set(h,'tag','hline','handlevisibility','off') % this last part is so that it doesn't show up on legends
    end % else

    if nargout
        hhh=h;
    end
end

function plotEnergy(i_blk, deltau, E_blk, handles,N_blksteps)
% plot the total energy of all walkers as a function of imaginary time

    global energyPlot ;
    axes(energyPlot);
    plot (N_blksteps*((1:i_blk)*deltau),E_blk,'-o');
    xlabel ('tau');
    ylabel ('E');
end

function plotWeight(i_blk, deltau, W_blk, handles,N_blksteps)
% plot the total weight of all walkers as a function of imaginary time

    global weightPlot;
    axes(weightPlot);
    plot (N_blksteps*((1:i_blk)*deltau),W_blk,'-o');
    xlabel ('tau');
    ylabel ('Total weight');
end

function announce(msg,handles)
% print messages to the GUI log

    oldmsgs = cellstr(get(handles.statusHndl,'String'));
    set(handles.statusHndl,'String',[{msg};oldmsgs] );
end

function handles = drawPanels(handles)
% redraw the panels when the visualization options are changed

    global energyPlotPanel walkerPanel densityPanel weightPlotPanel energyPlot weightPlot;
    set(handles.statusHndl,'String','Welcome to CPMC-Lab! The latest simulation events will appear at the top of this log.');
    seeWalker=get(handles.visualizeWalkerChkBx,'Value');
    seeDensity=get(handles.visualizeDensityChkBx,'Value');

    if seeWalker == 1 && seeDensity == 1  
        a = energyPlotPanel;
        b = walkerPanel;
        c= densityPanel;
        d= weightPlotPanel;    
        energyPlotPanel=uipanel(handles.tab2Handle,'Position',[0 0 0.34 0.3],'Title','Energy vs imaginary time','BackgroundColor','white');
        weightPlotPanel=uipanel(handles.tab2Handle,'Position',[0 0.32 0.34 0.3],'Title','Total weight vs imaginary time','BackgroundColor','white');
        walkerPanel=uipanel(handles.tab2Handle,'Position',[.35 .45 .65 .45],'Title','Orbital Structure of Random Walkers','BackgroundColor','White');
        densityPanel=uipanel(handles.tab2Handle,'Position',[.35 0 .65 .45],'Title','Electronic Density','BackgroundColor','White');  
        delete(a); 
        delete(b);
        delete(c);
        delete(d);         
        energyPlot=axes('parent',energyPlotPanel);
        weightPlot=axes('parent',weightPlotPanel); 
        
    elseif seeWalker == 0 && seeDensity == 1
        %store handle to the current panels
        a = energyPlotPanel;
        b = walkerPanel;
        c= densityPanel;
        d= weightPlotPanel;
        % make these handles point to new figures in new positions
        energyPlotPanel=uipanel(handles.tab2Handle,'Position',[.35 .45 .65 .45],'Title','Energy vs imaginary time','BackgroundColor','White');
        weightPlotPanel=uipanel(handles.tab2Handle,'Position',[0 0.32 0.34 0.3],'Title','Total weight vs imaginary time','BackgroundColor','white');
        densityPanel=uipanel(handles.tab2Handle,'Position',[.35 0 .65 .45],'Title','Electronic Density','BackgroundColor','White');
        walkerPanel=uipanel(handles.tab2Handle,'Visible','off');
        %then delete old panels    
        delete(a); 
        delete(b);
        delete(c);
        delete(d);    
        energyPlot=axes('parent',energyPlotPanel);
        weightPlot=axes('parent',weightPlotPanel);   
        
    elseif seeWalker == 1 && seeDensity == 0
        a = energyPlotPanel;
        b = walkerPanel;
        c= densityPanel;
        d= weightPlotPanel;%    
        energyPlotPanel=uipanel(handles.tab2Handle,'Position',[.35 0 .65 .45],'Title','Energy vs imaginary time','BackgroundColor','White');
        weightPlotPanel=uipanel(handles.tab2Handle,'Position',[0 0.32 0.34 0.3],'Title','Total weight vs imaginary time','BackgroundColor','white');
        densityPanel=uipanel(handles.tab2Handle,'Visible','off');
        walkerPanel=uipanel(handles.tab2Handle,'Position',[.35 .45 .65 .45],'Title','Orbital Structure of Random Walkers','BackgroundColor','White');
        delete(a); 
        delete(b);
        delete(c);
        delete(d);
        energyPlot=axes('parent',energyPlotPanel);
        weightPlot=axes('parent',weightPlotPanel); 
        
    elseif seeWalker == 0 && seeDensity == 0
        a = energyPlotPanel;
        b = walkerPanel;
        c= densityPanel;
        d= weightPlotPanel;
        energyPlotPanel=uipanel(handles.tab2Handle,'Position',[.35 .45 .65 .45],'Title','Energy vs imaginary time','BackgroundColor','White');
        weightPlotPanel=uipanel(handles.tab2Handle,'Position',[.35 0 .65 .45],'Title','Total weight vs imaginary time','BackgroundColor','White');
         walkerPanel=uipanel(handles.tab2Handle,'Visible','off');
        densityPanel=uipanel(handles.tab2Handle,'Visible','off');
        delete(a); 
        delete(b);
        delete(c);
        delete(d);
        energyPlot=axes('parent',energyPlotPanel);
        weightPlot=axes('parent',weightPlotPanel);
    else
        disp('Should never get here!');
    end
end

function v = getversion
%GETVERSION return MATLAB version number as a double.
% GETVERSION determines the MATLAB version, and returns it as a double.  This
% allows simple inequality comparisons to select code variants based on ranges
% of MATLAB versions.
%
% As of MATLAB 7.5, the version numbers are listed below:
%
%   MATLAB version                      getversion return value
%   -------------------------------     -----------------------
%   7.5.0.342 (R2007b)                  7.5
%   7.4.0.287 (R2007a)                  7.4
%   7.3.0.267 (R2006b)                  7.3
%   7.2.0.232 (R2006a)                  7.2
%   7.1.0.246 (R14) Service Pack 3      7.1
%   7.0.4.365 (R14) Service Pack 2      7.04
%   7.0.1.24704 (R14) Service Pack 1    7.01
%   6.5.2.202935 (R13) Service Pack 2   6.52
%   6.1.0.4865 (R12.1)                  6.1
%   ...
%   5.3.1.something (R11.1)             5.31
%   3.2 whatever                        3.2
%
% Example:
%
%       v = getversion ;
%       if (v >= 7.0)
%           this code is for MATLAB 7.x and later
%       elseif (v == 6.52)
%           this code is for MATLAB 6.5.2
%       else
%           this code is for MATLAB versions prior to 6.5.2
%       end
%
% This getversion function has been tested on versions 6.1 through 7.5, but it
% should work in any MATLAB that has the functions version, sscanf, and length.
%
% See also version, ver, verLessThan.

% Copyright 2007, Timothy A. Davis, Univ. of Florida

% This function does not use ver, in the interest of speed and portability.
% "version" is a built-in that is about 100 times faster than the ver m-file.
% ver returns a struct, and structs do not exist in old versions of MATLAB.
% All 3 functions used here (version, sscanf, and length) are built-in.
%
% Copyright (c) 2009, Timothy A. Davis
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the University of Florida nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

    v = sscanf (version, '%d.%d.%d') ;
    v = 10.^(0:-1:-(length(v)-1)) * v ;
end