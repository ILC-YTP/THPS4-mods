
ALWAYSPLAYMUSIC = 1
HIDEHUD = 0
meta_button_map_ps2 = [
  3
  0
  0
  1
  2
  2
  1
  1
  2
  1
  14
  15
  0
  1
  2
  16
  17
  2
  1
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
]
meta_button_map_gamecube = [
  3
  1
  0
  1
  2
  2
  1
  1
  2
  0
  14
  15
  1
  2
  2
  14
  15
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
]
meta_button_map_xbox = [
  3
  2
  0
  1
  2
  2
  1
  1
  0
  1
  14
  15
  2
  1
  1
  14
  15
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
  0
]
smallfont_colors = [
  [ 128 128 128 100 ]
  [ 102 26 8 100 ]
  [ 17 64 116 100 ]
  [ 9 107 36 100 ]
  [ 123 99 3 100 ]
  [ 0 128 128 100 ]
  [ 128 0 128 100 ]
  [ 30 50 80 100 ]
  [ 88 105 112 128 ]
]
dialogfont_colors = [
  [ 88 105 112 128 ]
  [ 102 26 8 100 ]
  [ 17 64 116 100 ]
  [ 9 107 36 100 ]
  [ 123 99 3 100 ]
  [ 127 102 0 100 ]
  [ 100 100 128 100 ]
]

SCRIPT new_screen_element_test
  PushMemProfile "Fonts and Bitmaps"
  ScreenElementSystemInit
  LoadLevelPreFile "panelsprites.pre"
  LoadFont "testtitle" char_spacing = -4 space_spacing = 15
  LoadFont "newtrickfont" char_spacing = -1 space_spacing = 14 color_tab = newtrickfont_colors
  LoadFont "small" char_spacing = 1.5 space_spacing = 9 color_tab = smallfont_colors
  LoadFont "newtimerfont" char_spacing = -1
  LoadFont "dialog" char_spacing = 0 space_spacing = 10 color_tab = dialogfont_colors
  LoadFont buttons_font
  load_textures_to_main_memory
  load_permanent_textures
  create_panel_stuff
  UnloadPreFile "panelsprites.pre" dont_assert
  setup_main_button_event_mappings
  SetScreenElementProps {
    id = root_window
    tags = { menu_state = off }
  }
  FireEvent type = focus target = root_window
  PopMemProfile
ENDSCRIPT

SCRIPT handle_start_pressed
  root_window:GetTags
  IF ChecksumEquals a = <menu_state> b = on
    IF GotParam pause_controller
      IF not ( <pause_controller> = -1 )
        IF not ( <device_num> = <pause_controller> )
          RETURN
        ENDIF
      ENDIF
    ENDIF
    IF not InNetGame
      UnPauseGame
    ENDIF
    exit_pause_menu
  ENDIF
  IF ChecksumEquals a = <menu_state> b = off
    IF not InMultiplayerGame
      IF not ControllerBoundToSkater controller = <device_num> skater = 0
        RETURN
      ENDIF
    ELSE
      IF InSplitScreenGame
        IF not ControllerBoundToSkater controller = <device_num> skater = 0
          IF not ControllerBoundToSkater controller = <device_num> skater = 1
            RETURN
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    SetTags pause_controller = <device_num>
    possibly_remove_temp_special_trick
    IF not InNetGame
      GetSkaterID
      IF GetSkaterCamAnimParams skater = <objId>
        IF ( <allow_pause> = 0 )
          RETURN
        ENDIF
      ENDIF
      Printf "-------------------- PAUSING GAME ----------------------"
      PauseGame
      Wait 1 gameframe
      pause_trick_text
      pause_balance_meter
      kill_blur
      IF ObjectExists id = speech_box_anchor
        RunScriptOnScreenElement id = speech_box_anchor hide_screen_element
      ENDIF
      IF ScreenElementExists id = goal_start_dialog
        DestroyScreenElement id = goal_start_dialog
      ENDIF
      IF ObjectExists id = ped_speech_dialog
        DestroyScreenElement id = ped_speech_dialog
      ENDIF
      IF ObjectExists id = goal_retry_anchor
        DestroyScreenElement id = goal_retry_anchor
      ENDIF
      hide_goal_panel_messages
      GoalManager_PauseAllGoals
    ENDIF
    create_pause_menu device_num = <device_num>
  ENDIF
ENDSCRIPT

SCRIPT restore_start_key_binding
  SetScreenElementProps {
    id = root_window
    event_handlers = [ { pad_start handle_start_pressed } ]
    replace_handlers
  }
ENDSCRIPT

SCRIPT kill_start_key_binding
  SetScreenElementProps {
    id = root_window
    event_handlers = [ { pad_start null_script } ]
    replace_handlers
  }
ENDSCRIPT

SCRIPT make_new_ingame_menu
  make_new_menu <...>
ENDSCRIPT

SCRIPT make_new_menu { menu_title = "Paused"
    padding_scale = 1.15
    internal_scale = 1
    pos = (230, 109)
    dims = (200, 100)
    internal_just = [ left top ]
    parent = root_window
    just = [ center center ]
    scrolling_menu_offset = (0, 10)
  }
   <pos> = ( <pos> + (0, 12) )
  SetScreenElementLock id = <parent> off
  CreateScreenElement {
    type = ContainerElement
    parent = <parent>
    id = <menu_id>
    font = small
    pos = (320, 240)
    scale = 1
    dims = (640, 480)
    focusable_child = <vmenu_id>
  }
  SWITCH <type>
  CASE VScrollingMenu
    IF GotParam scrolling_menu_title_id
      CreateScreenElement {
        type = TextElement
        parent = <menu_id>
        id = <scrolling_menu_title_id>
        font = testtitle
        text = <menu_title>
        scale = 1.4
        pos = <pos>
        just = [ left top ]
        rgba = [ 128 128 128 98 ]
        not_focusable
      }
      GetStackedScreenElementPos Y id = <id> offset = <scrolling_menu_offset>
    ENDIF
    CreateScreenElement {
      type = VScrollingMenu
      parent = <menu_id>
      id = <scrolling_menu_id>
      pos = <pos>
      just = [ left top ]
      dims = <dims>
      scale = <scale>
      internal_just = [ left top ]
      num_items_to_show = <num_items_to_show>
    }
     <vscrolling_menu_id> = <id>
    CreateScreenElement {
      type = VMenu
      parent = <vscrolling_menu_id>
      id = <vmenu_id>
      dims = <dims>
      dims = <dims>
      font = small
      just = [ left top ]
      pos = (0, 0)
      scale = <scale>
      regular_space_amount = <regular_space_amount>
      padding_scale = <padding_scale>
      internal_scale = <internal_scale>
      internal_just = <internal_just>
       <dont_allow_wrap>
      event_handlers = [ { pad_up generic_menu_up_or_down_sound params = { up } }
        { pad_down generic_menu_up_or_down_sound params = { down } }
        { pad_back generic_menu_pad_back_sound }
      ]
    }
  DEFAULT
    IF ( <menu_id> = main_menu )
      pad_back_script = null_script
    ELSE
      pad_back_script = generic_menu_pad_back_sound
    ENDIF
    CreateScreenElement {
      type = VMenu
      parent = <menu_id>
      id = <vmenu_id>
      font = small
      just = [ left top ]
      pos = <pos>
      padding_scale = <padding_scale>
      internal_scale = <internal_scale>
      internal_just = <internal_just>
       <dont_allow_wrap>
      event_handlers = [ { pad_up generic_menu_up_or_down_sound params = { up } }
        { pad_down generic_menu_up_or_down_sound params = { down } }
        { pad_back <pad_back_script> }
      ]
    }
    CreateScreenElement {
      type = TextElement
      parent = <vmenu_id>
      font = testtitle
      text = <menu_title>
      scale = 1.4
      rgba = [ 128 128 128 98 ]
      not_focusable
    }
  ENDSWITCH
  AssignAlias id = <menu_id> alias = current_menu_anchor
  AssignAlias id = <vmenu_id> alias = current_menu
  IF GotParam helper_text
    create_helper_text <helper_text>
  ENDIF
ENDSCRIPT

SCRIPT make_new_sprite_menu menu_id = main_menu_anchor vmenu_id = main_menu pad_back_script = exit_pause_menu
  SetScreenElementLock id = root_window off
  CreateScreenElement {
    type = ContainerElement
    parent = root_window
    id = <menu_id>
    font = small
    pos = (320, 240)
    just = [ center center ]
    scale = 0
    dims = (640, 480)
    focusable_child = <vmenu_id>
  }
  IF GotParam menu_title
    CreateScreenElement {
      type = SpriteElement
      parent = <menu_id>
      texture = <menu_title>
      pos = (330, 60)
      just = [ left top ]
      rgba = [ 128 128 128 70 ]
    }
  ENDIF
  CreateScreenElement {
    type = VMenu
    parent = <menu_id>
    id = <vmenu_id>
    font = small
    just = [ left top ]
    pos = (241, 80)
    internal_just = [ left top ]
    event_handlers = [ { pad_back generic_menu_pad_back_sound }
      { pad_back <pad_back_script> params = <pad_back_params> }
      { pad_up generic_menu_up_or_down_sound params = { up } }
      { pad_down generic_menu_up_or_down_sound params = { down } }
    ]
  }
  AssignAlias id = <menu_id> alias = current_menu_anchor
  AssignAlias id = <vmenu_id> alias = current_menu
ENDSCRIPT

SCRIPT set_menu_bg parent = current_menu_anchor
   <number_of_slices> = 7
   <slice_height> = 32
   <slice_scale> = (1, 1.25)
   <slice_height> = ( ( (0, 1).<slice_scale> ) * <slice_height> )
  CreateScreenElement {
    type = SpriteElement
    parent = <parent>
    texture = paused
    pos = (153, 69)
    just = [ left top ]
    rgba = [ 118 118 128 120 ]
  }
  GetStackedScreenElementPos X id = <id> offset = (-8, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = <parent>
    texture = SlicePause_1
    pos = <pos>
    just = [ left top ]
    scale = <paused_bar_scale>
  }
  IF ObjectExists id = current_menu
    SetScreenElementLock id = current_menu on
    GetScreenElementDims id = current_menu
    GetScreenElementPosition id = <id>
     <top_of_first_slice> = ( <ScreenElementPos>.(0, 1) )
    GetScreenElementPosition id = current_menu
     <top_of_menu> = ( <ScreenElementPos>.(0, 1) )
     <height> = ( <height> - <slice_height> )
     <height> = ( <height> + ( <top_of_menu> - <top_of_first_slice> ) )
     <draw_all> = 0
  ELSE
     <height> = 400
     <draw_all> = 1
  ENDIF
   <last_slice> = 1
  BEGIN
    IF ( <draw_all> = 0 )
      IF ( ( <height> < 0 ) or ( <last_slice> = <number_of_slices> ) )
        BREAK
      ENDIF
    ELSE
      IF ( <last_slice> = <number_of_slices> )
        BREAK
      ENDIF
    ENDIF
     <last_slice> = ( <last_slice> + 1 )
    FormatText ChecksumName = texture_name "SlicePause_%i" i = <last_slice>
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = <parent>
      texture = <texture_name>
      pos = <pos>
      just = [ left top ]
      scale = <slice_scale>
    }
     <height> = ( <height> - <slice_height> )
  REPEAT
ENDSCRIPT

SCRIPT set_sub_bg { parent = current_menu_anchor
    pos = (326, 115)
    scale = (1.17, 1.1)
    just = [ center top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = <parent>
    texture = options_bg
    draw_behind_parent
    pos = <pos>
    scale = <scale>
    just = <just>
    rgba = [ 128 128 128 128 ]
    z_priority = 1
  }
ENDSCRIPT

SCRIPT set_sub_bg_goal goal_mid_scale = (14.8, 1.33) pos = (250, 23) goal_end_scale = (1, 1.33)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = options_bg
    draw_behind_parent
    pos = <pos>
    scale = (1.1, 1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 0
  }
  GetStackedScreenElementPos Y id = <id> offset = (5, -36)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_left
    draw_behind_parent
    pos = <pos>
    scale = <goal_end_scale>
    just = [ left top ]
    rgba = [ 56 60 71 118 ]
    z_priority = 0
  }
  GetStackedScreenElementPos X id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_mid
    draw_behind_parent
    pos = <pos>
    scale = <goal_mid_scale>
    just = [ left top ]
    rgba = [ 56 60 71 118 ]
    z_priority = 0
  }
  GetStackedScreenElementPos X id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    draw_behind_parent
    pos = <pos>
    scale = <goal_end_scale>
    just = [ left top ]
    rgba = [ 56 60 71 118 ]
    z_priority = 0
  }
ENDSCRIPT

SCRIPT create_icon pos = (176, 115) parent = current_menu_anchor scale = (0.95, 0.95) z_priority = 5
  CreateScreenElement {
    type = SpriteElement
    parent = <parent>
    id = <id>
    pos = <pos>
    scale = <scale>
    just = [ left top ]
    rgba = [ 127 102 0 128 ]
    z_priority = <z_priority>
    texture = <texture>
  }
ENDSCRIPT

SCRIPT make_text_sprite pos = (-27, 10) just = [ center center ] rgba = [ 128 128 128 50 ] scale = 0.45
  CreateScreenElement {
    type = SpriteElement
    parent = <parent>
    texture = <texture>
    pos = <pos>
    rgba = [ 0 0 0 0 ]
    just = <just>
    scale = <scale>
  }
ENDSCRIPT

SCRIPT create_pause_menu
  IF CustomParkMode editing
    SetParkEditorPauseMode pause
  ENDIF
  IF not GotParam no_sound
    PlaySound MenuBack vol = 50
  ENDIF
  remove_ss_menu_textures_from_vram
  add_pause_menu_textures_to_vram
  unhide_root_window
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  IF ObjectExists id = console_message_vmenu
    DoScreenElementMorph id = console_message_vmenu time = 0 scale = 0
  ENDIF
  IF InNetGame
    IF LocalSkaterExists
      skater:NetDisablePlayerInput
    ENDIF
  ELSE
    IF CustomParkMode editing
      parked_setup_main_menu
      PauseMusicAndStreams 1
      RETURN
    ENDIF
    IF CustomParkMode testing
      parked_setup_test_play_menu
      PauseMusicAndStreams 1
      RETURN
    ENDIF
    IF InSplitScreenGame
      create_mp_pause_menu
      PauseMusicAndStreams 1
      RETURN
    ENDIF
  ENDIF
  PauseMusicAndStreams 1
  IF GotParam no_exit
    make_new_sprite_menu menu_id = pause_menu vmenu_id = pause_vmenu pad_back_script = nullscript
  ELSE
    make_new_sprite_menu menu_id = pause_menu vmenu_id = pause_vmenu pad_back_script = handle_start_pressed
  ENDIF
  IF not GotParam no_exit
    create_helper_text generic_helper_text
  ELSE
    create_helper_text generic_helper_text_no_back
  ENDIF
  kill_start_key_binding
  IF GameModeEquals is_singlesession
    IF GoalManager_GoalIsActive name = TrickAttack
      make_sprite_menu_item text = "Continue" id = menu_continue pad_choose_script = handle_start_pressed
      make_text_sprite texture = PA_continue parent = menu_continue
    ELSE
      SetScreenElementProps id = pause_vmenu event_handlers = [ { pad_back null_script } ] replace_handlers
      create_helper_text generic_helper_text_no_back
    ENDIF
  ELSE
    IF not GotParam no_exit
      make_sprite_menu_item text = "Continue" id = menu_continue pad_choose_script = handle_start_pressed
      make_text_sprite texture = PA_continue parent = menu_continue
    ENDIF
  ENDIF
  IF GameModeEquals is_goal_attack
    IF not IsObserving
      IF GoalManager_CanRetryGoal
        IF GoalManager_GetLastGoalId
          IF not GoalManager_HasWonGoal name = <goal_id>
            make_sprite_menu_item text = "Retry Last Goal" id = menu_retry_goal pad_choose_script = menu_select pad_choose_params = { menu_select_script = RetryCurrentGoal }
            make_text_sprite texture = PA_retry parent = menu_retry_goal
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    make_sprite_menu_item text = "View Goals" id = menu_view_goals pad_choose_script = create_view_selected_goals_menu
    make_text_sprite texture = PA_view parent = menu_view_goals
  ENDIF
  IF GameModeEquals is_career
    IF GoalManager_IsInCompetition
      GoalManager_GetGoalParams name = <goal_id>
      IF GotParam already_ended_run
        IF ( <already_ended_run> = 0 )
          make_sprite_menu_item text = "End Current Run" id = menu_end_run pad_choose_script = goal_comp_end_current_run
          make_text_sprite texture = PA_end parent = menu_end_run
        ENDIF
      ENDIF
    ENDIF
    IF GoalManager_CanRetryGoal
      IF GoalManager_GoalIsActive name = kon_goal_tour
        make_sprite_menu_item text = "End Goal Early" id = menu_end_run2 pad_choose_script = Kon_Goal_Tour_Expire_3
        make_text_sprite texture = PA_end parent = menu_end_run2
      endif
      IF GoalManager_GoalIsActive name = Alc_Goal_Gaps6
        make_sprite_menu_item text = "End Goal Early" id = menu_end_run2 pad_choose_script = Alc_Goal_Gaps6_End_Early
        make_text_sprite texture = PA_end parent = menu_end_run2
      endif
      make_sprite_menu_item text = "Retry Last Goal" id = menu_retry_goal pad_choose_script = menu_select pad_choose_params = { stop_streams menu_select_script = RetryCurrentGoal }
      make_text_sprite texture = PA_retry parent = menu_retry_goal
    ENDIF
    IF GoalManager_HasActiveGoals
      make_sprite_menu_item text = "End Current Goal" id = menu_end_current_goal pad_choose_script = menu_select pad_choose_params = { menu_select_script = end_current_goal_run }
      make_text_sprite texture = PA_end parent = menu_end_current_goal
    ENDIF
    make_sprite_menu_item text = "View Goals" id = menu_view_goals pad_choose_script = create_view_goals_menu
    make_text_sprite texture = PA_view parent = menu_view_goals
  ELSE
    IF GameModeEquals is_singlesession
      make_sprite_menu_item text = "Retry High Score" id = menu_retry_high_score pad_choose_script = change_gamemode_singlesession_menu
      make_text_sprite texture = PA_rescore parent = menu_retry_high_score
    ENDIF
  ENDIF
  IF InNetGame
    IF OnServer
      IF OnXbox
        make_sprite_menu_item text = "Host Options" id = menu_network_server_opts_select pad_choose_script = network_options_selected
      ELSE
        make_sprite_menu_item text = "Server Options" id = menu_network_server_opts_select pad_choose_script = network_options_selected
      ENDIF
      make_text_sprite texture = PA_network parent = menu_network_server_opts_select
    ENDIF
    IF IsHost
      IF GameModeEquals is_lobby
        IF not OnServer
          IF OnXbox
            make_sprite_menu_item text = "Server Options" id = menu_network_server_opts_select pad_choose_script = network_options_selected
          ELSE
            make_sprite_menu_item text = "Server Options" id = menu_network_server_opts_select pad_choose_script = network_options_selected
          ENDIF
          make_text_sprite texture = PA_network parent = menu_network_server_opts_select
        ENDIF
        IF not NetworkGamePending
          IF not ChangeLevelPending
            make_sprite_menu_item text = "Start Game" id = menu_network_start_select pad_choose_script = network_game_options_selected
            make_text_sprite texture = PA_retry parent = menu_network_start_select
            make_sprite_menu_item text = "Change level" id = menu_level_select pad_choose_script = launch_level_select_menu pad_choose_params = { show_warning }
            make_text_sprite texture = PA_level parent = menu_level_select
          ENDIF
        ENDIF
      ELSE
        make_sprite_menu_item text = "End Current Game" id = menu_network_end_select pad_choose_script = network_end_game_selected
        make_text_sprite texture = PA_end parent = menu_network_end_select
      ENDIF
    ENDIF
    make_sprite_menu_item text = "Options" id = menu_options pad_choose_script = create_options_menu
    make_text_sprite texture = PA_options parent = menu_options
    IF not OnXbox
      IF IsTrue bootstrap_build
        make_sprite_menu_item text = "Player List" id = menu_network_remove_select pad_choose_script = launch_remove_players_menu not_focusable = not_focusable
        make_text_sprite texture = PA_fonts parent = menu_network_remove_select
      ELSE
        make_sprite_menu_item text = "Player List" id = menu_network_player_list_select pad_choose_script = launch_player_list_menu
        make_text_sprite texture = PA_fonts parent = menu_network_player_list_select
        IF ProfileLoggedIn
          make_sprite_menu_item text = "Homie List" id = menu_network_homie_list_select pad_choose_script = launch_shell_buddy_list
          make_text_sprite texture = PA_fonts parent = menu_network_homie_list_select
        ENDIF
      ENDIF
    ENDIF
  ELSE
    IF not IsTrue bootstrap_build
      make_sprite_menu_item text = "Change level" id = menu_level_select pad_choose_script = launch_level_select_menu
      make_text_sprite texture = PA_level parent = menu_level_select
      make_sprite_menu_item text = "Save Game" id = menu_save_game pad_choose_script = launch_pause_menu_save_game_sequence
      make_text_sprite texture = PA_save parent = menu_save_game
    ENDIF
    make_sprite_menu_item text = "Instant Replay" id = menu_view_replay pad_choose_script = in_game_view_replay
    make_text_sprite texture = PA_movie parent = menu_view_replay
    make_sprite_menu_item text = "Options" id = menu_options pad_choose_script = create_options_menu
    make_text_sprite texture = PA_options parent = menu_options
    IF not IsTrue Demo_Build
      IF not CD
        make_sprite_menu_item text = "Goto Restart" id = menu_skip_to_restart pad_choose_script = launch_restart_menu
        make_text_sprite texture = PA_restart parent = menu_skip_to_restart
    make_sprite_menu_item text = "Debug Menu" id = debug_menu pad_choose_script = create_debug_menu
    make_text_sprite texture = PA_model parent = debug_menu
      ENDIF
    ENDIF
    IF not LevelIs load_Sk4Ed_gameplay
      make_sprite_menu_item text = "View Gaps" id = menu_skip_to_gap pad_choose_script = launch_gap_menu
      make_text_sprite texture = PA_gap parent = menu_skip_to_gap
    ENDIF
  ENDIF
  IF InNetGame
    IF GameModeEquals is_lobby
      IF not IsObserving
        make_sprite_menu_item {
          text = "Set Cust Restart"
          id = menu_set_custom
          pad_choose_script = menu_select
          pad_choose_params = { menu_select_script = set_custom_restart }
        }
        make_text_sprite texture = PA_set_cust parent = menu_set_custom
        IF skater:SetCustomRestart
          make_sprite_menu_item text = "Goto Cust Restart" id = menu_skip_to_custom pad_choose_script = menu_select pad_choose_params = { menu_select_script = skip_to_custom_restart }
          make_text_sprite texture = PA_skip_cust parent = menu_skip_to_custom
        ENDIF
      ENDIF
    ENDIF
  ELSE
    IF not GoalManager_HasActiveGoals count_all
      IF not skater:PlayerInputIsDisabled
        make_sprite_menu_item text = "Set Cust Restart" id = menu_set_custom pad_choose_script = menu_select pad_choose_params = { menu_select_script = set_custom_restart }
        make_text_sprite texture = PA_set_cust parent = menu_set_custom
        IF skater:SetCustomRestart
          make_sprite_menu_item text = "Goto Cust Restart" id = menu_skip_to_custom pad_choose_script = menu_select pad_choose_params = { menu_select_script = skip_to_custom_restart }
          make_text_sprite texture = PA_skip_cust parent = menu_skip_to_custom
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  IF InNetGame
    make_sprite_menu_item text = "Chat Message" id = menu_chat pad_choose_script = launch_chat_keyboard
    make_text_sprite texture = PA_taunt parent = menu_chat
    IF not OnServer
      IF not IsObserving
        IF InInternetMode
          IF IsTrue bootstrap_build
            make_sprite_menu_item text = "Observe" id = menu_network_observe_select pad_choose_script = chose_observe not_focusable = not_focusable
            make_text_sprite texture = PA_network parent = menu_network_observe_select
          ELSE
            make_sprite_menu_item text = "Observe" id = menu_network_observe_select pad_choose_script = chose_observe
            make_text_sprite texture = PA_network parent = menu_network_observe_select
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    IF OnServer
      IF IsHost
        IF GameModeEquals is_lobby
          IF not NetworkGamePending
            IF not ChangeLevelPending
              GetPreferenceChecksum pref_type = network device_type
              SWITCH <checksum>
              CASE device_sony_modem
              CASE device_usb_modem
                do_nothing
              DEFAULT
                IF InInternetMode
                  IF IsTrue bootstrap_build
                    make_sprite_menu_item text = "Sit Out" id = menu_network_sit_select pad_choose_script = launch_network_sit_out_menu not_focusable = not_focusable
                    make_text_sprite texture = PA_pause parent = menu_network_sit_select
                  ELSE
                    make_sprite_menu_item text = "Sit Out" id = menu_network_sit_select pad_choose_script = launch_network_sit_out_menu
                    make_text_sprite texture = PA_pause parent = menu_network_sit_select
                  ENDIF
                ENDIF
              ENDSWITCH
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    make_sprite_menu_item text = "Quit" id = menu_quit pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = launch_quit_game_dialog }
    make_text_sprite texture = PA_quit parent = menu_quit
  ELSE
    IF CustomParkMode testing
      Printf "PARK EDITOR TEST PLAY MENU"
      make_sprite_menu_item text = "Back to editor" id = menu_skateshop pad_choose_script = menu_confirm_quit pad_choose_params = { yes_script = exit_test_play }
      make_text_sprite texture = PA_quit parent = menu_skateshop
    ELSE
      make_sprite_menu_item text = "Quit" id = menu_skateshop pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = menu_confirm_quit }
      make_text_sprite texture = PA_quit parent = menu_skateshop
    ENDIF
  ENDIF
  set_menu_bg
  RunScriptOnScreenElement id = pause_menu menu_onscreen
ENDSCRIPT

SCRIPT create_mp_pause_menu
  SetButtonEventMappings unblock_menu_input
  make_new_sprite_menu menu_id = pause_menu vmenu_id = pause_vmenu pad_back_script = handle_start_pressed
  kill_start_key_binding
  create_helper_text generic_helper_text
  make_sprite_menu_item text = "Continue" id = menu_continue pad_choose_script = handle_start_pressed
  make_text_sprite texture = PA_continue parent = menu_continue
  make_sprite_menu_item text = "End Current Game" id = menu_network_end_select pad_choose_script = network_end_game_selected
  make_text_sprite texture = PA_network parent = menu_network_end_select
  make_sprite_menu_item text = "Options" id = menu_mp_options pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_options_menu }
  make_text_sprite texture = PA_options parent = menu_mp_options
  make_sprite_menu_item text = "Quit" id = menu_skateshop pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = menu_confirm_quit }
  make_text_sprite texture = PA_quit parent = menu_skateshop
  set_menu_bg
  RunScriptOnScreenElement id = pause_menu menu_onscreen
ENDSCRIPT

SCRIPT exit_pause_menu menu_id = current_menu_anchor
  Debounce X time = 0.3
  IF InNetGame
    IF LocalSkaterExists
      skater:NetEnablePlayerInput
    ENDIF
  ENDIF
  IF not RunningReplay
    UnPauseGame
  ENDIF
  PauseStream 0
  IF GoalManager_HasActiveGoals
    PauseMusic 0
  ELSE
    IF IsTrue ALWAYSPLAYMUSIC
      PauseMusic 0
    ENDIF
  ENDIF
  IF not InNetGame
    unpause_trick_text
  ENDIF
  Unpause_Balance_Meter
  possibly_add_temp_special_trick
  IF ObjectExists id = speech_box_anchor
    RunScriptOnScreenElement id = speech_box_anchor unhide_screen_element
  ENDIF
  IF ObjectExists id = goal_start_dialog
    RunScriptOnScreenElement id = goal_start_dialog unhide_screen_element
  ENDIF
  IF ObjectExists id = ped_speech_dialog
    RunScriptOnScreenElement id = ped_speech_dialog unhide_screen_element
  ENDIF
  show_goal_panel_messages
  IF not RunningReplay
    GoalManager_UnPauseAllGoals
  ENDIF
  SetViewMode 0
  IF ObjectExists id = <menu_id>
    DestroyScreenElement id = <menu_id>
  ENDIF
  remove_pause_menu_textures_from_vram no_assert
  remove_level_select_menu_textures_from_vram no_assert
  remove_select_skater_textures_from_vram no_assert
  remove_edit_skater_textures_from_vram no_assert
  kill_pause_menu_cams
  SetScreenElementProps id = root_window tags = { menu_state = off }
  IF not InMultiplayerGame
    GoalManager_ShowPoints
    IF not GoalManager_HasActiveGoals
      GoalManager_ShowGoalPoints
    ELSE
      GoalManager_HideGoalPoints
    ENDIF
  ENDIF
  IF CustomParkMode editing
    remove_pause_menu_textures_from_vram
    SetParkEditorState state = edit
    SetParkEditorPauseMode unpause
  ENDIF
  IF LevelIs load_skateshop
    SetScreenElementProps {
      id = root_window
      tags = { menu_state = off }
      event_handlers = [ { pad_start skateshop_practice_start_pressed } ]
      replace_handlers
    }
  ELSE
    restore_start_key_binding
  ENDIF
  IF ObjectExists id = console_message_vmenu
    DoScreenElementMorph id = console_message_vmenu time = 0 scale = 1
  ENDIF
  IF ( HIDEHUD = 1 )
    Printf "hiding"
    hide_root_window
  ENDIF
ENDSCRIPT

SCRIPT kill_pause_menu_cams
  kill_proset_cams
ENDSCRIPT

SCRIPT set_custom_restart
  skater:SetCustomRestart Set
ENDSCRIPT

SCRIPT skip_to_custom_restart
  skater:SkipToCustomRestart
ENDSCRIPT

SCRIPT launch_restart_menu
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_restart_menu
ENDSCRIPT

SCRIPT create_restart_menu
  make_new_menu menu_id = restart_menu vmenu_id = restart_vmenu menu_title = "RESTART" padding_scale = 0.8 internal_scale = 0.8 type = VScrollingMenu dims = (320, 280)
  SetScreenElementProps { id = restart_menu
    event_handlers = [ { pad_back generic_menu_pad_back params = { callback = create_pause_menu } } ]
    pos = (315, 180)
  }
  AddRestartsToMenu initial_scale = 0.8
  set_sub_bg pos = (320, 108)
  create_icon texture = PA_restart pos = (169, 108)
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT skip_to_selected_restart
  ResetSkaters <...>
  exit_pause_menu
ENDSCRIPT

SCRIPT preview_restart
  pulse_blur start = 200 speed = 5
  ResetSkaters <...>
  SetProps rgba = [ 128 128 0 128 ]
  DoMorph time = 0.25 scale = 1.0
ENDSCRIPT

SCRIPT scale_down_restart
  SetProps rgba = [ 88 105 112 128 ]
  DoMorph time = 0.25 scale = 0.8
ENDSCRIPT

SCRIPT launch_gap_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  create_gap_menu
ENDSCRIPT

SCRIPT create_gap_menu
  remove_pause_menu_textures_from_vram
  add_gap_menu_textures_to_vram
  GoalManager_HidePoints
  GoalManager_HideGoalPoints
  SetScreenElementLock id = root_window off
  CreateScreenElement {
    type = ContainerElement
    parent = root_window
    id = gap_menu
    dims = (640, 480)
    pos = (320, 240)
  }
  AssignAlias id = gap_menu alias = current_menu_anchor
  create_helper_text { helper_text_elements = [ { text = "\b7/\b4 = Select" }
      { text = "\m1 = Back" }
    ]
  }
  kill_start_key_binding
  set_sub_bg_goal goal_mid_scale = (19, 1.33) pos = (180, 23)
  create_icon texture = PA_gap pos = (37, 23)
   <root_pos> = (80, 25)
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "GAP CHECKLIST"
    rgba = [ 128 128 128 85 ]
    pos = ( <root_pos> + (4, 0) )
    just = [ left top ]
    scale = 1.35
  }
  GetStackedScreenElementPos Y id = <id> offset = (-19, -4)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_gaps_menu_top_bar
    texture = black
    rgba = [ 0 0 0 85 ]
    scale = (124, 7)
    pos = <pos>
    just = [ left top ]
    z_priority = 2
  }
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = dialog
    text = "Score"
    rgba = [ 127 102 0 100 ]
    scale = 0.9
    pos = ( <pos> + (7, 5) )
    just = [ left top ]
    z_priority = 3
  }
  GetStackedScreenElementPos X id = <id> offset = (15, 0)
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = dialog
    text = "Name"
    rgba = [ 127 102 0 100 ]
    pos = <pos>
    just = [ left top ]
    scale = 0.9
    z_priority = 3
  }
  GetStackedScreenElementPos X id = <id> offset = (115, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_gaps_menu_up_arrow
    texture = up_arrow
    rgba = [ 128 128 128 85 ]
    pos = <pos>
    just = [ left top ]
    z_priority = 3
  }
  GetStackedScreenElementPos X id = <id> offset = (168, 0)
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = dialog
    text = "Times"
    rgba = [ 127 102 0 100 ]
    pos = <pos>
    just = [ left top ]
    scale = 0.9
    z_priority = 3
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_top_bar offset = (60, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    scale = (2, 78)
    pos = <pos>
    just = [ left top ]
    rgba = [ 0 0 0 80 ]
  }
  GetStackedScreenElementPos X id = <id> offset = (355, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    scale = (2, 78)
    pos = <pos>
    just = [ left top ]
    rgba = [ 0 0 0 80 ]
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_top_bar offset = (0, 287)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    rgba = [ 0 0 0 105 ]
    scale = (124, 6)
    pos = <pos>
    just = [ left top ]
    z_priority = 2
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_up_arrow offset = (0, 300)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_gaps_menu_down_arrow
    texture = down_arrow
    rgba = [ 128 128 128 85 ]
    pos = <pos>
    just = [ left top ]
    z_priority = 3
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_top_bar offset = (20, 5)
  CreateScreenElement {
    type = VScrollingMenu
    parent = current_menu_anchor
    dims = (640, 278)
    pos = <pos>
    just = [ left top ]
    internal_just = [ center top ]
  }
  CreateScreenElement {
    type = VMenu
    parent = <id>
    id = gap_vmenu
    pos = (0, 0)
    just = [ left top ]
    internal_just = [ left top ]
    dont_allow_wrap
    event_handlers = [
      { pad_up set_which_arrow params = { arrow = view_gaps_menu_up_arrow } }
      { pad_down set_which_arrow params = { arrow = view_gaps_menu_down_arrow } }
      { pad_up generic_menu_up_or_down_sound params = { up } }
      { pad_down generic_menu_up_or_down_sound params = { down } }
      { pad_back generic_menu_pad_back_sound }
    ]
  }
  AssignAlias id = gap_vmenu alias = current_menu
  SetScreenElementProps {
    id = current_menu
    event_handlers = [ { pad_back gap_menu_exit_to_pause_menu } ]
  }
  AddGapsToMenu initial_scale = 0.8
  RunScriptOnScreenElement id = current_menu_anchor animate_in params = { menu_id = current_menu }
ENDSCRIPT

SCRIPT gap_menu_add_item
  IF GotParam first_item
    focus_params = { first_item }
  ELSE
    IF GotParam last_item
      focus_params = { last_item }
    ENDIF
  ENDIF
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    dims = (200, 20)
    event_handlers = [ { focus gap_menu_focus params = { <focus_params> times = <times> } }
      { unfocus gap_menu_unfocus params = { times = <times> } }
      { pad_choose nullscript }
    ]
  }
   <anchor_id> = <id>
  IF ( <times> > 0 )
    rgba = [ 25 83 67 128 ]
  ELSE
    rgba = [ 88 105 112 128 ]
  ENDIF
  FormatText TextName = gap_score "%i" i = <gap_score>
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    font = small
    text = <gap_score>
    pos = (13, 0)
    just = [ center top ]
    rgba = <rgba>
    scale = 0.8
  }
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    font = dialog
    text = <gap_name>
    pos = (55, 0)
    just = [ left top ]
    rgba = <rgba>
    scale = 0.8
  }
  IF ( <times> > 0 )
    GetScreenElementDims id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = <id>
      texture = goal_line
      pos = (-8, 13)
      just = [ left center ]
      rgba = [ 128 128 128 128 ]
      z_priority = 10
      scale = ( ( (1, 0) * ( <width> * 1.25 ) / 32 ) + (0.3, 0.4) )
    }
  ENDIF
  IF ( <times> > 99999 )
     <times> = 99999
  ENDIF
  FormatText TextName = times "%i" i = <times>
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    font = small
    text = <times>
    pos = (444, 0)
    just = [ center top ]
    rgba = <rgba>
    scale = 0.8
  }
ENDSCRIPT

SCRIPT skip_to_selected_gap
ENDSCRIPT

SCRIPT preview_gap
  SetProps rgba = [ 127 102 0 100 ]
  DoMorph time = 0.1 scale = 0.85
  GetTags
ENDSCRIPT

SCRIPT gap_menu_focus
  GetTags
  IF ( <times> > 0 )
    rgba = [ 99 121 6 128 ]
  ELSE
    rgba = [ 127 102 0 100 ]
  ENDIF
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = <rgba>
  }
  RunScriptOnScreenElement id = { <id> child = 1 } do_scale_up params = { rgba = <rgba> }
  SetScreenElementProps {
    id = { <id> child = 2 }
    rgba = <rgba>
  }
  IF GotParam first_item
    SetScreenElementProps {
      id = view_gaps_menu_up_arrow
      rgba = [ 128 128 128 0 ]
    }
  ELSE
    SetScreenElementProps {
      id = view_gaps_menu_up_arrow
      rgba = [ 128 128 128 85 ]
    }
  ENDIF
  IF GotParam last_item
    SetScreenElementProps {
      id = view_gaps_menu_down_arrow
      rgba = [ 128 128 128 0 ]
    }
  ELSE
    SetScreenElementProps {
      id = view_gaps_menu_down_arrow
      rgba = [ 128 128 128 85 ]
    }
  ENDIF
  gap_vmenu:GetTags
  IF GotParam arrow_id
    menu_vert_blink_arrow { id = <arrow_id> }
  ENDIF
ENDSCRIPT

SCRIPT gap_menu_unfocus
  GetTags
  IF ( <times> > 0 )
    rgba = [ 25 83 67 128 ]
  ELSE
    rgba = [ 88 105 112 128 ]
  ENDIF
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = <rgba>
  }
  RunScriptOnScreenElement id = { <id> child = 1 } do_scale_down params = { rgba = <rgba> }
  SetScreenElementProps {
    id = { <id> child = 2 }
    rgba = <rgba>
  }
ENDSCRIPT

SCRIPT gap_menu_exit_to_pause_menu
  GoalManager_ShowPoints
  IF not GoalManager_HasActiveGoals
    GoalManager_ShowGoalPoints
  ENDIF
  remove_gap_menu_textures_from_vram
  add_pause_menu_textures_to_vram
  restore_start_key_binding
  create_pause_menu
ENDSCRIPT

SCRIPT add_gap_menu_textures_to_vram
  AddTextureToVram "up_arrow"
  AddTextureToVram "down_arrow"
  AddTextureToVram "goal_left"
  AddTextureToVram "goal_mid"
  AddTextureToVram "goal_right"
  AddTextureToVram "pa_gap"
  AddTextureToVram "pa_sound"
  AddTextureToVram "goal_line"
ENDSCRIPT

SCRIPT remove_gap_menu_textures_from_vram
  RemoveTextureFromVram "up_arrow"
  RemoveTextureFromVram "down_arrow"
  RemoveTextureFromVram "goal_left"
  RemoveTextureFromVram "goal_mid"
  RemoveTextureFromVram "goal_right"
  RemoveTextureFromVram "pa_gap"
  RemoveTextureFromVram "pa_sound"
  RemoveTextureFromVram "goal_line"
ENDSCRIPT

SCRIPT got_all_gaps_screen_create
  IF GetGlobalFlag flag = GOT_ALL_GAPS
    RETURN
  ENDIF
  SetGlobalFlag flag = GOT_ALL_GAPS
  GoalManager_AddCash 1500
  create_panel_message id = goal_current_reward text = "You got $1500" style = goal_message_got_bigbucks params = { sound = cash }
  IF not InNetGame
    PauseGame
  ENDIF
  StopStream
  PlayStream FoundAllGaps vol = 150
  create_dialog_box { title = "All Gaps!"
    text = "Incredible! You got every single gap in the game! We didn't even know it was possible...You should come test THPS5 at Neversoft!"
    pos = (310, 183)
    just = [ center center ]
    text_rgba = [ 88 105 112 128 ]
    pad_back_script = <back_script>
    buttons = [ { font = small text = "OK" pad_choose_script = got_all_gaps_screen_exit } ]
    delay_input
  }
ENDSCRIPT

SCRIPT got_all_gaps_screen_exit
  dialog_box_exit
  IF LevelIs load_skateshop
    SetScreenElementProps {
      id = root_window
      event_handlers = [ { pad_start skateshop_practice_start_pressed } ]
      replace_handlers
    }
  ENDIF
  UnPauseGame
ENDSCRIPT

SCRIPT launch_pause_menu cur_menu = current_menu_anchor
  Printf "why was this called?"
ENDSCRIPT

SCRIPT menu_confirm_quit_out_yes
  DebugFn766
   <yes_script> params = <...>
ENDSCRIPT

SCRIPT menu_confirm_quit_out_no
  DebugFn 766
   <no_script> params = <...>
ENDSCRIPT

SCRIPT menu_confirm_quit {
    yes_script = level_select_change_level_quit
    no_script = menu_quit_no
    back_script = menu_quit_no
    title = "QUIT?"
    text = "Are you sure?"
    params = { }
  }
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_pause_menu_textures_from_vram
  IF not IsTrue bootstrap_build
    create_error_box { title = <title>
      text = <text>
      pos = (310, 183)
      just = [ center center ]
      text_rgba = [ 88 105 112 128 ]
      pad_back_script = <back_script>
      pad_back_params = <params>
      buttons = [ { font = small text = "Yes" pad_choose_script = <yes_script> pad_choose_params = { level = load_skateshop <params> } }
        { font = small text = "No" pad_choose_script = <no_script> pad_choose_params = <params> }
      ]
    }
  ELSE
    create_error_box { title = <title>
      text = "Exit Demo?"
      pos = (310, 183)
      just = [ center center ]
      text_rgba = [ 88 105 112 128 ]
      pad_back_script = <back_script>
      buttons = [ { font = small text = "Yes" pad_choose_script = bootstrap_quit }
        { font = small text = "No" pad_choose_script = <back_script> }
      ]
    }
  ENDIF
ENDSCRIPT

SCRIPT menu_confirm_quit_park_editor {
    yes_script = launch_park_editor_save_park_sequence
    no_script = parked_quit
    back_script = menu_quit_no
    title = "Save Park?"
  }
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_pause_menu_textures_from_vram
  IF IsParkUnsaved
    IF IsXBOX
      error_text = "Network Play may cause you to lose unsaved changes to this park. Save it now?"
    ELSE
      IF IsNGC
        error_text = "Do you want to save your park before quitting?"
      ELSE
        error_text = "Playing online or downloading a new park will cause you to lose unsaved changes to this park. Save it now?"
      ENDIF
    ENDIF
    create_error_box { title = <title>
      text = <error_text>
      pos = (310, 183)
      just = [ center center ]
      text_rgba = [ 88 105 112 128 ]
      pad_back_script = <back_script>
      buttons = [ { font = small text = "Yes" pad_choose_script = <yes_script> pad_choose_params = { level = load_skateshop } }
        { font = small text = "No" pad_choose_script = <no_script> pad_choose_params = { level = load_skateshop } }
      ]
    }
  ELSE
     <no_script> level = load_skateshop
  ENDIF
ENDSCRIPT

SCRIPT menu_confirm_goto_secret_shop {
    yes_script = exit_to_secrets
    no_script = menu_cash_no
    back_script = menu_cash_no
    title = "QUIT?"
    error_text = "Are you sure you want to quit to go spend cash?"
  }
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  IF GotParam change_skater
    error_text = "Are you sure you want to quit to change skaters?"
    yes_script = exit_to_skaters
  ENDIF
  remove_pause_menu_textures_from_vram
  create_error_box { title = <title>
    text = <error_text>
    pos = (310, 183)
    just = [ center center ]
    text_rgba = [ 88 105 112 128 ]
    pad_back_script = <back_script>
    buttons = [ { font = small text = "Yes" pad_choose_script = <yes_script> }
      { font = small text = "No" pad_choose_script = <no_script> }
    ]
  }
  create_helper_text generic_helper_text_left_right parent = dialog_box_anchor
ENDSCRIPT

SCRIPT exit_to_secrets
  Change goto_secret_shop = 1
  level_select_change_level_quit level = load_skateshop
ENDSCRIPT

SCRIPT exit_to_skaters
  Change goto_secret_shop = 2
  level_select_change_level_quit level = load_skateshop
ENDSCRIPT

SCRIPT level_select_change_level_quit
  MakeSkaterGoto SkaterInit
  SetButtonEventMappings block_menu_input
  GoalManager_DeactivateAllGoals
  GoalManager_LevelUnload
  Printf "leaving and destroying server"
  SetParkEditorState state = off
  UnPauseGame
  chosen_leave_server
  DisplayLoadingScreen "loadscrn_generic"
  SetGameType career
  SetCurrentGameType
  SetStatOverride
  SetServerMode on
  StartServer
  SetJoinMode JOIN_MODE_PLAY
  Printf "attempting to join server"
  JoinServer
  Printf "waiting"
  BEGIN
    Printf "waiting 1 frame"
    IF JoinServerComplete
      BREAK
    ELSE
      Wait 1
    ENDIF
    Printf "still waiting"
  REPEAT
  Printf "attempting to change level"
  level_select_change_level <...>
  SetButtonEventMappings unblock_menu_input
ENDSCRIPT

SCRIPT menu_quit_no
  generic_menu_pad_back_sound
  dialog_box_exit
  create_pause_menu
ENDSCRIPT

SCRIPT menu_cash_no
  dialog_box_exit
  create_options_menu
ENDSCRIPT

SCRIPT bootstrap_quit
  dialog_box_exit
  SetButtonEventMappings block_menu_input
  skater:DisablePlayerInput
  PauseGame
  Cleanup
  DisplayLoadingScreen "loadscrn_marketing"
  Wait 5 seconds
  ExitDemo
ENDSCRIPT

SCRIPT launch_view_models_menu
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_view_models_menu
ENDSCRIPT

SCRIPT make_select_view_model_line
  make_text_sub_menu_item text = <text> pad_choose_script = view_model pad_choose_params = { <...> }
ENDSCRIPT

SCRIPT create_view_models_menu
  make_new_menu menu_id = view_models_menu vmenu_id = view_models_vmenu menu_title = "MODELS" type = VScrollingMenu dims = (320, 200)
  SetScreenElementProps { id = view_models_menu event_handlers = [
      { pad_back create_pause_menu }
    ]
  }
  add_view_models_to_menu
  set_sub_bg
  create_icon texture = PA_model
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT view_model
  Printf "View Model here"
  SetViewerModel <...>
  restore_start_key_binding
  RunScriptOnScreenElement id = current_menu_anchor menu_offscreen
ENDSCRIPT

SCRIPT launch_set_pro_skater_menu
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_set_pro_skater_menu
ENDSCRIPT

SCRIPT make_select_set_pro_skater_line
  make_text_sub_menu_item text = <text> pad_choose_script = set_pro_skater pad_choose_params = <...>
ENDSCRIPT

SCRIPT create_set_pro_skater_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu menu_id = set_pro_skater_menu vmenu_id = set_pro_skater_vmenu menu_title = "PRO SKATERS"
  IF LevelIs load_skateshop
    KillSkaterCamAnim all
    PlaySkaterCamAnim name = SS_SkaterChoosing play_hold
    SetScreenElementProps {
      id = set_pro_skater_menu
      event_handlers = [ { pad_back launch_main_menu } ]
      replace_handlers
    }
    make_text_sub_menu_item { text = "Continue"
      pad_choose_script = skateshop_transition
      pad_choose_params = { new_menu_script = launch_ss_menu }
    }
  ELSE
    SetScreenElementProps {
      id = set_pro_skater_menu
      event_handlers = [ { pad_back create_debug_menu } ]
      replace_handlers
    }
  ENDIF
  add_set_pro_skater_to_menu
  set_sub_bg
  create_icon texture = PA_model
  RunScriptOnScreenElement id = current_menu_anchor animate_in params = { final_pos = (320, 134) }
ENDSCRIPT

SCRIPT set_pro_skater
  Printf "Set pro skater here"
  load_pro_skater { profile = 0 skater = 0 <...> }
  IF LevelIs load_skateshop
    Printf "we're in the skateshop"
    launch_ss_menu
  ELSE
    exit_pause_menu
  ENDIF
ENDSCRIPT

SCRIPT launch_change_skater_appearance_menu
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_change_skater_appearance_menu
ENDSCRIPT

SCRIPT make_select_change_skater_appearance_line
  make_text_sub_menu_item text = <text> pad_choose_script = change_skater_appearance pad_choose_params = { <...> }
ENDSCRIPT

SCRIPT create_change_skater_appearance_menu
  make_new_menu menu_id = change_skater_appearance_menu vmenu_id = change_skater_appearance_vmenu menu_title = "APPEARANCE"
  SetScreenElementProps { id = change_skater_appearance_menu event_handlers = [
      { pad_back create_pause_menu }
    ]
  }
  add_change_skater_appearance_to_menu
  set_sub_bg
  create_icon texture = PA_model
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT change_skater_appearance
  Printf "Change skater appearance here"
  InitSkaterModel skater = 0 <...>
  exit_pause_menu
ENDSCRIPT

SCRIPT create_debug_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu {
    menu_id = debug_menu
    vmenu_id = debug_vmenu
    menu_title = "DEBUG"
    type = VScrollingMenu
    dims = (200, 200)
    padding_scale = 0.95
    pos = (243, 113)
  }
  SetScreenElementProps { id = debug_menu
    event_handlers = [
      { pad_back create_pause_menu }
    ]
  }
  make_text_sub_menu_item text = "View Models" id = menu_view_models pad_choose_script = launch_view_models_menu
  make_text_sub_menu_item text = "Create-a-Skater" id = menu_create_a_skater pad_choose_script = launch_cas_menu
  make_text_sub_menu_item text = "Set Pro Skater" id = menu_set_pro_skater pad_choose_script = create_set_pro_skater_menu
  make_text_sub_menu_item text = "Menu Test" id = menu_test pad_choose_script = launch_menu_test
  make_text_sub_menu_item text = "Toggle Profiler" id = menu_profiler pad_choose_script = launch_toggle_profiler
  make_text_sub_menu_item text = "Start AutoTest" id = menu_start_autotest pad_choose_script = menu_start_autotest
  make_text_sub_menu_item text = "Stop AutoTest" id = menu_stop_autotest pad_choose_script = menu_stop_autotest
  make_text_sub_menu_item text = "Dump MemCard ScreenShots" id = menu_dumpshots pad_choose_script = launch_dumpshots
  make_text_sub_menu_item text = "Wireframe Toggle" pad_choose_script = toggle_wireframe
  make_text_sub_menu_item text = "Show Vert Polys" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_vert }
  make_text_sub_menu_item text = "Show Wallride Polys" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_wallride }
  make_text_sub_menu_item text = "Show Trigger Polys" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_trigger }
  make_text_sub_menu_item text = "Show Camera Polys" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_camera }
  make_text_sub_menu_item text = "Show Not Skateable" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_not_skatable }
  make_text_sub_menu_item text = "Show skater shadow" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_skater_shadow }
  make_text_sub_menu_item text = "Show no skater shadow" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_no_skater_shadow }
  make_text_sub_menu_item text = "Show no skater shadow wall" pad_choose_script = toggle_show_polys pad_choose_params = { showscript = show_no_skater_shadow_wall }
  make_text_sub_menu_item text = "CheckForHoles (Slow)" pad_choose_script = hole_check
  make_text_sub_menu_item text = "Rail Display Toggle" pad_choose_script = toggle_rails
  make_text_sub_menu_item text = "Keyboard" pad_choose_script = launch_keyboard
  IF CareerLevelIs LevelNum_Sch
    make_text_sub_menu_item text = "Screensaver" pad_choose_script = screensaver
  ENDIF
  make_text_sub_menu_item text = "Statistics test" pad_choose_script = create_statistics_menu
  make_text_sub_menu_item text = "Secrets test" pad_choose_script = create_secrets_menu
  make_text_sub_menu_item text = "Done" id = menu_done pad_choose_script = create_pause_menu
  set_sub_bg
  create_icon texture = PA_model
  RunScriptOnScreenElement id = current_menu_anchor animate_in params = { final_pos = (320, 134) }
ENDSCRIPT

SCRIPT screensaver
  SpawnScript create_startup_menu
  exit_pause_menu
ENDSCRIPT

SCRIPT hole_check
  CheckForHoles
  create_pause_menu
ENDSCRIPT

SCRIPT launch_toggle_profiler
  ToggleMetrics
  create_pause_menu
  SpawnsScript create_console
ENDSCRIPT

SCRIPT launch_dumpshots
  DumpShots
  create_pause_menu
ENDSCRIPT

SCRIPT toggle_rails
  ToggleRails
  pulse_item
ENDSCRIPT

SCRIPT toggle_wireframe
  ToggleRenderMode
  show_all
  pulse_item
ENDSCRIPT

SCRIPT toggle_show_all
  show_all
ENDSCRIPT

SCRIPT toggle_show_polys showscript = show_vert
   <showscript>
  pulse_item
ENDSCRIPT

SCRIPT launch_keyboard
  DestroyScreenElement id = current_menu_anchor
  create_onscreen_keyboard
ENDSCRIPT

SCRIPT launch_level_select_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_pause_menu_textures_from_vram
  add_level_select_menu_textures_to_vram
  SetMenuPadMappings [ active
    use_as_first
  ]
  create_level_select_menu <...>
ENDSCRIPT

SCRIPT create_level_select_menu pad_back_script = level_select_menu_exit
  SetScreenElementLock id = root_window off
  pulse_blur
  IF GotParam from_server_options
    change_gamemode_net
    net_pad_back = 0
    pad_back_script = network_level_select_pad_back
  ENDIF
  IF not GotParam no_cam_anim
    level_select_play_cam
  ENDIF
  CreateScreenElement {
    type = ContainerElement
    parent = root_window
    id = level_select_anchor
    dims = (640, 480)
    pos = (320, 240)
  }
  IF InSplitScreenGame
    ScriptGetScreenMode
    IF ( <screen_mode> = split_horizontal )
       <root_pos> = (50, 30)
    ELSE
       <root_pos> = (50, 30)
    ENDIF
  ELSE
     <root_pos> = (50, 30)
  ENDIF
  AssignAlias id = level_select_anchor alias = current_menu_anchor
  create_helper_text generic_helper_text
  kill_start_key_binding
  GoalManager_HidePoints
  IF ObjectExists id = current_goal
    DoScreenElementMorph {
      id = current_goal
      alpha = 0
      remember_alpha
    }
  ENDIF
  IF GameModeEquals is_career
    GoalManager_ShowGoalPoints
  ENDIF
  level_select_create_top_bar {
    text = "LEVEL SELECT"
    root_pos = <root_pos>
    scale = (1, 1)
  }
  level_select_create_menu_block pad_back_script = <pad_back_script> <...>
  IF IsTrue Demo_Build
    ForEachIn e3_level_select_menu_level_info do = level_select_menu_add_item params = <...>
  ELSE
    RemoveParameter text
    RemoveParameter name
    IF AllLevelsUnlockedBeenox
      ForEachIn level_select_menu_level_info_unlock do = level_select_menu_add_item params = <...>
    ELSE
      ForEachIn level_select_menu_level_info do = level_select_menu_add_item params = <...>
    ENDIF
  ENDIF
  level_select_create_info_box
  RunScriptOnScreenElement id = level_select_anchor_top select_skater_menu_animate_top
  RunScriptOnScreenElement id = level_select_anchor_middle select_skater_menu_animate_stats
  FireEvent type = focus target = level_select_vmenu
  SetButtonEventMappings block_menu_input
  WaitForEvent type = select_skater_menu_animate_stats_done
  SetButtonEventMappings unblock_menu_input
ENDSCRIPT

SCRIPT level_select_create_top_bar scale = (1.14, 1) text = "" parent = level_select_anchor
   <pos> = <root_pos>
  CreateScreenElement {
    type = ContainerElement
    parent = <parent>
    id = level_select_anchor_top
    pos = (320, 240)
    dims = (640, 480)
  }
  CreateScreenElement {
    type = TextElement
    parent = level_select_anchor_top
    id = select_skater_name
    text = <text>
    font = testtitle
    pos = ( <pos> + (18, 20) )
    scale = 1.3
    just = [ left center ]
    rgba = [ 88 105 112 118 ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_top
    id = select_skater_mainbar
    texture = mainbar
    pos = <pos>
    scale = <scale>
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = select_skater_mainbar
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_top
    texture = mainbar_join
    pos = <pos>
    just = [ left top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_top
    texture = longbar_edgy
    pos = <pos>
    scale = (3, 1)
    just = [ left top ]
  }
ENDSCRIPT

SCRIPT level_select_create_menu_block
  IF ObjectExists id = level_select_anchor_middle
    DestroyScreenElement id = level_select_anchor_middle
  ENDIF
  CreateScreenElement {
    type = ContainerElement
    parent = level_select_anchor
    id = level_select_anchor_middle
    dims = (640, 480)
    pos = (320, 240)
  }
  GetStackedScreenElementPos Y id = select_skater_mainbar
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_middle
    id = level_select_menu_top_sprite
    texture = level_top_piece
    scale = (1.04, 1)
    rgba = [ 128 128 128 90 ]
    pos = <pos>
    just = [ left top ]
  }
  GetStackedScreenElementPos Y id = level_select_menu_top_sprite offset = (28, 5)
  CreateScreenElement {
    type = VMenu
    parent = level_select_anchor_middle
    id = level_select_vmenu
    pos = <pos>
    just = [ left top ]
    internal_just = [ left center ]
    event_handlers = [ { pad_back <pad_back_script> params = { <...> } }
      { pad_up generic_menu_up_or_down_sound params = { up } }
      { pad_down generic_menu_up_or_down_sound params = { down } }
      { pad_back generic_menu_pad_back_sound }
    ]
    padding_scale = 0.9
    replace_handlers
  }
  AssignAlias id = level_select_vmenu alias = current_menu
  IF GameModeEquals is_career
    goals_title_rgba = [ 88 105 112 128 ]
  ELSE
    goals_title_rgba = [ 0 0 0 0 ]
  ENDIF
  GetStackedScreenElementPos Y id = level_select_menu_top_sprite offset = (196, -13)
  CreateScreenElement {
    type = TextElement
    parent = level_select_anchor_middle
    font = small
    text = "Goals"
    pos = <pos>
    just = [ left top ]
    rgba = <goals_title_rgba>
    scale = 0.8
    z_priority = 5
  }
   <id> = level_select_menu_top_sprite
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = level_select_anchor_middle
      texture = level_repeat_mid
      pos = <pos>
      just = [ left top ]
      scale = (1.04, 1)
      rgba = [ 128 128 128 90 ]
    }
  REPEAT 13
  bottom_cap_rgba = [ 128 128 128 90 ]
  GetCurrentSkaterProfileIndex
  GetSkaterProfileInfo player = <currentSkaterProfileIndex>
  IF GotParam is_secret
    bottom_cap_rgba = [ 128 128 128 0 ]
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = level_select_anchor_middle
      texture = level_repeat_mid
      pos = <pos>
      just = [ left top ]
      scale = (1.04, 1)
      rgba = [ 128 128 128 90 ]
    }
    GetStackedScreenElementPos Y id = <id>
     <lower_piece_pos> = <pos>
    CreateScreenElement {
      type = SpriteElement
      parent = level_select_anchor_middle
      id = level_select_menu_other_bottom_piece
      texture = level_bottom_piece
      pos = <pos>
      scale = (1, 1)
      rgba = [ 128 128 128 90 ]
      just = [ left top ]
    }
  ELSE
    IF not GameModeEquals is_career
      bottom_cap_rgba = [ 128 128 128 0 ]
      GetStackedScreenElementPos Y id = <id>
      CreateScreenElement {
        type = SpriteElement
        parent = level_select_anchor_middle
        texture = level_repeat_mid
        pos = <pos>
        just = [ left top ]
        scale = (1.04, 1)
        rgba = [ 128 128 128 90 ]
      }
      GetStackedScreenElementPos Y id = <id>
       <lower_piece_pos> = <pos>
      CreateScreenElement {
        type = SpriteElement
        parent = level_select_anchor_middle
        id = level_select_menu_other_bottom_piece
        texture = level_bottom_piece
        pos = <pos>
        scale = (1, 1)
        rgba = [ 128 128 128 90 ]
        just = [ left top ]
      }
    ENDIF
  ENDIF
  GetStackedScreenElementPos Y id = <id>
   <lower_piece_pos> = <pos>
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_middle
    id = level_select_menu_lower_piece
    texture = level_lower_piece
    pos = <pos>
    scale = (1.035, 1)
    rgba = <bottom_cap_rgba>
    just = [ left top ]
  }
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_middle
    texture = level_bottom_piece
    pos = <pos>
    scale = (1.04, 1)
    rgba = <bottom_cap_rgba>
    just = [ left top ]
  }
  GetStackedScreenElementPos XY id = level_select_menu_lower_piece offset = (0, -14)
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_middle
    id = level_select_menu_bottom_cap
    texture = level_bottom_cap
    pos = <pos>
    rgba = <bottom_cap_rgba>
    just = [ left center ]
  }
  IF GameModeEquals is_career
    CreateScreenElement {
      type = TextBlockElement
      parent = level_select_anchor_middle
      id = pro_specific_challenge_text
      font = dialog
      text = ""
      pos = ( <lower_piece_pos> + (40, 33) )
      just = [ left center ]
      scale = 0.75
      rgba = <pro_specific_challenge_text_rgba>
      z_priority = 3
      internal_just = [ left top ]
      dims = (340, 0)
      allow_expansion
    }
    GetStackedScreenElementPos X id = <id> offset = (-285, 5)
    CreateScreenElement {
      type = SpriteElement
      parent = level_select_anchor_middle
      id = pro_specific_challenge_icon
      texture = GO_done
      pos = <pos>
      rgba = [ 127 102 0 0 ]
      just = [ left top ]
      scale = 0.6
      z_priority = 5
    }
  ENDIF
  GetCurrentSkaterProfileIndex
  GetSkaterProfileInfo player = <currentSkaterProfileIndex>
  GoalManager_GetNumberOfGoalPoints total
   <points_to_go> = ( points_to_pro_challenge - <goal_points> )
  IF GameModeEquals is_career
    IF GotParam is_secret
      RETURN
    ENDIF
    IF ObjectExists id = pro_specific_challenge_text
      IF GoalManager_ProSpecificChallengesUnlocked
        IF GotParam is_secret
          RETURN
        ENDIF
        IF GoalManager_SkaterHasBeatenProSpecificChallenge skater = <name>
           <pro_challenge_texture> = GO_done
           <pro_challenge_texture_rgba> = [ 127 102 0 100 ]
           <pro_specific_challenge_text_rgba> = [ 25 83 67 128 ]
          IF ( <is_pro> = 0 )
            FormatText {
              TextName = level_text
              "%d's Pro Challenge"
              d = <display_name>
            }
          ELSE
            FormatText {
              TextName = level_text
              "%p's Pro Challenge"
              p = <first_name>
            }
          ENDIF
        ELSE
           <pro_challenge_texture> = GO_fail
           <pro_challenge_texture_rgba> = [ 115 26 26 128 ]
           <pro_specific_challenge_text_rgba> = [ 88 105 112 128 ]
          IF ( <is_pro> = 0 )
            FormatText {
              TextName = level_text
              "%d's Pro Challenge:\n%s"
              d = <display_name>
              s = ( ( level_select_pro_challenge_info.<name> ).text )
            }
          ELSE
            FormatText {
              TextName = level_text
              "%p's Pro Challenge:\n%s"
              p = <first_name>
              s = ( ( level_select_pro_challenge_info.<name> ).text )
            }
          ENDIF
        ENDIF
        SetScreenElementProps {
          id = pro_specific_challenge_text
          text = <level_text>
        }
        SetScreenElementProps {
          id = pro_specific_challenge_text
          rgba = <pro_specific_challenge_text_rgba>
        }
        SetScreenElementProps {
          id = pro_specific_challenge_icon
          texture = <pro_challenge_texture>
          rgba = <pro_challenge_texture_rgba>
        }
        DoScreenElementMorph {
          id = pro_specific_challenge_icon
          alpha = 1
        }
        IF GoalManager_SkaterHasBeatenProSpecificChallenge skater = <name>
          GetStackedScreenElementPos X id = pro_specific_challenge_icon offset = (5, 3)
          GetScreenElementDims id = pro_specific_challenge_text
          CreateScreenElement {
            type = SpriteElement
            parent = level_select_anchor_middle
            id = pro_specific_challenge_strikeout
            texture = goal_line
            rgba = [ 18 87 18 128 ]
            pos = <pos>
            scale = ( ( (1, 0) * ( <width> * 0.7 ) / 32 ) + (0, 0.3) )
            just = [ left top ]
            z_priority = 5
          }
        ENDIF
      ELSE
        IF IsTrue bootstrap_build
          SetScreenElementProps {
            id = pro_specific_challenge_text
            text = "NOT IN DEMO"
          }
        ELSE
          IF ( <points_to_go> = 1 )
            IF ( <is_pro> = 0 )
              FormatText {
                TextName = locked_text
                "%d's Pro Challenge:\n%i more Pro Point to unlock"
                d = <display_name>
                i = <points_to_go>
              }
            ELSE
              FormatText {
                TextName = locked_text
                "%p's Pro Challenge:\n%i more Pro Point to unlock"
                p = <first_name>
                i = <points_to_go>
              }
            ENDIF
          ELSE
            IF ( <is_pro> = 0 )
              FormatText {
                TextName = locked_text
                "%d's Pro Challenge:\n%i more Pro Points to unlock"
                d = <display_name>
                i = <points_to_go>
              }
            ELSE
              FormatText {
                TextName = locked_text
                "%p's Pro Challenge:\n%i more Pro Points to unlock"
                p = <first_name>
                i = <points_to_go>
              }
            ENDIF
          ENDIF
          SetScreenElementProps {
            id = pro_specific_challenge_text
            text = <locked_text>
          }
        ENDIF
        DoScreenElementMorph {
          id = pro_specific_challenge_icon
          alpha = 0
        }
      ENDIF
    ENDIF
  ENDIF
  IF ScreenElementExists id = pro_specific_challenge_text
    IF ( <is_pro> = 0 )
      test_text = <display_name>
    ELSE
      test_text = <first_name>
    ENDIF
    CreateScreenElement {
      type = TextElement
      parent = current_menu_anchor
      id = width_test_text
      text = <test_text>
      font = dialog
      scale = 0.75
      alpha = 0
    }
    GetScreenElementDims id = width_test_text
    IF ( ( <width> > 118 ) or ( French ) or ( German ) )
      IF GoalManager_ProSpecificChallengesUnlocked
        IF GoalManager_SkaterHasBeatenProSpecificChallenge skater = <name>
          FormatText {
            TextName = locked_text
            "Pro Challenge"
          }
        ELSE
          FormatText {
            TextName = locked_text
            "Pro Challenge:\n%s"
            s = ( ( level_select_pro_challenge_info.<name> ).text )
          }
        ENDIF
      ELSE
        IF ( <points_to_go> = 1 )
          FormatText {
            TextName = locked_text
            "Pro Challenge:\n%i more Pro Point to unlock"
            i = <points_to_go>
          }
        ELSE
          FormatText {
            TextName = locked_text
            "Pro Challenge:\n%i more Pro Points to unlock"
            i = <points_to_go>
          }
        ENDIF
      ENDIF
      SetScreenElementProps {
        id = pro_specific_challenge_text
        text = <locked_text>
      }
    ENDIF
  ENDIF
ENDSCRIPT

SCRIPT level_select_create_info_box
  IF GameModeEquals is_career
    pos = (320, 240)
  ELSE
    pos = (320, 208)
  ENDIF
  CreateScreenElement {
    type = ContainerElement
    parent = level_select_anchor
    id = level_select_anchor_info
    pos = <pos>
    dims = (640, 480)
  }
  GetStackedScreenElementPos X id = level_select_menu_bottom_cap offset = (10, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_info
    id = level_select_info_box_left
    texture = bottom_l_cap
    pos = <pos>
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_info
    id = level_select_info_box_middle
    texture = bottom_mid
    pos = <pos>
    just = [ left top ]
    scale = (14, 1)
  }
  GetStackedScreenElementPos X id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = level_select_anchor_info
    texture = bottom_r_cap
    pos = <pos>
    scale = (1.4, 1)
    just = [ left top ]
    z_priority = 10
  }
  GetStackedScreenElementPos X id = level_select_info_box_left offset = (0, 10)
  GetScreenElementDims id = level_select_info_box_middle
  CreateScreenElement {
    type = TextBlockElement
    parent = level_select_anchor_info
    id = level_select_points_info
    font = dialog
    text = ""
    dims = ( (1, 0) * <width> * 1.176 )
    allow_expansion
    pos = <pos>
    just = [ left top ]
    scale = 0.8
    internal_just = [ center top ]
    rgba = [ 88 105 112 128 ]
    z_priority = 4
  }
ENDSCRIPT

SCRIPT level_select_menu_add_item
  IF ( ( GameModeEquals is_career ) and ( <level_num> = 10 ) )
    RETURN
  ENDIF
   <can_afford_level> = 0
   <in_locked_group> = 0
  IF IntegerEquals a = all_levels_unlocked b = 1
     <rgba> = [ 88 105 112 128 ]
    IF ( <level_num> = 10 )
       <pad_choose_script> = level_select_created_park_menu
    ELSE
      IF GotParam from_server_options
         <pad_choose_script> = level_select_menu_exit
      ELSE
         <pad_choose_script> = level_select_change_level
      ENDIF
    ENDIF
     <pad_choose_params> = <...>
     <locked> = 0
  ELSE
    IF GetGlobalFlag flag = <flag>
       <rgba> = [ 88 105 112 128 ]
      IF ( <level_num> = 10 )
         <pad_choose_script> = level_select_created_park_menu
      ELSE
        IF GotParam from_server_options
           <pad_choose_script> = level_select_menu_exit
        ELSE
           <pad_choose_script> = level_select_change_level
        ENDIF
      ENDIF
       <pad_choose_params> = <...>
       <locked> = 0
    ELSE
      IF GotParam PreReq_flags
        GetArraySize <PreReq_flags>
         <index> = 0
        BEGIN
          IF not GetGlobalFlag flag = ( <PreReq_flags> [ <index> ] )
             <in_locked_group> = 1
            BREAK
          ENDIF
           <index> = ( <index> + 1 )
        REPEAT <array_size>
      ENDIF
      IF ( <points_to_unlock> = -1 )
         <rgba> = [ 47 42 38 128 ]
         <pad_choose_script> = level_select_invalid_choice
         <locked> = 1
      ELSE
        IF not GameModeEquals is_career
           <rgba> = [ 47 42 38 128 ]
           <pad_choose_script> = level_select_invalid_choice
           <locked> = 1
        ELSE
          IF not IsDemo
            IF GoalManager_HasGoalPoints <points_to_unlock>
              IF ( <in_locked_group> = 1 )
                 <rgba> = [ 47 42 38 128 ]
                 <pad_choose_script> = level_select_invalid_choice
              ELSE
                 <rgba> = [ 26 85 37 128 ]
                 <pad_choose_script> = level_select_spend_points_dialog
              ENDIF
               <pad_choose_params> = <...>
               <locked> = 1
               <can_afford_level> = 1
            ELSE
               <rgba> = [ 47 42 38 128 ]
               <pad_choose_script> = level_select_invalid_choice
               <pad_choose_params> = <...>
               <locked> = 1
            ENDIF
          ELSE
             <rgba> = [ 47 42 38 128 ]
             <pad_choose_script> = level_select_invalid_choice
             <pad_choose_params> = <...>
             <locked> = 1
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    id = <level>
    dims = (256, 25)
    event_handlers = [ { pad_choose generic_menu_pad_choose_sound }
      { pad_start generic_menu_pad_choose_sound }
      { pad_choose <pad_choose_script> params = <pad_choose_params> }
      { pad_start <pad_choose_script> params = <pad_choose_params> }
      { focus level_select_menu_focus params = <...> }
      { unfocus level_select_menu_unfocus params = { rgba = <rgba> } }
    ]
    replace_handlers
  }
  CreateScreenElement {
    type = TextElement
    parent = <id>
    font = dialog
    just = [ left top ]
    text = <text>
    rgba = <rgba>
    scale = 0.9
  }
  GoalManager_NumGoalsBeatenInLevel <level_num>
  IF ( ( ( <can_afford_level> = 0 ) and ( <locked> = 1 ) ) or ( <in_locked_group> = 1 ) )
    FormatText TextName = goals_beaten "N/A"
  ELSE
    IF ( <num_goals> = 0 )
      goals_beaten = ""
    ELSE
      IF GoalManager_IsPro
        FormatText TextName = goals_beaten "%b/%t" b = <num_beaten> t = <num_goals>
      ELSE
        FormatText TextName = goals_beaten "%b/%t" b = <num_beaten> t = <num_am_goals>
      ENDIF
    ENDIF
  ENDIF
  IF not GameModeEquals is_career
     <rgba> = [ 0 0 0 0 ]
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = <level>
    font = small
    pos = (173, 3)
    rgba = <rgba>
    just = [ left top ]
    text = <goals_beaten>
    scale = 0.8
  }
  CreateScreenElement {
    type = SpriteElement
    parent = <level>
    texture = highlight_bar
    pos = (-20, 2)
    just = [ left top ]
    scale = (0.95, 1.2)
    rgba = [ 128 128 128 0 ]
  }
ENDSCRIPT

SCRIPT network_level_select_pad_back
   <net_pad_back> = 1
  level_select_menu_exit <...>
ENDSCRIPT

SCRIPT level_select_menu_exit
  kill_level_select_cams
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_level_select_menu_textures_from_vram
  IF LevelIs load_skateshop
    GoalManager_HideGoalPoints
    IF GotParam from_server_options
      IF ( <net_pad_back> = 0 )
        prefs = network
        field = "level"
        string = <text>
        checksum = <level>
        select_host_option <...>
      ENDIF
      IF ObjectExists id = host_options_menu
        DestroyScreenElement id = host_options_menu
      ENDIF
      KillSkaterCamAnim all
      PlaySkaterCamAnim name = SS_MenuCam play_hold
      create_network_host_options_menu
    ELSE
      add_pause_menu_textures_to_vram
      launch_ss_menu <...>
    ENDIF
  ELSE
    add_pause_menu_textures_to_vram
    IF GotParam end_run
      create_end_run_menu
    ELSE
      GoalManager_ShowPoints
      IF GoalManager_HasActiveGoals
        GoalManager_HideGoalPoints
        IF ObjectExists id = current_goal
          DoScreenElementMorph {
            id = current_goal
            restore_alpha
          }
        ENDIF
      ELSE
        GoalManager_ShowGoalPoints
      ENDIF
      create_pause_menu
    ENDIF
  ENDIF
ENDSCRIPT

SCRIPT level_select_menu_focus
  GetTags
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = [ 128 118 0 128 ]
  }
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  IF GameModeEquals is_career
    SetScreenElementProps {
      id = { <id> child = 1 }
      rgba = [ 128 118 0 128 ]
    }
  ENDIF
  SetScreenElementProps {
    id = { <id> child = 2 }
    rgba = [ 128 128 128 50 ]
  }
  IF LevelIs load_skateshop
    Kill prefix = "Cab_sign_"
    Create name = <taxi_id>
  ENDIF
  RunScriptOnScreenElement id = level_select_anchor_info level_select_hide_info
  IF ( <locked> = 1 )
    IF ( <points_to_unlock> = -1 )
      IF IsDemo
         <info_text> = "Not available in demo version."
      ELSE
         <info_text> = "Buy this level in the secrets shop."
      ENDIF
      IF LevelIs load_skateshop
        Kill prefix = "Cab_sign_"
        Create name = Cab_sign_11_Locked
      ENDIF
    ELSE
      IF ( <points_to_unlock> > 1 )
         <points_text> = "Points"
      ELSE
         <points_text> = "Point"
      ENDIF
      IF LevelIs load_skateshop
        Kill prefix = "Cab_sign_"
        Create name = Cab_sign_11_Locked
      ENDIF
      GoalManager_GetNumberOfGoalPoints total
       <total_goal_points> = <goal_points>
      GoalManager_GetNumberOfGoalPoints
       <current_goal_points> = <goal_points>
      GetArraySize level_select_menu_level_info
       <level_info_index> = 0
      BEGIN
        IF GetGlobalFlag flag = ( ( level_select_menu_level_info [ <level_info_index> ] ).flag )
           <points_to_unlock> = ( <points_to_unlock> + ( ( level_select_menu_level_info [ <level_info_index> ] ).points_to_unlock ) )
        ENDIF
         <level_info_index> = ( <level_info_index> + 1 )
      REPEAT <array_size>
      IF IsDemo
        FormatText TextName = info_text "Not available in demo version."
      ELSE
        IF GameModeEquals is_career
          IF ( <in_locked_group> = 1 )
             <info_text> = <PreReq_message>
          ELSE
            IF ( <can_afford_level> = 1 )
              FormatText TextName = info_text "%i Pro %p to\nunlock the next level" p = <points_text> i = <points_to_unlock>
            ELSE
              FormatText TextName = info_text "%i Pro %p to\nunlock the next level" p = <points_text> i = <points_to_unlock>
            ENDIF
          ENDIF
        ELSE
          FormatText TextName = info_text "Unlock in Career Mode"
        ENDIF
      ENDIF
    ENDIF
    SetScreenElementProps {
      id = level_select_points_info
      text = <info_text>
    }
    RunScriptOnScreenElement id = level_select_anchor_info level_select_animate_info
  ENDIF
ENDSCRIPT
created_park_warning = 0

SCRIPT level_select_created_park_menu
  make_new_skateshop_menu {
    parent = current_menu_anchor
    pos = (369, 93)
    internal_just = [ left center ]
    menu_id = created_park_menu
    vmenu_id = created_park_vmenu
    menu_title = ""
  }
  kill_start_key_binding
  IF GotParam show_warning
    Change created_park_warning = 1
  ENDIF
  create_icon texture = PA_Pro pos = (320, 85)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = options_bg
    draw_behind_parent
    pos = (469, 85)
    scale = (1.17, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 3
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_blue_bar
    texture = stats_notch
    pos = (461, 230)
    rgba = [ 42 48 77 50 ]
    scale = (14, 0.2)
    just = [ center top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = (467, 103)
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT 6
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (0.96, 1)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-20, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = (0.8, 0.56)
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    pos = (467, 117)
    rgba = [ 0 0 0 30 ]
    scale = (59, 5)
    just = [ center top ]
  }
  GetCustomParkName
  IF ( <name> = "" )
     <name> = "unnamed park"
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    pos = (467, 115)
    font = dialog
    text = <name>
    just = [ center top ]
    scale = 1
    rgba = [ 128 128 128 80 ]
    not_focusable
    z_priority = 5
  }
  truncate_string id = <id> max_width = 200
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    pos = (365, 90)
    font = testtitle
    text = "CREATED PARK"
    just = [ left top ]
    scale = 1.4
    rgba = [ 128 128 128 98 ]
    not_focusable
    z_priority = 5
  }
  CreateScreenElement {
    type = TextElement
    parent = current_menu
    font = small
    text = ""
    not_focusable
  }
  SetScreenElementProps {
    id = created_park_vmenu
    event_handlers = [
      { pad_back generic_menu_pad_back_sound }
      { pad_back level_select_created_park_menu_exit }
    ]
    replace_handlers
  }
  IF GotParam from_server_options
    main_menu_add_item { text = 'Play Park'
      id = created_park_play_park
      pad_choose_script = created_park_launch
      pad_choose_params = { from_server_options }
    }
  ELSE
    main_menu_add_item { text = 'Play Park'
      id = created_park_play_park
      pad_choose_script = created_park_launch
      pad_choose_params = { }
    }
  ENDIF
  IF GotParam from_server_options
    main_menu_add_item { text = 'Load Park'
      id = created_park_load_park
      pad_choose_script = confirm_load_park
      pad_choose_params = { load_park from_server_options }
    }
  ELSE
    main_menu_add_item { text = 'Load Park'
      id = created_park_load_park
      pad_choose_script = confirm_load_park
      pad_choose_params = { load_park }
    }
  ENDIF
  IF GotParam from_server_options
    main_menu_add_item { text = 'Pre-Made Parks'
      id = created_park_premade
      pad_choose_script = level_select_created_park_menu_exit
      pad_choose_params = { park_list from_server_options }
    }
  ELSE
    main_menu_add_item { text = 'Pre-Made Parks'
      id = created_park_premade
      pad_choose_script = level_select_created_park_menu_exit
      pad_choose_params = { park_list }
    }
  ENDIF
  main_menu_add_item { text = 'Back'
    id = created_park_back
    pad_choose_script = level_select_created_park_menu_exit
    pad_choose_params = { }
  }
  FireEvent type = unfocus target = level_select_vmenu
  RunScriptOnScreenElement id = created_park_menu animate_in
ENDSCRIPT

SCRIPT created_park_launch
  IF GotParam from_server_options
    level_select_created_park_menu_exit from_server_options
    level = load_Sk4Ed_gameplay
    string = "Created Park"
    level_select_menu_exit from_server_options net_pad_back = 0 <...>
  ELSE
    level_select_created_park_menu_exit
    IF ( created_park_warning = 1 )
      Change created_park_warning = 0
      level_select_change_level level = load_Sk4Ed_gameplay <...> show_warning
    ELSE
      level_select_change_level level = load_Sk4Ed_gameplay <...>
    ENDIF
  ENDIF
ENDSCRIPT

SCRIPT confirm_load_park
  level_select_created_park_menu_exit
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  IF GotParam from_server_options
    Change still_in_net_area = 1
    IF IsParkUnsaved
      menu_confirm_quit { yes_script = launch_level_select_load_park_sequence
        title = "Replace unsaved park?"
        back_script = return_to_created_park_menu
        no_script = return_to_created_park_menu
        params = { from_server_options }
      }
    ELSE
      launch_level_select_load_park_sequence
    ENDIF
  ELSE
    IF IsParkUnsaved
      menu_confirm_quit { yes_script = launch_level_select_load_park_sequence
        title = "Replace unsaved park?"
        back_script = return_to_created_park_menu
        no_script = return_to_created_park_menu
      }
    ELSE
      launch_level_select_load_park_sequence
    ENDIF
  ENDIF
ENDSCRIPT
still_in_net_area = 0

SCRIPT return_to_created_park_menu
  dialog_box_exit
  launch_level_select_menu
  level_select_created_park_menu <...>
ENDSCRIPT

SCRIPT level_select_created_park_menu_exit
  IF ObjectExists id = created_park_menu
    DestroyScreenElement id = created_park_menu
  ENDIF
  AssignAlias id = level_select_anchor alias = current_menu_anchor
  IF GotParam launch_level
    Printf "launching created level"
  ENDIF
  IF GotParam load_park
    Printf "launching created level"
  ENDIF
  IF GotParam park_list
    level_select_created_park_list <...>
  ELSE
    FireEvent type = focus target = level_select_vmenu
  ENDIF
ENDSCRIPT

SCRIPT level_select_created_park_list
  Printf "level_select_created_park_list"
  dialog_box_exit
  IF GotParam in_park_editor
    IF ObjectExists id = current_menu_anchor
      DestroyScreenElement id = current_menu_anchor
    ENDIF
    delta_pos = (-130, 0)
  ELSE
    delta_pos = (0, 0)
  ENDIF
  remove_pause_menu_textures_from_vram
  add_level_select_menu_textures_to_vram
  make_new_skateshop_menu {
    parent = <id>
    pos = ( (369, 97) + <delta_pos> )
    dims = (200, 229)
    internal_just = [ left center ]
    menu_id = created_park_menu
    vmenu_id = created_park_vmenu
    menu_title = ""
    type = VScrollingMenu
    scrolling_menu_title_id = ""
    dont_allow_wrap = dont_allow_wrap
  }
  kill_start_key_binding
  SetScreenElementProps { id = created_park_vmenu
    event_handlers = [
      { pad_down menu_vert_blink_arrow params = { id = park_menu_down_arrow } }
      { pad_up menu_vert_blink_arrow params = { id = park_menu_up_arrow } }
    ]
  }
  IF GotParam in_park_editor
    create_helper_text generic_helper_text
  ENDIF
  create_icon texture = PA_Pro pos = ( (320, 85) + <delta_pos> )
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "PRE-MADE"
    scale = 1.4
    pos = ( (369, 88) + <delta_pos> )
    just = [ left top ]
    rgba = [ 128 128 128 98 ]
    not_focusable
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = options_bg
    draw_behind_parent
    pos = ( (469, 85) + <delta_pos> )
    scale = (1.17, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 2
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_blue_bar
    texture = stats_notch
    pos = ( (461, 364) + <delta_pos> )
    rgba = [ 42 48 77 50 ]
    scale = (14, 0.2)
    just = [ center top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = park_menu_up_arrow
    texture = up_arrow
    pos = ( (467, 115) + <delta_pos> )
    rgba = [ 128 128 128 128 ]
    just = [ center top ]
    z_priority = 4
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = park_menu_down_arrow
    texture = down_arrow
    pos = ( (467, 368) + <delta_pos> )
    rgba = [ 128 128 128 128 ]
    just = [ center top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = ( (467, 103) + <delta_pos> )
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT 15
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (0.96, 1)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-20, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = (0.8, 1.12)
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  IF GotParam from_server_options
    pad_back_params = { from_server_options }
  ELSE
    pad_back_params = { }
  ENDIF
  SetScreenElementProps {
    id = created_park_vmenu
    event_handlers = [ { pad_back level_select_created_park_list_exit params = <pad_back_params> } ]
    replace_handlers
  }
  GetArraySize premade_parks_info
  index = 0
  BEGIN
    main_menu_add_item { text = ( premade_parks_info [ <index> ].name )
      pad_choose_script = level_select_created_park_list_exit
      pad_choose_params = { <pad_back_params> slot = ( premade_parks_info [ <index> ].slot ) }
    }
     <index> = ( <index> + 1 )
  REPEAT <array_size>
  IF ScreenElementExists id = level_select_vmenu
    FireEvent type = unfocus target = level_select_vmenu
  ENDIF
  RunScriptOnScreenElement id = created_park_menu animate_in
ENDSCRIPT

SCRIPT level_select_created_park_list_exit
  IF ObjectExists id = created_park_menu
    DestroyScreenElement id = created_park_menu
  ENDIF
  IF ObjectExists id = level_select_anchor
    AssignAlias id = level_select_anchor alias = current_menu_anchor
  ELSE
    in_park_ed = 1
  ENDIF
  IF GotParam slot
    Printf "loading from disk"
    IF GotParam in_park_ed
      Printf "in the park editor"
      parked_load_from_disk slot = <slot>
    ELSE
      IF GotParam from_server_options
        LoadParkFromDisk slot = <slot> block_rebuild
        created_park_launch from_server_options
      ELSE
        LoadParkFromDisk slot = <slot> block_rebuild
        created_park_launch
      ENDIF
    ENDIF
  ELSE
    IF GotParam in_park_ed
      remove_level_select_menu_textures_from_vram
      parked_setup_main_menu
    ELSE
      level_select_created_park_menu <...>
    ENDIF
  ENDIF
ENDSCRIPT

SCRIPT premade_park_wait_message
  Printf "premade_park_wait_message"
  DoScreenElementMorph id = current_menu_anchor scale = 0
  create_error_box title = "Loading..." text = "Please wait while the pre-made park is loaded."
  FireEvent type = showed_wait_message target = system
ENDSCRIPT

SCRIPT level_select_hide_info
  DoMorph scale = 0
ENDSCRIPT

SCRIPT level_select_animate_info
  DoMorph scale = 1
ENDSCRIPT

SCRIPT level_select_menu_unfocus
  GetTags
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = <rgba>
  }
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_down params = { rgba = <rgba> }
  IF GameModeEquals is_career
    SetScreenElementProps {
      id = { <id> child = 1 }
      rgba = <rgba>
    }
  ENDIF
  SetScreenElementProps {
    id = { <id> child = 2 }
    rgba = [ 128 128 128 0 ]
  }
ENDSCRIPT

SCRIPT level_select_play_cam
  kill_level_select_cams
  IF LevelIs load_skateshop
    KillSkaterCamAnim all
    PlaySkaterCamAnim skater = 0 name = SS_LevelSelect play_hold
  ELSE
    PlaySkaterCamAnim skater = 0 name = MapGuy_ViewCam play_hold
    SetSkaterCamAnimShouldPause name = MapGuy_ViewCam 0
  ENDIF
ENDSCRIPT

SCRIPT kill_level_select_cams
  KillSkaterCamAnim name = MapGuy_ViewCam
ENDSCRIPT

SCRIPT really_change_level
  IF OnServer
    change_level <...>
  ELSE
    IF IsHost
      FCFSRequestChangeLevel <...>
    ENDIF
  ENDIF
ENDSCRIPT

SCRIPT level_select_change_level
  PlaySound GoToLoadLevel
  GoalManager_ShowPoints
  IF not GoalManager_HasActiveGoals
    GoalManager_ShowGoalPoints
  ENDIF
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_level_select_menu_textures_from_vram
  kill_level_select_cams
  IF CD
    IF IsCustomPark
      really_change_level <...>
    ELSE
      IF not LevelIs <level>
        really_change_level <...>
      ELSE
        IF GotParam chose_same_level_script
           <chose_same_level_script>
        ELSE
          IF GotParam end_run
            create_end_run_menu
            RETURN
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ELSE
    really_change_level <...>
  ENDIF
  restore_start_key_binding
  exit_pause_menu
ENDSCRIPT

SCRIPT level_select_invalid_choice
ENDSCRIPT

SCRIPT level_select_spend_points_dialog level_name = "Zoo" level = load_zoo
  RunScriptOnScreenElement id = current_menu_anchor hide_main_menu_anchor
  IF ( <points_to_unlock> = 1 )
    FormatText { TextName = prompt
      "Unlock %%level?"
      level = <text>
    }
  ELSE
    FormatText { TextName = prompt
      "Unlock %%level?"
      level = <text>
    }
  ENDIF
  FireEvent type = unfocus target = current_menu
  create_dialog_box { title = " "
    text = <prompt>
    pos = (320, 185)
    just = [ center center ]
    text_rgba = [ 88 105 112 128 ]
    text_scale = 1
    pad_back_script = level_select_dialog_no
    buttons = [ { font = small text = "Yes" pad_choose_script = level_select_spend_points pad_choose_params = { level = <level> goal_points = <points_to_unlock> flag = <flag> } }
      { font = small text = "No" pad_choose_script = level_select_dialog_no pad_choose_params = <...> }
    ]
  }
ENDSCRIPT

SCRIPT level_select_spend_points
  GoalManager_SpendGoalPoints <goal_points>
  SetGlobalFlag flag = <flag>
  SetScreenElementProps {
    id = root_window
    event_handlers = [ { pad_start handle_start_pressed } ]
    replace_handlers
  }
  dialog_box_exit
  change_level <...>
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_level_select_menu_textures_from_vram
  exit_pause_menu
ENDSCRIPT

SCRIPT level_select_dialog_no
  DestroyScreenElement id = dialog_box_anchor
  RunScriptOnScreenElement id = current_menu_anchor show_main_menu_anchor
  Wait 1 frame
  FireEvent type = focus target = current_menu
ENDSCRIPT

SCRIPT hide_main_menu_anchor
  DoMorph time = 0 scale = 0
ENDSCRIPT

SCRIPT show_main_menu_anchor
  DoMorph time = 0 scale = 1
ENDSCRIPT

SCRIPT add_level_select_menu_textures_to_vram
  AddTextureToVram "level_top_piece"
  AddTextureToVram "level_repeat_mid"
  AddTextureToVram "level_lower_piece"
  AddTextureToVram "level_bottom_piece"
  AddTextureToVram "level_bottom_cap"
  AddTextureToVram "bottom_l_cap"
  AddTextureToVram "bottom_mid"
  AddTextureToVram "bottom_r_cap"
  AddTextureToVram "mainbar"
  AddTextureToVram "mainbar_join"
  AddTextureToVram "longbar_edgy"
  AddTextureToVram "goal_right"
  AddTextureToVram "pa_pro"
  AddTextureToVram "stats_notch"
  AddTextureToVram "up_arrow"
  AddTextureToVram "down_arrow"
  AddTextureToVram "goal_line"
ENDSCRIPT

SCRIPT remove_level_select_menu_textures_from_vram
  RemoveTextureFromVram "level_top_piece"
  RemoveTextureFromVram "level_repeat_mid"
  RemoveTextureFromVram "level_lower_piece"
  RemoveTextureFromVram "level_bottom_piece"
  RemoveTextureFromVram "level_bottom_cap"
  RemoveTextureFromVram "bottom_l_cap"
  RemoveTextureFromVram "bottom_mid"
  RemoveTextureFromVram "bottom_r_cap"
  RemoveTextureFromVram "mainbar"
  RemoveTextureFromVram "mainbar_join"
  RemoveTextureFromVram "longbar_edgy"
  RemoveTextureFromVram "goal_right"
  RemoveTextureFromVram "pa_pro"
  RemoveTextureFromVram "stats_notch"
  RemoveTextureFromVram "up_arrow"
  RemoveTextureFromVram "down_arrow"
  RemoveTextureFromVram "goal_line"
ENDSCRIPT
e3_level_select_menu_level_info = [
  { text = "College" level_num = 1 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_sch taxi_id = Cab_sign_1_College }
  { text = "Zoo" level_num = 7 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_ZOO level = load_zoo taxi_id = Cab_sign_7_Zoo }
]
level_select_menu_level_info = [
  { text = "College" level_num = 1 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_sch taxi_id = Cab_sign_1_College }
  { text = "San Francisco" level_num = 2 points_to_unlock = 8 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SF2 level = load_sf2 taxi_id = Cab_sign_2_San_Fran }
  { text = "Alcatraz" level_num = 3 points_to_unlock = 8 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_ALC level = load_alc taxi_id = Cab_sign_3_Alcatraz }
  { text = "Kona" level_num = 4 points_to_unlock = 8 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_KON level = load_kon taxi_id = Cab_sign_4_Kona PreReq_flags = [ LEVEL_UNLOCKED_SCH LEVEL_UNLOCKED_SF2 LEVEL_UNLOCKED_ALC ] PreReq_message = "Visit Alcatraz and San Francisco first." }
  { text = "Shipyard" level_num = 5 points_to_unlock = 8 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_JNK level = load_jnk taxi_id = Cab_sign_5_Shipyard PreReq_flags = [ LEVEL_UNLOCKED_SCH LEVEL_UNLOCKED_SF2 LEVEL_UNLOCKED_ALC ] PreReq_message = "Visit Alcatraz and San Francisco first." }
  { text = "London" level_num = 6 points_to_unlock = 8 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_LON level = load_lon taxi_id = Cab_sign_6_London PreReq_flags = [ LEVEL_UNLOCKED_KON LEVEL_UNLOCKED_JNK ] PreReq_message = "Visit Kona and the Shipyard first." }
  { text = "Zoo" level_num = 7 points_to_unlock = 8 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_ZOO level = load_zoo taxi_id = Cab_sign_7_Zoo PreReq_flags = [ LEVEL_UNLOCKED_KON LEVEL_UNLOCKED_JNK ] PreReq_message = "Visit Kona and the Shipyard first." }
  { text = "Carnival" level_num = 8 points_to_unlock = -1 num_am_goals = 14 num_goals = 14 flag = LEVEL_UNLOCKED_CNV level = load_cnv taxi_id = Cab_sign_8_Carnival }
  { text = "Chicago" level_num = 9 points_to_unlock = -1 num_am_goals = 14 num_goals = 14 flag = LEVEL_UNLOCKED_HOF level = load_hof taxi_id = Cab_sign_9_Chicago }
  { text = "Created Park" level_num = 10 points_to_unlock = 0 num_goals = 0 flag = LEVEL_UNLOCKED_CPK level = load_Sk4Ed_gameplay taxi_id = Cab_sign_10_Custom }
]
level_select_menu_level_info_unlock = [
  { text = "College" level_num = 1 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_sch taxi_id = Cab_sign_1_College }
  { text = "San Francisco" level_num = 2 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_sf2 taxi_id = Cab_sign_2_San_Fran }
  { text = "Alcatraz" level_num = 3 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_alc taxi_id = Cab_sign_3_Alcatraz }
  { text = "Kona" level_num = 4 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_kon taxi_id = Cab_sign_4_Kona }
  { text = "Shipyard" level_num = 5 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_jnk taxi_id = Cab_sign_5_Shipyard }
  { text = "London" level_num = 6 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_lon taxi_id = Cab_sign_6_London }
  { text = "Zoo" level_num = 7 points_to_unlock = 0 num_am_goals = 16 num_goals = 21 flag = LEVEL_UNLOCKED_SCH level = load_zoo taxi_id = Cab_sign_7_Zoo }
  { text = "Carnival" level_num = 8 points_to_unlock = 0 num_am_goals = 14 num_goals = 14 flag = LEVEL_UNLOCKED_SCH level = load_cnv taxi_id = Cab_sign_8_Carnival }
  { text = "Chicago" level_num = 9 points_to_unlock = 0 num_am_goals = 14 num_goals = 14 flag = LEVEL_UNLOCKED_SCH level = load_hof taxi_id = Cab_sign_9_Chicago }
  { text = "Created Park" level_num = 10 points_to_unlock = 0 num_goals = 0 flag = LEVEL_UNLOCKED_SCH level = load_Sk4Ed_gameplay taxi_id = Cab_sign_10_Custom }
]
level_select_pro_challenge_info = {
  Hawk = { text = "In the College" }
  Thomas = { text = "In the College" }
  Burnquist = { text = "In the Zoo" }
  Campbell = { text = "In San Francisco" }
  Steamer = { text = "In Alcatraz" }
  Mullen = { text = "In Kona Park" }
  Lasek = { text = "In the Shipyard" }
  Rowley = { text = "In London" }
  Muska = { text = "In San Francisco" }
  Glifberg = { text = "In Alcatraz" }
  Caballero = { text = "In Kona Park" }
  Margera = { text = "In Alcatraz" }
  Koston = { text = "In the Shipyard" }
  Reynolds = { text = "In San Francisco" }
  custom = { text = "In the Shipyard" }
}
premade_parks_info = [
  { name = "DDT 3" slot = 5 }
  { name = "Splintzville" slot = 19 }
  { name = "Ledge Monkey" slot = 24 }
  { name = "Skillzilla Park" slot = 18 }
  { name = "FULL ON!" slot = 22 }
  { name = "Auto Bazootie" slot = 14 }
  { name = "Jiland 2" slot = 13 }
  { name = "A Happy Place" slot = 6 }
  { name = "Montana" slot = 3 }
  { name = "Purgatory" slot = 9 }
  { name = "Excavation" slot = 15 }
  { name = "Pools of Fury" slot = 20 }
  { name = "Lucifers Launch" slot = 25 }
  { name = "Libertyville" slot = 12 }
  { name = "D'Apark" slot = 2 }
  { name = "Wreck Center" slot = 23 }
  { name = "Owasis" slot = 4 }
  { name = "Skatechupichu" slot = 7 }
  { name = "The Reservoir" slot = 8 }
  { name = "Mongoose Maze" slot = 10 }
  { name = "Concrete Jinkin" slot = 11 }
  { name = "The Hole" slot = 1 }
  { name = "BARNS ONLY" slot = 17 }
  { name = "Kastle" slot = 21 }
  { name = "The Funk Hole" slot = 16 }
]

SCRIPT create_options_menu
  GoalManager_ShowPoints
  IF not GoalManager_HasActiveGoals
    GoalManager_ShowGoalPoints
  ENDIF
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  add_pause_menu_textures_to_vram
  IF InSplitScreenGame
    GoalManager_ShowPoints
    options_pos = (230, 88)
  ELSE
    options_pos = (230, 38)
  ENDIF
  make_new_menu {
    menu_id = options_menu
    vmenu_id = options_vmenu
    menu_title = "OPTIONS"
    pos = <options_pos>
  }
  create_helper_text generic_helper_text
  kill_start_key_binding
  IF LevelIs load_skateshop
    pad_back_script = skateshop_practice_pause_menu
  ELSE
    pad_back_script = create_pause_menu
  ENDIF
  SetScreenElementProps { id = options_menu
    event_handlers = [
      { pad_back <pad_back_script> }
    ]
  }
  IF GameModeEquals is_career
    IF not IsTrue Demo_Build
      make_text_sub_menu_item text = "Game Progress" id = menu_game_progress pad_choose_script = game_progress_menu_create
      make_text_sub_menu_item text = "Change Skater" id = menu_skater pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = menu_confirm_goto_secret_shop change_skater }
      IF IsDemo
        make_text_sub_menu_item text = "Spend Cash" id = menu_secret not_focusable = not_focusable pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = menu_confirm_goto_secret_shop }
      ELSE
        make_text_sub_menu_item text = "Spend Cash" id = menu_secret pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = menu_confirm_goto_secret_shop }
      ENDIF
    ENDIF
  ENDIF
  IF not InMultiplayerGame
    IF IsNGC
      SWITCH camera_angle
      CASE 0
        camera_text = "Camera Angle: 1"
      CASE 1
        camera_text = "Camera Angle: 2"
      CASE 2
        camera_text = "Camera Angle: 3"
      CASE 3
        camera_text = "Camera Angle: 4"
      ENDSWITCH
      make_text_sub_menu_item text = <camera_text> id = menu_camera pad_choose_script = toggle_camera_angle pad_choose_params = { }
    ENDIF
    make_text_sub_menu_item text = "Edit Stats" id = menu_edit_stats pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_stats_menu }
    IF not InSplitScreenGame
      IF GoalManager_HasActiveGoals
        make_text_sub_menu_item {
          text = "View Tricks"
          id = menu_edit_tricks
          pad_choose_script = create_edit_tricks_menu
        }
      ELSE
        make_text_sub_menu_item {
          text = "Edit Tricks"
          id = menu_edit_tricks
          pad_choose_script = create_edit_tricks_menu
        }
      ENDIF
    ENDIF
    IF GameModeEquals is_career
      IF GoalManager_HasActiveGoals count_all
        make_text_sub_menu_item {
          text = "Pro Trick Objects"
          pad_choose_script = generic_menu_pad_choose
          pad_choose_params = { callback = create_pro_trick_objects_menu }
          not_focusable
          rgba = [ 50 50 50 90 ]
        }
      ELSE
        make_text_sub_menu_item {
          text = "Pro Trick Objects"
          pad_choose_script = generic_menu_pad_choose
          pad_choose_params = { callback = create_pro_trick_objects_menu }
        }
      ENDIF
    ENDIF
    IF not ( ( IsTrue bootstrap_build ) or ( IsTrue Demo_Build ) )
      IF not CD
        make_text_sub_menu_item text = "Cheats: DO NOT TEST" id = menu_cheats pad_choose_script = launch_cheats_menu
      ENDIF
      IF IsDemo
        make_text_sub_menu_item text = "Cheats" id = menu_real_cheats not_focusable = not_focusable pad_choose_script = create_real_cheats_menu
      ELSE
        make_text_sub_menu_item text = "Cheats" id = menu_real_cheats pad_choose_script = create_real_cheats_menu
      ENDIF
    ENDIF
  ELSE
    IF not IsObserving
      IF not InSplitScreenGame
        IF GoalManager_HasActiveGoals
          make_text_sub_menu_item {
            not_focusable
            rgba = [ 50 50 50 90 ]
            text = "Edit Tricks"
            id = menu_edit_tricks
            pad_choose_script = create_edit_tricks_menu
          }
        ELSE
          make_text_sub_menu_item {
            text = "Edit Tricks"
            id = menu_edit_tricks
            pad_choose_script = create_edit_tricks_menu
          }
        ENDIF
      ENDIF
    ENDIF
    IF InNetGame
      IF GameModeEquals is_lobby
        IF GoalManager_HasActiveGoals count_all
          make_text_sub_menu_item {
            text = "Pro Trick Objects"
            pad_choose_script = generic_menu_pad_choose
            pad_choose_params = { callback = create_pro_trick_objects_menu }
            not_focusable
            rgba = [ 50 50 50 90 ]
          }
        ELSE
          make_text_sub_menu_item {
            text = "Pro Trick Objects"
            pad_choose_script = generic_menu_pad_choose
            pad_choose_params = { callback = create_pro_trick_objects_menu }
          }
        ENDIF
      ENDIF
      IF not ( ( IsTrue bootstrap_build ) or ( IsTrue Demo_Build ) )
        IF not CD
          make_text_sub_menu_item text = "Cheats: DO NOT TEST" id = menu_cheats pad_choose_script = launch_cheats_menu
        ENDIF
      ENDIF
    ELSE
    ENDIF
  ENDIF
  IF IsXBOX
    make_text_sub_menu_item text = "Adjust Gamma" id = menu_gamma pad_choose_script = create_gamma_menu
  ELSE
    make_text_sub_menu_item text = "Screen Mode" id = menu_screen pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_screen_menu }
  ENDIF
  make_text_sub_menu_item text = "Sound Options" id = menu_sound_options pad_choose_script = launch_sound_options_menu pad_choose_params = { from_options }
  IF InNetGame
    IF InTeamGame
      GetPreferenceString pref_type = network score_display
      make_text_sub_menu_item text = "Score Display Mode" id = menu_score_display pad_choose_script = create_options_score_display_menu
      make_text_sub_menu_item text = <ui_string> id = menu_score_display_str rgba = [ 80 80 80 128 ] not_focusable
    ENDIF
    GetPreferenceString pref_type = network show_names
    options_menu_add_toggle_item text = "Player Names:" id = menu_toggle_names pad_choose_script = toggle_show_name_option on_off_text = <ui_string>
    GetPreferenceString pref_type = network auto_brake
    options_menu_add_toggle_item text = "Auto-Brake:" id = menu_auto_brake pad_choose_script = toggle_auto_brake_option on_off_text = <ui_string>
  ELSE
    IF not ObjectExists id = menu_real_cheats
      IF IsDemo
        make_text_sub_menu_item text = "Cheats" id = menu_real_cheats not_focusable = not_focusable pad_choose_script = create_real_cheats_menu
      ELSE
        make_text_sub_menu_item text = "Cheats" id = menu_real_cheats pad_choose_script = create_real_cheats_menu
      ENDIF
    ENDIF
  ENDIF
  make_text_sub_menu_item text = "Done" id = menu_done pad_choose_script = <pad_back_script> pad_choose_params = { no_sound }
  IF InSplitScreenGame
    set_sub_bg pos = (326, 95)
    create_icon pos = (176, 95) texture = PA_options
  ELSE
    set_sub_bg pos = (326, 45)
    create_icon pos = (176, 45) texture = PA_options
  ENDIF
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT options_menu_add_toggle_item { focus_script = do_scale_up
    unfocus_script = do_scale_down
    pad_choose_script = nullscript
    font_face = small
    parent_menu_id = current_menu
    scale = 1
    rgba = [ 88 105 112 128 ]
    on_off_text = "On"
  }
  IF GotParam not_focusable
    CreateScreenElement {
      type = TextElement
      parent = <parent_menu_id>
      id = <id>
      text = <text>
      font = <font_face>
      rgba = [ 30 30 30 128 ]
      scale = <scale>
      dims = <dims>
      not_focusable
    }
  ELSE
    CreateScreenElement {
      type = TextElement
      parent = <parent_menu_id>
      id = <id>
      text = <text>
      font = <font_face>
      rgba = <rgba>
      scale = <scale>
      dims = <dims>
      event_handlers = [
        { focus <focus_script> params = <focus_params> }
        { unfocus <unfocus_script> params = <unfocus_params> }
        { pad_choose generic_menu_pad_choose_sound }
        { pad_start generic_menu_pad_choose_sound }
        { pad_choose <pad_choose_script> params = <pad_choose_params> }
        { pad_start <pad_choose_script> params = <pad_choose_params> }
      ]
    }
    GetScreenElementDims id = <id>
    toggle_pos = ( ( <width> * (1, 0) ) + (10, 12) )
    CreateScreenElement {
      type = TextElement
      parent = <id>
      pos = <toggle_pos>
      just = [ left center ]
      text = <on_off_text>
      font = <font_face>
      rgba = <rgba>
      scale = <scale>
    }
  ENDIF
ENDSCRIPT
camera_angle = 0

SCRIPT toggle_camera_angle
  SWITCH camera_angle
  CASE 0
    Change camera_angle = 1
    SetScreenElementProps id = menu_camera text = "Camera Angle: 2"
    ToggleSkaterCamMode skater = 0
  CASE 1
    Change camera_angle = 2
    SetScreenElementProps id = menu_camera text = "Camera Angle: 3"
    ToggleSkaterCamMode skater = 0
  CASE 2
    Change camera_angle = 3
    SetScreenElementProps id = menu_camera text = "Camera Angle: 4"
    ToggleSkaterCamMode skater = 0
  CASE 3
    Change camera_angle = 0
    SetScreenElementProps id = menu_camera text = "Camera Angle: 1"
    ToggleSkaterCamMode skater = 0
  ENDSWITCH
ENDSCRIPT

SCRIPT create_real_cheats_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  IF InSplitScreenGame
    GoalManager_HidePoints
  ENDIF
  make_new_menu {
    menu_id = cheats_menu
    vmenu_id = cheats_vmenu
    menu_title = "CHEATS"
    pos = (230, 38)
  }
  SetScreenElementProps { id = cheats_menu
    event_handlers = [
      { pad_back generic_menu_pad_back params = { callback = create_options_menu } }
    ]
  }
  create_helper_text generic_helper_text_toggle
  kill_start_key_binding
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_1
    make_cheats_menu_item text = "Cool Specials" cheat_flag = CHEAT_COOL_SPECIAL_TRICKS pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_2
    make_cheats_menu_item {
      text = "Gorilla Mode"
      id = menu_gorilla
      cheat_flag = CHEAT_GORILLA
      pad_choose_script = toggle_cheat
      pad_choose_params = {
        on_callback = refresh_skater_model_for_cheats
        off_callback = refresh_skater_model_for_cheats
      }
    }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_3
    make_cheats_menu_item {
      text = "Kid Mode"
      cheat_flag = CHEAT_KID
      pad_choose_script = toggle_cheat
      pad_choose_params = {
        on_callback = refresh_skater_model_for_cheats
        off_callback = refresh_skater_model_for_cheats
      }
    }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_4
    make_cheats_menu_item {
      text = "Big Head Mode"
      id = menu_bighead
      cheat_flag = CHEAT_BIGHEAD
      pad_choose_script = toggle_cheat
      pad_choose_params = {
        on_callback = refresh_skater_model_for_cheats
        off_callback = refresh_skater_model_for_cheats
      }
    }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_5
    make_cheats_menu_item {
      text = "Hoverboard"
      cheat_flag = CHEAT_HOVERBOARD
      pad_choose_script = toggle_cheat
      pad_choose_params = {
        on_callback = refresh_skater_model_for_cheats
        off_callback = refresh_skater_model_for_cheats
      }
    }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_6
    make_cheats_menu_item text = "Slomo" cheat_flag = CHEAT_SLOMO pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_7
    IF not InSplitScreenGame
      make_cheats_menu_item text = "Disco Mode" cheat_flag = CHEAT_DISCO pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
    ENDIF
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_8
    make_cheats_menu_item {
      text = "Invisible"
      cheat_flag = CHEAT_INVISIBLE
      pad_choose_script = toggle_cheat
      pad_choose_params = {
        on_callback = refresh_skater_model_for_cheats
        off_callback = refresh_skater_model_for_cheats
      }
    }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_9
    make_cheats_menu_item text = "Super Blood" cheat_flag = CHEAT_SUPER_BLOOD pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_10
    make_cheats_menu_item text = "Flame" cheat_flag = CHEAT_FLAME pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_11
    make_cheats_menu_item text = "Sim Mode" cheat_flag = CHEAT_SIM pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_12
    make_cheats_menu_item text = "Always Special" cheat_flag = CHEAT_ALWAYS_SPECIAL pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_13
    make_cheats_menu_item text = "Perfect Rail" cheat_flag = CHEAT_PERFECT_RAIL pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_14
    make_cheats_menu_item text = "Perfect Skitch" cheat_flag = CHEAT_PERFECT_SKITCH pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_15
    make_cheats_menu_item text = "Stats 13" cheat_flag = CHEAT_STATS_13 pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_16
    make_cheats_menu_item text = "Perfect Manual" cheat_flag = CHEAT_PERFECT_MANUAL pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_17
    make_cheats_menu_item text = "Moon Gravity" cheat_flag = CHEAT_MOON pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  IF GetGlobalFlag flag = CHEAT_UNLOCKED_18
    make_cheats_menu_item text = "Matrix Mode" cheat_flag = CHEAT_MATRIX pad_choose_script = toggle_cheat pad_choose_params = { on_callback = nullscript off_callback = nullscript }
  ENDIF
  make_text_sub_menu_item text = "Done" id = menu_done scale = 0.8 pad_choose_script = create_options_menu
  set_sub_bg pos = (326, 45)
  create_icon pos = (174, 45) texture = PA_options
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT make_cheats_menu_item { focus_script = do_scale_up
    unfocus_script = do_scale_down
    pad_choose_script = nullscript
    font_face = small
    parent_menu_id = current_menu
    scale = 0.8
    dims = (350, 14)
    rgba = [ 88 105 112 128 ]
  }
  pad_choose_params = { cheat_flag = <cheat_flag> <pad_choose_params> }
  IF GotParam not_focusable
    CreateScreenElement {
      type = TextElement
      parent = <parent_menu_id>
      id = <id>
      text = <text>
      font = <font_face>
      rgba = [ 30 30 30 128 ]
      scale = <scale>
      dims = <dims>
      not_focusable
    }
  ELSE
    CreateScreenElement {
      type = TextElement
      parent = <parent_menu_id>
      id = <id>
      text = <text>
      font = <font_face>
      rgba = <rgba>
      scale = <scale>
      dims = <dims>
      event_handlers = [
        { focus <focus_script> params = <focus_params> }
        { unfocus <unfocus_script> params = <unfocus_params> }
        { pad_choose generic_menu_pad_choose_sound }
        { pad_choose <pad_choose_script> params = <pad_choose_params> }
        { pad_start <pad_choose_script> params = <pad_choose_params> }
      ]
    }
    GetScreenElementDims id = <id>
    toggle_pos = ( ( <width> * (1, 0) ) + (-50, 12) )
    IF ( GetGlobalFlag flag = <cheat_flag> )
      on_off_text = "On"
    ELSE
      on_off_text = "Off"
    ENDIF
    CreateScreenElement {
      type = TextElement
      parent = <id>
      pos = <toggle_pos>
      just = [ left center ]
      text = <on_off_text>
      font = <font_face>
      rgba = <rgba>
      scale = <scale>
    }
  ENDIF
ENDSCRIPT

SCRIPT choose_boolean_option
  set_preferences_from_ui prefs = network <...>
  remove_pause_menu_textures_from_vram
  create_options_menu
ENDSCRIPT

SCRIPT back_from_boolean_menus
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_pause_menu_textures_from_vram
  create_options_menu
ENDSCRIPT

SCRIPT create_options_score_display_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu {
    menu_id = score_display_options_menu
    vmenu_id = score_display_options_vmenu
    menu_title = "SCORE DISPLAY MODE"
    pos = (230, 79)
  }
  SetScreenElementProps {
    id = score_display_options_menu
    event_handlers = [ { pad_back back_from_boolean_menus } ]
    replace_handlers
  }
  make_text_sub_menu_item text = "Show Players" id = menu_players pad_choose_script = choose_boolean_option pad_choose_params = { field = "score_display" checksum = score_players string = "Show Players" }
  make_text_sub_menu_item text = "Show Teams" id = menu_teams pad_choose_script = choose_boolean_option pad_choose_params = { field = "score_display" checksum = score_teams string = "Show Teams" }
  make_text_sub_menu_item text = "Done" id = menu_done pad_choose_script = back_from_boolean_menus
  set_sub_bg pos = (326, 85)
  create_icon pos = (176, 85) texture = PA_options
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT toggle_show_name_option
  GetTags
  GetPreferenceString pref_type = network show_names
  IF ( <ui_string> = "Off" )
    text = "On"
    set_preferences_from_ui prefs = network field = "show_names" checksum = boolean_true string = "On"
    SetScreenElementProps id = { <id> child = 0 } text = "On"
  ELSE
    text = "Off"
    set_preferences_from_ui prefs = network field = "show_names" checksum = boolean_false string = "Off"
    SetScreenElementProps id = { <id> child = 0 } text = "Off"
    destroy_all_player_names
  ENDIF
ENDSCRIPT

SCRIPT toggle_auto_brake_option
  GetTags
  GetPreferenceString pref_type = network auto_brake
  IF ( <ui_string> = "Off" )
    text = "On"
    set_preferences_from_ui prefs = network field = "auto_brake" checksum = boolean_true string = "On"
    SetScreenElementProps id = { <id> child = 0 } text = "On"
  ELSE
    text = "Off"
    set_preferences_from_ui prefs = network field = "auto_brake" checksum = boolean_false string = "Off"
    SetScreenElementProps id = { <id> child = 0 } text = "Off"
  ENDIF
ENDSCRIPT

SCRIPT create_gamma_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu menu_title = "GAMMA" menu_id = gamma_menu vmenu_id = gamma_vmenu
  SetScreenElementProps {
    id = gamma_menu
    event_handlers = [ { pad_back create_options_menu } ]
    replace_handlers
  }
  set_sub_bg
  create_icon texture = PA_options
  make_text_sub_menu_item text = "Red: " id = gamma_menu_red
  make_text_sub_menu_item text = "Green: " id = gamma_menu_green
  make_text_sub_menu_item text = "Blue: " id = gamma_menu_blue
  make_text_sub_menu_item text = "Done" id = gamma_menu_done pad_choose_script = create_options_menu
  SetScreenElementProps {
    id = gamma_menu_red
    event_handlers = [ { pad_left gamma_menu_turn_down params = { color = red } }
      { pad_right gamma_menu_turn_up params = { color = red } }
    ]
    replace_handlers
  }
  SetScreenElementProps {
    id = gamma_menu_green
    event_handlers = [ { pad_left gamma_menu_turn_down params = { color = green } }
      { pad_right gamma_menu_turn_up params = { color = green } }
    ]
    replace_handlers
  }
  SetScreenElementProps {
    id = gamma_menu_blue
    event_handlers = [ { pad_left gamma_menu_turn_down params = { color = blue } }
      { pad_right gamma_menu_turn_up params = { color = blue } }
    ]
    replace_handlers
  }
  GetGammaValues
  FormatText TextName = red_text "%i" i = <red>
  FormatText TextName = green_text "%i" i = <green>
  FormatText TextName = blue_text "%i" i = <blue>
  gamma_menu_create_child text = <red_text> parent = gamma_menu_red
  gamma_menu_create_child text = <green_text> parent = gamma_menu_green
  gamma_menu_create_child text = <blue_text> parent = gamma_menu_blue
  create_helper_text { helper_text_elements = [ { text = "\b7/\b4=Select" }
      { text = "\b6/\b5=Adjust" }
      { text = "\m0=Accept" }
      { text = "\m1=Back" }
    ]
  }
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT gamma_menu_create_child
  SetScreenElementLock id = <parent> off
  CreateScreenElement {
    type = TextElement
    parent = <parent>
    text = <text>
    font = small
    just = [ right top ]
    pos = (150, 0)
  }
ENDSCRIPT

SCRIPT gamma_menu_check_levels
  GetGammaValues
  FormatText TextName = red_text "%i" i = <red>
  FormatText TextName = green_text "%i" i = <green>
  FormatText TextName = blue_text "%i" i = <blue>
  SetScreenElementLock id = gamma_menu_red off
  SetScreenElementLock id = gamma_menu_green off
  SetScreenElementLock id = gamma_menu_blue off
  SetScreenElementProps {
    id = { gamma_menu_red child = 0 }
    text = <red_text>
  }
  SetScreenElementProps {
    id = { gamma_menu_green child = 0 }
    text = <green_text>
  }
  SetScreenElementProps {
    id = { gamma_menu_blue child = 0 }
    text = <blue_text>
  }
ENDSCRIPT

SCRIPT gamma_menu_turn_up
  GetGammaValues
  SWITCH <color>
  CASE red
    IF not ( <red> > 99 )
      PlaySound GUI_click06
    ENDIF
  CASE blue
    IF not ( <blue> > 99 )
      PlaySound GUI_click06
    ENDIF
  CASE green
    IF not ( <green> > 99 )
      PlaySound GUI_click06
    ENDIF
  ENDSWITCH
  ApplyChangeGamma <...> Change = 0.01
  Wait 1 frame
  gamma_menu_check_levels
ENDSCRIPT

SCRIPT gamma_menu_turn_down
  GetGammaValues
  SWITCH <color>
  CASE red
    IF not ( 1 > <red> )
      PlaySound GUI_click06
    ENDIF
  CASE blue
    IF not ( 1 > <blue> )
      PlaySound GUI_click06
    ENDIF
  CASE green
    IF not ( 1 > <green> )
      PlaySound GUI_click06
    ENDIF
  ENDSWITCH
  ApplyChangeGamma <...> Change = -0.01
  Wait 1 frame
  gamma_menu_check_levels
ENDSCRIPT

SCRIPT create_split_menu callback_script = create_options_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu menu_title = "SCREEN SETUP" menu_id = screen_menu vmenu_id = screen_vmenu
  create_helper_text generic_helper_text
  SetScreenElementProps {
    id = screen_menu
    event_handlers = [ { pad_back generic_menu_pad_back params = { callback = <callback_script> } } ]
    replace_handlers
  }
  set_sub_bg
  create_icon texture = PA_network
  make_text_sub_menu_item text = "Horizontal" pad_choose_script = generic_menu_pad_choose pad_choose_params = { <...> callback = split_setup_horizontal }
  make_text_sub_menu_item text = "Vertical" pad_choose_script = generic_menu_pad_choose pad_choose_params = { <...> callback = split_setup_vertical }
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT create_screen_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu menu_title = "SCREEN SETUP" menu_id = screen_menu vmenu_id = screen_vmenu helper_text = generic_helper_text
  SetScreenElementProps {
    id = screen_menu
    event_handlers = [ { pad_back generic_menu_pad_back params = { callback = create_options_menu } } ]
    replace_handlers
  }
  set_sub_bg
  create_icon texture = PA_options
  IF IsPS2
    make_text_sub_menu_item text = "Standard 4:3" pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = screen_setup_standard }
    make_text_sub_menu_item text = "Widescreen 16:9" pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = screen_setup_widescreen }
  ENDIF
  IF IsNGC
    make_text_sub_menu_item text = "Standard 4:3" pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = screen_setup_standard }
    make_text_sub_menu_item text = "Widescreen 16:9" pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = screen_setup_widescreen }
  ENDIF
  IF not IsTrue bootstrap_build
    make_text_sub_menu_item text = "Done" id = screen_menu_done pad_choose_script = create_options_menu
  ENDIF
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT screen_option_update_hud_toggle
  IF ( HIDEHUD = 1 )
    FormatText TextName = text "HUD: off"
  ELSE
    FormatText TextName = text "HUD: on"
  ENDIF
  SetScreenElementProps {
    id = screen_option_hide_hud
    text = <text>
  }
ENDSCRIPT

SCRIPT screen_setup_hide_hud
  IF ( HIDEHUD = 0 )
    Change HIDEHUD = 1
  ELSE
    Change HIDEHUD = 0
  ENDIF
  screen_option_update_hud_toggle
ENDSCRIPT

SCRIPT split_setup_horizontal
  Printf "changing split mode to horizontal"
  SetScreenMode split_horizontal
  ResetSkaterCameras
  ScreenElementSystemCleanup
  IF GotParam end_run
    create_end_run_menu
  ELSE
    create_pause_menu
  ENDIF
  UpdateScore
ENDSCRIPT

SCRIPT split_setup_vertical
  Printf "changing split mode to vertical"
  SetScreenMode split_vertical
  ResetSkaterCameras
  ScreenElementSystemCleanup
  IF GotParam end_run
    create_end_run_menu
  ELSE
    create_pause_menu
  ENDIF
  UpdateScore
ENDSCRIPT

SCRIPT launch_cheats_menu
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_cheats_menu
ENDSCRIPT

SCRIPT create_cheats_menu
  GoalManager_HidePoints
  GoalManager_HideGoalPoints
  make_new_menu {
    padding_scale = 1
    menu_id = cheats_menu
    vmenu_id = cheats_vmenu
    menu_title = "CHEATS"
    padding_scale = 0.9
    pos = (230, 40)
    helper_text = generic_helper_text
  }
  kill_start_key_binding
  SetScreenElementProps { id = cheats_menu
    event_handlers = [ { pad_back create_options_menu } ]
  }
  make_toggle_menu_item id = cheats_menu_level_lock text = "Levels unlocked: " pad_choose_script = cheats_menu_change_level_lock
  make_text_sub_menu_item text = "100 Stat Points" pad_choose_script = cheats_menu_100_stat_points
  make_text_sub_menu_item text = "$5000 cash" pad_choose_script = cheats_menu_cash
  IF GoalManager_HasActiveGoals
    make_text_sub_menu_item text = "Beat current goal" pad_choose_script = cheats_menu_beat_current_goal
  ENDIF
  make_text_sub_menu_item text = "Unlock all goals" pad_choose_script = cheats_menu_UnlockAllGoals
  make_text_sub_menu_item text = "Score 5 million points" pad_choose_script = cheats_menu_score5mil
  make_text_sub_menu_item text = "Turn Pro" pad_choose_script = cheats_menu_turnPro
  make_text_sub_menu_item text = "Mark all goals unbeaten" pad_choose_script = cheats_menu_UnBeatAllGoals
  make_text_sub_menu_item text = "Add 1 pro point" pad_choose_script = cheats_menu_addgoalpoint
  RunScriptOnScreenElement id = cheats_menu_level_lock cheats_menu_check_level_lock
  set_sub_bg pos = (330, 40)
  create_icon texture = PA_cheats pos = (180, 40)
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT cheats_menu_change_flag
  GetTags
  IF GetGlobalFlag flag = <flag>
    UnSetGlobalFlag flag = <flag>
    toggle_menu_item_off id = <id>
  ELSE
    SetGlobalFlag flag = <flag>
    toggle_menu_item_on id = <id>
  ENDIF
ENDSCRIPT

SCRIPT cheats_menu_check_flag
  GetTags
  IF GetGlobalFlag flag = <flag>
    toggle_menu_item_on id = <id>
  ELSE
    toggle_menu_item_off id = <id>
  ENDIF
ENDSCRIPT

SCRIPT cheats_menu_check_level_lock
  GetTags
  IF IntegerEquals a = all_levels_unlocked b = 1
    toggle_menu_item_on id = <id>
  ELSE
    toggle_menu_item_off id = <id>
  ENDIF
ENDSCRIPT

SCRIPT cheats_menu_change_level_lock
  GetTags
  IF IntegerEquals a = all_levels_unlocked b = 1
    toggle_menu_item_off id = <id>
    Change all_levels_unlocked = 0
  ELSE
    IF IntegerEquals a = all_levels_unlocked b = 0
      toggle_menu_item_on id = <id>
      Change all_levels_unlocked = 1
    ENDIF
  ENDIF
  pulse_item
ENDSCRIPT

SCRIPT cheats_menu_check_cool_special
  GetTags
  IF IntegerEquals a = COOL_SPECIAL_TRICKS b = 1
    toggle_menu_item_on id = <id>
  ELSE
    toggle_menu_item_off id = <id>
  ENDIF
ENDSCRIPT

SCRIPT cheats_menu_change_cool_special
  GetTags
  IF IntegerEquals a = COOL_SPECIAL_TRICKS b = 1
    toggle_menu_item_off id = <id>
    Change COOL_SPECIAL_TRICKS = 0
  ELSE
    IF IntegerEquals a = COOL_SPECIAL_TRICKS b = 0
      toggle_menu_item_on id = <id>
      Change COOL_SPECIAL_TRICKS = 1
    ENDIF
  ENDIF
  pulse_item
ENDSCRIPT

SCRIPT cheats_menu_100_stat_points
  AwardStatPoint 100
  pulse_item
ENDSCRIPT

SCRIPT cheats_menu_UnlockAllGoals
  GoalManager_UnlockAllGoals
  GoalManager_UnlockProSpecificChallenges
  pulse_item
ENDSCRIPT

SCRIPT cheats_menu_score5mil
  skater:SetTrickName "You cheat like Kurt"
  skater:SetTrickScore 5000000
  skater:Display
ENDSCRIPT

SCRIPT cheats_menu_turnPro
  GoalManager_TurnPro
ENDSCRIPT

SCRIPT cheats_menu_UnBeatAllGoals
  GoalManager_UnBeatAllGoals
ENDSCRIPT

SCRIPT cheats_menu_addgoalpoint
  GoalManager_AddGoalPoint
ENDSCRIPT

SCRIPT cheats_menu_unlockProChallenges
  GoalManager_UnlockProSpecificChallenges
ENDSCRIPT

SCRIPT cheats_menu_cash
  GoalManager_AddCash 5000
ENDSCRIPT

SCRIPT cheats_menu_beat_current_goal
  IF GoalManager_GetActiveGoalId
    exit_pause_menu
    GoalManager_WinGoal name = <goal_id>
  ENDIF
ENDSCRIPT
current_soundtrack = #""

SCRIPT launch_sound_options_menu
  IF GotParam from_options
    RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_sound_options_menu callback_params = { from_options }
  ELSE
    RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_sound_options_menu
  ENDIF
ENDSCRIPT

SCRIPT create_sound_options_menu
  remove_pause_menu_textures_from_vram
  add_ss_menu_textures_to_vram
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 frame
  ENDIF
  make_new_skateshop_menu {
    internal_just = [ left center ]
    menu_id = sound_options_menu
    vmenu_id = sound_options_vmenu
    menu_title = "SOUND"
    helper_text = { helper_text_elements = [ { text = "\b7/\b4 = Select" }
        { text = "\b6/\b5 = Adjust Levels" }
        { text = "\m1 = Back" }
        { text = "\m0 = Accept" }
      ]
    }
  }
  kill_start_key_binding
  delta_pos = (95, 25)
  IF IsXBOX
    middle_repeat = 9
    blue_bar_pos = ( (230, 280) + <delta_pos> )
    goal_right_scale = (0.8, 0.75)
  ELSE
    middle_repeat = 8
    blue_bar_pos = ( (230, 259) + <delta_pos> )
    goal_right_scale = (0.8, 0.68)
  ENDIF
  GetStackedScreenElementPos X id = current_menu_anchor
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = sound_options_bg
    texture = options_bg
    draw_behind_parent
    pos = ( (232, 88) + <delta_pos> )
    scale = (1.17, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 2
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_blue_bar
    texture = stats_notch
    pos = ( (230, 118) + <delta_pos> )
    rgba = [ 42 48 77 50 ]
    scale = (14, 0.2)
    just = [ center top ]
    z_priority = 5
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_blue_bar2
    texture = stats_notch
    pos = <blue_bar_pos>
    rgba = [ 42 48 77 50 ]
    scale = (14, 0.2)
    just = [ center top ]
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = ( (230, 100) + <delta_pos> )
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT <middle_repeat>
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (0.96, 1)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-20, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = <goal_right_scale>
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = sound_options_bg
  create_icon texture = PA_sound pos = ( (80, 88) + <delta_pos> )
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu
    texture = stats_notch
    rgba = [ 42 48 77 0 ]
    scale = (14, 0.2)
    not_focusable
  }
  IF GotParam from_options
    SetScreenElementProps { id = sound_options_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = sound_options_exit from_options } }
      ]
    }
  ELSE
    SetScreenElementProps { id = sound_options_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = sound_options_exit } }
      ]
    }
  ENDIF
  IF ( SongOrder = 0 )
    song_text = "Songs: Random"
  ELSE
    song_text = "Songs: In Order"
  ENDIF
  main_menu_add_item { text = <song_text>
    id = menu_song_order
    pad_choose_script = toggle_song_order
    highlight_bar_scale = (0.94, 1.3)
    highlight_bar_pos = (94, -7)
  }
  IF IsDemo
    main_menu_add_item { text = "Skip Track"
      not_focusable = not_focusable
      id = menu_skip_track
      focus_script = skip_track_focus
      unfocus_script = skip_track_unfocus
      pad_choose_script = generic_menu_pad_choose
      pad_choose_params = { callback = skip_track }
      highlight_bar_scale = (0.94, 1.3)
      highlight_bar_pos = (94, -7)
    }
  ELSE
    main_menu_add_item { text = "Skip Track"
      id = menu_skip_track
      focus_script = skip_track_focus
      unfocus_script = skip_track_unfocus
      pad_choose_script = generic_menu_pad_choose
      pad_choose_params = { callback = skip_track }
      highlight_bar_scale = (0.94, 1.3)
      highlight_bar_pos = (94, -7)
    }
  ENDIF
  IF GotParam from_options
    IF IsXBOX
    ENDIF
    IF ( current_soundtrack = #"" )
      IF IsDemo
        main_menu_add_item { text = "Playlist"
          id = menu_playlist
          not_focusable = not_focusable
          pad_choose_script = generic_menu_pad_choose
          pad_choose_params = { callback = create_playlist_menu from_options }
          highlight_bar_scale = (0.94, 1.3)
          highlight_bar_pos = (94, -7)
        }
      ELSE
        main_menu_add_item { text = "Playlist"
          id = menu_playlist
          pad_choose_script = generic_menu_pad_choose
          pad_choose_params = { callback = create_playlist_menu from_options }
          highlight_bar_scale = (0.94, 1.3)
          highlight_bar_pos = (94, -7)
        }
      ENDIF
    ELSE
      main_menu_add_item { text = "Playlist"
        id = menu_playlist
        pad_choose_script = nullscript
        not_focusable = not_focusable
        highlight_bar_scale = (0.94, 1.3)
        highlight_bar_pos = (94, -7)
      }
    ENDIF
  ELSE
    IF IsXBOX
    ENDIF
    IF ( current_soundtrack = #"" )
      IF IsDemo
        main_menu_add_item { text = "Playlist"
          id = menu_playlist
          not_focusable = not_focusable
          pad_choose_script = generic_menu_pad_choose
          pad_choose_params = { callback = create_playlist_menu }
          highlight_bar_scale = (0.94, 1.3)
          highlight_bar_pos = (94, -7)
        }
      ELSE
        main_menu_add_item { text = "Playlist"
          id = menu_playlist
          pad_choose_script = generic_menu_pad_choose
          pad_choose_params = { callback = create_playlist_menu }
          highlight_bar_scale = (0.94, 1.3)
          highlight_bar_pos = (94, -7)
        }
      ENDIF
    ELSE
      main_menu_add_item { text = "Playlist"
        id = menu_playlist
        pad_choose_script = nullscript
        not_focusable = not_focusable
        highlight_bar_scale = (0.94, 1.3)
        highlight_bar_pos = (94, -7)
      }
    ENDIF
  ENDIF
  main_menu_add_item { text = "Music Level:    "
    id = menu_music_level
    focus_script = menu_music_level_focus
    unfocus_script = menu_music_level_unfocus
    highlight_bar_scale = (0.94, 1.3)
    highlight_bar_pos = (94, -7)
    no_sound
  }
  main_menu_add_item { text = "Sound Level:    "
    id = menu_sound_level
    focus_script = menu_music_level_focus
    unfocus_script = menu_music_level_unfocus
    highlight_bar_scale = (0.94, 1.3)
    highlight_bar_pos = (94, -7)
    no_sound
  }
  IF GotParam from_options
    main_menu_add_item text = "Done" id = menu_done pad_choose_script = sound_options_exit pad_choose_params = { from_options } highlight_bar_scale = (0.94, 1.3) highlight_bar_pos = (94, -7)
  ELSE
    main_menu_add_item text = "Done" id = menu_done pad_choose_script = sound_options_exit highlight_bar_scale = (0.94, 1.3) highlight_bar_pos = (94, -7)
  ENDIF
  sound_options_show_levels
  RunScriptOnScreenElement id = current_menu_anchor animate_in
  PauseMusic
ENDSCRIPT

SCRIPT sound_options_exit
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_ss_menu_textures_from_vram
  IF GotParam just_remove
    RETURN
  ENDIF
  IF GotParam from_options
    add_pause_menu_textures_to_vram
    PauseMusic 1
    create_options_menu
  ELSE
    PauseMusic 0
    create_setup_options_menu
  ENDIF
ENDSCRIPT

SCRIPT sound_options_show_levels
  GetValueFromVolume cdvol
  FormatText TextName = cdvol "%v" v = <value>
  CreateScreenElement {
    type = TextElement
    parent = menu_music_level
    font = small
    just = [ center top ]
    pos = (188, -17)
    text = <cdvol>
    rgba = [ 88 105 112 128 ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_music_level
    texture = left_arrow
    rgba = [ 128 128 128 0 ]
    pos = (172, -17)
    just = [ right top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_music_level
    texture = right_arrow
    rgba = [ 128 128 128 0 ]
    pos = (200, -17)
    just = [ left top ]
    scale = 0.75
  }
  GetValueFromVolume sfxvol
  FormatText TextName = sfxvol "%v" v = <value>
  CreateScreenElement {
    type = TextElement
    parent = menu_sound_level
    font = small
    just = [ center top ]
    pos = (188, -17)
    text = <sfxvol>
    rgba = [ 88 105 112 128 ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_sound_level
    texture = left_arrow
    rgba = [ 128 128 128 0 ]
    pos = (172, -17)
    just = [ right top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_sound_level
    texture = right_arrow
    rgba = [ 128 128 128 0 ]
    pos = (200, -17)
    just = [ left top ]
    scale = 0.75
  }
  SetScreenElementProps {
    id = menu_music_level
    event_handlers = [ { pad_left menu_turn_music_down }
      { pad_right menu_turn_music_up }
    ]
    replace_handlers
  }
  SetScreenElementProps {
    id = menu_sound_level
    event_handlers = [ { pad_left menu_turn_sound_down }
      { pad_right menu_turn_sound_up }
    ]
    replace_handlers
  }
ENDSCRIPT

SCRIPT create_sound_options_mini_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 frame
  ENDIF
  IF GotParam song_order
    title = "SONG ORDER"
  ENDIF
  IF GotParam music_or_ambience
    title = "SOUND MODE"
  ENDIF
  make_new_skateshop_menu {
    internal_just = [ left center ]
    menu_id = sound_options_mini_menu
    vmenu_id = sound_options_mini_vmenu
    menu_title = <title>
    helper_text = generic_helper_text
  }
  kill_start_key_binding
  IF GotParam from_options
    SetScreenElementProps { id = sound_options_mini_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = create_sound_options_menu from_options } }
      ]
    }
  ELSE
    SetScreenElementProps { id = sound_options_mini_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = create_sound_options_menu } }
      ]
    }
  ENDIF
  delta_pos = (100, 30)
  GetStackedScreenElementPos X id = current_menu_anchor
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = sound_options_bg
    texture = options_bg
    draw_behind_parent
    pos = ( (232, 85) + <delta_pos> )
    scale = (1.17, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 3
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_blue_bar2
    texture = stats_notch
    pos = ( (228, 194) + <delta_pos> )
    rgba = [ 42 48 77 50 ]
    scale = (14, 0.2)
    just = [ center top ]
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = ( (230, 100) + <delta_pos> )
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT 4
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (0.96, 0.6)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-20, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = (0.8, 0.412)
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = sound_options_bg
  create_icon texture = PA_sound pos = ( (80, 85) + <delta_pos> )
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu
    texture = stats_notch
    rgba = [ 42 48 77 0 ]
    scale = (14, 0.2)
    not_focusable
  }
  IF GotParam from_options
    IF GotParam song_order
      main_menu_add_item { text = "In Order"
        id = menu_in_order
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = inorder from_options }
      }
      main_menu_add_item { text = "Random"
        id = menu_random
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = randomly from_options }
      }
    ENDIF
    IF GotParam music_or_ambience
      main_menu_add_item { text = "Music"
        id = menu_music
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = music from_options }
      }
      main_menu_add_item { text = "Ambience"
        id = menu_ambience
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = ambience from_options }
      }
    ENDIF
    main_menu_add_item text = "Done" id = menu_done pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_sound_options_menu from_options }
  ELSE
    IF GotParam song_order
      main_menu_add_item { text = "In Order"
        id = menu_in_order
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = inorder }
      }
      main_menu_add_item { text = "Random"
        id = menu_random
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = randomly }
      }
    ENDIF
    IF GotParam music_or_ambience
      main_menu_add_item { text = "Music"
        id = menu_music
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = music }
      }
      main_menu_add_item { text = "Ambience"
        id = menu_ambience
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = sound_mini_menu_select choice = ambience }
      }
    ENDIF
    main_menu_add_item text = "Done" id = menu_done pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_sound_options_menu }
  ENDIF
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT sound_mini_menu_select
  SWITCH <choice>
  CASE inorder
    PlaySongsInOrder
  CASE randomly
    PlaySongsRandomly
  CASE music
    SetCDToMusic
  CASE ambience
    SetCDToAmbience
  ENDSWITCH
  IF GotParam from_options
    create_sound_options_menu from_options
  ELSE
    create_sound_options_menu
  ENDIF
ENDSCRIPT
SongOrder = 0

SCRIPT toggle_song_order
  IF ( SongOrder = 1 )
    SetScreenElementProps id = { menu_song_order child = 0 } text = "Songs: Random"
    PlaySongsRandomly
    Change SongOrder = 0
  ELSE
    SetScreenElementProps id = { menu_song_order child = 0 } text = "Songs: In Order"
    PlaySongsInOrder
    Change SongOrder = 1
  ENDIF
ENDSCRIPT

SCRIPT create_playlist_menu
  IF not CD
    IF not ( testmusicfromhost = 1 )
      RETURN
    ENDIF
  ENDIF
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_pause_menu_textures_from_vram
  add_gap_menu_textures_to_vram
  GoalManager_HidePoints
  GoalManager_HideGoalPoints
  SetScreenElementLock id = root_window off
  CreateScreenElement {
    type = ContainerElement
    parent = root_window
    id = playlist_menu
    dims = (640, 480)
    pos = (320, 240)
  }
  AssignAlias id = playlist_menu alias = current_menu_anchor
  create_helper_text { helper_text_elements = [ { text = "\b7/\b4 = Select" }
      { text = "\m1 = Back" }
      { text = "\b3 = Toggle" }
      { text = "\me = Preview Track" }
    ]
  }
  kill_start_key_binding
  set_sub_bg_goal goal_mid_scale = (19, 1.33) pos = (180, 23)
  create_icon texture = PA_sound pos = (33, 23)
   <root_pos> = (80, 25)
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "PLAYLIST"
    rgba = [ 128 128 128 85 ]
    pos = <root_pos>
    just = [ left top ]
    scale = 1.35
  }
  GetStackedScreenElementPos Y id = <id> offset = (-15, -4)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_gaps_menu_top_bar
    texture = black
    rgba = [ 0 0 0 85 ]
    scale = (124, 7)
    pos = <pos>
    just = [ left top ]
    z_priority = 2
  }
  GetStackedScreenElementPos X id = view_gaps_menu_top_bar offset = (-260, 5)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_gaps_menu_up_arrow
    texture = up_arrow
    rgba = [ 128 128 128 85 ]
    pos = <pos>
    just = [ left top ]
    z_priority = 3
  }
  GetStackedScreenElementPos X id = view_gaps_menu_top_bar offset = (-60, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    scale = (2, 78)
    pos = <pos>
    just = [ left top ]
    rgba = [ 0 0 0 80 ]
    z_priority = 5
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_top_bar offset = (0, 285)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    rgba = [ 0 0 0 105 ]
    scale = (124, 6)
    pos = <pos>
    just = [ left top ]
    z_priority = 2
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_up_arrow offset = (0, 300)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_gaps_menu_down_arrow
    texture = down_arrow
    rgba = [ 128 128 128 85 ]
    pos = <pos>
    just = [ left top ]
    z_priority = 3
  }
  GetStackedScreenElementPos Y id = view_gaps_menu_top_bar offset = (20, 5)
  CreateScreenElement {
    type = VScrollingMenu
    parent = current_menu_anchor
    dims = (640, 280)
    pos = <pos>
    just = [ left top ]
    internal_just = [ center top ]
  }
   <callback> = exit_playlist_menu
  CreateScreenElement {
    type = VMenu
    parent = <id>
    id = gap_vmenu
    pos = (0, 0)
    just = [ left top ]
    internal_just = [ left top ]
    dont_allow_wrap
    event_handlers = [
      { pad_up set_which_arrow params = { arrow = view_gaps_menu_up_arrow } }
      { pad_down set_which_arrow params = { arrow = view_gaps_menu_down_arrow } }
      { pad_back generic_menu_pad_back params = { <...> } }
      { pad_up generic_menu_up_or_down_sound params = { up } }
      { pad_down generic_menu_up_or_down_sound params = { down } }
      { pad_back generic_menu_pad_back_sound }
    ]
  }
  AssignAlias id = gap_vmenu alias = current_menu
  kill_start_key_binding
  add_tracks_to_menu
  PrintStruct <...>
  RunScriptOnScreenElement id = current_menu_anchor animate_in params = { menu_id = current_menu }
ENDSCRIPT

SCRIPT exit_playlist_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_gap_menu_textures_from_vram
  IF GotParam from_options
    create_sound_options_menu from_options
  ELSE
    create_sound_options_menu
  ENDIF
ENDSCRIPT

SCRIPT create_soundtrack_menu
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 frame
  ENDIF
  scale = (1.75, 1)
  GetNumSoundtracks
  IF ( <numsoundtracks> = 0 )
    empty = 1
  ELSE
    empty = 0
  ENDIF
  IF ( 9 > <numsoundtracks> )
    middle_repeat = ( ( ( <numsoundtracks> * 3 ) / 2 ) + 2 )
    menu_pos = (230, 110)
    SWITCH <numsoundtracks>
    CASE 0
      box_right_scale = (0.8, 0.29)
    CASE 1
      middle_repeat = 5
      box_right_scale = (0.8, 0.475)
    CASE 2
      box_right_scale = (0.8, 0.475)
    CASE 3
      box_right_scale = (0.8, 0.535)
    CASE 4
      box_right_scale = (0.8, 0.66)
    CASE 5
      box_right_scale = (0.8, 0.72)
    CASE 6
      box_right_scale = (0.8, 0.845)
    CASE 7
      box_right_scale = (0.8, 0.905)
    CASE 8
      box_right_scale = (0.8, 1.04)
    ENDSWITCH
  ELSE
    middle_repeat = 16
    menu_pos = (230, 125)
    box_right_scale = (0.8, 1.16)
  ENDIF
  make_new_skateshop_menu {
    internal_just = [ left top ]
    menu_id = soundtrack_menu
    vmenu_id = soundtrack_vmenu
    type = VScrollingMenu
    pos = <menu_pos>
    dims = (300, 252)
    just = [ center top ]
    dont_allow_wrap = dont_allow_wrap
    helper_text = generic_helper_text
  }
  kill_start_key_binding
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "SOUNDTRACKS"
    scale = 1.4
    pos = (135, 80)
    just = [ left top ]
    rgba = [ 128 128 128 98 ]
    not_focusable
    z_priority = 5
  }
  IF ( <numsoundtracks> > 9 )
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      id = soundtrack_up_arrow
      texture = up_arrow
      pos = (320, 105)
      just = [ center top ]
      rgba = [ 128 128 128 128 ]
      z_priority = 3
    }
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      id = soundtrack_down_arrow
      texture = down_arrow
      pos = (320, 372)
      just = [ center top ]
      rgba = [ 128 128 128 128 ]
      z_priority = 3
    }
  ENDIF
  IF GotParam from_options
    SetScreenElementProps { id = soundtrack_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = create_sound_options_menu from_options } }
      ]
    }
  ELSE
    SetScreenElementProps { id = soundtrack_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = create_sound_options_menu } }
      ]
    }
  ENDIF
  delta_pos = (100, 0)
  GetStackedScreenElementPos X id = current_menu_anchor
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = sound_options_bg
    texture = options_bg
    draw_behind_parent
    pos = ( (228, 75) + <delta_pos> )
    scale = (2, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 3
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = ( (230, 90) + <delta_pos> )
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT <middle_repeat>
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (1.7, 0.6)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-25, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = <box_right_scale>
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  create_icon texture = PA_sound pos = ( (-15, 75) + <delta_pos> )
  main_menu_add_item { text = "THPS4 Playlist"
    focus_script = soundtrack_focus
    pad_choose_script = generic_menu_pad_choose
    pad_choose_params = { callback = SetSoundtrack track = "" }
    highlight_bar_scale = (1.625, 1.3)
  }
  IF not ( <empty> = 1 )
    index = 0
    BEGIN
      GetSoundtrackName <index>
      main_menu_add_item { text = <soundtrackname>
        focus_script = soundtrack_focus
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = SetSoundtrack track = <soundtrackname> }
        highlight_bar_scale = (1.625, 1.3)
        max_width = 380
      }
       <index> = ( <index> + 1 )
    REPEAT <numsoundtracks>
  ENDIF
  IF GotParam from_options
    main_menu_add_item text = "Done" id = menu_done focus_script = soundtrack_focus pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_sound_options_menu from_options } highlight_bar_scale = (1.625, 1.3)
  ELSE
    main_menu_add_item text = "Done" id = menu_done focus_script = soundtrack_focus pad_choose_script = generic_menu_pad_choose pad_choose_params = { callback = create_sound_options_menu } highlight_bar_scale = (1.625, 1.3)
  ENDIF
  IF ObjectExists id = soundtrack_up_arrow
    SetScreenElementProps { id = soundtrack_vmenu
      event_handlers = [
        { pad_down menu_vert_blink_arrow params = { id = soundtrack_down_arrow } }
        { pad_up menu_vert_blink_arrow params = { id = soundtrack_up_arrow } }
      ]
    }
  ENDIF
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT GetSoundtracks
  GetNumSoundtracks
  index = 0
  BEGIN
    GetSoundtrackName <index>
    soundtracks [ <index> ] = <soundtrackname>
  REPEAT <numsoundtracks>
  RETURN soundtracks
ENDSCRIPT

SCRIPT SetSoundtrack
  IF IsPS2
    RETURN
  ENDIF
  FormatText ChecksumName = trackchecksum "%t" t = <track>
  Printf "soundtrack = %i" i = <trackchecksum>
  generic_menu_pad_choose
  SoundtrackExists trackname = <track>
  Printf "soundtrack index = %i" i = <index>
  IF not ( current_soundtrack = <trackchecksum> )
    StopMusic
  ENDIF
  IF ( <index> = -1 )
    Printf "use playlist"
    UseStandardSoundtrack
  ELSE
    Printf "use soundtrack"
    UseUserSoundtrack <index>
  ENDIF
  Change current_soundtrack = <trackchecksum>
  IF LevelIs load_skateshop
    create_sound_options_menu
  ELSE
    create_sound_options_menu from_options
  ENDIF
ENDSCRIPT

SCRIPT SoundtrackExists trackname = ""
  Printf "trackname = %t" t = <trackname>
  FormatText ChecksumName = tracknamesum "%t" t = <trackname>
  GetNumSoundtracks
  IF not ( <numsoundtracks> = 0 )
    index = 0
    BEGIN
      GetSoundtrackName <index>
      Printf "soundtrackname = %t" t = <soundtrackname>
      FormatText ChecksumName = soundtracksum "%s" s = <soundtrackname>
      IF ( <tracknamesum> = <soundtracksum> )
        RETURN { index = <index> }
      ENDIF
      index = ( <index> + 1 )
    REPEAT <numsoundtracks>
  ENDIF
  RETURN { index = -1 }
ENDSCRIPT

SCRIPT set_loaded_soundtrack
  Printf "set_loaded_soundtrack"
  IF not IsXBOX
    RETURN
  ENDIF
  current_soundtrack_exists
  IF not ( current_soundtrack = #"" )
    StopMusic
  ENDIF
  IF ( <index> = -1 )
    Printf "use playlist"
    UseStandardSoundtrack
  ELSE
    Printf "use soundtrack %i" i = <index>
    UseUserSoundtrack <index>
  ENDIF
ENDSCRIPT

SCRIPT current_soundtrack_exists
  GetNumSoundtracks
  IF not ( <numsoundtracks> = 0 )
    index = 0
    BEGIN
      GetSoundtrackName <index>
      FormatText ChecksumName = soundtracksum "%s" s = <soundtrackname>
      IF ( current_soundtrack = <soundtracksum> )
        RETURN { index = <index> }
      ENDIF
      index = ( <index> + 1 )
    REPEAT <numsoundtracks>
  ENDIF
  RETURN { index = -1 }
ENDSCRIPT

SCRIPT soundtrack_focus
  IF ObjectExists id = soundtrack_up_arrow
    generic_menu_update_arrows menu_id = soundtrack_vmenu up_arrow_id = soundtrack_up_arrow down_arrow_id = soundtrack_down_arrow
  ENDIF
  main_menu_focus
ENDSCRIPT

SCRIPT add_tracks_to_menu
  IF IsTrue Xbox
  ENDIF
  GetArraySize playlist_tracks
  index = 0
  BEGIN
    playlist_menu_add_item { index = <index> }
     <index> = ( <index> + 1 )
  REPEAT <array_size>
ENDSCRIPT

SCRIPT playlist_menu_add_item highlight_bar_scale = (1.9, 1) highlight_bar_pos = (227, 7)
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    dims = (200, 20)
    event_handlers = [ { focus playlist_menu_focus params = <focus_params> }
      { unfocus playlist_menu_unfocus }
      { pad_choose change_track_state params = { index = <index> } }
      { pad_choose generic_menu_pad_choose_sound }
      { pad_start change_track_state params = { index = <index> } }
      { pad_start generic_menu_pad_choose_sound }
      { pad_option preview_music_track params = { index = <index> } }
    ]
  }
   <anchor_id> = <id>
  track_title = ( ( playlist_tracks [ <index> ] ).track_title )
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    font = small
    text = <track_title>
    pos = (-5, 0)
    just = [ left top ]
    rgba = [ 88 105 112 128 ]
    scale = 0.7
  }
  IF TrackEnabled <index>
    on_or_off = "on"
  ELSE
    on_or_off = "off"
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    font = small
    text = <on_or_off>
    pos = (444, 0)
    just = [ center top ]
    rgba = [ 88 105 112 128 ]
    scale = 0.7
  }
  CreateScreenElement {
    type = SpriteElement
    parent = <anchor_id>
    texture = highlight_bar
    pos = <highlight_bar_pos>
    scale = <highlight_bar_scale>
    just = [ center center ]
    rgba = [ 128 128 128 0 ]
    z_priority = 3
  }
ENDSCRIPT

SCRIPT change_track_state
  GetTags
  IF TrackEnabled <index>
    ChangeTrackState <index> off
    PauseMusic 1
    SetScreenElementProps id = { <id> child = 1 } text = "off"
  ELSE
    ChangeTrackState <index> on
    SetScreenElementProps id = { <id> child = 1 } text = "on"
  ENDIF
ENDSCRIPT

SCRIPT preview_music_track
  GetTags
  IF not TrackEnabled <index>
    ChangeTrackState <index> on
    SetScreenElementProps id = { <id> child = 1 } text = "on"
  ENDIF
  IF MusicIsPaused
    PauseMusic 0
    StopMusic
    Wait 0.5 second
    GetValueFromVolume cdvol
    IF ( <value> = 0 )
      SetCDToMusic
      SetMusicVolume 50
    ENDIF
    PlayTrack <index>
  ELSE
    PauseMusic 1
  ENDIF
ENDSCRIPT

SCRIPT playlist_menu_focus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  SetScreenElementProps { id = { <id> child = 1 } rgba = [ 128 118 0 128 ] }
  SetScreenElementProps { id = { <id> child = 2 } rgba = [ 128 128 128 50 ] }
  gap_vmenu:GetTags
  IF GotParam arrow_id
    menu_vert_blink_arrow { id = <arrow_id> }
  ENDIF
  generic_menu_update_arrows menu_id = gap_vmenu up_arrow_id = view_gaps_menu_up_arrow down_arrow_id = view_gaps_menu_down_arrow
ENDSCRIPT

SCRIPT playlist_menu_unfocus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_down
  RunScriptOnScreenElement id = { <id> child = 1 } do_scale_down
  SetScreenElementProps { id = { <id> child = 2 } rgba = [ 128 128 128 0 ] }
  PauseMusic 1
ENDSCRIPT

SCRIPT menu_music_level_focus
  PauseMusic 0
  menu_sound_level_focus { music_level <...> }
ENDSCRIPT

SCRIPT menu_music_level_unfocus
  menu_sound_level_unfocus <...>
  PauseMusic 1
ENDSCRIPT

SCRIPT skip_track_focus
  PauseMusic 0
  main_menu_focus <...>
ENDSCRIPT

SCRIPT skip_track_unfocus
  main_menu_unfocus <...>
  PauseMusic 1
ENDSCRIPT

SCRIPT menu_sound_level_focus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  RunScriptOnScreenElement id = { <id> child = 2 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  SetScreenElementProps { id = { <id> child = 1 } rgba = [ 128 128 128 50 ] }
  IF GotParam music_level
    GetValueFromVolume cdvol
  ELSE
    GetValueFromVolume sfxvol
  ENDIF
  IF ( <value> = 0 )
    SetScreenElementProps { id = { <id> child = 3 } rgba = [ 128 128 128 0 ] }
  ELSE
    SetScreenElementProps { id = { <id> child = 3 } rgba = [ 128 128 128 85 ] }
  ENDIF
  IF ( <value> = 10 )
    SetScreenElementProps { id = { <id> child = 4 } rgba = [ 128 128 128 0 ] }
  ELSE
    SetScreenElementProps { id = { <id> child = 4 } rgba = [ 128 128 128 85 ] }
  ENDIF
ENDSCRIPT

SCRIPT menu_sound_level_unfocus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_down
  RunScriptOnScreenElement id = { <id> child = 2 } do_scale_down
  SetScreenElementProps { id = { <id> child = 1 } rgba = [ 128 128 128 0 ] }
  SetScreenElementProps { id = { <id> child = 3 } rgba = [ 128 128 128 0 ] }
  SetScreenElementProps { id = { <id> child = 4 } rgba = [ 128 128 128 0 ] }
ENDSCRIPT

SCRIPT menu_turn_music_down
  GetTags
  GetValueFromVolume cdvol
  IF ( <value> > 0 )
    SetScreenElementProps id = { <id> child = 4 } rgba = [ 128 128 128 128 ]
     <value> = ( <value> - 1 )
    sound_options_set_level level = <value> id = menu_music_level type = cdvol
    menu_horiz_blink_arrow arrow_id = { <id> child = 3 }
  ENDIF
  IF ( <value> = 0 )
    SetScreenElementProps id = { <id> child = 3 } rgba = [ 128 128 128 0 ]
    SetCDToAmbience
    Printf "SetCDToAmbience"
  ENDIF
ENDSCRIPT

SCRIPT menu_turn_music_up
  GetTags
  GetValueFromVolume cdvol
  IF ( <value> < 10 )
    SetScreenElementProps id = { <id> child = 3 } rgba = [ 128 128 128 128 ]
     <value> = ( <value> + 1 )
    sound_options_set_level level = <value> id = menu_music_level type = cdvol
    menu_horiz_blink_arrow arrow_id = { <id> child = 4 }
  ENDIF
  IF ( <value> = 10 )
    SetScreenElementProps id = { <id> child = 4 } rgba = [ 128 128 128 0 ]
  ENDIF
  IF ( <value> = 1 )
    SetCDToMusic
    Printf "SetCDToMusic"
  ENDIF
ENDSCRIPT

SCRIPT menu_turn_sound_down
  GetTags
  GetValueFromVolume sfxvol
  IF ( <value> > 0 )
    SetScreenElementProps id = { <id> child = 4 } rgba = [ 128 128 128 128 ]
     <value> = ( <value> - 1 )
    sound_options_set_level level = <value> id = menu_sound_level type = sfxvol
    menu_horiz_blink_arrow arrow_id = { <id> child = 3 }
    PlaySound ollieconc vol = 70
  ENDIF
  IF ( <value> = 0 )
    SetScreenElementProps id = { <id> child = 3 } rgba = [ 128 128 128 0 ]
  ENDIF
ENDSCRIPT

SCRIPT menu_turn_sound_up
  GetTags
  GetValueFromVolume sfxvol
  IF ( <value> < 10 )
    SetScreenElementProps id = { <id> child = 3 } rgba = [ 128 128 128 128 ]
     <value> = ( <value> + 1 )
    sound_options_set_level level = <value> id = menu_sound_level type = sfxvol
    menu_horiz_blink_arrow arrow_id = { <id> child = 4 }
    PlaySound ollieconc vol = 70
  ENDIF
  IF ( <value> = 10 )
    SetScreenElementProps id = { <id> child = 4 } rgba = [ 128 128 128 0 ]
  ENDIF
ENDSCRIPT

SCRIPT sound_options_set_level
  FormatText TextName = vol "%v" v = <level>
  SetScreenElementProps {
    id = { <id> child = 2 }
    text = <vol>
  }
   <level> = ( <level> * 10 )
  SWITCH <type>
  CASE cdvol
    SetMusicVolume <level>
  CASE sfxvol
    SetSfxVolume <level>
  ENDSWITCH
ENDSCRIPT

SCRIPT focus_skip_track
  do_scale_up
  PauseMusic 0
ENDSCRIPT

SCRIPT unfocus_skip_track
  do_scale_down
  PauseMusic 1
ENDSCRIPT

SCRIPT skip_track
  skiptrack
  pulse_item
ENDSCRIPT

SCRIPT pulse_item
  DoMorph time = 0.05 scale = 0.9
  DoMorph time = 0.05 scale = 1.0
ENDSCRIPT

SCRIPT change_music_mode
  DoMorph time = 0.1 scale = 0.9
  DoMorph time = 0.1 scale = 1.2
  DoMorph time = 0.1 scale = 1
  IF IsTrue ALWAYSPLAYMUSIC
    Change ALWAYSPLAYMUSIC = 0
    SetScreenElementProps text = "Music Mode: Goals Only" id = menu_change_musicmode
  ELSE
    Change ALWAYSPLAYMUSIC = 1
    SetScreenElementProps text = "Music Mode: Always On" id = menu_change_musicmode
  ENDIF
ENDSCRIPT

SCRIPT create_controller_config_menu
  remove_pause_menu_textures_from_vram
  add_ss_menu_textures_to_vram
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 frame
  ENDIF
  IF GotParam controller_number
    FormatText TextName = menu_title "PLAYER %n" n = <controller_number>
    helper_text = { helper_text_elements = [ { text = "\b7/\b4 = Select" }
        { text = "\b6/\b5 = Adjust" }
        { text = "\m1 = Back" }
        { text = "\m0 = Accept" }
      ]
    }
  ELSE
    menu_title = "CONTROL SETUP"
    helper_text = { helper_text_elements = [ { text = "\b7/\b4 = Select" }
        { text = "\m1 = Back" }
        { text = "\m0 = Accept" }
      ]
    }
  ENDIF
  make_new_skateshop_menu {
    internal_just = [ left center ]
    menu_id = sound_options_menu
    vmenu_id = sound_options_vmenu
    menu_title = <menu_title>
    helper_text = <helper_text>
  }
  kill_start_key_binding
  delta_pos = (100, 25)
  IF GotParam controller_number
    middle_repeat = 4
    box_right_scale = (0.8, 0.435)
  ELSE
    IF IsXBOX
      middle_repeat = 6
      box_right_scale = (0.8, 0.555)
    ELSE
      middle_repeat = 3
      box_right_scale = (0.8, 0.375)
    ENDIF
  ENDIF
  GetStackedScreenElementPos X id = current_menu_anchor
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = sound_options_bg
    texture = options_bg
    draw_behind_parent
    pos = ( (232, 88) + <delta_pos> )
    scale = (1.17, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 2
  }
  GetStackedScreenElementPos X id = sound_options_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = ( (230, 100) + <delta_pos> )
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT <middle_repeat>
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (0.96, 1)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-20, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = <box_right_scale>
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = sound_options_bg
  create_icon texture = PA_controls pos = ( (80, 88) + <delta_pos> )
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu
    texture = stats_notch
    rgba = [ 42 48 77 0 ]
    scale = (14, 0.2)
    not_focusable
  }
  IF IsNGC
     <vibration_text> = "Rumble"
  ELSE
     <vibration_text> = "Vibration  "
  ENDIF
  IF GotParam controller_number
    SetScreenElementProps { id = sound_options_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = create_controller_config_menu } }
      ]
    }
    main_menu_add_item { text = <vibration_text>
      id = menu_vibration
      focus_script = controller_config_focus
      unfocus_script = controller_config_unfocus
      pad_choose_script = nullscript
    }
    main_menu_add_item { text = "Autokick "
      id = menu_autokick
      focus_script = controller_config_focus
      unfocus_script = controller_config_unfocus
      pad_choose_script = nullscript
    }
    main_menu_add_item { text = "180 Spin Taps      "
      id = menu_spintaps
      focus_script = controller_config_focus
      unfocus_script = controller_config_unfocus
      pad_choose_script = nullscript
    }
    main_menu_add_item { text = "Done"
      id = menu_done
      pad_choose_script = generic_menu_pad_choose
      pad_choose_params = { callback = create_controller_config_menu }
    }
    control_config_show_values controller_number = <controller_number>
  ELSE
    SetScreenElementProps { id = sound_options_menu
      event_handlers = [
        { pad_back generic_menu_pad_back params = { callback = controller_config_exit } }
      ]
    }
    main_menu_add_item { text = "Player 1"
      id = menu_controller_1
      pad_choose_script = generic_menu_pad_choose
      pad_choose_params = { callback = create_controller_config_menu controller_number = 1 }
    }
    IF not IsDemo
      main_menu_add_item { text = "Player 2"
        id = menu_controller_2
        pad_choose_script = generic_menu_pad_choose
        pad_choose_params = { callback = create_controller_config_menu controller_number = 2 }
      }
    ENDIF
    main_menu_add_item { text = "Done"
      id = menu_done
      pad_choose_script = generic_menu_pad_choose
      pad_choose_params = { callback = controller_config_exit }
    }
  ENDIF
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT controller_config_exit
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  remove_ss_menu_textures_from_vram
  IF GotParam from_options
    add_pause_menu_textures_to_vram
    create_options_menu
  ELSE
    create_setup_options_menu
  ENDIF
ENDSCRIPT

SCRIPT control_change_values
  player = ( <controller_number> - 1 )
  IF GotParam vibration
    KillSpawnedScript name = control_menu_vibrate_controller
    VibrateController port = <player> actuator = 1 percent = 0
    IF VibrationIsOn <player>
      VibrationOff <player>
      SetScreenElementProps id = menu_vibration_value text = "off"
    ELSE
      VibrationOn <player> pulse
      SetScreenElementProps id = menu_vibration_value text = "on"
      SpawnScript control_menu_vibrate_controller params = <...>
    ENDIF
  ENDIF
  IF GotParam autokick
    IF AutoKickIsOn <player>
      AutoKickOff <player>
      SetScreenElementProps id = menu_autokick_value text = "off"
    ELSE
      AutoKickOn <player>
      SetScreenElementProps id = menu_autokick_value text = "on"
    ENDIF
  ENDIF
  IF GotParam spintaps
    IF SpinTapsAreOn <player>
      SpinTapsOff <player>
      SetScreenElementProps id = menu_spintaps_value text = "off"
    ELSE
      SpinTapsOn <player>
      SetScreenElementProps id = menu_spintaps_value text = "on"
    ENDIF
  ENDIF
  GetTags
  IF GotParam left
    RunScriptOnScreenElement id = { <id> child = 3 } menu_blink_arrow
  ELSE
    RunScriptOnScreenElement id = { <id> child = 4 } menu_blink_arrow
  ENDIF
  generic_menu_pad_choose_sound
ENDSCRIPT

SCRIPT control_menu_vibrate_controller
  VibrateController port = <player> actuator = 1 percent = 70
  Wait 250
  VibrateController port = <player> actuator = 1 percent = 0
ENDSCRIPT

SCRIPT control_config_show_values
  player = ( <controller_number> - 1 )
  IF VibrationIsOn <player>
    vibration_value = "on"
  ELSE
    vibration_value = "off"
  ENDIF
  IF AutoKickIsOn <player>
    autokick_value = "on"
  ELSE
    autokick_value = "off"
  ENDIF
  IF SpinTapsAreOn <player>
    spintaps_value = "on"
  ELSE
    spintaps_value = "off"
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = menu_vibration
    id = menu_vibration_value
    font = small
    just = [ center top ]
    pos = (183, -17)
    text = <vibration_value>
    rgba = [ 88 105 112 128 ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_vibration
    texture = left_arrow
    rgba = [ 128 128 128 0 ]
    pos = (162, -17)
    just = [ right top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_vibration
    texture = right_arrow
    rgba = [ 128 128 128 0 ]
    pos = (200, -17)
    just = [ left top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = TextElement
    parent = menu_autokick
    id = menu_autokick_value
    font = small
    just = [ center top ]
    pos = (183, -17)
    text = <autokick_value>
    rgba = [ 88 105 112 128 ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_autokick
    texture = left_arrow
    rgba = [ 128 128 128 0 ]
    pos = (162, -17)
    just = [ right top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_autokick
    texture = right_arrow
    rgba = [ 128 128 128 0 ]
    pos = (200, -17)
    just = [ left top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = TextElement
    parent = menu_spintaps
    id = menu_spintaps_value
    font = small
    just = [ center top ]
    pos = (183, -17)
    text = <spintaps_value>
    rgba = [ 88 105 112 128 ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_spintaps
    texture = left_arrow
    rgba = [ 128 128 128 0 ]
    pos = (162, -17)
    just = [ right top ]
    scale = 0.75
  }
  CreateScreenElement {
    type = SpriteElement
    parent = menu_spintaps
    texture = right_arrow
    rgba = [ 128 128 128 0 ]
    pos = (200, -17)
    just = [ left top ]
    scale = 0.75
  }
  SetScreenElementProps {
    id = menu_vibration
    event_handlers = [ { pad_left control_change_values params = { vibration controller_number = <controller_number> left } }
      { pad_right control_change_values params = { vibration controller_number = <controller_number> } }
    ]
    replace_handlers
  }
  SetScreenElementProps {
    id = menu_autokick
    event_handlers = [ { pad_left control_change_values params = { autokick controller_number = <controller_number> left } }
      { pad_right control_change_values params = { autokick controller_number = <controller_number> } }
    ]
    replace_handlers
  }
  SetScreenElementProps {
    id = menu_spintaps
    event_handlers = [ { pad_left control_change_values params = { spintaps controller_number = <controller_number> left } }
      { pad_right control_change_values params = { spintaps controller_number = <controller_number> } }
    ]
    replace_handlers
  }
ENDSCRIPT

SCRIPT controller_config_focus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  RunScriptOnScreenElement id = { <id> child = 2 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  SetScreenElementProps { id = { <id> child = 1 } rgba = [ 128 128 128 50 ] }
  SetScreenElementProps { id = { <id> child = 3 } rgba = [ 128 128 128 85 ] }
  SetScreenElementProps { id = { <id> child = 4 } rgba = [ 128 128 128 85 ] }
ENDSCRIPT

SCRIPT controller_config_unfocus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_down
  RunScriptOnScreenElement id = { <id> child = 2 } do_scale_down
  SetScreenElementProps { id = { <id> child = 1 } rgba = [ 128 128 128 0 ] }
  SetScreenElementProps { id = { <id> child = 3 } rgba = [ 128 128 128 0 ] }
  SetScreenElementProps { id = { <id> child = 4 } rgba = [ 128 128 128 0 ] }
ENDSCRIPT

SCRIPT create_movies_menu
  remove_pause_menu_textures_from_vram
  add_ss_menu_textures_to_vram
  pulse_blur
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 frame
  ENDIF
  make_new_skateshop_menu {
    internal_just = [ left center ]
    menu_id = movies_menu
    vmenu_id = movies_vmenu
    type = VScrollingMenu
    dims = (300, 298)
    menu_title = "MOVIES"
    pos = (230, 82)
    scrolling_menu_id = movies_scrolling_vmenu
    dont_allow_wrap = dont_allow_wrap
    helper_text = { helper_text_elements = [ { text = "\b7/\b4 = Select" }
        { text = "\m1 = Back" }
        { text = "\m0 = Accept" }
      ]
    }
  }
  kill_start_key_binding
  delta_pos = (100, -56)
  middle_repeat = 19
  box_right_scale = (0.8, 1.37)
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "MOVIES"
    scale = 1.4
    pos = (230, 35)
    just = [ left top ]
    rgba = [ 128 128 128 98 ]
    not_focusable
  }
  GetStackedScreenElementPos X id = current_menu_anchor
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = movies_bg
    texture = options_bg
    draw_behind_parent
    pos = ( (232, 88) + <delta_pos> )
    scale = (1.17, 1.1)
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 2
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = movie_up_arrow
    texture = up_arrow
    pos = ( (227, 118) + <delta_pos> )
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 4
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = movie_down_arrow
    texture = down_arrow
    pos = ( (227, 432) + <delta_pos> )
    just = [ center top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 4
  }
  GetStackedScreenElementPos X id = movies_bg
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = main_menu_box_top
    texture = level_top_piece
    pos = ( (230, 100) + <delta_pos> )
    rgba = [ 128 128 128 80 ]
    scale = <scale>
    just = [ center top ]
  }
  BEGIN
    GetStackedScreenElementPos Y id = <id>
    CreateScreenElement {
      type = SpriteElement
      parent = current_menu_anchor
      texture = level_repeat_mid
      pos = <pos>
      scale = <scale>
      rgba = [ 128 128 128 80 ]
      just = [ left top ]
    }
  REPEAT <middle_repeat>
  GetStackedScreenElementPos Y id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = level_bottom_piece
    pos = <pos>
    rgba = [ 128 128 128 80 ]
    scale = (0.96, 1)
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = main_menu_box_top offset = (-20, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    scale = <box_right_scale>
    rgba = [ 128 128 128 80 ]
    pos = <pos>
    just = [ left top ]
  }
  GetStackedScreenElementPos X id = movies_bg
  create_icon texture = PA_movie pos = ( (80, 88) + <delta_pos> ) z_priority = 4
  SetScreenElementProps { id = movies_menu
    event_handlers = [
      { pad_back generic_menu_pad_back params = { callback = controller_config_exit } }
    ]
  }
  SetScreenElementProps { id = movies_vmenu
    event_handlers = [
      { pad_down menu_vert_blink_arrow params = { id = movie_down_arrow } }
      { pad_up menu_vert_blink_arrow params = { id = movie_up_arrow } }
    ]
  }
  GetArraySize movie_info
  index = 0
  BEGIN
    IF GetGlobalFlag flag = ( ( movie_info [ <index> ] ).flag )
      main_menu_add_item { text = ( ( movie_info [ <index> ] ).name )
        pad_choose_script = movie_menu_play_movie
        pad_choose_params = { movie_file = ( ( movie_info [ <index> ] ).file ) }
        focus_script = movie_menu_focus
      }
    ELSE
      main_menu_add_item { text = ( ( movie_info [ <index> ] ).name )
        pad_choose_script = nullscript
        not_focusable = not_focusable
      }
    ENDIF
     <index> = ( <index> + 1 )
  REPEAT <array_size>
  main_menu_add_item { text = "Done"
    id = menu_done
    pad_choose_script = generic_menu_pad_choose
    pad_choose_params = { callback = controller_config_exit }
    focus_script = movie_menu_focus
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = movie_black_box
    texture = black
    pos = (320, 240)
    rgba = [ 0 0 0 128 ]
    scale = (0, 0)
    just = [ center center ]
    z_priority = 5
  }
  KillSkaterCamAnim all
  PlaySkaterCamAnim name = SS_menucam_movies play_hold
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT movie_menu_play_movie
  IF ObjectExists id = movie_black_box
    RunScriptOnScreenElement id = movie_black_box animate_movie_in
    Wait 0.21 seconds
  ENDIF
  UnloadPreFile "skaterparts.pre"
  MemPushContext 0
  PlayMovie <movie_file>
  MemPopContext
  DumpHeaps
  LoadPreFile "skaterparts.pre"
  IF ObjectExists id = movie_black_box
    RunScriptOnScreenElement id = movie_black_box animate_movie_out
  ENDIF
ENDSCRIPT

SCRIPT animate_movie_in
  SetButtonEventMappings block_menu_input
  SetScreenElementProps id = root_window tags = { menu_state = entering }
  DoMorph time = 0 scale = 190 alpha = 0
  DoMorph time = 0.07 scale = 190 alpha = 0.33
  DoMorph time = 0.07 scale = 190 alpha = 0.66
  DoMorph time = 0.07 scale = 190 alpha = 1
  SetScreenElementProps id = root_window tags = { menu_state = on }
  SetButtonEventMappings unblock_menu_input
ENDSCRIPT

SCRIPT animate_movie_out
  GetTags
  SetButtonEventMappings block_menu_input
  SetScreenElementProps id = root_window tags = { menu_state = entering }
  DoMorph time = 0 scale = 190 alpha = 1
  DoMorph time = 0.07 scale = 190 alpha = 0.66
  DoMorph time = 0.07 scale = 190 alpha = 0.33
  DoMorph time = 0.07 scale = 190 alpha = 0
  SetScreenElementProps id = root_window tags = { menu_state = on }
  SetButtonEventMappings unblock_menu_input
ENDSCRIPT

SCRIPT movie_menu_focus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up params = { rgba = [ 128 118 0 128 ] }
  generic_menu_update_arrows {
    up_arrow_id = movie_up_arrow
    down_arrow_id = movie_down_arrow
  }
  SetScreenElementProps {
    id = { <id> child = 1 }
    rgba = [ 128 128 128 50 ]
  }
ENDSCRIPT
movie_info = [
  { name = "Neversoft Logo" file = "movies\nslogo" flag = LEVEL_UNLOCKED_SCH first_name = "" }
  { name = "Activision Logo" file = "movies\atvi" flag = LEVEL_UNLOCKED_SCH first_name = "" }
  { name = "THPS4 Intro" file = "movies\intro" flag = LEVEL_UNLOCKED_SCH first_name = "" }
  { name = "Tony Hawk" file = "movies\hawk" flag = MOVIE_UNLOCKED_HAWK first_name = "Tony" }
  { name = "Bob Burnquist" file = "movies\burnq" flag = MOVIE_UNLOCKED_BURNQUIST first_name = "Bob" }
  { name = "Steve Caballero" file = "movies\cab" flag = MOVIE_UNLOCKED_CABALLERO first_name = "Steve" }
  { name = "Kareem Campbell" file = "movies\campbell" flag = MOVIE_UNLOCKED_CAMPBELL first_name = "Kareem" }
  { name = "Rune Glifberg" file = "movies\glifberg" flag = MOVIE_UNLOCKED_GLIFBERG first_name = "Rune" }
  { name = "Eric Koston" file = "movies\koston" flag = MOVIE_UNLOCKED_KOSTON first_name = "Eric" }
  { name = "Bucky Lasek" file = "movies\lasek" flag = MOVIE_UNLOCKED_LASEK first_name = "Bucky" }
  { name = "Bam Margera" file = "movies\margera" flag = MOVIE_UNLOCKED_MARGERA first_name = "Bam" }
  { name = "Rodney Mullen" file = "movies\mullen" flag = MOVIE_UNLOCKED_MULLEN first_name = "Rodney" }
  { name = "Chad Muska" file = "movies\muska" flag = MOVIE_UNLOCKED_MUSKA first_name = "Chad" }
  { name = "Andrew Reynolds" file = "movies\reynolds" flag = MOVIE_UNLOCKED_REYNOLDS first_name = "Andrew" }
  { name = "Geoff Rowley" file = "movies\rowley" flag = MOVIE_UNLOCKED_ROWLEY first_name = "Geoff" }
  { name = "Elissa Steamer" file = "movies\steamer" flag = MOVIE_UNLOCKED_STEAMER first_name = "Elissa" }
  { name = "Jamie Thomas" file = "movies\thomas" flag = MOVIE_UNLOCKED_THOMAS first_name = "Jamie" }
  { name = "Pro Bails 1" file = "movies\probails" flag = MOVIE_UNLOCKED_CAS first_name = "custom" }
  { name = "Pro Bails 2" file = "movies\bails2" flag = MOVIE_UNLOCKED_BAILS2 first_name = "" }
  { name = "Homies Skatin' 1" file = "movies\homiesp1" flag = MOVIE_UNLOCKED_HOMIES1 first_name = "" }
  { name = "Homies Skatin' 2" file = "movies\homiesp2" flag = MOVIE_UNLOCKED_HOMIES2 first_name = "" }
  { name = "Kona Old School" file = "movies\kona" flag = MOVIE_UNLOCKED_KONA first_name = "" }
  { name = "Outtakes" file = "movies\outtakes" flag = MOVIE_UNLOCKED_OUTTAKES first_name = "" }
]

SCRIPT create_view_goals_menu
  GoalManager_HidePoints
  GoalManager_HideGoalPoints
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 gameframe
    remove_pause_menu_textures_from_vram
  ENDIF
  view_goals_menu_add_textures_to_vram
  make_new_menu {
    menu_id = view_goals_menu
    vmenu_id = view_goals_vmenu
    type = VScrollingMenu
    dims = (600, 288)
    padding_scale = 0.6
    pos = (90, 69)
    helper_text = { helper_text_elements = [ { text = "\b7/\b4 = Select" }
        { text = "\m1 = Back" }
        { text = "\m0 = Jump to Goal (if unlocked)" }
      ]
    }
  }
  SetScreenElementProps {
    id = view_goals_vmenu
    dont_allow_wrap
    event_handlers = [ { pad_down menu_vert_blink_arrow params = { id = view_goals_menu_down_arrow } }
      { pad_up menu_vert_blink_arrow params = { id = view_goals_menu_up_arrow } }
    ]
  }
  SetScreenElementProps { id = view_goals_menu
    event_handlers = [
      { pad_back view_goals_menu_exit params = { callback = create_pause_menu } }
    ]
  }
  GoalManager_AddViewGoalsList
   <root_pos> = (190, 23)
  set_sub_bg_goal {
    pos = <root_pos>
    goal_mid_scale = (19, 1.33)
    goal_end_scale = (1, 1.33)
  }
  create_icon texture = PA_view pos = (47, 21)
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "VIEW GOALS"
    rgba = [ 128 128 128 85 ]
    scale = 1.4
    pos = (93, 23)
    just = [ left top ]
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    pos = ( <root_pos> + (-110, 30) )
    just = [ left top ]
    rgba = [ 0 0 0 85 ]
    scale = (124, 7)
    z_priority = 2
  }
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = dialog
    text = "Goal"
    rgba = [ 127 102 0 100 ]
    scale = 0.9
    pos = ( <root_pos> + (-100, 35) )
    just = [ left top ]
    z_priority = 3
  }
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = dialog
    text = "Record"
    rgba = [ 127 102 0 100 ]
    scale = 0.9
    pos = ( <root_pos> + (259, 35) )
    just = [ left top ]
    z_priority = 3
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_goals_menu_up_arrow
    texture = up_arrow
    pos = ( <root_pos> + (119, 35) )
    just = [ left top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 3
  }
  GetScreenElementPosition id = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = view_goals_menu_down_arrow
    texture = down_arrow
    pos = ( <root_pos> + (119, 345) )
    just = [ left top ]
    rgba = [ 128 128 128 128 ]
    z_priority = 3
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    pos = ( <root_pos> + (-110, 340) )
    just = [ left top ]
    rgba = [ 0 0 0 85 ]
    scale = (124, 7)
    z_priority = 2
  }
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    scale = (2, 70.5)
    rgba = [ 0 0 0 80 ]
    pos = ( <root_pos> + (250, 58) )
    just = [ left top ]
  }
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT view_goals_menu_add_item
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    id = <goal_id>
    dims = (500, 24)
  }
  CreateScreenElement {
    type = TextElement
    parent = <goal_id>
    text = <text>
    font = dialog
    scale = 0.75
    pos = (0, 0)
    just = [ left top ]
  }
  IF GoalManager_HasWonGoal name = <goal_id>
    IF not GotParam win_record_string
       <win_record_string> = "N/A"
    ENDIF
    CreateScreenElement {
      type = TextElement
      parent = <goal_id>
      font = small
      text = <win_record_string>
      scale = 0.7
      pos = (420, 0)
      just = [ center top ]
    }
     <goal_id>:SetTags win_record
  ENDIF
  IF GoalManager_HasWonGoal name = <goal_id>
    view_goals_menu_set_color id = <goal_id> rgba = [ 25 83 67 128 ]
    SetScreenElementProps {
      id = <goal_id>
      event_handlers = [
        { focus view_goals_menu_focus_beaten }
        { unfocus view_goals_menu_unfocus_beaten }
        { pad_choose view_goals_menu_start_beaten_goal params = { goal_id = <goal_id> } }
        { pad_start view_goals_menu_start_beaten_goal params = { goal_id = <goal_id> } }
        { pad_choose generic_menu_pad_choose_sound }
      ]
    }
    GetScreenElementDims id = { <goal_id> child = 0 }
    CreateScreenElement {
      type = SpriteElement
      parent = { <goal_id> child = 0 }
      texture = goal_line
      pos = (-10, 13)
      just = [ left center ]
      rgba = [ 128 128 128 128 ]
      scale = ( ( (1, 0) * ( <width> * 1.38 ) / 32 ) + (0.3, 0.4) )
    }
  ELSE
    IF GoalManager_GoalIsLocked name = <goal_id>
      IF IsTrue bootstrap_build
         <locked_text> = "NOT IN DEMO"
      ELSE
        GoalManager_GetGoalParams name = <goal_id>
        IF GotParam pro_goal
           <locked_text> = "Complete Pro Challenge to unlock"
        ELSE
           <locked_text> = "Locked"
        ENDIF
      ENDIF
      view_goals_menu_set_color {
        id = <goal_id>
        rgba = [ 42 42 38 128 ]
        text = <locked_text>
      }
      SetScreenElementProps {
        id = <goal_id>
        event_handlers = [
          { focus view_goals_menu_focus_locked }
          { unfocus view_goals_menu_unfocus_locked }
          { pad_choose view_goals_menu_pad_choose_locked }
          { pad_start view_goals_menu_pad_choose_locked }
        ]
        replace_handlers
      }
    ELSE
      IF GoalManager_HasSeenGoal name = <goal_id>
        view_goals_menu_set_color {
          id = <goal_id>
          rgba = [ 88 105 112 128 ]
        }
        SetScreenElementProps {
          id = <goal_id>
          event_handlers = [
            { focus view_goals_menu_focus_unlocked params = { goal_id = <goal_id> } }
            { unfocus view_goals_menu_unfocus_unlocked params = { goal_id = <goal_id> } }
            { pad_choose view_goals_menu_start_goal params = { goal_id = <goal_id> } }
            { pad_start view_goals_menu_start_goal params = { goal_id = <goal_id> } }
          ]
          replace_handlers
        }
      ELSE
        view_goals_menu_set_color {
          id = <goal_id>
          rgba = [ 42 42 38 128 ]
          text = "??????????"
        }
        SetScreenElementProps {
          id = <goal_id>
          event_handlers = [
            { focus view_goals_menu_focus_locked params = { goal_id = <goal_id> } }
            { unfocus view_goals_menu_unfocus_locked params = { goal_id = <goal_id> } }
            { pad_choose view_goals_menu_pad_choose_locked }
            { pad_start view_goals_menu_pad_choose_locked }
          ]
          replace_handlers
        }
      ENDIF
    ENDIF
  ENDIF
ENDSCRIPT

SCRIPT view_goals_menu_set_color
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = <rgba>
    text = <text>
  }
   <id>:GetTags
  IF GotParam win_record
    SetScreenElementProps {
      id = { <id> child = 1 }
      rgba = <rgba>
      scale = <scale>
    }
  ENDIF
ENDSCRIPT

SCRIPT view_goals_menu_focus_locked
  generic_menu_update_arrows {
    menu_id = view_goals_vmenu
    up_arrow_id = view_goals_menu_up_arrow
    down_arrow_id = view_goals_menu_down_arrow
  }
  GetTags
  view_goals_menu_set_color id = <id> rgba = [ 67 62 58 128 ]
  RunScriptOnScreenElement id = { <id> child = 0 } do_random_effect
  IF GotParam goal_id
    view_goals_menu_play_preview_cam <...>
  ENDIF
ENDSCRIPT

SCRIPT view_goals_menu_unfocus_locked
  GetTags
  generic_menu_pad_up_down_sound
  KillSpawnedScript name = do_random_effect
  view_goals_menu_set_color id = <id> rgba = [ 47 42 38 128 ]
  IF GotParam goal_id
    view_goals_menu_kill_preview_cam <...>
  ENDIF
ENDSCRIPT

SCRIPT view_goals_menu_focus_unlocked
  generic_menu_update_arrows {
    menu_id = view_goals_vmenu
    up_arrow_id = view_goals_menu_up_arrow
    down_arrow_id = view_goals_menu_down_arrow
  }
  GetTags
  view_goals_menu_set_color id = <id> rgba = [ 127 102 0 128 ]
  RunScriptOnScreenElement id = { <id> child = 0 } do_random_effect
  view_goals_menu_play_preview_cam <...>
ENDSCRIPT

SCRIPT view_goals_menu_unfocus_unlocked
  GetTags
  generic_menu_pad_up_down_sound
  KillSpawnedScript name = do_random_effect
  view_goals_menu_set_color id = <id> rgba = [ 88 105 112 128 ]
  view_goals_menu_kill_preview_cam <...>
ENDSCRIPT

SCRIPT view_goals_menu_focus_beaten
  generic_menu_update_arrows {
    menu_id = view_goals_vmenu
    up_arrow_id = view_goals_menu_up_arrow
    down_arrow_id = view_goals_menu_down_arrow
  }
  GetTags
  view_goals_menu_set_color id = <id> rgba = [ 99 121 6 128 ]
  RunScriptOnScreenElement id = { <id> child = 0 } do_random_effect
ENDSCRIPT

SCRIPT view_goals_menu_unfocus_beaten
  GetTags
  generic_menu_pad_up_down_sound
  KillSpawnedScript name = do_random_effect
  view_goals_menu_set_color id = <id> rgba = [ 25 83 67 128 ]
ENDSCRIPT

SCRIPT view_goals_menu_pad_choose_locked
ENDSCRIPT

SCRIPT view_goals_menu_start_goal
  view_goals_menu_exit callback = exit_pause_menu
  GoalManager_DeactivateAllGoals
  goal_accept_trigger goal_id = <goal_id> force_start
ENDSCRIPT

SCRIPT view_goals_menu_start_beaten_goal
  view_goals_menu_exit callback = exit_pause_menu
  GoalManager_DeactivateAllGoals
  goal_accept_trigger goal_id = <goal_id> force_start
ENDSCRIPT

SCRIPT view_goals_menu_play_preview_cam
  GoalManager_GetGoalParams name = <goal_id>
  IF IsAlive name = <trigger_obj_id>
     <trigger_obj_id>:Obj_GetId
     <targetId> = <objId>
    GetSkaterID
    PlaySkaterCamAnim { name = <goal_id>
      skater = <objId>
      targetId = <targetId>
      targetOffset = (0, 45, 0)
      positionOffset = (10, 10, 90)
      frames = 120
      skippable = 0
      virtual_cam
      play_hold
    }
    SetSkaterCamAnimShouldPause name = <goal_id> should_pause = 0
  ENDIF
  view_goals_vmenu:SetTags current_cam_anim = <goal_id>
ENDSCRIPT

SCRIPT view_goals_menu_kill_preview_cam
  GetSkaterID
  KillSkaterCamAnim skater = <objId> name = <goal_id>
ENDSCRIPT

SCRIPT view_goals_menu_exit
  IF ScreenElementExists id = view_goals_vmenu
    view_goals_vmenu:GetTags
    IF GotParam current_cam_anim
      GetSkaterID
      KillSkaterCamAnim skater = <objId> name = <current_cam_anim>
    ENDIF
  ENDIF
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 gameframe
  ENDIF
  view_goals_menu_remove_textures_from_vram
  add_pause_menu_textures_to_vram
  GoalManager_ShowPoints
  IF not GoalManager_HasActiveGoals
    GoalManager_ShowGoalPoints
  ENDIF
   <callback>
ENDSCRIPT

SCRIPT view_goals_menu_add_textures_to_vram
  AddTextureToVram "PA_View"
  AddTextureToVram "goal_line"
  AddTextureToVram "up_arrow"
  AddTextureToVram "down_arrow"
  AddTextureToVram "goal_left"
  AddTextureToVram "goal_mid"
  AddTextureToVram "goal_right"
ENDSCRIPT

SCRIPT view_goals_menu_remove_textures_from_vram
  RemoveTextureFromVram "PA_View"
  RemoveTextureFromVram "goal_line"
  RemoveTextureFromVram "up_arrow"
  RemoveTextureFromVram "down_arrow"
  RemoveTextureFromVram "goal_left"
  RemoveTextureFromVram "goal_mid"
  RemoveTextureFromVram "goal_right"
ENDSCRIPT
stat_names = [ { name = air string = "Air" description = "Your jump height out of a half pipe" }
  { name = hangtime string = "Hangtime" description = "How long you stay in the air" }
  { name = ollie string = "Ollie" description = "How high you jump on flat ground" }
  { name = speed string = "Speed" description = "Your top speed on the ground" }
  { name = spin string = "Spin" description = "How fast you spin in the air" }
  { name = #"switch" string = "Switch" description = "When maxed out, you skate equally well switch and regular" }
  { name = flip_speed string = "Flip Speed" description = "How fast your flip tricks will turn" }
  { name = rail_balance string = "Rail Balance" description = "How well you balance on rails" }
  { name = lip_balance string = "Lip Balance" description = "How well you balance during lip trick stalls" }
  { name = manual_balance string = "Manual Balance" description = "How well you balance during manuals" }
]

SCRIPT create_stats_menu root_pos = (115, 35)
  GoalManager_HidePoints
  GoalManager_HideGoalPoints
  IF LevelIs load_skateshop
     <root_pos> = ( <root_pos> - (90, 0) )
  ENDIF
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  make_new_menu {
    menu_title = "STATS"
    pos = ( <root_pos> + (52, -5) )
    menu_id = stats_menu
    vmenu_id = stats_vmenu
    padding_scale = 1
    helper_text = { helper_text_elements = [ { text = "\b7/\b4 = Select" }
        { text = "\b5/\b6 = Change Stat" }
        { text = "\m1 = Back" }
        { text = "\m0 = Accept" }
      ]
    }
  }
  SetScreenElementProps {
    id = stats_vmenu
    event_handlers = [ { pad_up null_script }
      { pad_down null_script }
    ]
    replace_handlers
  }
  kill_start_key_binding
  create_icon texture = PA_fonts pos = <root_pos> id = stats_menu_icon
  SetScreenElementProps {
    id = stats_menu
    event_handlers = [ { pad_back generic_menu_pad_back_sound }
      { pad_back generic_menu_pad_back params = { callback = stats_menu_exit } }
    ]
    replace_handlers
  }
  GetStackedScreenElementPos X id = stats_menu_icon offset = (-33, 0)
  set_sub_bg pos = <pos> just = [ left top ]
  GetArraySize stat_names
   <index> = 0
  BEGIN
    stats_menu_add_item ( stat_names [ <index> ] ) <...> stats_parent = current_menu
     <index> = ( <index> + 1 )
  REPEAT <array_size>
  IF LevelIs load_skateshop
     <done_button_pad_choose_script> = launch_ss_menu
  ELSE
    IF not GotParam done_button_pad_choose_script
       <done_button_pad_choose_script> = create_options_menu
    ENDIF
  ENDIF
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    dims = (200, 40)
    event_handlers = [ { pad_choose generic_menu_pad_choose_sound }
      { pad_start generic_menu_pad_choose_sound }
      { pad_choose <done_button_pad_choose_script> }
      { pad_start <done_button_pad_choose_script> }
      { focus stats_menu_done_focus }
      { unfocus stats_menu_done_unfocus }
    ]
    z_priority = 10
  }
  CreateScreenElement {
    type = TextElement
    parent = <id>
    pos = (150, 20)
    rgba = [ 88 105 112 128 ]
    font = small
    text = "Done"
    scale = 0.85
  }
  GetStackedScreenElementPos X id = stats_menu_icon offset = (116, 268)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    id = done_bg_box
    texture = black
    z_priority = 0
    scale = (18, 5)
    pos = <pos>
    just = [ left top ]
    rgba = [ 0 0 0 90 ]
  }
  GetStackedScreenElementPos X id = done_bg_box offset = (0, 0)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    z_priority = 0
    scale = (0.6, 0.07)
    pos = <pos>
    just = [ center top ]
    rgba = [ 0 0 0 90 ]
  }
  GetStackedScreenElementPos X id = done_bg_box offset = (-35, 3)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = stats_notch
    pos = <pos>
    scale = (4.1, 1.1)
    just = [ center top ]
    rgba = [ 100 100 100 30 ]
  }
  GetCurrentSkaterProfileIndex
  GetNumStatPointsAvailable player = <currentSkaterProfileIndex>
  FormatText TextName = points_text "Points Available: %i" i = <points_available>
  GetStackedScreenElementPos X id = done_bg_box offset = (-30, 40)
  CreateScreenElement {
    type = TextElement
    id = stat_points_available
    parent = current_menu_anchor
    pos = <pos>
    rgba = [ 127 102 0 128 ]
    font = small
    text = <points_text>
    scale = 0.8
    not_focusable
  }
  GetStackedScreenElementPos X id = done_bg_box offset = (-35, 29)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = stats_notch
    pos = <pos>
    scale = (18, 1.5)
    just = [ center top ]
    rgba = [ 100 100 100 30 ]
  }
  GetStackedScreenElementPos X id = stats_menu_icon offset = (333, 24)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    pos = <pos>
    z_priority = 0
    scale = (1, 0.9)
    just = [ center top ]
    rgba = [ 128 128 128 90 ]
  }
  GetStackedScreenElementPos X id = done_bg_box offset = (-35, 25)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = black
    pos = <pos>
    draw_behind_parent
    scale = (75, 15)
    just = [ center top ]
    rgba = [ 0 0 0 98 ]
  }
  GetStackedScreenElementPos X id = done_bg_box offset = (115, 25)
  CreateScreenElement {
    type = SpriteElement
    parent = current_menu_anchor
    texture = goal_right
    pos = <pos>
    z_priority = 0
    scale = (0.8, 0.23)
    just = [ center top ]
    rgba = [ 128 128 128 90 ]
  }
  GetStackedScreenElementPos Y id = done_bg_box offset = (40, 25)
  CreateScreenElement {
    type = TextBlockElement
    parent = current_menu_anchor
    id = stat_point_description
    dims = (347, 0)
    pos = <pos>
    rgba = [ 37 84 136 80 ]
    font = dialog
    just = [ center top ]
    scale = 0.8
    text = ( ( stat_names [ 0 ] ).description )
    not_focusable
    allow_expansion
  }
  RunScriptOnScreenElement id = stats_menu animate_in
ENDSCRIPT

SCRIPT stats_menu_create_stats_block parent = current_menu scale = 1 pos = (180, 147)
  CreateScreenElement {
    type = ContainerElement
    parent = <parent>
    id = stats_block_anchor
    pos = <pos>
    just = [ left top ]
    dims = (640, 480)
    scale = <scale>
  }
   <stats_parent> = <id>
  GetArraySize stat_names
   <index> = 0
  BEGIN
    stats_menu_add_item ( stat_names [ <index> ] ) <...>
     <index> = ( <index> + 1 )
  REPEAT <array_size>
ENDSCRIPT

SCRIPT stats_menu_add_item z_priority = 2
  FormatText ChecksumName = row_id "stats_menu_names_%n" n = <name>
   <pos> = ( (0, 1) * ( 23 * ( <index> + 1 ) ) )
   <pos> = ( <pos> + (150, -12) )
  CreateScreenElement {
    type = ContainerElement
    parent = <stats_parent>
    id = <row_id>
    dims = (300, 23)
    pos = <pos>
    event_handlers = [
      { focus stats_menu_focus params = { name = <name> row_id = <row_id> description = <description> } }
      { unfocus stats_menu_unfocus params = { name = <name> row_id = <row_id> } }
      { pad_right stats_menu_change_stat params = { name = <name> row_id = <row_id> Change = 1 update_all_skaters = <update_all_skaters> } }
      { pad_left stats_menu_change_stat params = { name = <name> row_id = <row_id> Change = -1 update_all_skaters = <update_all_skaters> } }
      { pad_choose stats_menu_fire_pad_down params = { target = <stats_parent> } }
      { pad_start stats_menu_fire_pad_down params = { target = <stats_parent> } }
      { pad_choose generic_menu_pad_choose_sound }
      { pad_start generic_menu_pad_choose_sound }
    ]
  }
   <anchor_id> = <id>
  IF GotParam not_focusable
    SetScreenElementProps {
      id = <anchor_id>
      not_focusable
    }
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    rgba = [ 88 105 112 128 ]
    font = small
    text = <string>
    scale = 0.85
    z_priority = <z_priority>
    just = [ right top ]
    pos = (140, 0)
  }
   <x_pos> = 145
  BEGIN
    CreateScreenElement {
      type = SpriteElement
      parent = <row_id>
      texture = pip_on
      pos = ( (1, 0) * <x_pos> + (0, 3) )
      just = [ left top ]
      z_priority = ( <z_priority> - 1 )
    }
     <x_pos> = ( <x_pos> + 18 )
  REPEAT 10
  CreateScreenElement {
    type = SpriteElement
    parent = <anchor_id>
    texture = stats_bg
    pos = (-30, -5)
    scale = (1.4, 1.2)
    rgba = [ 128 128 128 100 ]
    just = [ left top ]
    z_priority = ( <z_priority> - 2 )
  }
  stats_menu_update_row <...>
ENDSCRIPT

SCRIPT stats_menu_fire_pad_down
  FireEvent type = pad_down target = <target>
ENDSCRIPT

SCRIPT stats_menu_update_row highlight_rgba = [ 75 75 75 128 ] locked_highlight_rgba = [ 95 75 75 128 ]
  IF IsTrue gary_debug
    IF GotParam skater_name
      script_assert "Get rid of skater name"
    ENDIF
  ENDIF
  GetStatValue <name>
  stats_menu_get_original_stat_value name = <name>
  IF GotParam not_focusable
     <highlight_rgba> = [ 128 128 128 128 ]
     <locked_highlight_rgba> = [ 128 75 75 128 ]
  ENDIF
   <child> = 1
  IF GotParam original_stat_value
    IF ( <original_stat_value> > 0 )
      IF ( <stat_value> > 0 )
        BEGIN
          SetScreenElementProps {
            id = { <row_id> child = <child> }
            rgba = <locked_highlight_rgba>
          }
           <child> = ( <child> + 1 )
        REPEAT <original_stat_value>
      ENDIF
       <stat_value> = ( <stat_value> - <original_stat_value> )
    ENDIF
  ENDIF
  IF ( <stat_value> > 0 )
    BEGIN
      SetScreenElementProps {
        id = { <row_id> child = <child> }
        rgba = <highlight_rgba>
      }
       <child> = ( <child> + 1 )
    REPEAT <stat_value>
  ENDIF
  BEGIN
    IF ( <child> < 11 )
      SetScreenElementProps {
        id = { <row_id> child = <child> }
        rgba = [ 40 40 40 70 ]
      }
       <child> = ( <child> + 1 )
    ELSE
      BREAK
    ENDIF
  REPEAT
ENDSCRIPT

SCRIPT stats_menu_get_original_stat_value
   <stat_name> = <name>
  IF GotParam skater_name
    GetSkaterProfileInfoByName name = <skater_name>
  ELSE
    GetCurrentSkaterProfileIndex
    GetSkaterProfileInfo player = <currentSkaterProfileIndex>
  ENDIF
  IF ( <name> = custom )
    RETURN original_stat_value = 0
  ENDIF
  GetArraySize master_skater_list
   <index> = 0
  BEGIN
    IF ( ( ( master_skater_list [ <index> ] ).name ) = <name> )
       <original_stat_value> = ( ( master_skater_list [ <index> ] ).<stat_name> )
      BREAK
    ENDIF
     <index> = ( <index> + 1 )
  REPEAT <array_size>
  IF not GotParam original_stat_value
    script_assert "couldn't find the stat!"
  ENDIF
  RETURN original_stat_value = <original_stat_value>
ENDSCRIPT

SCRIPT stats_menu_change_stat
  GetCurrentSkaterProfileIndex
  GetNumStatPointsAvailable player = <currentSkaterProfileIndex>
  GetStatValue <name>
  IF ( <Change> < 0 )
    IF ( <stat_value> < 1 )
      RETURN
    ENDIF
  ENDIF
  IF ( <Change> > 0 )
    IF ( <stat_value> > 9 )
      RETURN
    ENDIF
  ENDIF
  IF ( <points_available> < <Change> )
    RETURN
  ENDIF
  stats_menu_get_original_stat_value name = <name>
  IF ( ( <stat_value> + <Change> ) < <original_stat_value> )
    RETURN
  ENDIF
  PlaySound menu03 vol = 100
  AwardStatPoint ( <Change> * -1 )
  GetNumStatPointsAvailable player = <currentSkaterProfileIndex>
  FormatText TextName = points_text "Points Available: %i" i = <points_available>
  SetScreenElementProps {
    id = stat_points_available
    text = <points_text>
  }
   <stat_value> = ( <stat_value> + <Change> )
  SetSkaterProfileProperty player = <currentSkaterProfileIndex> <name> <stat_value>
  IF LevelIs load_skateshop
    UpdateSkaterStats player = 0
  ELSE
    UpdateSkaterStats player = <currentSkaterProfileIndex>
  ENDIF
  stats_menu_update_row name = <name> row_id = <row_id> highlight_rgba = [ 128 128 128 128 ] locked_highlight_rgba = [ 128 75 75 128 ]
  IF GotParam update_all_skaters
     <stat_name> = <name>
    GetSkaterProfileInfo player = <currentSkaterProfileIndex>
    ForEachSkaterProfile {
      do = stats_menu_change_other_skater_stats
      params = { Change = <Change>
        current_skater_name = <name>
        stat_name = <stat_name>
      }
    }
  ENDIF
ENDSCRIPT

SCRIPT stats_menu_focus
  stats_menu_update_row {
    name = <name>
    row_id = <row_id>
    highlight_rgba = [ 128 128 128 128 ]
    locked_highlight_rgba = [ 128 75 75 128 ]
  }
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up
  IF ObjectExists id = stat_point_description
    SetScreenElementProps {
      id = stat_point_description
      text = <description>
    }
  ENDIF
ENDSCRIPT

SCRIPT stats_menu_unfocus
  stats_menu_update_row name = <name> row_id = <row_id>
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_down
ENDSCRIPT

SCRIPT stats_menu_done_focus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_up
  IF ObjectExists id = stat_point_description
    SetScreenElementProps {
      id = stat_point_description
      text = ""
    }
  ENDIF
ENDSCRIPT

SCRIPT stats_menu_done_unfocus
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } do_scale_down
ENDSCRIPT

SCRIPT stats_menu_change_other_skater_stats
  IF ( <current_skater_name> = <name> )
    RETURN
  ENDIF
  IF ( <Change> < 0 )
    RETURN
  ENDIF
  IF ( <Change> > <points_available> )
    RETURN
  ENDIF
  GetStatValue skater = <name> <stat_name>
  IF ( <stat_value> = 10 )
    GetArraySize stat_names
     <index> = 0
    BEGIN
       <stat_name> = ( ( stat_names [ <index> ] ).name )
      GetStatValue skater = <name> <stat_name>
      IF ( <stat_value> < 10 )
        BREAK
      ENDIF
       <index> = ( <index> + 1 )
      IF ( <index> = <array_size> )
        RETURN
      ENDIF
    REPEAT <array_size>
  ENDIF
  SWITCH <stat_name>
  CASE air
    SetSkaterProfileInfoByName name = <name> params = { air = ( <stat_value> + <Change> ) }
  CASE hangtime
    SetSkaterProfileInfoByName name = <name> params = { hangtime = ( <stat_value> + <Change> ) }
  CASE ollie
    SetSkaterProfileInfoByName name = <name> params = { ollie = ( <stat_value> + <Change> ) }
  CASE speed
    SetSkaterProfileInfoByName name = <name> params = { speed = ( <stat_value> + <Change> ) }
  CASE spin
    SetSkaterProfileInfoByName name = <name> params = { spin = ( <stat_value> + <Change> ) }
  CASE #"switch"
    SetSkaterProfileInfoByName name = <name> params = { #"switch" = ( <stat_value> + <Change> ) }
  CASE flip_speed
    SetSkaterProfileInfoByName name = <name> params = { flip_speed = ( <stat_value> + <Change> ) }
  CASE rail_balance
    SetSkaterProfileInfoByName name = <name> params = { rail_balance = ( <stat_value> + <Change> ) }
  CASE lip_balance
    SetSkaterProfileInfoByName name = <name> params = { lip_balance = ( <stat_value> + <Change> ) }
  CASE manual_balance
    SetSkaterProfileInfoByName name = <name> params = { manual_balance = ( <stat_value> + <Change> ) }
  DEFAULT
    script_assert "bad stat name"
  ENDSWITCH
   <points_available> = ( <points_available> - <Change> )
  IF not SetSkaterProfileInfoByName name = <name> params = { points_available = <points_available> }
    Printf "############### couldn't change points available!"
  ENDIF
ENDSCRIPT

SCRIPT stats_menu_exit
  IF LevelIs load_skateshop
    launch_ss_menu
  ELSE
    GoalManager_ShowPoints
    IF not GoalManager_HasActiveGoals
      GoalManager_ShowGoalPoints
    ENDIF
    create_options_menu
  ENDIF
ENDSCRIPT

SCRIPT launch_gamemode_menu
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_gamemode_menu
ENDSCRIPT

SCRIPT create_gamemode_menu
  make_new_menu menu_id = gamemode_menu vmenu_id = gamemode_vmenu menu_title = "GAMEMODE" helper_text = generic_helper_text
  SetScreenElementProps { id = gamemode_menu
    event_handlers = [
      { pad_back create_options_menu }
    ]
  }
  make_text_sub_menu_item text = "Career Mode" id = gamemode_career_mode pad_choose_script = change_gamemode_career_menu
  make_text_sub_menu_item text = "Single Session" id = gamemode_single_session pad_choose_script = change_gamemode_singlesession_menu
  make_text_sub_menu_item text = "Free Skate" id = gamemode_free_skate pad_choose_script = change_gamemode_freeskate_menu
  make_text_sub_menu_item text = "Quickstart 2P" id = gamemode_quickstart_2p
  make_text_sub_menu_item text = "Quickstart Server" id = gamemode_quickstart_server
  make_text_sub_menu_item text = "Back" id = gamemode_back pad_choose_script = create_options_menu
  set_sub_bg
  create_icon texture = PA_mode
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT change_gamemode_career
  Printf "********** CHANGING GAME MODE TO CAREER"
  SetGameType career
  SetCurrentGameType
ENDSCRIPT

SCRIPT change_gamemode_net
  Printf "********** CHANGING GAME MODE TO NET!!!"
  SetGameType net
  SetCurrentGameType
ENDSCRIPT

SCRIPT change_gamemode_singlesession
  SetGameType singlesession
  SetCurrentGameType
ENDSCRIPT

SCRIPT change_gamemode_freeskate_2p
  SetGameType freeskate2p
  SetCurrentGameType
ENDSCRIPT

SCRIPT change_gamemode_freeskate
  SetGameType freeskate
  SetCurrentGameType
ENDSCRIPT

SCRIPT change_gamemode_career_menu
  exit_pause_menu
  SetGameType career
  SetCurrentGameType
  Retry
ENDSCRIPT

SCRIPT change_gamemode_singlesession_menu
  kill_all_panel_messages
  SetGameType singlesession
  SetCurrentGameType
  GoalManager_DeactivateAllGoals
  Change EndOfReplayShouldJumpToPauseMenu = 0
  Retry
ENDSCRIPT

SCRIPT change_gamemode_freeskate_menu
  exit_pause_menu
  SetGameType freeskate
  SetCurrentGameType
  Retry
ENDSCRIPT

SCRIPT create_statistics_menu { pad_back_script = statistics_menu_exit
    pad_choose_script = nullscript
  }
  GoalManager_HidePoints
  GoalManager_HideGoalPoints
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 frame
    remove_pause_menu_textures_from_vram
  ENDIF
  add_statistics_menu_textures_to_vram
  make_new_menu { menu_id = statistics_menu
    vmenu_id = statistics_vmenu
    menu_title = "STATISTICS"
    padding_scale = 1
    internal_scale = 1
    pos = (160, 43)
  }
  SetScreenElementProps {
    id = current_menu
    event_handlers = [ { pad_back <pad_back_script> params = <pad_back_params> }
      { pad_choose <pad_choose_script> params = <pad_choose_params> }
    ]
    replace_handlers
  }
  create_icon texture = pa_stats pos = (113, 43)
  set_sub_bg pos = (263, 45)
  statistics_menu_add_item text = "Total Score:" value = 24925596
  statistics_menu_add_item text = "High Score:" value = 24925596
  statistics_menu_add_item text = "Longest Grind:" value = 12.23 unit = "seconds"
  statistics_menu_add_item text = "Longest manual:" value = 30.28 unit = "seconds"
  statistics_menu_add_item text = "Longest Lip:" value = 23.45 unit = "seconds"
  statistics_menu_add_item text = "Longest Combo:" value = 6 unit = "tricks"
  statistics_menu_add_item text = "Best Combo:" value = 90000 unit = "points"
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    dims = (500, 70)
    not_focusable
  }
   <anchor_id> = <id>
  CreateScreenElement {
    type = SpriteElement
    parent = <anchor_id>
    texture = black
    pos = (-25, -5)
    just = [ left top ]
    scale = (100, 35)
    rgba = [ 0 0 0 70 ]
  }
   <text_block_scale> = 0.6
  CreateScreenElement {
    type = TextBlockElement
    parent = <anchor_id>
    font = newtrickfont
    dims = ( ( 1 / <text_block_scale> ) * (400, 140) )
    pos = (-25, 0)
    scale = <text_block_scale>
    rgba = [ 47 94 136 100 ]
    just = [ left top ]
    internal_just = [ center top ]
    text = [ "BS 50-50 + Pop Shove-It + Nose Manual + "
      "FS Boardslide + 360 360 Flip + Japan + "
      "The 900 + BS Nosegrind + some other trick "
      "+ whoa that was cool + you are so good + how long "
      " is this + almost fell + whatever "
      "FS Boardslide + 360 360 Flip + Japan + "
      "The 900 + BS Nosegrind + some other trick "
      "+ whoa that was cool + you are so good + how long "
      " is this + almost fell + whatever "
      "FS Boardslide + 360 360 Flip + Japan + "
      "The 900 + BS Nosegrind + some other trick "
      "+ whoa that was cool + you are so good + how long "
      " is this + almost fell + whatever "
    ]
  }
  FireEvent type = focus target = current_menu
ENDSCRIPT

SCRIPT statistics_menu_add_item
  CreateScreenElement {
    type = ContainerElement
    parent = current_menu
    dims = (500, 28)
    not_focusable
  }
   <container_id> = <id>
  CreateScreenElement {
    type = TextElement
    parent = <container_id>
    text = <text>
    font = small
    pos = (160, 8)
    just = [ right center ]
    rgba = [ 108 120 128 128 ]
    scale = 0.9
  }
  FormatText TextName = value_string "%v" v = <value>
  IF GotParam unit
    FormatText TextName = value_string "%s %u" s = <value_string> u = <unit>
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = <container_id>
    text = <value_string>
    font = dialog
    pos = (165, 8)
    just = [ left center ]
    rgba = [ 127 102 0 128 ]
    scale = 0.9
  }
   <pos> = (-25, -5)
  BEGIN
    CreateScreenElement {
      type = SpriteElement
      parent = <container_id>
      texture = comp_single_line
      pos = <pos>
      just = [ left top ]
      scale = (1, 1)
      rgba = [ 128 128 128 90 ]
    }
    GetStackedScreenElementPos X id = <id>
  REPEAT 57
ENDSCRIPT

SCRIPT statistics_menu_exit
  GoalManager_ShowPoints
  IF not GoalManager_HasActiveGoals
    GoalManager_ShowGoalPoints
  ENDIF
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
    Wait 1 gameframe
    remove_statistics_menu_textures_from_vram
  ENDIF
  add_pause_menu_textures_to_vram
  create_debug_menu
ENDSCRIPT

SCRIPT add_statistics_menu_textures_to_vram
  AddTextureToVram "PA_Stats"
  AddTextureToVram "comp_single_line"
ENDSCRIPT

SCRIPT remove_statistics_menu_textures_from_vram
  RemoveTextureFromVram "PA_Stats"
  RemoveTextureFromVram "comp_single_line"
ENDSCRIPT

SCRIPT menu_start_autotest
  SetTesterScript TestLevels
  exit_pause_menu
ENDSCRIPT

SCRIPT menu_stop_autotest
  KillTesterScript
  exit_pause_menu
ENDSCRIPT

SCRIPT launch_menu_test
  RunScriptOnScreenElement id = current_menu_anchor animate_out callback = create_menu_test_menu
ENDSCRIPT

SCRIPT menu_select menu_select_script = item_chosen
  IF GotParam stop_streams
    StopStream
  ENDIF
  exit_pause_menu
   <menu_select_script>
ENDSCRIPT

SCRIPT item_chosen menu_id = current_menu_anchor
  Printf "item_chosen"
  RunScriptOnScreenElement id = <menu_id> animate_out callback = create_pause_menu
ENDSCRIPT

SCRIPT make_text_sub_menu_item { focus_script = do_scale_up
    unfocus_script = do_scale_down
    pad_choose_script = nullscript
    font_face = small
    parent_menu_id = current_menu
    scale = 1
    rgba = [ 88 105 112 128 ]
  }
  IF GotParam not_focusable
     <nofocus_rgba> = [ 60 60 60 75 ]
    CreateScreenElement {
      type = TextElement
      parent = <parent_menu_id>
      id = <id>
      text = <text>
      font = <font_face>
      rgba = <nofocus_rgba>
      scale = <scale>
      event_handlers = [
        { focus <focus_script> params = <focus_params> }
        { unfocus <unfocus_script> params = <unfocus_params> }
        { pad_choose <pad_choose_script> params = <pad_choose_params> }
        { pad_start <pad_choose_script> params = <pad_choose_params> }
      ]
      not_focusable
    }
  ELSE
    IF GotParam no_choose_sound
      CreateScreenElement {
        type = TextElement
        parent = <parent_menu_id>
        id = <id>
        text = <text>
        font = <font_face>
        rgba = <rgba>
        scale = <scale>
        event_handlers = [
          { focus <focus_script> params = <focus_params> }
          { unfocus <unfocus_script> params = <unfocus_params> }
          { pad_choose <pad_choose_script> params = <pad_choose_params> }
          { pad_start <pad_choose_script> params = <pad_choose_params> }
        ]
      }
    ELSE
      CreateScreenElement {
        type = TextElement
        parent = <parent_menu_id>
        id = <id>
        text = <text>
        font = <font_face>
        rgba = <rgba>
        scale = <scale>
        event_handlers = [
          { focus <focus_script> params = <focus_params> }
          { unfocus <unfocus_script> params = <unfocus_params> }
          { pad_choose generic_menu_pad_choose_sound }
          { pad_start generic_menu_pad_choose_sound }
          { pad_choose <pad_choose_script> params = <pad_choose_params> }
          { pad_start <pad_choose_script> params = <pad_choose_params> }
        ]
      }
    ENDIF
  ENDIF
  IF GotParam pad_circle_script
    SetScreenElementProps { id = <id>
      event_handlers = [
        { pad_circle <pad_circle_script> params = <pad_circle_params> }
      ]
    }
  ENDIF
ENDSCRIPT

SCRIPT make_text_menu_item { focus_script = do_scale_up
    unfocus_script = do_scale_down
    pad_choose_script = item_chosen
    pad_back_script = exit_pause_menu
    font_face = small }
  CreateScreenElement {
    type = TextElement parent = current_menu
    id = <id>
    text = <text>
    font = <font_face>
    rgba = [ 128 128 128 75 ]
    event_handlers = [
      { focus <focus_script> }
      { unfocus <unfocus_script> }
      { pad_choose <pad_choose_script> params = <pad_choose_params> }
      { pad_back <pad_back_script> }
    ]
  }
ENDSCRIPT

SCRIPT make_sprite_menu_item { focus_script = sprite_focus
    text = "Default sprite text"
    unfocus_script = sprite_unfocus
    pad_choose_script = item_chosen
    scale = 1
    rgba = [ 88 105 112 128 ]
  }
  IF GotParam not_focusable
     <rgba> = [ 60 60 60 75 ]
  ENDIF
  CreateScreenElement {
    type = TextElement
    parent = current_menu
    id = <id>
    font = small
    text = <text>
    rgba = <rgba>
    scale = <scale>
    pos = (320, 240)
    just = [ center center ]
    event_handlers = [
      { focus <focus_script> params = { text = <text> } }
      { unfocus <unfocus_script> }
      { pad_start generic_menu_pad_choose_sound }
      { pad_choose generic_menu_pad_choose_sound }
      { pad_choose <pad_choose_script> params = <pad_choose_params> }
      { pad_start <pad_choose_script> params = <pad_choose_params> }
    ]
     <not_focusable>
  }
ENDSCRIPT

SCRIPT make_sprite_sub_menu_item { focus_script = sprite_focus
    text = "Default sprite text"
    unfocus_script = sprite_unfocus
    pad_choose_script = item_chosen
  }
  CreateScreenElement {
    type = TextElement parent = current_menu
    rgba = [ 92 92 92 70 ]
    id = <id>
    font = small
    text = <text>
    scale = 1.0
    pos = (320, 240)
    just = [ center center ]
    event_handlers = [
      { focus <focus_script> params = { text = <text> } }
      { unfocus <unfocus_script> }
      { pad_choose <pad_choose_script> params = <pad_choose_params> }
    ]
  }
ENDSCRIPT

SCRIPT make_toggle_menu_item { font = small
    child_pos = { (210, 0) relative }
    rgba = [ 88 105 112 128 ]
    child_rgba = [ 88 105 112 128 ]
    just = [ right top ]
    child_just = [ left top ]
    child_scale = 1
    focus_script = do_scale_up
    unfocus_script = do_scale_down
    pad_choose_script = item_chosen
  }
  CreateScreenElement {
    type = TextElement
    parent = current_menu
    id = <id>
    font = <font>
    pos = <pos>
    rgba = <rgba>
    just = <just>
    text = <text>
    scale = <scale>
    event_handlers = [
      { focus <focus_script> params = <focus_params> }
      { unfocus <unfocus_script> params = <unfocus_params> }
      { pad_choose <pad_choose_script> params = <pad_choose_params> }
      { pad_start <pad_choose_script> params = <pad_choose_params> }
    ]
  }
  CreateScreenElement {
    type = TextElement
    parent = <id>
    font = <font>
    pos = <child_pos>
    rgba = <child_rgba>
    just = <child_just>
    text = "off"
    scale = <child_scale>
  }
ENDSCRIPT

SCRIPT toggle_menu_item_on
  SetScreenElementProps {
    id = { <id> child = 0 }
    text = "on"
  }
ENDSCRIPT

SCRIPT toggle_menu_item_off
  SetScreenElementProps {
    id = { <id> child = 0 }
    text = "off"
  }
ENDSCRIPT

SCRIPT animate_in
  PlaySound AnimateIn vol = 200
  SetButtonEventMappings block_menu_input
  SetScreenElementProps id = root_window tags = { menu_state = entering }
  DoMorph time = 0 scale = 0 alpha = 0
  FireEvent type = focus target = <menu_id>
  DoMorph time = 0.07 scale = 1.1 alpha = 0.4
  DoMorph time = 0.07 scale = 0.95 alpha = 1
  DoMorph time = 0.07 scale = 1.0
  SetScreenElementProps id = root_window tags = { menu_state = on }
  IF not GotParam dont_unblock
    SetButtonEventMappings unblock_menu_input
  ENDIF
ENDSCRIPT

SCRIPT menu_onscreen menu_id = current_menu_anchor
  DoMorph scale = 1 time = 0
  IF GotParam pos
    DoMorph pos = <pos>
  ENDIF
  SetProps just = [ center center ]
  GetTags
  IF GotParam focus_child
    FireEvent type = focus target = <menu_id> data = { child_id = <focus_child> }
  ELSE
    FireEvent type = focus target = <id>
  ENDIF
  IF not GotParam preserve_menu_state
    SetScreenElementProps id = root_window tags = { menu_state = on }
  ENDIF
ENDSCRIPT

SCRIPT animate_out menu_id = current_menu_anchor
  PlaySound AnimateOut
  SetButtonEventMappings block_menu_input
  SetScreenElementProps id = root_window tags = { menu_state = leaving }
  GetTags
  SetProps just = [ center center ]
  DoMorph time = 0 scale = 1.0
  DoMorph time = 0.07 scale = 1.3
  DoMorph time = 0.05 scale = 1.4 alpha = 0.05
  DoMorph time = 0.15 scale = 0.0 alpha = 0
  SetScreenElementProps id = root_window tags = { menu_state = off }
  SetScreenElementLock id = root_window off
  DestroyScreenElement id = <menu_id>
  SetButtonEventMappings unblock_menu_input
ENDSCRIPT

SCRIPT menu_offscreen
  SetScreenElementProps id = root_window tags = { menu_state = off }
  SetScreenElementLock id = root_window off
  GetTags
  FireEvent type = unfocus target = <id>
  DestroyScreenElement id = <id> recurse
ENDSCRIPT

SCRIPT load_textures_to_main_memory
  LoadTexture no_vram_alloc "PanelSprites/paused"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_1"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_2"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_3"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_4"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_5"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_6"
  LoadTexture no_vram_alloc "PanelSprites/SlicePause_7"
  LoadTexture no_vram_alloc "PanelSprites/PA_continue"
  LoadTexture no_vram_alloc "PanelSprites/PA_retry"
  LoadTexture no_vram_alloc "PanelSprites/PA_end"
  LoadTexture no_vram_alloc "PanelSprites/PA_view"
  LoadTexture no_vram_alloc "PanelSprites/PA_rescore"
  LoadTexture no_vram_alloc "PanelSprites/PA_level"
  LoadTexture no_vram_alloc "PanelSprites/PA_save"
  LoadTexture no_vram_alloc "PanelSprites/PA_Load"
  LoadTexture no_vram_alloc "PanelSprites/PA_options"
  LoadTexture no_vram_alloc "PanelSprites/PA_shop"
  LoadTexture no_vram_alloc "PanelSprites/PA_fonts"
  LoadTexture no_vram_alloc "PanelSprites/PA_set_cust"
  LoadTexture no_vram_alloc "PanelSprites/PA_skip_cust"
  LoadTexture no_vram_alloc "PanelSprites/PA_restart"
  LoadTexture no_vram_alloc "PanelSprites/PA_model"
  LoadTexture no_vram_alloc "PanelSprites/PA_startauto"
  LoadTexture no_vram_alloc "PanelSprites/PA_stopauto"
  LoadTexture no_vram_alloc "PanelSprites/PA_pro"
  LoadTexture no_vram_alloc "PanelSprites/PA_mode"
  LoadTexture no_vram_alloc "PanelSprites/PA_sound"
  LoadTexture no_vram_alloc "PanelSprites/PA_cheats"
  LoadTexture no_vram_alloc "PanelSprites/PA_quit"
  LoadTexture no_vram_alloc "PanelSprites/PA_pause"
  LoadTexture no_vram_alloc "PanelSprites/PA_gap"
  LoadTexture no_vram_alloc "PanelSprites/PA_taunt"
  LoadTexture no_vram_alloc "PanelSprites/PA_create"
  LoadTexture no_vram_alloc "PanelSprites/PA_controls"
  LoadTexture no_vram_alloc "PanelSprites/PA_movie"
  LoadTexture no_vram_alloc "PanelSprites/PA_replay"
  LoadTexture no_vram_alloc "PanelSprites/PA_homie"
  LoadTexture no_vram_alloc "PanelSprites/PA_hardware"
  LoadTexture no_vram_alloc "PanelSprites/PA_connection"
  LoadTexture no_vram_alloc "PanelSprites/goal_left"
  LoadTexture no_vram_alloc "PanelSprites/goal_mid"
  LoadTexture no_vram_alloc "PanelSprites/goal_right"
  LoadTexture no_vram_alloc "PanelSprites/goal_line"
  LoadTexture no_vram_alloc "PanelSprites/stats_notch"
  LoadTexture no_vram_alloc "PanelSprites/generic_key"
  LoadTexture no_vram_alloc "PanelSprites/key_left"
  LoadTexture no_vram_alloc "PanelSprites/key_middle"
  LoadTexture no_vram_alloc "PanelSprites/key_right"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/pip_on"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/bottom_l_cap"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/bottom_mid"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/bottom_r_cap"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/highlight_skater"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/left_arrow"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/lock_skater"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/longbar"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/longbar_cap"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/mainbar"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/mainbar_join"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/off_skater"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/right_arrow"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/stats_bg"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/tab"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/up_arrow"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/tab1"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/tab2"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/tab3"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/repeat_piece"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/repeat_piece2"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/repeat_piece3"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/menu_bottom"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/down_arrow"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_board"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_done"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_head"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_info"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_legs"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_pads"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_resize"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_secret"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_scale"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_tat"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_torso"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/ED_tricks"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/edit_bar"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/bw_slider"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/colorbar"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/scalebar"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/scale_down"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/scale_up"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/level_top_piece"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/level_repeat_mid"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/level_lower_piece"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/level_bottom_piece"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/level_bottom_cap"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/longbar_edgy"
  LoadTexture no_vram_alloc "PanelSprites/THPS4"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/grungeframe_top"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/grungeframe_mid"
  LoadTexture no_vram_alloc "PanelSprites/SkateSprites/grungeframe_bot"
  LoadTexture no_vram_alloc "PanelSprites/MemCardSprites/mem_career"
  LoadTexture no_vram_alloc "PanelSprites/MemCardSprites/mem_park"
  LoadTexture no_vram_alloc "PanelSprites/MemCardSprites/mem_replay"
  LoadTexture no_vram_alloc "PanelSprites/MemCardSprites/mem_skater"
  LoadTexture no_vram_alloc "PanelSprites/MemCardSprites/mem_bad"
  LoadTexture no_vram_alloc "PanelSprites/MemCardSprites/mem_net"
  LoadTexture no_vram_alloc "PanelSprites/pro_burnquist"
  LoadTexture no_vram_alloc "PanelSprites/pro_caballero"
  LoadTexture no_vram_alloc "PanelSprites/pro_campbell"
  LoadTexture no_vram_alloc "PanelSprites/pro_custom"
  LoadTexture no_vram_alloc "PanelSprites/pro_glifberg"
  LoadTexture no_vram_alloc "PanelSprites/pro_hawk"
  LoadTexture no_vram_alloc "PanelSprites/pro_koston"
  LoadTexture no_vram_alloc "PanelSprites/pro_lasek"
  LoadTexture no_vram_alloc "PanelSprites/pro_margera"
  LoadTexture no_vram_alloc "PanelSprites/pro_mullen"
  LoadTexture no_vram_alloc "PanelSprites/pro_muska"
  LoadTexture no_vram_alloc "PanelSprites/pro_reynolds"
  LoadTexture no_vram_alloc "PanelSprites/pro_rowley"
  LoadTexture no_vram_alloc "PanelSprites/pro_steamer"
  LoadTexture no_vram_alloc "PanelSprites/pro_thomas"
  LoadTexture no_vram_alloc "PanelSprites/PA_Stats"
  LoadTexture no_vram_alloc "PanelSprites/comp_single_line"
  LoadTexture no_vram_alloc "PanelSprites/PA_trick"
  LoadTexture no_vram_alloc "PanelSprites/PA_grab"
  LoadTexture no_vram_alloc "PanelSprites/PA_flip"
  LoadTexture no_vram_alloc "PanelSprites/PA_lip"
  LoadTexture no_vram_alloc "PanelSprites/PA_special"
  LoadTexture no_vram_alloc "PanelSprites/parked_piece_frame"
  LoadTexture no_vram_alloc "PanelSprites/HighScore"
  LoadTexture no_vram_alloc "PanelSprites/bot_gradient"
  LoadTexture no_vram_alloc "PanelSprites/top_gradient"
  LoadTexture no_vram_alloc "PanelSprites/bink"
  LoadTexture no_vram_alloc "PanelSprites/comp_base_line"
  LoadTexture no_vram_alloc "PanelSprites/comp_fill"
  LoadTexture no_vram_alloc "PanelSprites/comp_end_cap"
  LoadTexture no_vram_alloc "PanelSprites/comp_hori_lines"
  LoadTexture no_vram_alloc "PanelSprites/comp_tall_line"
  LoadTexture no_vram_alloc "PanelSprites/PA_goals"
  IF IsPS2
    LoadTexture no_vram_alloc "PanelSprites/gslogo"
  ENDIF
ENDSCRIPT

SCRIPT remove_temp_textures_from_vram
  RemoveTextureFromVram no_assert "paused"
  RemoveTextureFromVram no_assert "SlicePause_1"
  RemoveTextureFromVram no_assert "SlicePause_2"
  RemoveTextureFromVram no_assert "SlicePause_3"
  RemoveTextureFromVram no_assert "SlicePause_4"
  RemoveTextureFromVram no_assert "SlicePause_5"
  RemoveTextureFromVram no_assert "SlicePause_6"
  RemoveTextureFromVram no_assert "SlicePause_7"
  RemoveTextureFromVram no_assert "PA_continue"
  RemoveTextureFromVram no_assert "PA_retry"
  RemoveTextureFromVram no_assert "PA_end"
  RemoveTextureFromVram no_assert "PA_view"
  RemoveTextureFromVram no_assert "PA_rescore"
  RemoveTextureFromVram no_assert "PA_level"
  RemoveTextureFromVram no_assert "PA_save"
  RemoveTextureFromVram no_assert "PA_Load"
  RemoveTextureFromVram no_assert "PA_options"
  RemoveTextureFromVram no_assert "PA_shop"
  RemoveTextureFromVram no_assert "PA_fonts"
  RemoveTextureFromVram no_assert "PA_set_cust"
  RemoveTextureFromVram no_assert "PA_skip_cust"
  RemoveTextureFromVram no_assert "PA_restart"
  RemoveTextureFromVram no_assert "PA_model"
  RemoveTextureFromVram no_assert "PA_startauto"
  RemoveTextureFromVram no_assert "PA_stopauto"
  RemoveTextureFromVram no_assert "PA_pro"
  RemoveTextureFromVram no_assert "PA_mode"
  RemoveTextureFromVram no_assert "PA_sound"
  RemoveTextureFromVram no_assert "PA_cheats"
  RemoveTextureFromVram no_assert "PA_quit"
  RemoveTextureFromVram no_assert "PA_pause"
  RemoveTextureFromVram no_assert "PA_gap"
  RemoveTextureFromVram no_assert "PA_taunt"
  RemoveTextureFromVram no_assert "PA_create"
  RemoveTextureFromVram no_assert "PA_controls"
  RemoveTextureFromVram no_assert "PA_movie"
  RemoveTextureFromVram no_assert "PA_replay"
  RemoveTextureFromVram no_assert "PA_homie"
  RemoveTextureFromVram no_assert "PA_hardware"
  RemoveTextureFromVram no_assert "PA_connection"
  RemoveTextureFromVram no_assert "goal_left"
  RemoveTextureFromVram no_assert "goal_mid"
  RemoveTextureFromVram no_assert "goal_right"
  RemoveTextureFromVram no_assert "goal_line"
  RemoveTextureFromVram no_assert "stats_notch"
  RemoveTextureFromVram no_assert "generic_key"
  RemoveTextureFromVram no_assert "key_left"
  RemoveTextureFromVram no_assert "key_middle"
  RemoveTextureFromVram no_assert "key_right"
  RemoveTextureFromVram no_assert "pip_on"
  RemoveTextureFromVram no_assert "bottom_l_cap"
  RemoveTextureFromVram no_assert "bottom_mid"
  RemoveTextureFromVram no_assert "bottom_r_cap"
  RemoveTextureFromVram no_assert "highlight_skater"
  RemoveTextureFromVram no_assert "left_arrow"
  RemoveTextureFromVram no_assert "lock_skater"
  RemoveTextureFromVram no_assert "longbar"
  RemoveTextureFromVram no_assert "longbar_cap"
  RemoveTextureFromVram no_assert "mainbar"
  RemoveTextureFromVram no_assert "mainbar_join"
  RemoveTextureFromVram no_assert "off_skater"
  RemoveTextureFromVram no_assert "right_arrow"
  RemoveTextureFromVram no_assert "stats_bg"
  RemoveTextureFromVram no_assert "tab"
  RemoveTextureFromVram no_assert "up_arrow"
  RemoveTextureFromVram no_assert "tab1"
  RemoveTextureFromVram no_assert "tab2"
  RemoveTextureFromVram no_assert "tab3"
  RemoveTextureFromVram no_assert "repeat_piece"
  RemoveTextureFromVram no_assert "repeat_piece2"
  RemoveTextureFromVram no_assert "repeat_piece3"
  RemoveTextureFromVram no_assert "menu_bottom"
  RemoveTextureFromVram no_assert "down_arrow"
  RemoveTextureFromVram no_assert "ED_board"
  RemoveTextureFromVram no_assert "ED_done"
  RemoveTextureFromVram no_assert "ED_head"
  RemoveTextureFromVram no_assert "ED_info"
  RemoveTextureFromVram no_assert "ED_legs"
  RemoveTextureFromVram no_assert "ED_pads"
  RemoveTextureFromVram no_assert "ED_resize"
  RemoveTextureFromVram no_assert "ED_secret"
  RemoveTextureFromVram no_assert "ED_scale"
  RemoveTextureFromVram no_assert "ED_tat"
  RemoveTextureFromVram no_assert "ED_torso"
  RemoveTextureFromVram no_assert "ED_tricks"
  RemoveTextureFromVram no_assert "edit_bar"
  RemoveTextureFromVram no_assert "bw_slider"
  RemoveTextureFromVram no_assert "colorbar"
  RemoveTextureFromVram no_assert "scalebar"
  RemoveTextureFromVram no_assert "scale_down"
  RemoveTextureFromVram no_assert "scale_up"
  RemoveTextureFromVram no_assert "level_top_piece"
  RemoveTextureFromVram no_assert "level_repeat_mid"
  RemoveTextureFromVram no_assert "level_lower_piece"
  RemoveTextureFromVram no_assert "level_bottom_piece"
  RemoveTextureFromVram no_assert "level_bottom_cap"
  RemoveTextureFromVram no_assert "longbar_edgy"
  RemoveTextureFromVram no_assert "THPS4"
  RemoveTextureFromVram no_assert "grungeframe_top"
  RemoveTextureFromVram no_assert "grungeframe_mid"
  RemoveTextureFromVram no_assert "grungeframe_bot"
  RemoveTextureFromVram no_assert "mem_career"
  RemoveTextureFromVram no_assert "mem_park"
  RemoveTextureFromVram no_assert "mem_replay"
  RemoveTextureFromVram no_assert "mem_skater"
  RemoveTextureFromVram no_assert "mem_bad"
  RemoveTextureFromVram no_assert "mem_net"
  RemoveTextureFromVram no_assert "pro_burnquist"
  RemoveTextureFromVram no_assert "pro_caballero"
  RemoveTextureFromVram no_assert "pro_campbell"
  RemoveTextureFromVram no_assert "pro_custom"
  RemoveTextureFromVram no_assert "pro_glifberg"
  RemoveTextureFromVram no_assert "pro_hawk"
  RemoveTextureFromVram no_assert "pro_koston"
  RemoveTextureFromVram no_assert "pro_lasek"
  RemoveTextureFromVram no_assert "pro_margera"
  RemoveTextureFromVram no_assert "pro_mullen"
  RemoveTextureFromVram no_assert "pro_muska"
  RemoveTextureFromVram no_assert "pro_reynolds"
  RemoveTextureFromVram no_assert "pro_rowley"
  RemoveTextureFromVram no_assert "pro_steamer"
  RemoveTextureFromVram no_assert "pro_thomas"
  RemoveTextureFromVram no_assert "PA_Stats"
  RemoveTextureFromVram no_assert "comp_single_line"
  RemoveTextureFromVram no_assert "PA_trick"
  RemoveTextureFromVram no_assert "PA_grab"
  RemoveTextureFromVram no_assert "PA_flip"
  RemoveTextureFromVram no_assert "PA_lip"
  RemoveTextureFromVram no_assert "PA_special"
  RemoveTextureFromVram no_assert "parked_piece_frame"
  RemoveTextureFromVram no_assert "HighScore"
  RemoveTextureFromVram no_assert "bot_gradient"
  RemoveTextureFromVram no_assert "top_gradient"
  RemoveTextureFromVram no_assert "bink"
  RemoveTextureFromVram no_assert "comp_base_line"
  RemoveTextureFromVram no_assert "comp_fill"
  RemoveTextureFromVram no_assert "comp_end_cap"
  RemoveTextureFromVram no_assert "comp_hori_lines"
  RemoveTextureFromVram no_assert "comp_tall_line"
  RemoveTextureFromVram no_assert "PA_goals"
  IF IsPS2
    RemoveTextureFromVram no_assert "gslogo"
  ENDIF
ENDSCRIPT

SCRIPT add_pause_menu_textures_to_vram
  AddTextureToVram "paused"
  AddTextureToVram "SlicePause_1"
  AddTextureToVram "SlicePause_2"
  AddTextureToVram "SlicePause_3"
  AddTextureToVram "SlicePause_4"
  AddTextureToVram "SlicePause_5"
  AddTextureToVram "SlicePause_6"
  AddTextureToVram "SlicePause_7"
  AddTextureToVram "PA_continue"
  AddTextureToVram "PA_retry"
  AddTextureToVram "PA_end"
  AddTextureToVram "PA_view"
  AddTextureToVram "PA_rescore"
  AddTextureToVram "PA_level"
  AddTextureToVram "PA_save"
  AddTextureToVram "PA_options"
  AddTextureToVram "PA_shop"
  AddTextureToVram "PA_fonts"
  AddTextureToVram "PA_set_cust"
  AddTextureToVram "PA_skip_cust"
  AddTextureToVram "PA_restart"
  AddTextureToVram "PA_model"
  AddTextureToVram "PA_startauto"
  AddTextureToVram "PA_stopauto"
  AddTextureToVram "PA_pro"
  AddTextureToVram "PA_mode"
  AddTextureToVram "PA_sound"
  AddTextureToVram "PA_cheats"
  AddTextureToVram "PA_quit"
  AddTextureToVram "PA_pause"
  AddTextureToVram "PA_gap"
  AddTextureToVram "PA_taunt"
  AddTextureToVram "PA_create"
  AddTextureToVram "PA_movie"
  AddTextureToVram "PA_replay"
  AddTextureToVram "goal_left"
  AddTextureToVram "goal_mid"
  AddTextureToVram "goal_right"
  AddTextureToVram "goal_line"
  AddTextureToVram "stats_bg"
  AddTextureToVram "stats_notch"
  AddTextureToVram "pip_on"
ENDSCRIPT

SCRIPT remove_pause_menu_textures_from_vram
  RemoveTextureFromVram "paused"
  RemoveTextureFromVram "SlicePause_1"
  RemoveTextureFromVram "SlicePause_2"
  RemoveTextureFromVram "SlicePause_3"
  RemoveTextureFromVram "SlicePause_4"
  RemoveTextureFromVram "SlicePause_5"
  RemoveTextureFromVram "SlicePause_6"
  RemoveTextureFromVram "SlicePause_7"
  RemoveTextureFromVram "PA_continue"
  RemoveTextureFromVram "PA_retry"
  RemoveTextureFromVram "PA_end"
  RemoveTextureFromVram "PA_view"
  RemoveTextureFromVram "PA_rescore"
  RemoveTextureFromVram "PA_level"
  RemoveTextureFromVram "PA_save"
  RemoveTextureFromVram "PA_options"
  RemoveTextureFromVram "PA_shop"
  RemoveTextureFromVram "PA_fonts"
  RemoveTextureFromVram "PA_set_cust"
  RemoveTextureFromVram "PA_skip_cust"
  RemoveTextureFromVram "PA_restart"
  RemoveTextureFromVram "PA_model"
  RemoveTextureFromVram "PA_startauto"
  RemoveTextureFromVram "PA_stopauto"
  RemoveTextureFromVram "PA_pro"
  RemoveTextureFromVram "PA_mode"
  RemoveTextureFromVram "PA_sound"
  RemoveTextureFromVram "PA_cheats"
  RemoveTextureFromVram "PA_quit"
  RemoveTextureFromVram "PA_pause"
  RemoveTextureFromVram "PA_gap"
  RemoveTextureFromVram "PA_taunt"
  RemoveTextureFromVram "PA_create"
  RemoveTextureFromVram "PA_movie"
  RemoveTextureFromVram "PA_replay"
  RemoveTextureFromVram "goal_left"
  RemoveTextureFromVram "goal_mid"
  RemoveTextureFromVram "goal_right"
  RemoveTextureFromVram "goal_line"
  RemoveTextureFromVram "stats_bg"
  RemoveTextureFromVram "stats_notch"
  RemoveTextureFromVram "pip_on"
ENDSCRIPT

SCRIPT load_all_textures
ENDSCRIPT

SCRIPT sprite_focus
  SetProps rgba = [ 127 102 0 128 ]
  SetProps blur_effect
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } scale_sprite_up
  RunScriptOnScreenElement id = <id> do_blur_effect
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = [ 127 102 0 128 ]
  }
ENDSCRIPT

SCRIPT sprite_unfocus
  generic_menu_pad_up_down_sound
  SetProps rgba = [ 88 105 112 128 ]
  SetProps no_blur_effect
  GetTags
  RunScriptOnScreenElement id = { <id> child = 0 } scale_sprite_down
  SetScreenElementProps {
    id = { <id> child = 0 }
    rgba = [ 128 128 128 40 ]
  }
ENDSCRIPT

SCRIPT scale_sprite_up
  DoMorph time = 0.1 scale = 0.95
ENDSCRIPT

SCRIPT scale_sprite_down
  DoMorph time = 0.0 scale = 0
ENDSCRIPT

SCRIPT do_scale_up rgba = [ 127 102 0 100 ]
  GetTags
  SetProps rgba = <rgba>
  RunScriptOnScreenElement id = <id> do_random_effect params = { id = <id> }
ENDSCRIPT

SCRIPT do_scale_down rgba = [ 88 105 112 128 ]
  IF not GotParam no_sound
    generic_menu_pad_up_down_sound
  ENDIF
  KillSpawnedScript name = do_random_effect
  SetProps no_blur_effect
  SetProps rgba = <rgba>
ENDSCRIPT

SCRIPT do_random_effect
  GetTags
  SetTags random_effect_done = 0
  RunScriptOnScreenElement id = <id> do_random_effect2
  BEGIN
    GetTags
    IF ( <random_effect_done> = 1 )
      SetTags random_effect_done = 0
      RunScriptOnScreenElement id = <id> do_random_effect2 params = {
        id = <id>
        effect = random( @2 @3 @5 @8 @2 @3 @5 @2 @3 @5 @2 @10 @3 @2 @3 @5 @2 @3 @8 @3 @5 @9 @2 @3 @5 @2 @3 @5 @6 @2 @3 @9 @5 @3 @2 @3 @5 @2 @3 @5 @2 @3 @5 @6 @7 @1 ) 
      }
    ENDIF
    Wait 10 frame
  REPEAT
ENDSCRIPT

SCRIPT do_random_effect2
  SWITCH <effect>
  CASE 1
    DoMorph time = 0.04 scale = (1.1, 0.95) alpha = 0.1 relative_scale
    DoMorph time = 0.04 scale = 1 alpha = 1 relative_scale
  CASE 2
    DoMorph time = 0.05 pos = { (-0.75, 0.5) relative }
    DoMorph time = 0.05 pos = { (1.5, -1) relative }
    DoMorph time = 0.05 pos = { (-0.75, 0.5) relative }
  CASE 3
    DoMorph time = 0.05 alpha = 0.6
    DoMorph time = 0.05 alpha = 1
  CASE 4
    SetProps blur_effect
    do_blur_effect_highlight
    SetProps no_blur_effect
  CASE 5
    DoMorph time = 0.05 pos = { (-1.5, 0.5) relative }
    DoMorph time = 0.05 pos = { (3, -1) relative }
    DoMorph time = 0.05 pos = { (-1.5, 0.5) relative }
  CASE 6
    DoMorph time = 0.05 pos = { (-0.75, 1.5) relative }
    DoMorph time = 0.05 pos = { (1.5, -3) relative }
    DoMorph time = 0.05 pos = { (-0.75, 1.5) relative }
  CASE 7
    SetProps blur_effect
    do_blur_effect_accept
    SetProps no_blur_effect
  CASE 8
    DoMorph time = 0.05 scale = 1.1 relative_scale
    DoMorph time = 0.05 scale = 1 relative_scale
  CASE 9
    DoMorph time = 0.04 scale = (0.95, 0.65) alpha = 0.8 relative_scale
    DoMorph time = 0.04 scale = 1 alpha = 1 relative_scale
  CASE 10
    DoMorph time = 0.05 pos = { (-2, 0) relative }
    DoMorph time = 0.05 pos = { (4, 0) relative }
    DoMorph time = 0.05 pos = { (-2, 0) relative }
  DEFAULT
    SetProps blur_effect
    do_blur_effect
    SetProps no_blur_effect
  ENDSWITCH
  SetTags random_effect_done = 1
ENDSCRIPT

SCRIPT hide_root_window
  RunScriptOnScreenElement id = root_window hide_screen_element
ENDSCRIPT

SCRIPT unhide_root_window
  RunScriptOnScreenElement id = root_window unhide_screen_element
ENDSCRIPT

SCRIPT hide_screen_element
  DoMorph scale = 0
ENDSCRIPT

SCRIPT unhide_screen_element
  DoMorph scale = 1
ENDSCRIPT

SCRIPT create_taunt_options_menu
  remove_pause_menu_textures_from_vram
  add_ss_menu_textures_to_vram
  make_new_menu menu_id = network_options_menu vmenu_id = network_options_vmenu menu_title = "" pos = (226, 110) helper_text = generic_helper_text
  SetScreenElementProps { id = network_options_vmenu event_handlers = [
      { pad_back launch_setup_options_menu }
    ]
  }
  CreateScreenElement {
    type = TextElement
    parent = current_menu_anchor
    font = testtitle
    text = "TAUNT OPTIONS"
    scale = 1.4
    pos = (166, 118)
    just = [ left top ]
    rgba = [ 128 128 128 98 ]
    not_focusable
  }
  main_menu_add_item text = "" not_focusable = not_focusable dims = (200, 18)
  IF IsPS2
    noway_buttons = "(\be+\bf+\b2)"
    daddy_buttons = "(\be+\bf+\b1)"
    props_buttons = "(\be+\bf+\b0)"
    getsome_buttons = "(\be+\bf+\b3)"
  ELSE
    noway_buttons = "(\bg+\b2)"
    daddy_buttons = "(\bg+\b1)"
    props_buttons = "(\bg+\b0)"
    getsome_buttons = "(\bg+\b3)"
  ENDIF
  menu_item_dims = (200, 22)
  GetPreferenceString pref_type = taunt no_way_string
  taunt_options_add_item text = "'No Way' Text" button_text = <noway_buttons> text_pos = (110, -5) id = no_way_item pad_choose_script = launch_onscreen_keyboard_from_taunt_menu pad_choose_params = { field = "no_way_string" text = <ui_string> title = "NO WAY STRING" min_length = 1 max_length = 31 } dims = <menu_item_dims>
  main_menu_add_item text = <ui_string> id = no_way_item_string max_width = 300 rgba = [ 80 80 80 128 ] scale = 0.9 not_focusable = not_focusable dims = <menu_item_dims> font = dialog
  GetPreferenceString pref_type = taunt your_daddy_string
  taunt_options_add_item text = "'Your Daddy' Text" button_text = <daddy_buttons> text_pos = (137, -5) id = your_daddy_item pad_choose_script = launch_onscreen_keyboard_from_taunt_menu pad_choose_params = { field = "your_daddy_string" text = <ui_string> title = "YOUR DADDY STRING" min_length = 1 max_length = 31 } dims = <menu_item_dims>
  main_menu_add_item text = <ui_string> id = your_daddy_item_string max_width = 300 rgba = [ 80 80 80 128 ] scale = 0.9 not_focusable = not_focusable dims = <menu_item_dims> font = dialog
  GetPreferenceString pref_type = taunt props_string
  taunt_options_add_item text = "'Props' Text" button_text = <props_buttons> text_pos = (105, -5) id = props_item pad_choose_script = launch_onscreen_keyboard_from_taunt_menu pad_choose_params = { field = "props_string" text = <ui_string> title = "PROPS STRING" min_length = 1 max_length = 31 } dims = <menu_item_dims>
  main_menu_add_item text = <ui_string> id = props_item_string max_width = 300 rgba = [ 80 80 80 128 ] scale = 0.9 not_focusable = not_focusable dims = <menu_item_dims> font = dialog
  GetPreferenceString pref_type = taunt get_some_string
  taunt_options_add_item text = "'Get Some' Text" button_text = <getsome_buttons> text_pos = (125, -5) id = get_some_item pad_choose_script = launch_onscreen_keyboard_from_taunt_menu pad_choose_params = { field = "get_some_string" text = <ui_string> title = "GET SOME STRING" min_length = 1 max_length = 31 } dims = <menu_item_dims>
  main_menu_add_item text = <ui_string> id = get_some_item_string max_width = 300 rgba = [ 80 80 80 128 ] scale = 0.9 not_focusable = not_focusable dims = <menu_item_dims> font = dialog
  set_sub_bg type = SpriteElement pos = (125, 115) scale = (1.74, 1.1) just = [ left top ]
  create_icon texture = PA_taunt pos = (113, 115)
  CreateScreenElement {
    type = SpriteElement
    parent = network_options_menu
    id = taunt_blackbar_1
    texture = black
    pos = (145, 190)
    rgba = [ 0 0 0 60 ]
    just = [ left center ]
    scale = (90, 5)
  }
  CreateScreenElement {
    type = SpriteElement
    parent = network_options_menu
    id = taunt_blackbar_2
    texture = black
    pos = (145, 240)
    rgba = [ 0 0 0 60 ]
    just = [ left center ]
    scale = (90, 5)
  }
  CreateScreenElement {
    type = SpriteElement
    parent = network_options_menu
    id = taunt_blackbar_3
    texture = black
    pos = (145, 291)
    rgba = [ 0 0 0 60 ]
    just = [ left center ]
    scale = (90, 5)
  }
  CreateScreenElement {
    type = SpriteElement
    parent = network_options_menu
    id = taunt_blackbar_4
    texture = black
    pos = (145, 342)
    rgba = [ 0 0 0 60 ]
    just = [ left center ]
    scale = (90, 5)
  }
  draw_menu_box delta_pos = (94, 30) middle_repeat = 12 box_right_scale = (0.8, 0.935) scale = (1.5, 1) box_bottom_scale = (1.45, 1) box_right_offset = (-23, 0)
  RunScriptOnScreenElement id = current_menu_anchor animate_in
ENDSCRIPT

SCRIPT taunt_options_add_item { parent = current_menu
    font = small
    highlight_bar_scale = (1.4, 1.3)
    highlight_bar_pos = (97, -7)
    focus_script = main_menu_focus
    unfocus_script = main_menu_unfocus
    text_just = [ right , center ]
    text_pos = (95, -5)
    dims = (200, 20)
    pad_choose_script = nullscript
  }
  IF GotParam not_focusable
    CreateScreenElement {
      type = ContainerElement
      parent = <parent>
      id = <id>
      dims = <dims>
      event_handlers = [ { focus <focus_script> params = <focus_params> }
        { unfocus <unfocus_script> params = <unfocus_params> }
        { pad_choose <pad_choose_script> params = <pad_choose_params> }
        { pad_start <pad_choose_script> params = <pad_choose_params> }
      ]
      replace_handlers
      not_focusable
    }
  ELSE
    CreateScreenElement {
      type = ContainerElement
      parent = <parent>
      id = <id>
      dims = <dims>
      event_handlers = [ { focus <focus_script> params = <focus_params> }
        { unfocus <unfocus_script> params = <unfocus_params> }
        { pad_choose generic_menu_pad_choose_sound }
        { pad_choose <pad_choose_script> params = <pad_choose_params> }
        { pad_start <pad_choose_script> params = <pad_choose_params> }
      ]
      replace_handlers
    }
  ENDIF
   <anchor_id> = <id>
  IF GotParam mark_first_input
    SetScreenElementProps {
      id = <anchor_id>
      event_handlers = [ { pad_choose mark_first_input_received }
        { pad_choose generic_menu_pad_choose_sound }
        { pad_choose <pad_choose_script> params = <pad_choose_params> }
      ]
      replace_handlers
    }
  ENDIF
  IF GotParam not_focusable
     <text_rgba> = [ 60 60 60 75 ]
    CreateScreenElement {
      type = TextElement
      parent = <anchor_id>
      id = <text_id>
      font = <font>
      text = <text>
      scale = <scale>
      pos = <text_pos>
      just = <text_just>
      rgba = <text_rgba>
      not_focusable
    }
  ELSE
     <text_rgba> = [ 88 105 112 128 ]
    CreateScreenElement {
      type = TextElement
      parent = <anchor_id>
      id = <text_id>
      font = <font>
      text = <text>
      scale = <scale>
      pos = <text_pos>
      just = <text_just>
      rgba = <text_rgba>
    }
  ENDIF
  text_id = <id>
  IF GotParam max_width
    truncate_string id = <id> max_width = <max_width>
  ENDIF
  CreateScreenElement {
    type = SpriteElement
    parent = <anchor_id>
    texture = highlight_bar
    pos = <highlight_bar_pos>
    scale = <highlight_bar_scale>
    just = [ center center ]
    rgba = [ 128 128 128 0 ]
    z_priority = 3
  }
  CreateScreenElement {
    type = TextElement
    parent = <anchor_id>
    pos = ( <text_pos> + (20, 7) )
    font = <font>
    text = <button_text>
    scale = 0.8
    just = [ top right ]
    rgba = <text_rgba>
  }
ENDSCRIPT

SCRIPT create_end_run_menu
  dialog_box_exit
  IF ObjectExists id = current_menu_anchor
    DestroyScreenElement id = current_menu_anchor
  ENDIF
  SetGameType freeskate2p
  SetCurrentGameType
  PauseGame
  add_pause_menu_textures_to_vram
  make_new_menu menu_id = end_run_menu vmenu_id = end_run_vmenu menu_title = "TWO PLAYERS"
  create_helper_text generic_helper_text_no_back
  make_text_sub_menu_item text = "Start Game" id = menu_end_run_start_game pad_choose_script = create_network_game_options_menu pad_choose_params = { end_run }
  make_text_sub_menu_item text = "Change Levels" id = menu_end_run_change_levels pad_choose_script = launch_level_select_menu pad_choose_params = { end_run }
  make_text_sub_menu_item text = "Split Mode" id = menu_end_run_split_mode pad_choose_script = create_split_menu pad_choose_params = { callback_script = create_end_run_menu end_run }
  make_text_sub_menu_item text = "Quit" id = menu_end_run_quit pad_choose_script = menu_confirm_quit pad_choose_params = { no_script = create_end_run_menu back_script = create_end_run_menu }
  set_sub_bg type = SpriteElement
  create_icon texture = PA_network
  RunScriptOnScreenElement id = current_menu_anchor menu_onscreen
  kill_start_key_binding
ENDSCRIPT

SCRIPT set_taunt_preference
  GetTextElementString id = keyboard_current_string
  set_preferences_from_ui prefs = taunt <...>
  destroy_onscreen_keyboard
  add_ss_menu_textures_to_vram
  create_taunt_options_menu
ENDSCRIPT

SCRIPT taunt_back_from_keyboard
  destroy_onscreen_keyboard
  add_ss_menu_textures_to_vram
  create_taunt_options_menu
ENDSCRIPT

SCRIPT launch_onscreen_keyboard_from_taunt_menu
  RunScriptOnScreenElement id = current_menu_anchor menu_offscreen callback = pre_create_onscreen_keyboard callback_params = { allow_cancel keyboard_cancel_script = taunt_back_from_keyboard keyboard_done_script = set_taunt_preference keyboard_title = <title> <...> }
ENDSCRIPT

SCRIPT pre_create_onscreen_keyboard
  remove_pause_menu_textures_from_vram
  create_onscreen_keyboard allow_cancel keyboard_cancel_script = taunt_back_from_keyboard keyboard_done_script = set_taunt_preference keyboard_title = <title> <...>
ENDSCRIPT

SCRIPT generic_menu_update_arrows menu_id = current_menu
  IF not ObjectExists id = <up_arrow_id>
    RETURN
  ENDIF
  IF not ObjectExists id = <down_arrow_id>
    RETURN
  ENDIF
  IF MenuSelectedIndexIs id = <menu_id> first
    SetScreenElementProps {
      id = <up_arrow_id>
      rgba = [ 128 128 128 0 ]
    }
  ELSE
    SetScreenElementProps {
      id = <up_arrow_id>
      rgba = [ 128 128 128 128 ]
    }
  ENDIF
  IF MenuSelectedIndexIs id = <menu_id> last
    SetScreenElementProps {
      id = <down_arrow_id>
      rgba = [ 128 128 128 0 ]
    }
  ELSE
    SetScreenElementProps {
      id = <down_arrow_id>
      rgba = [ 128 128 128 128 ]
    }
  ENDIF
ENDSCRIPT

SCRIPT generic_menu_pad_back
  generic_menu_pad_back_sound
  IF GotParam callback
     <callback> <...>
  ENDIF
ENDSCRIPT

SCRIPT generic_menu_pad_choose
  IF GotParam callback
     <callback> <...>
  ENDIF
ENDSCRIPT

SCRIPT generic_menu_pad_back_sound
  PlaySound MenuBack vol = 100
ENDSCRIPT

SCRIPT generic_menu_pad_up_down_sound
ENDSCRIPT

SCRIPT generic_menu_pad_choose_sound
  PlaySound MenuSelect vol = 100
ENDSCRIPT

SCRIPT generic_menu_up_or_down_sound menu_id = current_menu
  IF GotParam up
    PlaySound MenuUp vol = 100
  ENDIF
  IF GotParam down
    PlaySound MenuDown vol = 100
  ENDIF
ENDSCRIPT

SCRIPT generic_menu_scroll_sideways_sound
  PlaySound gui_type02 vol = 100
ENDSCRIPT

SCRIPT parked_scroll_sideways_sound
  PlaySound gui_type02 vol = 100
ENDSCRIPT

SCRIPT generic_keyboard_sound
  PlaySound GUI_click06
ENDSCRIPT
