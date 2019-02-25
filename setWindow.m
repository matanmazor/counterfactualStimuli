function [ w, rect ] = setWindow( debug )
%open psychtoolbox and set up screen for experiment
if debug
    PsychDebugWindowConfiguration() 
end

Screen('Preference','SkipSyncTests', debug)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;
[w, rect] = Screen('OpenWindow', screenNumber,...
    [255/2,255/2,255/2],[], 32, doublebuffer+1);
Screen(w,'TextSize',40)
KbName('UnifyKeyNames');
AssertOpenGL;
PsychVideoDelayLoop('SetAbortKeys', KbName('Escape'));
HideCursor();
Priority(MaxPriority(w));
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%The fMRI button box does not work well with KbCheck. I use KbQueue
%instead here, to get precise timings and be sensitive to all presses.
KbQueueCreate;
KbQueueStart;


end

