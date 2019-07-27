/**
 * Created by wjl on 2015/9/8.
 */

module.exports = {

    MSG:{
        ID_REQ : 0x01000000,
        ID_ACK : 0x02000000,
        ID_NTF : 0x04000000,

        //inter msg
        ID_BASE_INTER_SYSTEM: 0x00001000,
        ID_BASE_OUTER_GAME: 0x00020000,
        MSG_INNER_SERVER_REGISTER:0x00001000 + 0x08, //内部服务器注册

        MSG_SYS_LED:0x00008000 + 0x84,
        //out system tcp_sys_msg
        MSGID_GET_ROOM_CFG: 0x00020000 + 101,
        MSGID_QUICK_START: 0x00020000 + 102,
        MSGID_JOIN_TABLE: 0x00020000 + 103,
        MSGID_READY: 0x00020000 + 104,
        MSGID_LEAVE_TABLE: 0x00020000 + 105,
        MSGID_TABLE_EVENT: 0x00020000 + 106,
        MSGID_BROKEN: 0x00020000 + 107,
        MSGID_ROBOT_JOIN_TABLE: 0x00020000 + 108,
        MSGID_ROBOT_SIT_DOWN: 0x00020000 + 109,
        MSGID_BAI_STATUS: 0x00020000 + 111,
        MSGID_BAI_XIAZHU: 0x00020000 + 112,
        MSGID_BAI_BOARDINFO: 0x00020000 + 113,
        MSGID_BAI_WIN_HISTORY: 0x00020000 + 114,
        MSGID_BAI_UPDATE_COINS: 0x00020000 + 115
    },

    UserStatus:{
        user_status_connect_gamesvrd:0,
        user_status_sit:1,
        user_status_playing:2
    },

    PlayingState:{
        playing_state_normal:0,
        playing_state_trustship:1,
        playing_state_escape:2,
        playing_state_offline:3,
        playing_state_timeout:4
    },

    UserState:{
        user_state_unknown:0,		// 未知
        user_state_getout:1,		// 离开了
        user_state_free:2,			// 在房间站立
        user_state_sit:3,			// 坐在椅子上,没按开始(等待)
        user_state_ready:4,			// 同意游戏开始(等待)
        user_state_playing:5,		// 正在玩
        user_state_offline:6,		// 断线等待续玩
        user_state_lookon:7		    // 旁观
    },

    BaiRobotType:{
        robot_type_banker:0,
        robot_type_stand:1,
        robot_type_sitdown:2
    },

    BaiGameStatus:{
        game_status_unknown:0,
        game_status_xiazhu:1,
        game_status_fapai:2,
        game_status_jiesuan:3
    },

    BaiTimeOutType:{
        timeout_type_unknown:0,
        timeout_type_xiazhu:1,
        timeout_type_fapai:2,
        timeout_type_jiesuan:3,
        timeout_type_no_ready:4
    },

    UserIdentity:{
        identity_type_unknown:0,
        identity_type_player:1,
        identity_type_viewer:2,
        identity_type_robot:3
    },

    Login:{
        login_success:0,				// 成功
        login_failed_unknown:1,		    // 未知错误
        login_failed_low_version:2,	    // client版本过低,必须升级
        login_failed_forbidden:3,	    // 账号限制
        login_failed_id:4,			    // 错误的user id
        login_failed_token:5,			// 错误的token
        login_failed_multi:6		    // 多点登陆
    },

    QuickStart:{
        quick_start_success:0,				// 成功
        quick_start_failed_unknown:1,		// 未知错误
        quick_start_failed_coins_small:2,	// 金币不足
        quick_start_failed_coins_big:3,     // 金币太多
        quick_start_failed_param_roomid:4   // 房间ID错误
    },

    JoinTable:{
        join_table_success:0,			   // 成功
        join_table_reconnect:1,			   // 断线重连
        join_table_failed_unknown:2,	   // 未知错误
        join_table_failed_id:3,			   // 错误的table id
        join_table_failed_multi:4,		   // 在其他桌子未离开
        join_table_failed_getout:5,		   // 上局逃跑，游戏未结束
        join_table_failed_error_state:6,   // 游戏状态错误
        join_table_failed_already_full:7,  // 桌子已坐满
        join_table_failed_already_join:8,  // 玩家已在桌子上
        join_table_failed_limit_min:9,     // 金币太少
        join_table_failed_limit_max:10,    // 金币太多
        join_table_failed_seat_id:11,      // 座位号错误
        join_table_failed_seat_not_free:12 // 座位上有人
    },

    SitDown:{
        sit_down_success:0,              // 成功
        sit_down_failed_unknown:1,	     // 未知错误
        sit_down_failed_id:2,		     // 错误的桌子ID
        sit_down_failed_error_state:3,   // 游戏状态错误
        sit_down_failed_error_seat_id:4, // 错误的座位ID
        sit_down_failed_error_not_join:5,// 未加入桌子
        sit_down_failed_error_identity:6,// 错误的身份
        sit_down_failed_not_free:7,      // 玩家不是free状态
        sit_down_failed_other_here:8,    // 该座位已有人
        sit_down_failed_no_noble:9,      // 不是贵族
        sit_down_failed_is_banker:10     // 庄家不能入座
    },

    Ready:{
        ready_success:0,              // 成功
        ready_failed_unknown:1,       // 未知错误
        ready_failed_id:2,		      // 错误的桌子ID
        ready_failed_error_state:3,   // 游戏状态错误
        ready_failed_error_not_join:4,// 未加入桌子
        ready_failed_error_identity:5,// 错误的身份
        ready_failed_not_sit_down:6,  // 未坐下
        ready_failed_limit_min:7,     // 低于最低限制
        ready_failed_limit_max:8      // 高于最高限制
    },

    KickReason:{
        kick_reason_unknow:0,		// 未知
        kick_reason_no_ready:1,		// 指定时间内不ready
        kick_reason_limit_min:2,    // 低于最低限制
        kick_reason_limit_max:3,	// 高于最高限制
        kick_reason_offline:4,       // 断线
        kick_reason_limit_operatetime:5, //长时间不操作
        kick_reason_win_limit_min:6,  // 当天输的超过最高限制
        kick_reason_win_limit_max:7,  // 当天赢的超过最高限制
        kick_reason_game_close:8      // 小游戏关闭
    },

    LeaveTable:{
        leave_table_success:0,				// 成功
        leave_table_failed_unknown:1,		// 未知错误
        leave_table_failed_id:2,			// 错误的table id
        leave_table_failed_playing:3,		// 游戏中
        leave_table_failed_not_join:4,      // 没有加入桌子
        leave_table_failed_error_identity:5 // 错误的身份
    },

    TableEvent:{
        table_event_login:0,					// 玩家登陆
        table_event_join_table:1,				// 玩家加入桌子
        table_event_sit_down:2,					// 玩家坐下
        table_event_stand_up:3,					// 玩家站起
        table_event_ready:4,					// 玩家ready
        table_event_cancel_ready:5,				// 玩家取消ready
        table_event_leave_table:6,				// 玩家离开桌子
        table_event_force_quit:7,				// 玩家强退
        table_event_viewer_join_table:8,		// 旁观者进入
        table_event_viewer_leave_table:9,		// 旁观者退出
        table_event_kick_off:10,				// 玩家被踢出
        table_event_offline:11,					// 玩家断线
        table_event_reconnect:12,				// 断线重连
        table_event_game_start:13,				// 游戏开始
        table_event_game_end:14,				// 游戏结束
        table_event_game_info:15,				// 玩家gameinfo改变
        table_event_user_info:16,				// 玩家userinfo改变
        table_event_table_info:17,				// tableinfo改变
        table_event_broadcast:18,				// 广播
        table_event_trustee:19,					// 托管
        table_event_cancel_trustee:20			// 取消托管
    },

    Macro:{
        MAX_AVATAR:10,   //用户图像的最大值
        IDTYPE_GUEST:12,
        IDTYPE_MOBILE:13,
        IDTYPE_ROBOT:20,
        ROOMS:[101]
    },

    BIRD:{
        //HOST:'211.155.95.182',
        HOST:'10.44.171.87',
        PORT:9009,
        GAMEID:10003,
        TOKEN:'qifan_self_game_10003_KQ89hPpqYtlU8wPZ',
        STAT_TOKEN:'aXh4b28ubWVAZ21haWwuY29tCg=='
    },

    BROADCAST:{
        BROADCAST_TYPE_SYSTEM:1
    },

    COINSCHG:{
        COINSCHG_XIAZHU:1,
        COINSCHG_CAL:2
    }
};
