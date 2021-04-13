///////////////////////////////////////////////////////////
//
//                         OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

uses
    MM, Helpers, Back, MMAttack, Keys;

var
    Profession: integer;

///////////////////////////////////////////////////////////
//
//                   OVERRIDE FUNCTIONS
//
///////////////////////////////////////////////////////////

procedure OnPacket(id1, id2: cardinal; data: pointer; size: word);
begin
    if (id1 = CHAR_INFO_PACKET) or (id1 = MAGIC_SKILL_USE_PACKET)
    then Backlight.OnPacket(id1, data, size);

    if (id1 = MAGIC_SKILL_USE_PACKET)
    then begin
        if (Profession = MM_CLASS)
        then begin
            MysticMuse.AutoFlashPacket(data, size);
            MysticMuse.AssistPacket(data, size);
        end;
    end;
end;

///////////////////////////////////////////////////////////
//
//                     THREADS FUNCTIONS
//
///////////////////////////////////////////////////////////

procedure DetectProfessionThread();
begin
    while true do
    begin
        if (Profession <> User.ClassID())
        then begin
            Profession := User.ClassID();
            PrintBotMsg('Switch to new class: ' + ClassIDToStr(Profession));
        end;
        Delay(1000);
    end;
end;

procedure AutoAttackThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.RunAutoAttack();
        Delay(10);
    end;
end;

procedure AutoFlashThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.AutoFlash();
        Delay(10);
    end;
end;

procedure FindAfterKillThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.FindTargetAfterKill();
        Delay(10);
    end;
end;

procedure HoldTargetThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.TargetHold();
        Delay(10);
    end;
end;

procedure SaveTargetThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.TargetSave();
        Delay(10);
    end;
end;

procedure SelfBuffThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.SelfBuff();
        Delay(10);
    end;
end;

procedure ReskillThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.Reskill();
        Delay(10);
    end;
end;

procedure KeysThread();
begin
    while true do
    begin
        Keyboard.KeysRead();
        delay(10);
    end;
end;

procedure AssistAttackThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.AssistAttack();
        delay(300);
    end;
end;

procedure AssistSpellThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.AssistSpell();
        delay(50);
    end;
end;

procedure MoveToAssistThread();
begin
    while true do
    begin
        if (Profession = MM_CLASS)
        then MysticMuse.MoveToAssister();
        delay(50);
    end;
end;

///////////////////////////////////////////////////////////
//
//                      MAIN FUNCTION
//
///////////////////////////////////////////////////////////

begin
    PrintBotMsg('===========================');
    PrintBotMsg('Welcome to OTOMO Next');
    PrintBotMsg('Free Radar + Assister by LanGhost');
    PrintBotMsg('https://github.com/adrixfree');
    PrintBotMsg('Change your configs in settings.ini');
    PrintBotMsg('===========================');

    Backlight := TBacklight.Create();
    MysticMuse := TMysticMuse.Create();
    Keyboard := TKeyboard.Create();

    Keyboard.Addkey(KEY_MM_NEXT_TARGET_ALL, '1');
    Keyboard.Addkey(KEY_MM_NEXT_TARGET_MM, '2');
    Keyboard.Addkey(KEY_MM_NEXT_TARGET_BP, '3');
    Keyboard.Addkey(KEY_MM_NEXT_ATTACK_RANGE, 'F2');
    Keyboard.Addkey(KEY_MM_FAST_RES, '5');
    Keyboard.Addkey(KEY_MM_AUTO_ATTACK_RUN, 'SPACE');

    Keyboard.Addkey(KEY_MM_NEXT_ROLE, 'F1');
    Keyboard.Addkey(KEY_MM_IGNORE_WL, '4');
    Keyboard.Addkey(KEY_MM_TARGET_FIND_AFTER_KILL, 'F3');
    Keyboard.Addkey(KEY_MM_SELF_NOOBLE, 'F4');
    Keyboard.Addkey(KEY_MM_NEXT_ATTACK_TYPE, 'F5');
    Keyboard.Addkey(KEY_MM_CANCEL, '6');

    MysticMuse.AddAssister('Cyclone');
    MysticMuse.SetMoveToAssister(true);

    script.NewThread(@DetectProfessionThread);
    script.NewThread(@AutoAttackThread);
    script.NewThread(@AutoFlashThread);
    script.NewThread(@SaveTargetThread);
    script.NewThread(@HoldTargetThread);
    script.NewThread(@FindAfterKillThread);
    script.NewThread(@SelfBuffThread);
    script.NewThread(@ReskillThread);
    script.NewThread(@KeysThread);
    script.NewThread(@AssistSpellThread);
    script.NewThread(@AssistAttackThread);
    script.NewThread(@MoveToAssistThread);
end.