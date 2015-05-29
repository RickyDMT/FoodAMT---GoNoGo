function FoodANT_UM(varargin)
%Food-based Go/NoGo task, developed for Psychtoolbox by ELK (elk@uoregon.edu)
% Get latest version at github.com/rickyDMT
% 
%All variables and data are saved to a structure called FoodANT_###_#.mat and/or a similarly named text file.
% 
% Variables & Data:
% FoodANT.data.SubjID:      Subject ID
% FoodANT.data.Block:       Block Number
% FoodANT.data.Trial:       Trial Number
% FoodANT.data.block_type:  1 = Healthy-Go block; 0 = Unhealthy-Go block
% FoodANT.data.trial_type:  1 = Go trial; 0 = No Go trial -- Whether it is Healthy-Go or Unhealthy-Go is determined by "block_type"
% FoodANT.data.pic_num:     Number to help the program find the image
% FoodANT.data.pic_name:    Name of image that is displayed in that trial
% FoodANT.data.rt:          Reaction time in seconds. Clock starts when image is presented and stops if/when space bar is pressed.
%                           If space bar is not pressed, result is recorded as "NaN"
% FoodANT.data.correct:     Designates if trial was correct. 1 = correct; 0 = incorrect
%                           Note that this does not distinguish Go from NoGo, only if whatever happened was correct or not.
% 
% FoodANT.info:             Basic info of subject, session, condition, etc.
% 
% Notes:
% 1. Task beeps at start-up to allow you to adjust your speakers.


prompt={'SUBJECT ID' 'Order Condition (1 = H-Go first; 2 = UnH-Go first)' 'Session Number'}; % 'Practice? 0 or 1'};
defAns={'4444' '1' '1'}; % '1'};

answer=inputdlg(prompt,'Please input subject info',1,defAns);

ID=str2double(answer{1});
COND = str2double(answer{2});
SESS = str2double(answer{3});
% prac = str2double(answer{4});

%Make sure input data makes sense.
% try
%     if SESS > 1;
%         %Find subject data & make sure same condition.
%         
%     end
% catch
%     error('Subject ID & Condition code do not match.');
% end

rng_num = ID*SESS;
rng(rng_num); %Seed random number generator with subject ID
d = clock;

KEY = struct;
KEY.rt = KbName('SPACE');


COLORS = struct;
COLORS.BLACK = [0 0 0];
COLORS.WHITE = [255 255 255];
COLORS.RED = [255 0 0];
COLORS.BLUE = [0 0 255];
COLORS.GREEN = [0 255 0];
COLORS.YELLOW = [255 255 0];
COLORS.rect = COLORS.WHITE;

STIM = struct;
STIM.blocks = 4;
STIM.trials = 96;
STIM.gotrials = 74;     %Across one run, not total
STIM.notrials = 24;     %Across one run, not total
STIM.totes = STIM.blocks*STIM.trials;
STIM.totes_go = STIM.totes/2;
STIM.trialdur = 1;
STIM.rest = 45;         %How much "rest time" between blocks.

%% Find & load in pics
%find the image directory by figuring out where the .m is kept

[mdir,~,~] = fileparts(which('FoodANT_UM.m'));

imgdir = [mdir filesep 'Pics'];

try
    cd(imgdir)
catch
    error('Could not find and/or open the pic folder. Are you sure you have added the .m and its folder to the path?');
end


    PICS.in.Healthy = dir('Healthy*');
    PICS.in.Unhealthy = dir('Unhealthy*');

%Check if pictures are present. If not, throw error.
if isempty(PICS.in.Healthy) || isempty(PICS.in.Unhealthy)
    error('Could not find pics. Please ensure pictures are found in a folder names IMAGES within the folder containing the .m task file.');
end

%% Fill in rest of pertinent info

%Each row represents a block ordering, per info document. RA will either
%enter or .m will randomly select which condition to assign participant to.
ordercond = [1 1 0 0; 0 0 1 1]; %1 = Healthy is go; 0 = Unhealthy is go

% Order if you have to use "1 2 3 4" per initial instructions
%  ordercond = [1 3 2 4;
%     3 1 2 4;
%     1 3 4 2;
%     2 4 1 3;
%     4 2 1 3;
%     2 4 3 1]
    

trial_types = [ones(STIM.gotrials,1); zeros(STIM.notrials,1)];  %1 = go; 0 = no.  Block type determines whether go = healthy, etc.

%Make long list of #s to represent each pic; randomly ordered.
% Note: This creates an extra long list, just to be safe.
piclist_H = [randperm(length(PICS.in.Healthy)) randperm(length(PICS.in.Healthy))]; 
piclist_UnH = [randperm(length(PICS.in.Unhealthy)) randperm(length(PICS.in.Unhealthy))];

FoodANT.data = struct('SubjID',[],'Block',[],'Trial',[],'block_type',[],'trial_type',[],'pic_num',[],'pic_name',[],'rt',[],'correct',[]);

Hpic = 1;
UnHpic = 1;
for g = 1:STIM.blocks;
    shuffled = trial_types(randperm(size(trial_types,1)),:);
    
    for ttt = 1:STIM.trials;
        row = (g-1)*STIM.trials + ttt;
        
        FoodANT.data(row).SubjID = ID;
        FoodANT.data(row).Block = g;
        FoodANT.data(row).Trial = ttt;
        FoodANT.data(row).block_type = ordercond(COND,g);
        FoodANT.data(row).trial_type = shuffled(ttt);
        if ordercond(COND,g) == 1
            if shuffled(ttt) == 1;
                %this is a Healthy - go trial
                FoodANT.data(row).pic_num = piclist_H(Hpic);
                FoodANT.data(row).pic_name = PICS.in.Healthy(piclist_H(Hpic)).name;
                Hpic = Hpic + 1;
            else
                %this is an Unhealthy - nogo trial
                FoodANT.data(row).pic_num = piclist_UnH(UnHpic);
                FoodANT.data(row).pic_name = PICS.in.Unhealthy(piclist_UnH(UnHpic)).name;                
                UnHpic = UnHpic + 1;
            end
        else
            if shuffled(ttt) == 1;
                %this is an Unhealthy - go trial
                FoodANT.data(row).pic_num = piclist_UnH(UnHpic);
                FoodANT.data(row).pic_name = PICS.in.Unhealthy(piclist_UnH(UnHpic)).name;                
                UnHpic = UnHpic + 1;
            else
                %this is a Healthy - nogo trial
                FoodANT.data(row).pic_num = piclist_H(Hpic);
                FoodANT.data(row).pic_name = PICS.in.Healthy(piclist_H(Hpic)).name;
                Hpic = Hpic + 1;
            end
        end
        FoodANT.data(row).rt = NaN;
        FoodANT.data(row).correct = NaN;
    end
end

%     FoodANT.var.picname = cell(STIM.trials,STIM.blocks);
%     FoodANT.data.rt = zeros(STIM.trials, STIM.blocks);
%     FoodANT.data.correct = zeros(STIM.trials, STIM.blocks)-999;
%     FoodANT.data.avg_rt = zeros(STIM.blocks,1);
    FoodANT.info.ID = ID;
    FoodANT.info.cond = COND;               %Condtion 1 = Food; Condition 2 = animals
    FoodANT.info.session = SESS;
    FoodANT.info.date = sprintf('%s %2.0f:%02.0f',date,d(4),d(5));
    


commandwindow;

%%
%change this to 0 to fill whole screen
DEBUG=0;

%set up the screen and dimensions

%list all the screens, then just pick the last one in the list (if you have
%only 1 monitor, then it just chooses that one)
Screen('Preference', 'SkipSyncTests', 1);

screenNumber=max(Screen('Screens'));

if DEBUG==1;
    %create a rect for the screen
    winRect=[0 0 640 480];
    %establish the center points
    XCENTER=320;
    YCENTER=240;
else
    %change screen resolution
%     Screen('Resolution',0,1024,768,[],32);
    
    %this gives the x and y dimensions of our screen, in pixels.
    [swidth, sheight] = Screen('WindowSize', screenNumber);
    XCENTER=fix(swidth/2);
    YCENTER=fix(sheight/2);
    %when you leave winRect blank, it just fills the whole screen
    winRect=[];
end

%open a window on that monitor. 32 refers to 32 bit color depth (millions of
%colors), winRect will either be a 1024x768 box, or the whole screen. The
%function returns a window "w", and a rect that represents the whole
%screen. 
[w, ~]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%% Sound stuff.
wave=sin(1:0.25:500);
freq=8000;  % change this to change freq of tone
nrchannels = size(wave,1);
% Default to auto-selected default output device:
deviceid = -1;
% Request latency mode 2, which used to be the best one in our measurement:
reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2
% Initialize driver, request low-latency preinit:
InitializePsychSound(1);
% Open audio device for low-latency output:
pahandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freq, nrchannels);
PsychPortAudio('FillBuffer', pahandle, wave);

%% Font Stuff
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,30);

KbName('UnifyKeyNames');

%% Set Image Location
STIM.imgrect = [XCENTER-300; YCENTER-225; XCENTER+300; YCENTER+225];


%% Initial screen
PsychPortAudio('Start', pahandle, 1);
DrawFormattedText(w,'Welcome to the reaction time task.\nPress any key to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
KbWait();
Screen('Flip',w);
WaitSecs(1);

%% Instructions
instruct = 'In this task, we will show you a series of images of food. We want you to press the space bar as quickly & accurately as you can when you see certain types of foods -- either healthy or unhealthy. \n\nBefore each round we will tell you whether to press the space bar for healthy or unhealthy foods.\n\nPress any key to continue.'; %sprintf('In this task, we are going to show you a series of images. ',KbName(KEY.left),KbName(KEY.right));
DrawFormattedText(w,instruct,'center','center',COLORS.WHITE,75,[],[],1.5);
Screen('Flip',w);
KbWait();

%% Blocks & Trials of the Task
DrawFormattedText(w,'The task is about to begin.\n\n\nPress any key to begin the task.','center','center',COLORS.WHITE,60,[],[],1.5);
Screen('Flip',w);
KbWait([],3);
Screen('Flip',w);
WaitSecs(1.5);

for block = 1:STIM.blocks;
    %Load pics block by block.
    
    if ordercond(COND,block) == 1
        go_word = 'HEALTHY';
        nogo_word = 'UNHEALTHY';
    else
        go_word = 'UNHEALTHY';
        nogo_word = 'HEALTHY';
    end
    
    ibt = sprintf('Prepare for Round %d. \n\nIn this round, press the space bar when you see pictures of %s foods. \n\nIf you see %s foods do not press the button. \n\nPress any key when you are ready to begin.',block,go_word,nogo_word);
    DrawFormattedText(w,ibt,'center','center',COLORS.WHITE,80,[],[],1.5);
    Screen('Flip',w);
    KbWait();
    
    old = Screen('TextSize',w,180);
    for trial = 1:STIM.trials;
        %Figure out which row to grab var/put data...
        tnum = (block-1)*STIM.trials + trial;
        
        %Draw the right pic.
        pic_raw = imread(FoodANT.data(tnum).pic_name);
        pic_texture = Screen('MakeTexture',w,pic_raw);
        
        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(.5); %XXX: Jitter this.
        
        Screen('DrawTexture',w,pic_texture,[],STIM.imgrect);
        RT_start = Screen('Flip',w,[],1);
        telap = GetSecs() - RT_start;
        
        correct = -999;
        
        while telap <= (STIM.trialdur);
            telap = GetSecs() - RT_start;
            [Down, ~, Code] = KbCheck();            %wait for key to be pressed
            if (Down == 1 && any(find(Code) == KEY.rt))
                FoodANT.data(tnum).rt = GetSecs() - RT_start;
                
                if FoodANT.data(tnum).trial_type == 0
                    %This was a nogo trial; throw error X.
                    Screen('DrawTexture',w,pic_texture,[],STIM.imgrect);
                    DrawFormattedText(w,'X','center','center',COLORS.RED);
                    Screen('Flip',w);
                    WaitSecs(.5);
                    
                    correct = 0;
                    break
                else
                    Screen('Flip',w);
                    
                    correct = 1;
                    break
                end
            end
        end
        
        if correct == -999
            %If no button was pressed...
            
            if FoodANT.data(tnum).trial_type == 0;
                %this was a correct no go trial!
                Screen('Flip',w);
                    
                correct = 1;
            else
                %You no-goed a go trial!
                Screen('DrawTexture',w,pic_texture,[],STIM.imgrect);
                DrawFormattedText(w,'X','center','center',COLORS.RED);
                Screen('Flip',w);
                WaitSecs(.5);
                
                correct = 0;
            end
        end
        
        FoodANT.data(tnum).correct = correct;
        
        %Wait 500 ms in darkness
        Screen('Flip',w);
        WaitSecs(.5);
    end
    
    Screen('TextSize',w,old);
    
    if block < STIM.blocks
        postbloc_text = sprintf('REST. \n\nThe next round will begin in %d seconds.',STIM.rest);
        DrawFormattedText(w,postbloc_text,'center','center',COLORS.WHITE);
        Screen('Flip',w);
        
        for elap = 1:STIM.rest
        
            if rem(elap,5) == 0
                countd = STIM.rest - elap;
                postbloc_text = sprintf('REST. \n\nThe next round will begin in %d seconds.',countd);
                DrawFormattedText(w,postbloc_text,'center','center',COLORS.WHITE);
                Screen('Flip',w);   %clear screen first.
            end
            WaitSecs(1);
        end
        PsychPortAudio('Start', pahandle, 1);
    end
    
end

DrawFormattedText(w,'That concludes this task. Please let the experimenter know you are finished.','center','center',COLORS.WHITE);
Screen('Flip',w);


%% Save all the data

%Export FoodANT to text and save with subject number.
%find the mfilesdir by figuring out where show_faces.m is kept

%Find the Results folder
savedir = [mdir filesep 'Results' filesep];
try
    cd(savedir)
catch
    warning('Could not change directory to %s. Are you sure it exists? Will attempt to save in main directory, located at %s',savedir,mdir);
    savedir = mdir;
    try
        cd(savedir)
    catch
        warning('Can''t find main directory for some reason. Now attemping to save the file at %s',pwd);
    end
end

save_name = sprintf('FoodANT_%03d_%d',ID,SESS);
save_name_txt = [save_name '.txt'];

if exist(save_name_txt,'file') == 2
    save_name = sprintf('FoodANT_%03d_%d_%s_%2.0f%02.0f',ID,SESS,date,d(4),d(5));
end


try
fid = fopen(save_name_txt,'a');
fprintf(fid,'ID: %d\nCond: %d\nSession: %d\nDate & Time: %s\n',FoodANT.info.ID,FoodANT.info.cond,FoodANT.info.session,FoodANT.info.date);

%Save Tab-delim Text File
WriteStructsToText(fid,FoodANT.data);

%Save the raw structure as a .mat
save([save_name '.mat'],'FoodANT');

catch
    save_name_ins = [save_name '-err.mat'];
    warning('There may have been a problem saving the file. Check that the subject file was saved. As an insurance policy, the entirey of the workspace has now been saved as %s in %s.',save_name_ins,pwd);
    save(save_name_ins);
end

fclose(fid);

% DrawFormattedText(w,'Thank you for participating\n in this part of the study!','center','center',COLORS.WHITE);
WaitSecs(5);
Screen('Flip', w);


sca

end

