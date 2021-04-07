///////////////////////////////////////////////////////////
//
//                         OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

uses
    MM, Helpers, Back, MMAttack;

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
        then MysticMuse.AutoFlashPacket(data, size);
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

///////////////////////////////////////////////////////////
//
//                      MAIN FUNCTION
//
///////////////////////////////////////////////////////////

begin
    PrintBotMsg('===========================');
    PrintBotMsg('Welcome to OTOMO');
    PrintBotMsg('Free Radar + Assister by LanGhost');
    PrintBotMsg('https://github.com/adrixfree');
    PrintBotMsg('Change your configs in settings.ini');
    PrintBotMsg('===========================');

    Backlight := TBacklight.Create();
    MysticMuse := TMysticMuse.Create();

    script.NewThread(@DetectProfessionThread);
    script.NewThread(@AutoAttackThread);
    script.NewThread(@AutoFlashThread);
    script.NewThread(@SaveTargetThread);
    script.NewThread(@HoldTargetThread);
    script.NewThread(@FindAfterKillThread);
    script.NewThread(@SelfBuffThread);
end.