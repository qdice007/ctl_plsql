CREATE OR REPLACE PACKAGE ctl_task_main_pkg 
IS

    /*
     * 名称: ctl_task_main_pkg
     * 类型: 包头
     * 描述: 任务调度主控包
     * 包含: 
     *       ctl_loop_main_prc   - 主控循环
     *       ctl_main_log_prc    - 实时输出日志
     *       ctl_loop_msg_prc    - 发送管道消息
     *       ctl_loop_sfile_prc  - 源文件登记与统计
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     *
     */
    
    /*
     * 名称: ctl_loop_main_prc
     * 类型: 存储过程
     * 描述: 主控循环
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_loop_main_prc ;

    /*
     * 名称: ctl_main_log_prc
     * 类型: 存储过程
     * 描述: 实时输出日志
     * 参数: 
     *       p_log_file     IN  UTL_FILE.FILE_TYPE  --文件句柄
     *       p_msg_content  IN  VARCHAR2            --日志消息的内容
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_main_log_prc 
        ( p_log_file     IN  UTL_FILE.FILE_TYPE
         ,p_msg_content  IN  VARCHAR2
        ) ;

    /*
     * 名称: ctl_loop_msg_prc
     * 类型: 存储过程
     * 描述: 发送管道消息
     * 参数: 
     *       p_pipe_name    IN  VARCHAR2  --管道名称
     *       p_msg_content  IN  VARCHAR2  --管道消息内容
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_loop_msg_prc 
        ( p_pipe_name    IN  VARCHAR2
         ,p_msg_content  IN  VARCHAR2
        ) ;

    /*
     * 名称: ctl_loop_sfile_prc
     * 类型: 存储过程
     * 描述: 源文件登记与统计
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_loop_sfile_prc ;


END ctl_task_main_pkg ;
/



CREATE OR REPLACE PACKAGE BODY ctl_task_main_pkg 
IS

    /*
     * 名称: ctl_task_main_pkg
     * 类型: 包头
     * 描述: 任务调度主控包
     * 包含: 
     *       ctl_loop_main_prc   - 主控循环
     *       ctl_main_log_prc    - 实时输出日志
     *       ctl_loop_msg_prc    - 发送管道消息
     *       ctl_loop_sfile_prc  - 源文件登记与统计
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     *
     */
    
    /*
     * 名称: ctl_loop_main_prc
     * 类型: 存储过程
     * 描述: 主控循环
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_loop_main_prc
    IS
        -- 日志文件所在DIRECTORY
        v_log_dir  VARCHAR2(100) := 'CTL_LOGS_MAIN' ;
        -- 当天日期(字符串YYYYMMDD)
        v_curr_date  VARCHAR2(8) := TO_CHAR(SYSDATE, 'YYYYMMDD') ;
        -- 管道名称
        v_pipe_name  VARCHAR2(12) := 'CTL_MAIN' ;
        -- 管道相关的运行结果
        v_pipe_result  INTEGER ;
        -- 管道接收的消息
        v_pipe_buf  VARCHAR2(64) ;
        -- 测试用
        v_loop_count  INTEGER  := 0 ;
        -- 日志文件(文件句柄)
        v_log_file  UTL_FILE.FILE_TYPE ;
        -- 睡眠时间(单位 秒)
        v_sleep_seconds  INTEGER  := 30 ;
    BEGIN
        -- 打开日志文件,写入主控循环启动的相关日志信息
        v_log_file := UTL_FILE.FOPEN_NCHAR(v_log_dir, 'ctl_main_'||v_curr_date||'.log', 'a') ;
        
        -- 创建管道
        v_pipe_result := DBMS_PIPE.CREATE_PIPE(v_pipe_name) ;

        -- 无限循环
        <<MAIN_LOOP>> 
        LOOP
            EXIT WHEN v_loop_count > 100 ;  --测试用,100次循环
            -- 如果当前日期已改变,则切换日志文件
            IF v_curr_date != TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 
                UTL_FILE.FCLOSE(v_log_file) ;
                v_log_file := UTL_FILE.FOPEN_NCHAR(v_log_dir, 'ctl_main_'||v_curr_date||'.log', 'a') ;
                ctl.ctl_main_log_prc(v_log_file, '[INFO] 主控更换日志.') ;
            END IF ;
            -- 输出日志消息
            ctl.ctl_main_log_prc(v_log_file, '[INFO] I am alive !  --' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')) ;
            
            -- 检查是否收到消息
            IF DBMS_PIPE.RECEIVE_MESSAGE(v_pipe_name, 0) = 0 THEN
                -- 循环处理每个消息
                LOOP
                    EXIT WHEN DBMS_PIPE.NEXT_ITEM_TYPE = 0 ;
                    -- 解包消息
                    DBMS_PIPE.UNPACK_MESSAGE(v_pipe_buf) ;
                    -- 如果消息是'STOP',就退出循环,结束存储过程
                    -- 如果消息是'INFO',就输出消息至日志文件
                    IF v_pipe_buf = 'STOP' THEN
                        -- 退出主循环
                        EXIT MAIN_LOOP ;
                    ELSIF v_pipe_buf = 'INFO' THEN
                        ctl.ctl_main_log_prc(v_log_file, '[INFO] 测试 -- ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')) ;
                    END IF ;
                END LOOP ;
            END IF ;
            -- 休眠(单位: 秒)
            DBMS_LOCK.SLEEP(v_sleep_seconds) ;
            v_loop_count := v_loop_count + 1 ;  --测试用
        END LOOP MAIN_LOOP ;
        ctl.ctl_main_log_prc(v_log_file, '[INFO] 收到退出信号, 主循环已结束运行.  --' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')) ;
        ctl.ctl_main_log_prc(v_log_file, '[INFO] END') ;
        -- 关闭管道和文件句柄
        v_pipe_result := DBMS_PIPE.REMOVE_PIPE(v_pipe_name) ;
        UTL_FILE.FCLOSE(v_log_file) ;
    EXCEPTION
        WHEN OTHERS THEN
            UTL_FILE.FCLOSE(v_log_file) ;
            v_pipe_result := DBMS_PIPE.REMOVE_PIPE(v_pipe_name) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ctl_loop_main_prc ;


    /*
     * 名称: ctl_main_log_prc
     * 类型: 存储过程
     * 描述: 实时输出日志
     * 参数: 
     *       p_log_file     IN  UTL_FILE.FILE_TYPE  --文件句柄
     *       p_msg_content  IN  VARCHAR2            --日志消息的内容
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_main_log_prc
        ( p_log_file     IN  UTL_FILE.FILE_TYPE
         ,p_msg_content  IN  VARCHAR2
        )
    IS
        -- 必须为自治事务
        PRAGMA AUTONOMOUS_TRANSACTION ;
    BEGIN
        -- 给指定的文件句柄输出传入的字符串内容
        UTL_FILE.PUT_LINE_NCHAR(p_log_file, p_msg_content) ;
        -- 立刻刷新输出写入文件
        UTL_FILE.FFLUSH(p_log_file) ;
        COMMIT ;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ctl_main_log_prc ;


    /*
     * 名称: ctl_loop_msg_prc
     * 类型: 存储过程
     * 描述: 发送管道消息
     * 参数: 
     *       p_pipe_name    IN  VARCHAR2  --管道名称
     *       p_msg_content  IN  VARCHAR2  --管道消息内容
     * 返回: 无
     * 创建: LiBing  2017-09-20
     * 修改:
     */
    PROCEDURE ctl_loop_msg_prc 
        ( p_pipe_name    IN  VARCHAR2
         ,p_msg_content  IN  VARCHAR2
        ) 
    IS 
        -- 管道的相关运行结果
        v_pipe_result  INTEGER ;
    BEGIN
        -- 打包消息
        DBMS_PIPE.PACK_MESSAGE(NVL(p_msg_content, 'NONE')) ;
        -- 发送消息
        v_pipe_result := DBMS_PIPE.SEND_MESSAGE(UPPER(p_pipe_name)) ;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ctl_loop_msg_prc ;

    PROCEDURE ctl_loop_sfile_prc 
    IS
        -- 日志文件所在DIRECTORY
        v_log_dir  VARCHAR2(100) := 'CTL_LOGS_FILE' ;
        -- 当天日期(字符串YYYYMMDD)
        v_curr_date  VARCHAR2(8) := TO_CHAR(SYSDATE, 'YYYYMMDD') ;
        -- 程序运行开始时间
        v_prg_run_time  DATE := SYSDATE ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(200) := 'None' ;
        -- 管道名称
        v_pipe_name  VARCHAR2(12) := 'CTL_FILE' ;
        -- 函数或SQL返回结果
        v_result  INTEGER ;
        v_count  INTEGER ;
        -- 数据文件统计结果表中对应任务的最大日期
        v_file_max_dt  DATE ;
        -- 年份
        v_year  VARCHAR2(4) ;
        -- 月日
        v_month_day  VARCHAR2(4) ;
        -- 数据文件存储的基本路径
        v_file_base_dir  VARCHAR2(200) ;
        -- 数据文件存储的全路径
        v_file_full_dir  VARCHaR2(200) ;
        -- 数据文件是否存在的标识
        v_file_exists  BOOLEAN ;
        -- 数据文件的长度
        v_file_length  NUMBER(20) ;
        -- 数据文件所在操作系统的文件块大小
        v_file_blockSize  NUMBER ;
        -- 管道消息
        v_pipe_msg  VARCHAR2(100) ;
        -- 管道消息解析
        v_msg_1  VARCHAR2(50) ;
        v_msg_2  VARCHAR2(50) ;
        -- 睡眠时间(单位 秒)
        v_sleep_seconds  INTEGER  := 60 ;

        -- 管道创建失败
        e_pipe_crt_fail EXCEPTION ;
    BEGIN
        -- 获取当前日期
        v_curr_date := TO_CHAR(SYSDATE, 'YYYYMMDD') ;
        -- 打开日志文件,写入主控循环启动的相关日志信息
        v_log_file := UTL_FILE.FOPEN_NCHAR(v_log_dir, 'ctl_file_'||v_curr_date||'.log', 'a') ;
        -- 创建管道
        v_pipe_result := DBMS_PIPE.CREATE_PIPE(v_pipe_name) ;
        -- 无限循环
        <<MAIN_LOOP>> 
        -- 创建私有管道 
        v_result := DBMS_PIPE.CREATE_PIPE(v_pipe_name) ;
        -- 程序无限循环,只能通过管道接收STOP指令才能退出
        <<MAIN_LOOP>>
        LOOP 
            -- 根据任务配置表中每项任务的goal_data_dt,填充数据文件统计结果表
            FOR rec_task IN ( SELECT task_name
                                    ,goal_data_dt
                                FROM hfdp.ctl_task_conf_tbl
                               WHERE is_valid = '1' )
            LOOP 
                -- 取数据文件统计结果表中对应任务的最大日期
                SELECT MAX(TO_DATE(NVL(data_dt, TO_CHAR(SYSDATE,'YYYYMMDD')),'YYYYMMDD'))
                  INTO v_file_max_dt 
                  FROM hfdp.ctl_file_sum_tbl 
                 WHERE task_name = rec_task.task_name ;
                -- 循环填充数据文件统计结果表
                WHILE (v_file_max_dt <= rec_task.goal_data_dt)
                LOOP 
                    INSERT INTO hfdp.ctl_file_sum_tbl VALUES 
                        ( TO_CHAR(v_file_max_dt,'YYYYMMDD') 
                         ,rec_task.task_name 
                         ,'0' 
                         ,0 
                        ) ;
                    v_file_max_dt := v_file_max_dt + 1 ;
                END LOOP ;
                COMMIT ;
            END LOOP ;
            -- 统计文件登记情况,更新统计结果表的is_ready标识
            FOR rec IN ( SELECT t1.task_name
                               ,t2.data_dt
                           FROM ( SELECT task_name
                                        ,COUNT (1)  AS  conf_count
                                    FROM hfdp.ctl_file_conf_tbl 
                                   WHERE is_valid = '1' 
                                   GROUP BY task_name ) t1
                          INNER JOIN
                                ( SELECT data_dt
                                        ,task_name
                                        ,COUNT(1)  AS reg_count
                                    FROM hfdp.ctl_file_reg_tbl 
                                   GROUP by task_name, data_dt ) t2
                             ON t1.task_name = t2.task_name
                          WHERE t1.conf_count = t2.reg_count )
            LOOP 
                UPDATE hfdp.ctl_file_sum_tbl 
                   SET is_ready = '1'
                 WHERE task_name = rec.task_name 
                   AND data_dt = rec.data_dt ;
            END LOOP ;
            COMMIT ;
            
            -- 获取数据文件存储的全局基本路径
            SELECT param_value
              INTO v_file_base_dir 
              FROM hfdp.uti_hfdp_params_tbl 
             WHERE obj_name = 'FILE_STORE' 
               AND is_valid = '1' ;
            
            -- 根据数据文件配置表,检查数据文件是否已存在,如果在,则登记到数据文件登记表中
            -- 还需要补充完整各源系统的DIRECTORY创建与文件查找
            FOR rec IN ( SELECT t1.data_dt 
                               ,t1.task_name 
                               ,t2.param_value  AS  dir_name
                           FROM hfdp.ctl_file_sum_tbl t1
                          INNER JOIN hfdp.uti_hfdp_params_tbl t2
                             ON t1.task_name = t2.obj_name 
                          WHERE t1.is_ready = 0 
                            AND TO_DATE(t1.data_dt,'YYYYMMDD') <= SYSDATE
                          ORDER BY TO_DATE(t1.data_dt,'YYYYMMDD') )
            LOOP 
                -- 从日期中解析出年与月日
                v_year := SUBSTR(rec.data_dt, 1, 4) ;
                v_month_day := SUBSTR(rec.data_dt, 5) ;
                -- 拼接数据文件存放的全路径,并创建DIRECTORY
                v_file_full_dir := v_file_base_dir||rec.dir_name||v_year||'/'||v_month_day||'/' ;
                EXECUTE IMMEDIATE 
                    'CREATE OR REPLACE DIRECTORY FILE_DIR AS :v_1' USING v_file_full_dir ;
                -- 根据数据文件配置表,循环检查每一个数据文件
                FOR rec_file IN ( SELECT file_base_name||'_'||rec.data_dt||'.TXT'  AS  file_name 
                                    FROM hfdp.ctl_file_conf_tbl 
                                   WHERE task_name = rec.task_name 
                                     AND sys_name = rec.dir_name 
                                     AND is_valid = '1' )
                LOOP 
                    BEGIN
                        UTL_FILE.FGETATTR
                            ( location     => 'FILE_DIR' 
                             ,filename     => rec_file.file_name 
                             ,fexists      => v_file_exists     --返回结果: 文件是否存在的布尔值
                             ,file_length  => v_file_length     --返回结果: 文件长度(单位Bytes)
                             ,block_size   => v_file_blockSize  --返回结果: 操作系统的文件块大小(单位Bytes)
                            ) ;
                        -- 如果数据文件存在则插入数据文件登记表
                        IF v_file_exists THEN 
                            INSERT INTO hfdp.ctl_file_reg_tbl 
                            VALUES 
                                ( rec.data_dt
                                 ,rec.task_name 
                                 ,rec.dir_name 
                                 ,rec_file.file_name 
                                 ,v_file_length 
                                ) ;
                        ELSE 
                            CONTINUE ;
                        END IF ;
                    EXCEPTION 
                        WHEN OTHERS THEN
                            CONTINUE ;
                    END ;
                END LOOP ;
                COMMIT ;
            END LOOP ;
            
            -- 检查管道中是否有消息 
            IF ( DBMS_PIPE.RECEIVE_MESSAGE(v_pipe_name, 0)=0 ) THEN 
                -- 解包消息 
                DBMS_PIPE.UNPACK_MESSAGE(v_pipe_msg) ;
                -- 解析消息
                v_msg_1 := UPPER(SUBSTR(v_pipe_msg, 1, INSTR(v_pipe_msg, '$')-1)) ; 
                v_msg_2 := UPPER(SUBSTR(v_pipe_msg, INSTR(v_pipe_msg, '$')+1)) ;
                IF (v_msg_1=v_pipe_name AND v_msg_2='STOP') THEN
                    -- 退出无限循环
                    EXIT MAIN_LOOP;
                END IF ;
            END IF ;
            
            -- 睡眠 
            DBMS_LOCK.SLEEP(v_sleep_seconds) ;
        END LOOP ;

    EXCEPTION
        WHEN OTHERS THEN 
            v_result := DBMS_PIPE.REMOVE_PIPE(v_pipe_name) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ctl_loop_sfile_prc;

END ctl_task_main_pkg ;
/