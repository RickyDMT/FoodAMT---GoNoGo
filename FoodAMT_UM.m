function FoodAMT_UM(varargin)
%Developed based on Lawrence, 2014 GoNoGo task by ELK (elk@uoregon.edu)

%The Dictionary.
%All variables and data are stored in a .mat structure called FoodAMT_###.mat.
%A script will be developed (12/5 = in development) to extract data to a
%csv.
%Variables:
%FoodAMT.var.trial_type: Tells you what pic type was displayed; 1 = Go pic
%(e.g., lo cal food); 2 = NoGo (high cal food); 3 = Neutral (water)
%FoodAMT.var.picnum:  Which pic from list was chosen.
%FoodAMT.var.GoNoGo:  1 = go trial, 0 = no-go trial
%FoodAMT.var.lr: What side was image presented on.  1 = left; 2 = right

%Data:
%All trial-by-trial data are arranged such that each column represents a
%block and each row represents a trial within that block.
%FoodAMT.data.rt: Reaction time. Initially all 0s. Correct & incorrect rts
    %stored in seconds. If appropriate non-press, value = -999.
%FoodAMT.data.correct: Designates if trial was correct. initially -999 (and so,
    %remains -999 if trials was not completed); 1 = correct; 0 = incorrect; 2 =
    %trial was a Go trial, but wrong button was pressed (i.e., Left button when
    %trial was a Right-side).
%FoodAMT.data.avg_rt: Average reaction time per block.
%FoodAMT.data.info: Basic info of subject, session, condition, etc.

global KEY COLORS w wRect XCENTER YCENTER PICS STIM FoodAMT trial

prompt={'SUBJECT ID' 'Order Condition (1-6)' 'Session (1, 2, 3, or 4)' 'Practice? 0 or 1'};
defAns={'4444' '1' '1' '1'};

answer=inputdlg(prompt,'Please input subject info',1,defAns);

ID=str2double(answer{1});
COND = str2double(answer{2});
SESS = str2double(answer{3});
prac = str2double(answer{4});

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
KEY.left = KbName('c');
KEY.right = KbName('m');


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
STIM.trials = 48;
STIM.gotrials = 72;     %Across two blocks, not total
STIM.notrials = 24;     %Across two blocks, not total
STIM.totes = STIM.blocks*STIM.trials;
STIM.trialdur = 1;

%% Find & load in pics
%find the image directory by figuring out where the .m is kept

[imgdir,~,~] = fileparts(which('FoodAMT_UM.m'));

try
    cd(imgdir)
catch
    error('Could not find and/or open the pic folder. Are you sure you have added the .m to the path?');
end


    PICS.in.Healthy = dir('*');
    PICS.in.Unhealthy = dir('Flower*');

%Check if pictures are present. If not, throw error.
if isempty(PICS.in.Healthy) || isempty(PICS.in.Unhealthy)
    error('Could not find pics. Please ensure pictures are found in a folder names IMAGES within the folder containing the .m task file.');
end

%% Fill in rest of pertinent info
FoodAMT = struct;

%Each row represents a block ordering, per info document. RA will either
%enter or .m will randomly select which condition to assign participant to.
ordercond = [1 1 0 0;
    1 1 0 0;
    1 1 0 0;
    0 0 1 1;
    0 0 1 1;
    0 0 1 1];

% Order if you have to use "1 2 3 4"
%  ordercond = [1 3 2 4;
%     3 1 2 4;
%     1 3 4 2;
%     2 4 1 3;
%     4 2 1 3;
%     2 4 3 1]
    
%Or this will be hard coded?
trial_types = [ones(STIM.gotrials,1); repmat(2,STIM.notrials,1)];  %1 = go; 2 = no.  Block type determines whether go = healthy, etc.
gonogo = [ones(STIM.gotrials,1); zeros(STIM.notrials,1)];                         %1 = go; 0 = nogo;

%Make long list of #s to represent each pic
%Assumes right number of pics are present!
piclist = [1:length(PICS.in.Healthy) 1:length(PICS.in.Unhealthy)]';

% trial_types = [trial_types gonogo piclist l_r];
% shuffled = trial_types(randperm(size(trial_types,1)),:);

piclist = NaN(length(gonogo),1);

trial_types = [trial_types gonogo piclist l_r]; %jitter];
shuffled = trial_types(randperm(size(trial_types,1)),:);
shuffled((shuffled(:,1)==1),3) = [randperm(60)'; randperm(60)'; randperm(60,STIM.gotrials-120)'];
shuffled((shuffled(:,1)==2),3) = [randperm(60)'; randperm(60)'; randperm(60,STIM.notrials-120)'];

%Add jitter on "+"

for g = 1:STIM.blocks;
    row = ((g-1)*STIM.trials)+1;
    rend = row+STIM.trials - 1;
    FoodAMT.var.trial_type(1:STIM.trials,g) = shuffled(row:rend,1);
    FoodAMT.var.picnum(1:STIM.trials,g) = shuffled(row:rend,3);
    FoodAMT.var.GoNoGo(1:STIM.trials,g) = shuffled(row:rend,2);
    FoodAMT.var.lr(1:STIM.trials,g) = shuffled(row:rend,4);
end

    FoodAMT.var.picname = cell(STIM.trials,STIM.blocks);
    FoodAMT.data.rt = zeros(STIM.trials, STIM.blocks);
    FoodAMT.data.correct = zeros(STIM.trials, STIM.blocks)-999;
    FoodAMT.data.avg_rt = zeros(STIM.blocks,1);
    FoodAMT.data.info.ID = ID;
    FoodAMT.data.info.cond = COND;               %Condtion 1 = Food; Condition 2 = animals
    FoodAMT.data.info.session = SESS;
    FoodAMT.data.info.date = sprintf('%s %2.0f:%02.0f',date,d(4),d(5));
    


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
[w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,30);

KbName('UnifyKeyNames');

%% Set frame size;

% This sets 'DrawLine' to draw dashed line.
Screen('LineStipple',w,1,5);

%This sets location for L & R image display. Basically chooses a square
%whose side=1/2 the vertical size of the screen $ is vertically centered.
%The square is then placed 1/10th the width of the screen from the L & R
%edge.
STIM.img(1,1:4) = [wRect(3)/10,wRect(4)/4,wRect(3)/10+wRect(4)/2,wRect(4)*(3/4)];             %L
STIM.img(2,1:4) = [(wRect(3)*(9/10))-wRect(4)/2,wRect(4)/4,wRect(3)*(9/10),wRect(4)*(3/4)];   %R

border = 20;
STIM.framerect = [STIM.img(1,1) - border; STIM.img(1,2) - border; STIM.img(2,3) + border; STIM.img(2,4) + border];

%% Initial screen
DrawFormattedText(w,'The Go-NoGo task is about to begin.\nPress any key to continue.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
KbWait();
Screen('Flip',w);
WaitSecs(1);

%% Instructions
instruct = sprintf('You will see pictures either on the left or right side of the screen, surrounded by a solid or dashed border.\n\nPress the "%s" if the image is on the left side of the screen or "%s" if the image is on right side of the screen\nBUT only if you see a solid bar around the image.\n\nDo not press if you see a dashed bar.\n\nPress any key to continue.',KbName(KEY.left),KbName(KEY.right));
DrawFormattedText(w,instruct,'center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
KbWait();

%% Practice

if prac == 1;
    %Set up single trials with instructions; and maybe additional trials with
    %verbose feedback ("You pressed the key when the line was dashed. Only
    %press the key when the line is solid.")
    DrawFormattedText(w,'Let''s practice.\n\nPress any key to continue.','center','center',COLORS.WHITE);
    Screen('Flip',w);
    KbWait([],2);
    
    
    % Practice goes here.
    % Pratice is mandatory.  Should ask at end if they want to see practice
    % again. Use "while 1" and break with KbCheck == no, do not repeat
    % practice.
    
    oldold = Screen('TextSize',w,20);
    
    %Make box for text
    prac_box = STIM.img;
    prac_box(:,2) = 0;
    prac_box(:,4) = wRect(4);
    
    %Load first neutral pic
    practpic = imread(getfield(PICS,'in','neut',{1},'name'));
    practpic = Screen('MakeTexture',w,practpic);
    
    %Display pic on left to show go signal and "left" key.
    Screen('FrameRect',w,COLORS.rect,STIM.framerect,6);
    Screen('DrawTexture',w,practpic,[],STIM.img(1,:));
    pract_text = sprintf('In this trial you would press "%s" because the image is on the left with a solid frame. Press "%s" now.',KbName(KEY.left),KbName(KEY.left));
    DrawFormattedText(w,pract_text,'center','center',COLORS.WHITE,25,[],[],1.5,[],prac_box(2,:));
    Screen('Flip',w);
    
%     while 1
%         [d, ~, ccc] = KbCheck();            %wait for left key to be pressed
%         if (d == 1 && any(find(ccc)) == KEY.left)
%             Screen('Flip',w);
%             WaitSecs(1);
%             break;         
%         end
%     end
    while 1

        [dd, ~, cc] = KbCheck();            %wait for "right" key to be pressed
        if dd == 1 && find(cc) == KEY.left
            Screen('Flip',w);
            WaitSecs(1);

            break;

        end
    end
    %Display img on Right to show use of "right" key.
    Screen('FrameRect',w,COLORS.rect,STIM.framerect,6);
    Screen('DrawTexture',w,practpic,[],STIM.img(2,:));
    pract_text = sprintf('And in this trial you would press "%s" because the image is on the right with a solid frame.\n\nPress "%s" now.',KbName(KEY.right),KbName(KEY.right));
    DrawFormattedText(w,pract_text,'center','center',COLORS.WHITE,25,[],[],1.5,[],prac_box(1,:));
    Screen('Flip',w);
    while 1
       
        [dd, ~, cc] = KbCheck();            %wait for "right" key to be pressed
        if dd == 1 && find(cc) == KEY.right
            Screen('Flip',w);
            WaitSecs(1);
            
            break;

        end
    end
    Screen('Flip',w);
    WaitSecs(1);
    
    %Now do "no go" trial.
    DrawDashRect();
    Screen('DrawTexture',w,practpic,[],STIM.img(1,:));
    pract_text = sprintf('In the trials with the dashed frame, do not press any buttons. A real trial like this will move on automatically.\n\nPress any key to continue.');
    DrawFormattedText(w,pract_text,'center','center',COLORS.WHITE,25,[],[],1.5,[],prac_box(2,:));
    Screen('Flip',w);
    KbWait([],2);
    WaitSecs(.5);
    
    %Do another no go trial with image on other side
    DrawDashRect();
    Screen('DrawTexture',w,practpic,[],STIM.img(2,:));
    pract_text = sprintf('It doesn''t matter which side the image is on, do not press either button.\n\nPress any key to continue.');
    DrawFormattedText(w,pract_text,'center','center',COLORS.WHITE,25,[],[],1.5,[],prac_box(1,:));
    Screen('Flip',w);
    KbWait([],2);
    Screen('Flip',w);
    WaitSecs(2);
    
    Screen('TextSize',w,oldold);
end

%% Task
DrawFormattedText(w,'The Go-NoGo task is about to begin.\n\n\nPress any key to begin the task.','center','center',COLORS.WHITE);
Screen('Flip',w);
KbWait([],3);
Screen('Flip',w);
WaitSecs(1.5);

for block = 1:STIM.blocks;
    %Load pics block by block.
    DrawPics4Block(block);
    ibt = sprintf('Prepare for Block %d. \n\n\nPress any key when you are ready to begin.',block);
    DrawFormattedText(w,ibt,'center','center',COLORS.WHITE);
    Screen('Flip',w);
    KbWait();
    
    old = Screen('TextSize',w,80);
    for trial = 1:STIM.trials;
        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(.5); %XXX: Jitter this.
        
        [FoodAMT.data.rt(trial,block), FoodAMT.data.correct(trial,block)] = DoPicGoNoGo(trial,block);
        
        %Wait 500 ms
        Screen('Flip',w);
        WaitSecs(.5);
    end
    Screen('TextSize',w,old);
    %Inter-block info here, re: Display RT, accuracy, etc.
    %Calculate block RT
    Screen('Flip',w);   %clear screen first.
    
    block_text = sprintf('Block %d Results',block);
    
    c = FoodAMT.data.correct(:,block) == 1;                                 %Find correct trials
%     corr_count = sprintf('Number Correct:\t%d of %d',length(find(c)),STIM.trials);  %Number correct = length of find(c)
    corr_per = length(find(c))*100/length(c);                           %Percent correct = length find(c) *100 / total trials
%     corr_pert = sprintf('Percent Correct:\t%4.1f%%',corr_per);          %sprintf that data to string.
%     fulltext = sprintf('Number Correct:\t\t%d of %d\nPercent Correct:\t\t%4.1f%%',length(find(c)),STIM.trials,corr_per);
    
    if isempty(c(c==1))
        %Don't try to calculate avg RT, they got them all wrong (WTF?)
        %Display "N/A" for this block's RT.
%         ibt_rt = sprintf('Average RT:\tUnable to calculate RT due to 0 correct trials.');
        fulltext = sprintf('Number Correct:\t\t%d of %d\nPercent Correct:\t\t%4.1f%%\nAverage RT:\t\tUnable to calculate due to 0 correct trials.',length(find(c)),STIM.trials,corr_per);
    else
        block_go = FoodAMT.var.GoNoGo(:,block) == 1;                        %Find go trials
        blockrts = FoodAMT.data.rt(:,block);                                %Pull all RT data
        blockrts = blockrts(c & block_go);                              %Resample RT only if go & correct.
        FoodAMT.data.avg_rt(block) = fix(mean(blockrts)*1000);                        %Display avg rt in milliseconds.
%         ibt_rt = sprintf('Average RT:\t\t\t%3d milliseconds',avg_rt_block);
        fulltext = sprintf('Number Correct:\t\t%d of %d\nPercent Correct:\t\t%4.1f%%\nAverage Rt:\t\t\t %3d milliseconds',length(find(c)),STIM.trials,corr_per,FoodAMT.data.avg_rt(block));

    end
    
    ibt_xdim = wRect(3)/10;
    ibt_ydim = wRect(4)/4;
%    old = Screen('TextSize',w,25);
    DrawFormattedText(w,block_text,'center',wRect(4)/10,COLORS.WHITE);   %Next lines display all the data.
%     DrawFormattedText(w,corr_count,ibt_xdim,ibt_ydim,COLORS.WHITE);
%     DrawFormattedText(w,corr_pert,ibt_xdim,ibt_ydim+30,COLORS.WHITE);    
%     DrawFormattedText(w,ibt_rt,ibt_xdim,ibt_ydim+60,COLORS.WHITE);
    DrawFormattedText(w,fulltext,ibt_xdim,ibt_ydim,COLORS.WHITE,[],[],[],1.5);
    %Screen('Flip',w);
    
    if block > 1
        % Also display rest of block data summary
        tot_trial = block * STIM.trials;
        totes_c = FoodAMT.data.correct == 1;
%         corr_count_totes = sprintf('Number Correct: \t%d of %d',length(find(totes_c)),tot_trial);
        corr_per_totes = length(find(totes_c))*100/tot_trial;
%         corr_pert_totes = sprintf('Percent Correct:\t%4.1f%%',corr_per_totes);
        
        if isempty(totes_c(totes_c ==1))
            %Don't try to calculate RT, they have missed EVERY SINGLE GO
            %TRIAL! 
            %Stop task & alert experimenter?
            fullblocktext = sprintf('Number Correct:\t\t%d of %d\nPercent Correct:\t\t%4.1f%%\nAverage RT:\tUnable to calculate RT due to 0 correct trials.',length(find(totes_c)),tot_trial,corr_per_totes);
        else
            tot_go = FoodAMT.var.GoNoGo == 1;
            totrts = FoodAMT.data.rt;
            totrts = totrts(totes_c & tot_go);
            avg_rt_tote = fix(mean(totrts)*1000);     %Display in units of milliseconds.
%             tot_rt = sprintf('Average RT:\t\t\t%3d milliseconds',avg_rt_tote);
            fullblocktext = sprintf('Number Correct:\t\t%d of %d\nPercent Correct:\t\t%4.1f%%\nAverage RT:\t\t\t %3d milliseconds',length(find(totes_c)),tot_trial,corr_per_totes,avg_rt_tote);
        end
        
        DrawFormattedText(w,'Total Results','center',YCENTER,COLORS.WHITE);
%         DrawFormattedText(w,corr_count_totes,ibt_xdim,ibt_ydim+150,COLORS.WHITE);
%         DrawFormattedText(w,corr_pert_totes,ibt_xdim,ibt_ydim+180,COLORS.WHITE);
%         DrawFormattedText(w,tot_rt,ibt_xdim,ibt_ydim+210,COLORS.WHITE);
        DrawFormattedText(w,fullblocktext,ibt_xdim,YCENTER+40,COLORS.WHITE,[],[],[],1.5);

    end
    
    if corr_per >= 70;
        praise_text = sprintf('%s\n\nPress any key to continue.',praise{randi(length(praise))});
    elseif corr_per >= 50;
        praise_text = sprintf('Nice job, but keep trying to improve!\n\nPress any key to continue.');
    else
        praise_text = sprintf('Stick with it! I know you can do better!\n\nPress any key to continue.');
    end
    DrawFormattedText(w,praise_text,'center',wRect(4)*8/10,COLORS.WHITE);
    Screen('Flip',w);
    KbWait();
    Screen('Flip',w);
end

%% Save all the data

%Export FoodAMT to text and save with subject number.
%find the mfilesdir by figuring out where show_faces.m is kept
[mfilesdir,~,~] = fileparts(which('Lawrence_GoNoGo.m'));

%get the parent directory, which is one level up from mfilesdir
savedir = [mfilesdir filesep 'Results' filesep];

if exist(savedir,'dir') == 0;
    % If savedir (the directory to save files in) does not exist, make it.
    mkdir(savedir);
end

try

save([savedir 'FoodAMT_' num2str(ID) '_' num2str(SESS) '.mat'],'FoodAMT');

catch
    error('Although data was (most likely) collected, file was not properly saved. 1. Right click on variable in right-hand side of screen. 2. Save as SST_#_#.mat where first # is participant ID and second is session #. If you are still unsure what to do, contact your boss, Kim Martin, or Erik Knight (elk@uoregon.edu).')
end

DrawFormattedText(w,'Thank you for participating\n in this part of the study!','center','center',COLORS.WHITE);
Screen('Flip', w);
KbWait();

sca

end

%%
function [trial_rt, correct] = DoPicGoNoGo(trial,block,varargin)
% tstart = tic;
% telap = toc(tstart);

global w STIM PICS COLORS FoodAMT KEY

lr = FoodAMT.var.lr(trial,block);           %Bring in L/R location; 1 = L, 2 = R
if lr == 1;                             %set up response keys
    corr_respkey = KEY.left;
    incorr_respkey = KEY.right;
else
    corr_respkey = KEY.right;
    incorr_respkey = KEY.left;
end
    
    Screen('DrawTexture',w,PICS.out(trial).texture,[],STIM.img(lr,:));
%     Screen('Flip',w,[],1);           %If there isn't supposed to be a delay between G/NG & pic, this should be removed.
    
    switch FoodAMT.var.GoNoGo(trial,block)
        case {1}    %GO
            Screen('FrameRect',w,COLORS.rect,STIM.framerect,6);
        case {0}    %NO GO
            DrawDashRect();     %Boutique code to draw dashed-frame
    end
%     Screen('DrawTexture',w,PICS.out(trial).texture,[],STIM.img(FoodAMT.var.lr(trial,block)));
    %NEEDS ANSWER: IS this a 100 ms delay in this task as well?
%     WaitSecs(.1);   
    RT_start = Screen('Flip',w,[],1);
    telap = GetSecs() - RT_start;
    correct = -999; 

    while telap <= (STIM.trialdur); %Subtract .1 from this if delay is desired.
        telap = GetSecs() - RT_start;
        [Down, ~, Code] = KbCheck();            %wait for key to be pressed
        if (Down == 1 && any(find(Code) == corr_respkey))
            trial_rt = GetSecs() - RT_start;
            
            if FoodAMT.var.GoNoGo(trial,block) == 0;        %If NoGo + Press, throw X
                DrawFormattedText(w,'X','center','center',COLORS.RED);
                Screen('Flip',w);
                correct = 0;
                WaitSecs(.5);
            else                                        %If Go + Press, move on
                Screen('Flip',w);                       %'Flip' in order to clear buffer; next flip (in main script) flips to black screen.
                correct = 1;
            end
            break
            
        elseif (Down == 1 && any(find(Code) == incorr_respkey)) %The wrong key was pressed. Throw X regardless of Go/No Go
            trial_rt = GetSecs() - RT_start;
            
            DrawFormattedText(w,'X','center','center',COLORS.RED);
            Screen('Flip',w);
            if FoodAMT.var.GoNoGo(trial,block) == 0;        %Distinguish between NoGo & Go incorrect
                correct = 0;
            else
                correct = 2;
            end
            
            WaitSecs(.5);
            break
        else
            FlushEvents();
        end
        
    end
    
    if correct == -999;
    Screen('DrawTexture',w,PICS.out(trial).texture,[],STIM.img(lr,:));
        
        if FoodAMT.var.GoNoGo(trial,block) == 0;    %NoGo Trial + Correct no press. Do nothing, move to inter-trial
            Screen('Flip',w);                   %'Flip' in order to clear buffer; next flip (in main script) flips to black screen.
            correct = 1;
        else                                    %Incorrect no press. Show "X" for .5 sec.
            DrawFormattedText(w,'X','center','center',COLORS.RED);
            Screen('Flip',w);
            correct = 0;
            WaitSecs(.5);
        end
        trial_rt = NaN;                        %No press = no RT = NaN
    end
    

FlushEvents();
end

%%
function DrawPics4Block(block,varargin)

global PICS FoodAMT w

    for j = 1:length(FoodAMT.var.trial_type);
        pic = FoodAMT.var.picnum(j,block);
        switch FoodAMT.var.trial_type(j,block)
            case {1}
                picname = getfield(PICS,'in','go',{pic},'name');
                PICS.out(j).raw = imread(picname);
%                 %I think this is is covered outside of switch/case
%                 PICS.out(j).texture = Screen('MakeTexture',w,PICS.out(j).raw);
            case {2}
                picname = getfield(PICS,'in','no',{pic},'name');
                PICS.out(j).raw = imread(picname);
            case {3}
                picname = getfield(PICS,'in','neut',{pic},'name');
                PICS.out(j).raw = imread(picname);
        end
        PICS.out(j).texture = Screen('MakeTexture',w,PICS.out(j).raw);
        FoodAMT.var.picname{j,block} = picname;
    end
%end
end

%%
function DrawDashRect(varargin)

global STIM w COLORS 

xl = STIM.framerect(1);
xr = STIM.framerect(3)+10;
yt = STIM.framerect(2);
yb = STIM.framerect(4)+10;

Screen('DrawLine',w,COLORS.WHITE,xl,yt,xl,yb,6);
Screen('DrawLine',w,COLORS.WHITE,xl,yb,xr,yb,6);
Screen('DrawLine',w,COLORS.WHITE,xr,yt,xr,yb,6);
Screen('DrawLine',w,COLORS.WHITE,xl,yt,xr,yt,6);
%Screen('Flip',w);

end

