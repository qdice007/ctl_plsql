CREATE OR REPLACE PACKAGE ctl_task_tools_pkg 
IS

   /*
    * 程序: CTL_TASK_TOOLS_PKG
    * 类型: 存储过程包
    * 功能: 任务调度
    *       - 更新任务状态程序
    *       - 任务主控循环程序 
    *       - 作业执行循环程序
    *       - 数据文件登记与统计循环程序    
    *       - 消息发送程序
    *       - 任务所需数据文件统计
    *       - 作业实例化程序
    *       - 作业执行程序
    *       - 任务完成后清理
    * 创建: LiBing  2016-12-21
    * 修改:
    *
    */


   /*
    * 程序: CTL_TASK_STAT_FNC 
    * 类型: 函数
    * 功能: 更新任务状态
    * 参数: p_table        模块名称('CONFIG'表示配置表,INSTANCE表示实例表)
    *       p_task_name    调度任务的名称
    *       p_task_status  任务状态值(PAUSE表示人工干预暂停,ERROR表示任务运行出错)
    * 创建: LiBing  2016-12-26
    * 修改:
    */
    FUNCTION ctl_task_stat_fnc 
        ( p_task_name    IN  VARCHAR2
         ,p_task_status  IN  VARCHAR2 
        ) 
        RETURN INTEGER ;

        
/*
    * 程序: CTL_LOOP_MAIN_PRC 
    * 类型: 存储过程
    * 功能: 任务主控循环程序
    * 参数: 
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_loop_main_prc ;


/*
    * 程序: CTL_LOOP_EXEC_PRC 
    * 类型: 存储过程
    * 功能: 作业执行循环程序
    * 参数: 
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_loop_exec_prc ;


/*
    * 程序: CTL_LOOP_FILE_PRC 
    * 类型: 存储过程
    * 功能: 数据文件登记与统计循环程序
    * 参数: 
    * 创建: LiBing  2016-12-27
    * 修改:
*/
    PROCEDURE ctl_loop_file_prc ;


/*
    * 程序: CTL_LOOP_MSG_PRC 
    * 类型: 存储过程
    * 功能: 消息发送程序
    * 参数: p_pipe_name  管道名称(如为空,默认为PIPE_MAIN)
    *       p_msg        消息内容(如为空,默认为PIPE_MAIN$STOP)
    * 创建: LiBing  2016-12-21
    * 修改: 
*/
    PROCEDURE ctl_loop_msg_prc 
        ( p_pipe_name  IN  VARCHAR2 
         ,p_msg        IN  VARCHAR2
        ) ;


/*
    * 程序: CTL_FILE_COUNT_PRC 
    * 类型: 函数
    * 功能: 任务所需数据文件统计
    * 参数: 
    * 创建: LiBing  2016-12-26
    * 修改:

    FUNCTION ctl_file_count_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_data_dt    IN  VARCHAR2 
        ) 
        RETURN INTEGER ;
*/


/*
    * 程序: CTL_JOB_INST_PRC 
    * 类型: 存储过程
    * 功能: 作业实例化
    * 参数: 
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_job_inst_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_data_dt    IN  VARCHAR2 
        ) ;


/*
    * 程序: CTL_JOB_EXEC_PRC 
    * 类型: 存储过程
    * 功能: 作业执行
    * 参数: p_task_name  调度任务名称
    *       p_job_name   作业名称
    *       p_job_prog   作业实际执行的命令内容
    *       p_data_dt    所属任务的数据日期
    * 创建: LiBing  2016-12-26
    * 修改:
*/
    PROCEDURE ctl_job_exec_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_job_name   IN  VARCHAR2 
         ,p_job_prog   IN  VARCHAR2
         ,p_data_dt    IN  VARCHAR2 
        ) ;


/*
    * 程序: CTL_TASK_CLEAN_PRC 
    * 类型: 存储过程
    * 功能: 任务完成后清理
    * 参数: p_task_name  任务名称
    *       p_mode       处理模式(1正常完成任务 2节假日不触发任务 3异常中断任务清理)
    *       p_data_dt    任务的数据日期
    * 创建: LiBing  2016-12-26
    * 修改:
*/
    PROCEDURE ctl_task_clean_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_mode       IN  VARCHAR2 
         ,p_data_dt    IN  VARCHAR2 
        ) ;


END ;
/




CREATE OR REPLACE PACKAGE BODY ctl_task_tools_pkg 
IS 


/*
    * 程序: CTL_TASK_STAT_FNC 
    * 类型: 函数
    * 功能: 更新任务状态
    * 参数: p_task_name    调度任务的名称
    *       p_task_status  任务状态值(PAUSE表示人工干预暂停,ERROR表示任务运行出错)
    * 创建: LiBing  2016-12-26
    * 修改:
*/
    FUNCTION ctl_task_stat_fnc 
        ( p_task_name    IN  VARCHAR2
         ,p_task_status  IN  VARCHAR2 
        ) 
        RETURN INTEGER 
    IS 
        -- 程序运行开始时间
        v_prg_run_time  DATE := sysdate ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(200) := 'None' ;
    BEGIN
        -- 程序运行开始写日志
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_STAT_FNC'
             ,'更新任务状态'
             ,USER
             ,'CTL_TASK_INST_TBL,CTL_TASK_CONF_TBL'
             ,v_prg_run_time
             ,NULL 
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result 
             ,'CTL'
            ) ;
        -- 更新任务配置表或任务实例表中的任务状态和人工干预标志 
        -- 如果任务状态值为ERROR,则只需要更新任务配置表,因为实例表已经在
        --     作业循环程序中实时更新
        -- 如果任务状态值为PAUSE,意味着是人工干预,需要更新配置表和实例表
        IF p_task_status = 'ERROR' THEN
                UPDATE hfdp.ctl_task_conf_tbl 
                   SET task_status = 'ERROR' 
                 WHERE task_name = UPPER(p_task_name) 
                   AND is_valid = '1' ;
        ELSIF p_task_status = 'PAUSE' THEN 
                UPDATE hfdp.ctl_task_conf_tbl 
                   SET task_status = 'PAUSE'
                      ,manual_flag = 1 
                 WHERE task_name = UPPER(p_task_name) 
                   AND is_valid = '1' ;
                UPDATE hfdp.ctl_task_inst_tbl 
                   SET task_status = 'PAUSE' 
                      ,manual_flag = 1                    
                 WHERE task_name = UPPER(p_task_name) ;
        END IF ;
        COMMIT ;
        -- 任务运行成功写日志
        v_prg_run_result := '更新任务状态成功 | '||p_task_name||' | '||p_task_status ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_STAT_FNC'
             ,'更新任务状态'
             ,USER
             ,'CTL_TASK_INST_TBL,CTL_TASK_CONF_TBL'
             ,v_prg_run_time
             ,SYSDATE 
             ,0
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result 
             ,'CTL'
            ) ;
        RETURN 0 ;
    EXCEPTION 
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_STAT_FNC'
             ,'更新任务状态'
             ,USER
             ,'CTL_TASK_INST_TBL,CTL_TASK_CONF_TBL'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RETURN 1 ;
    END ;


/*
    * 程序: CTL_LOOP_MAIN_PRC 
    * 类型: 存储过程
    * 功能: 调度主控循环程序
    * 参数: 
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_loop_main_prc 
    IS
        -- 程序运行开始时间
        v_prg_run_time  DATE := sysdate ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(200) := 'None' ;
        -- 管道名称
        v_pipe_name  VARCHAR2(12) := 'PIPE_MAIN' ;
        -- 函数或SQL返回结果
        v_result  INTEGER ;
        v_count  INTEGER ;
        -- 任务的不触发规则SQL
        v_not_run_sql  VARCHAR2(500) ;
        -- 管道消息
        v_pipe_msg  VARCHAR2(100) ;
        -- 管道消息解析
        v_msg_1  VARCHAR2(50) ;
        v_msg_2  VARCHAR2(50) ;
        -- 睡眠时间(单位 秒)
        v_sleep_seconds  INTEGER  := 300 ;
    BEGIN
        -- 程序运行开始日志 
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_MAIN_PRC'
             ,'任务调度主控循环'
             ,USER
             ,'PIPE_MAIN'
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        -- 创建私有管道 
        v_result := DBMS_PIPE.CREATE_PIPE(v_pipe_name) ;
        -- 程序无限循环,只能通过管道PIPE_MAIN接收PIPE_MAIN$STOP指令才能退出
        LOOP
            -- 检查任务配置表,并与任务实例化表关联,获取已实例化的信息(如果有)
            -- 如果满足以下条件,就开始任务实例化和作业实例化 
            -- 1) 任务状态正常
            -- 2) 任务没有被人工干预
            -- 3) 数据日期正常
            -- 4) 数据日期所对应的数据文件已齐备
            -- 5) 任务在任务实例表中如果存在,则状态不能是RUNNING
            FOR rec_task IN ( SELECT t1.task_name 
                                    ,t1.not_run_rule 
                                    ,t1.jobs_concurrency 
                                    ,TO_CHAR(t1.next_data_dt, 'YYYYMMDD')  AS  next_data_dt
                                    ,NVL(t2.task_name, 'NONE')  AS  inst_task_name
                                    ,NVL(t2.data_dt, '99991231')  AS  inst_data_dt
                                    ,NVL(t2.task_status, 'NONE')  AS  inst_task_status
                                    ,NVL(TO_CHAR(t2.manual_flag), '9')  AS  inst_manual_flag 
                                    ,NVL(t3.is_ready, '0')  AS  file_is_ready 
                                FROM hfdp.ctl_task_conf_tbl t1        --任务配置表
                                LEFT JOIN hfdp.ctl_task_inst_tbl t2   --任务实例表
                                  ON t1.task_name = t2.task_name 
                                LEFT JOIN hfdp.ctl_file_sum_tbl t3    --数据文件统计表
                                  ON t1.task_name = t3.task_name AND 
                                     t1.next_data_dt = t3.data_dt 
                               WHERE t1.is_valid = '1' 
                                 AND t1.task_status = 'READY' 
                                 AND t1.manual_flag = 0 
                                 AND t1.next_data_dt <= t1.goal_data_dt 
                                 AND t2.task_status <> 'RUNNING' 
                                 AND t3.is_ready = 1 
                            )
            LOOP
                -- 如果有且满足不触发规则,则调用ctl_task_clean_prc,然后CONTINUE
                SELECT NVL(not_run_rule, 'NONE')
                  INTO v_not_run_sql 
                  FROM hfdp.ctl_task_conf_tbl 
                 WHERE task_name = rec_task.task_name 
                   AND is_valid = '1' ;
                IF (v_not_run_sql <> 'NONE') THEN 
                    EXECUTE IMMEDIATE v_not_run_sql INTO v_result USING TO_CHAR(rec_task.next_data_dt,'YYYYMMDD') ;
                    IF (v_result = 1) THEN
                        -- 调用ctl_task_clean_prc来处理节假日任务
                        hfdp.ctl_task_tools_pkg.ctl_task_clean_prc
                            (rec_task.task_name, '2', rec_task.next_data_dt) ;
                        CONTINUE ;
                    END IF ;
                END IF ;
                -- 任务实例化
                IF (rec_task.inst_task_name='NONE') THEN
                    INSERT INTO hfdp.ctl_task_inst_tbl VALUES
                        ( rec_task.task_name 
                         ,rec_task.next_data_dt 
                         ,rec_task.jobs_concurrency 
                         ,SYSDATE 
                         ,NULL 
                         ,'RUNNING' 
                         ,0
                         ,0
                        ) ;
                ELSIF (rec_task.task_name = rec_task.inst_task_name AND 
                       rec_task.next_data_dt=rec_task.inst_data_dt) THEN 
                    UPDATE hfdp.ctl_task_inst_tbl 
                       SET manual_flag = 0 
                          ,task_status = 'RUNNING' 
                     WHERE task_name = rec_task.task_name 
                       AND data_dt = rec_task.next_data_dt ;
                ELSE 
                    EXECUTE IMMEDIATE 
                        'DELETE FROM hfdp.ctl_task_inst_tbl WHERE task_name=:v_1' USING rec_task.task_name ;
                    INSERT INTO hfdp.ctl_task_inst_tbl VALUES
                        ( rec_task.task_name 
                         ,rec_task.next_data_dt 
                         ,rec_task.jobs_concurrency 
                         ,SYSDATE 
                         ,NULL 
                         ,'RUNNING' 
                         ,0
                         ,0
                        ) ;
                END IF ;
                COMMIT ;
                -- 作业实例化
                SELECT COUNT(1) 
                  INTO v_count 
                  FROM hfdp.ctl_job_inst_tbl 
                 WHERE task_name = rec_task.task_name 
                   AND data_dt = rec_task.next_data_dt ; 
                IF (v_count=0) THEN
                    -- 调用作业实例化程序
                    hfdp.ctl_task_tools_pkg.ctl_job_inst_prc
                        ( rec_task.task_name, rec_task.next_data_dt ) ;
                END IF ;
            END LOOP ;
            -- 检查管道中是否有消息 
            IF ( DBMS_PIPE.RECEIVE_MESSAGE(v_pipe_name, 0) = 0 ) THEN
                -- 解包消息 
                DBMS_PIPE.UNPACK_MESSAGE(v_pipe_msg) ;
                -- 解析消息
                v_msg_1 := UPPER(SUBSTR(v_pipe_msg, 1, INSTR(v_pipe_msg, '$')-1)) ; 
                v_msg_2 := UPPER(SUBSTR(v_pipe_msg, INSTR(v_pipe_msg, '$')+1)) ;
                IF ( v_msg_1='PIPE_MAIN' AND v_msg_2='STOP' ) THEN
                    -- 退出无限循环
                    EXIT ;
                ELSIF v_msg_2 IN ('PAUSE', 'ERROR') THEN 
                    -- 设置对应v_msg_1的任务的状态值为v_msg_2
                    v_result := hfdp.ctl_task_tools_pkg.ctl_task_stat_fnc
                                    ( v_msg_1, v_msg_2) ;
                END IF ;
            END IF ;
            
            -- 睡眠 
            DBMS_LOCK.SLEEP(v_sleep_seconds) ;
        END LOOP ;
        
        -- 程序运行结束写日志
        v_prg_run_result := '任务调度主控程序退出' ;
        v_result := DBMS_PIPE.REMOVE_PIPE(v_pipe_name) ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_MAIN_PRC'
             ,'任务调度主控循环'
             ,USER
             ,'PIPE_MAIN'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_MAIN_PRC'
             ,'任务调度主控循环'
             ,USER
             ,'PIPE_MAIN'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;


/*
    * 程序: CTL_LOOP_EXEC_PRC 
    * 类型: 存储过程
    * 功能: 作业执行循环程序
    * 参数: 
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_loop_exec_prc 
    IS
        -- 程序运行开始时间
        v_prg_run_time  DATE := sysdate ;
        -- 程序运行结果
        v_prg_run_result  VARCHAR2(200) := 'None' ; 
        -- 管道名称
        v_pipe_name  VARCHAR2(12) := 'PIPE_EXEC' ;
        -- 函数返回结果
        v_result  INTEGER ;
        -- 正在运行的job个数
        v_job_running_count  INTEGER ;
        -- PLSQL块文本
        v_plsql  VARCHAR2(1000) ;
        -- 管道消息
        v_pipe_msg  VARCHAR2(100) ;
        -- 管道消息解析
        v_msg_1  VARCHAR2(50) ;
        v_msg_2  VARCHAR2(50) ;
        -- 睡眠时间(单位 秒)
        v_sleep_seconds  INTEGER  := 60 ;
    BEGIN
        -- 程序运行开始日志 
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_EXEC_PRC'
             ,'作业执行循环程序'
             ,USER
             ,'PIPE_EXEC'
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        
        -- 创建私有管道 
        v_result := DBMS_PIPE.CREATE_PIPE(v_pipe_name) ;
        
        -- 程序无限循环,只能通过管道接收STOP指令才能退出
        LOOP 
            -- 判断是否已有任务全部完成了作业
            FOR rec_task IN ( SELECT y.task_name
                                    ,y.data_dt 
                                FROM ( SELECT x.task_name
                                             ,x.data_dt 
                                             ,COUNT(1)  AS  job_no 
                                             ,SUM(x.job_status)  AS job_suc 
                                         FROM ( SELECT t1.task_name
                                                      ,t1.data_dt 
                                                      ,t2.job_name 
                                                      ,CASE t2.job_status 
                                                           WHEN 'SUCCESS' THEN 1
                                                           ELSE 0
                                                       END  AS  job_status 
                                                  FROM hfdp.ctl_task_inst_tbl t1 
                                                  LEFT JOIN hfdp.ctl_job_inst_tbl t2 
                                                    ON t1.task_name = t2.task_name AND
                                                       t1.data_dt = t2.data_dt 
                                                 WHERE t1.task_status = 'RUNNING') x 
                                        GROUP BY x.task_name ) y
                               WHERE y.job_no = y.job_suc )
            LOOP 
                -- 更新任务实例表中的任务状态
                UPDATE hfdp.ctl_task_inst_tbl 
                   SET task_status = 'SUCCESS' 
                      ,end_dt = SYSDATE 
                 WHERE task_name = rec_task.task_name ;
                -- 调用任务完成后清理程序
                hfdp.ctl_task_tools_pkg.ctl_task_clean_prc
                    (rec_task.task_name, '1', rec_task.data_dt) ;
            END LOOP ;
            -- 循环处理作业实例表中的每个正在运行的任务
            FOR rec_task IN ( SELECT task_name 
                                    ,jobs_concurrency 
                                    ,data_dt 
                                FROM hfdp.ctl_task_inst_tbl 
                               WHERE task_status = 'RUNNING' 
                                 AND error_alert = 0 
                                 AND manual_flag = 0 )
            LOOP 
                -- 将有出错job的任务的error_alert置为1,并更新任务状态,并CONTINUE循环
                SELECT COUNT(1)
                  INTO v_result 
                  FROM hfdp.ctl_job_inst_tbl 
                 WHERE task_name = rec_task.task_name 
                   AND data_dt = rec_task.data_dt 
                   AND job_status = 'ERROR' ;
                IF (v_result <> 0) THEN 
                    UPDATE hfdp.ctl_task_inst_tbl 
                       SET task_status = 'ERROR' 
                          ,end_dt = SYSDATE 
                     WHERE task_name = rec_task.task_name ;
                    COMMIT ;
                    -- 发消息给PIPE_MAIN管道
                    hfdp.ctl_task_tools_pkg.ctl_loop_msg_prc('PIPE_MAIN', rec_task.task_name||'$ERROR') ;
                    CONTINUE ;
                END IF ;
                -- 获取当前正在执行的job个数,并循环执行状态为READY的作业
                SELECT COUNT(1) 
                  INTO v_job_running_count 
                  FROM hfdp.ctl_job_inst_tbl 
                 WHERE task_name = rec_task.task_name 
                   AND job_status = 'RUNNING' ; 
                
                FOR rec_job IN ( SELECT task_name 
                                       ,job_prog 
                                       ,job_name 
                                       ,data_dt 
                                   FROM hfdp.ctl_job_inst_tbl 
                                  WHERE data_dt = rec_task.data_dt 
                                    AND task_name = rec_task.task_name 
                                    AND job_status = 'READY'
                                  ORDER BY tree_level )
                LOOP 
                    EXIT WHEN v_job_running_count >= 10 ;
                    v_plsql := 'BEGIN hfdp.ctl_task_tools_pkg.ctl_job_exec_prc('''||
                               rec_job.task_name ||
                               ''', ''' ||
                               rec_job.job_name ||
                               ''', ''' ||
                               rec_job.job_prog ||
                               ''', ''' ||
                               rec_job.data_dt ||
                               ''') ; END ;' ;
                    DBMS_SCHEDULER.CREATE_JOB
                        ( job_name   => rec_job.task_name||'_'||TO_CHAR(SYSDATE,'yyyymmddhh24miss')||'_'||DBMS_RANDOM.STRING('X',20)
                         ,job_type   => 'PLSQL_BLOCK' 
                         ,job_action => v_plsql 
                         ,enabled    => TRUE 
                        ) ;
                    v_job_running_count := v_job_running_count + 1 ;
                END LOOP ;
            END LOOP ;
            
            -- 检查管道中是否有消息 
            IF ( DBMS_PIPE.RECEIVE_MESSAGE(v_pipe_name, 0)=0 ) THEN 
                -- 解包消息 
                DBMS_PIPE.UNPACK_MESSAGE(v_pipe_msg) ;
                -- 解析消息
                v_msg_1 := UPPER(SUBSTR(v_pipe_msg, 1, INSTR(v_pipe_msg, '$')-1)) ; 
                v_msg_2 := UPPER(SUBSTR(v_pipe_msg, INSTR(v_pipe_msg, '$')+1)) ;
                IF ( v_msg_1=v_pipe_name AND v_msg_2='STOP' ) THEN
                    -- 退出无限循环
                    EXIT ;
                END IF ;
            END IF ;
            
            -- 睡眠 
            DBMS_LOCK.SLEEP(v_sleep_seconds) ;
        END LOOP ;
        
        -- 程序运行结束写日志
        v_prg_run_result := '作业执行循环程序退出' ;
        v_result := DBMS_PIPE.REMOVE_PIPE(v_pipe_name) ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_EXEC_PRC'
             ,'作业执行循环程序'
             ,USER
             ,'PIPE_EXEC'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_EXEC_PRC'
             ,'作业执行循环程序'
             ,USER
             ,'PIPE_EXEC'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;


/*
    * 程序: CTL_LOOP_FILE_PRC 
    * 类型: 存储过程
    * 功能: 数据文件登记与统计循环程序
    * 参数: 
    * 创建: LiBing  2016-12-27
    * 修改:
*/
    PROCEDURE ctl_loop_file_prc 
    IS
        -- 程序运行开始时间
        v_prg_run_time  DATE := sysdate ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(200) := 'None' ;
        -- 管道名称
        v_pipe_name  VARCHAR2(12) := 'PIPE_FILE' ;
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
        v_sleep_seconds  INTEGER  := 180 ;
    BEGIN
        -- 程序运行开始日志 
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_FILE_PRC'
             ,'数据文件登记与统计循环程序'
             ,USER
             ,'PIPE_FILE'
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        -- 创建私有管道 
        v_result := DBMS_PIPE.CREATE_PIPE(v_pipe_name) ;
        -- 程序无限循环,只能通过管道接收STOP指令才能退出
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
                    EXIT ;
                END IF ;
            END IF ;
            
            -- 睡眠 
            DBMS_LOCK.SLEEP(v_sleep_seconds) ;
        END LOOP ;
        -- 程序运行结束写日志
        v_prg_run_result := '数据文件登记与统计循环程序退出' ;
        v_result := DBMS_PIPE.REMOVE_PIPE(v_pipe_name) ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_FILE_PRC'
             ,'数据文件登记与统计循环程序'
             ,USER
             ,'PIPE_FILE'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_FILE_PRC'
             ,'数据文件登记与统计循环程序'
             ,USER
             ,'PIPE_FILE'
             ,v_prg_run_time
             ,SYSDATE
             ,0
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;


/*
    * 程序: CTL_LOOP_MSG_PRC 
    * 类型: 存储过程
    * 功能: 消息发送程序
    * 参数: 
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_loop_msg_prc 
        ( p_pipe_name  IN  VARCHAR2 
         ,p_msg        IN  VARCHAR2 
        ) 
    IS
        -- 程序运行时间
        v_prg_run_time  DATE  := SYSDATE ;
        -- 程序运行结果
        v_prg_run_result  VARCHAR2(100) := 'None' ;
        -- 管道操作结果
        v_pipe_result  INTEGER ;
    BEGIN
        -- 程序运行开始写日志
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_MSG_PRC'
             ,'通过管道发送消息'
             ,USER
             ,UPPER(NVL(p_pipe_name, 'CTL_MAIN'))||' | '||p_msg
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        
        -- 打包消息
        DBMS_PIPE.PACK_MESSAGE(UPPER(NVL(p_msg, 'PIPE_MAIN$STOP'))) ;
        
        -- 发送消息
        v_pipe_result := DBMS_PIPE.SEND_MESSAGE(UPPER(NVL(p_pipe_name, 'PIPE_MAIN'))) ;
        
        -- 程序运行成功写日志
        v_prg_run_result := '消息发送成功' ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_MSG_PRC'
             ,'通过管道发送消息'
             ,USER
             ,UPPER(NVL(p_pipe_name, 'PIPE_MAIN'))||' | '||UPPER(NVL(p_msg, 'PIPE_MAIN$STOP'))
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_LOOP_MSG_PRC'
             ,'通过管道发送消息'
             ,USER
             ,UPPER(NVL(p_pipe_name, 'PIPE_MAIN'))||' | '||UPPER(NVL(p_msg, 'PIPE_MAIN$STOP'))
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;
/*
    * 程序: CTL_JOB_INST_PRC 
    * 类型: 存储过程
    * 功能: 作业实例化
    * 参数: p_task_name  调度任务名称
    *       p_data_dt    任务运行的数据日期
    * 创建: LiBing  2016-12-21
    * 修改:
*/
    PROCEDURE ctl_job_inst_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_data_dt    IN  VARCHAR2 
        ) 
    IS
        -- 程序运行时间
        v_prg_run_time  DATE  := SYSDATE ;
        -- 程序运行结果
        v_prg_run_result  VARCHAR2(100) := 'None' ;
    BEGIN
        -- 程序运行开始写日志
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_INST_PRC'
             ,'作业实例化'
             ,USER
             ,p_task_name||' | '||p_data_dt 
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        
        -- 填充作业实例表
        INSERT INTO hfdp.ctl_job_inst_tbl 
        SELECT p_data_dt 
              ,p_task_name 
              ,job_name 
              ,job_owner||'.'||job_prog  AS  job_prog 
              ,SYSDATE 
              ,NULL
              ,'INSTANCED' 
              ,tree_level 
          FROM hfdp.ctl_job_conf_tbl 
         WHERE task_name = p_task_name 
           AND is_valid = '1' ;
        
        COMMIT ;
        
        -- 将任务的根节点作业的状态更新为READY
        UPDATE hfdp.ctl_job_inst_tbl 
           SET job_status = 'READY' 
         WHERE task_name = p_task_name 
           AND data_dt = p_data_dt 
           AND job_name = 'ROOT_JOB' ;
        
        COMMIT ;
        
        -- 程序运行成功写日志
        v_prg_run_result := '作业实例化成功' ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_INST_PRC'
             ,'作业实例化'
             ,USER
             ,p_task_name||' | '||p_data_dt 
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_INST_PRC'
             ,'作业实例化'
             ,USER
             ,p_task_name||' | '||p_data_dt 
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;
/*
    * 程序: CTL_JOB_EXEC_PRC   -- 要不要去掉写日志????????
    * 类型: 存储过程
    * 功能: 作业执行
    * 参数: p_task_name  调度任务名称
    *       p_job_name   作业名称
    *       p_job_prog   作业实际执行的命令内容
    *       p_data_dt    所属任务的数据日期
    * 创建: LiBing  2016-12-26
    * 修改:
*/
    PROCEDURE ctl_job_exec_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_job_name   IN  VARCHAR2 
         ,p_job_prog   IN  VARCHAR2
         ,p_data_dt    IN  VARCHAR2  
        ) 
    IS
        -- 程序运行时间
        v_prg_run_time  DATE  := SYSDATE ;
        -- 程序运行结果
        v_prg_run_result  VARCHAR2(100) := 'None' ;
        -- 程序运行结果
        v_result  INTEGER ;
        -- 动态执行的SQL语句 
        v_sql  VARCHAR2(2000) ;
    BEGIN
        -- 程序运行开始写日志
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_EXEC_PRC'
             ,'作业执行'
             ,USER
             ,p_task_name||' | '||p_job_prog 
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        -- 对job_prog的内容作必要的替换
        
        -- 执行p_job_prog中的命令
        v_sql := p_job_prog || ':v_1)' ;
        EXECUTE IMMEDIATE v_sql USING v_result ;
        -- 根据程序运行结果,更新JOB实例表中的job_status值为SUCCESS或ERROR
        IF (v_result = 0) THEN
            -- 更新JOB实例表中的job_status值为SUCCUSS 
            UPDATE hfdp.ctl_job_inst_tbl 
               SET job_status = 'SUCCUSS' 
             WHERE task_name = p_task_name 
               AND job_name = p_job_name 
               AND job_prog = p_job_prog 
               AND data_dt = p_data_dt ;
        ELSIF (v_result = 1) THEN 
            -- 更新JOB实例表中的job_status值为SUCCUSS 
            UPDATE hfdp.ctl_job_inst_tbl 
               SET job_status = 'ERROR' 
             WHERE task_name = p_task_name 
               AND job_name = p_job_name 
               AND job_prog = p_job_prog 
               AND data_dt = p_data_dt ;
        END IF ;
        COMMIT ;

        -- 刷新job的状态,将满足条件的job_status从INSTANCED更新为READY 
        FOR rec_job IN ( SELECT y.job_name
                               ,y.task_name
                           FROM ( SELECT x.job_name
                                        ,COUNT(1)  AS job_no
                                        ,SUM(x.job_status)  AS job_suc
                                        ,x.task_name
                                    FROM ( SELECT t1.job_name
                                                 ,t1.job_dependent
                                                 ,CASE t3.job_status 
                                                      WHEN 'SUCCESS' THEN 1 
                                                      ELSE 0 
                                                  END  AS  job_status
                                                 ,t1.task_name 
                                             FROM hfdp.ctl_job_conf_tbl t1
                                             LEFT JOIN hfdp.ctl_job_inst_tbl t2
                                               ON t1.job_name = t2.job_name AND 
                                                  t1.task_name = t2.task_name 
                                             LEFT JOIN hfdp.ctl_job_inst_tbl t3
                                               ON t1.job_dependent = t2.job_name AND 
                                                  t1.task_name = t2.task_name 
                                            WHERE t2.job_status='INSTANCED' ) x
                                   GROUP BY x.job_name ) y
                          WHERE y.job_no = y.job_suc )
        LOOP 
            UPDATE hfdp.ctl_job_inst_tbl 
               SET job_status = 'READY' 
             WHERE job_status = 'INSTANCED' 
               AND job_name = rec_job.job_name 
               AND task_name = rec_job.task_name ;
        END LOOP ;
        COMMIT ;
        -- 程序运行成功写日志
        v_prg_run_result := '作业执行完成' ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_EXEC_PRC'
             ,'作业执行'
             ,USER
             ,p_task_name||' | '||p_job_prog 
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_EXEC_PRC'
             ,'作业执行'
             ,USER
             ,p_task_name||' | '||p_job_prog
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;


/*
    * 程序: CTL_TASK_CLEAN_PRC 
    * 类型: 存储过程
    * 功能: 任务完成后清理
    * 参数: p_task_name  任务名称
    *       p_mode       处理模式(1正常完成任务 2节假日不触发任务 3异常中断任务清理)
    *       p_data_dt    任务运行的数据日期 
    * 创建: LiBing  2016-12-26
    * 修改:
*/
    PROCEDURE ctl_task_clean_prc 
        ( p_task_name  IN  VARCHAR2 
         ,p_mode       IN  VARCHAR2 
         ,p_data_dt    IN  VARCHAR2 
        ) 
    IS
        -- 程序运行时间
        v_prg_run_time  DATE  := SYSDATE ;
        -- 程序运行结果
        v_prg_run_result  VARCHAR2(100) := 'None' ;
        -- 程序运行结果
        v_result  INTEGER ;
        -- 数据日期
        v_data_dt  DATE := TO_DATE(p_data_dt, 'YYYYMMDD') ;
        -- 处理模式翻译
        v_mode  VARCHAR2(100) ;
    BEGIN
        -- 处理模式翻译
        v_mode := CASE p_mode 
                      WHEN '1' THEN '成功' 
                      WHEN '2' THEN '跳过' 
                      WHEN '3' THEN '中断'
                  END ;
        
        -- 程序运行开始写日志
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_CLEAN_PRC'
             ,'任务完成后清理'
             ,USER
             ,p_task_name||' | '||v_mode 
             ,v_prg_run_time
             ,NULL
             ,0
             ,0
             ,'R'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
        
        -- 根据参数p_mode的值分别进行相应处理
        IF p_mode = '1' THEN
            -- 将任务实例表的记录移入任务历史表
            INSERT INTO hfdp.ctl_task_hist_tbl 
            SELECT task_name 
                  ,data_dt 
                  ,start_dt 
                  ,end_dt 
                  ,task_status 
                  ,manual_flag 
              FROM hfdp.ctl_task_inst_tbl 
             WHERE task_name = p_task_name 
               AND task_status = 'SUCCESS' ;
            IF SQL%ROWCOUNT <> 0 THEN
                EXECUTE IMMEDIATE 
                    'DELETE FROM hfdp.ctl_task_inst_tbl WHERE task_name=:v_1 ANd task_status=''SUCCESS''' 
                    USING p_task_name ;
            END IF ;
            -- 将作业实例表的记录移入作业历史表
            INSERT INTO hfdp.ctl_job_hist_tbl 
            SELECT data_dt
                  ,task_name 
                  ,job_name 
                  ,job_prog 
                  ,start_dt 
                  ,end_dt 
                  ,job_status 
              FROM hfdp.ctl_job_inst_tbl 
             WHERE task_name = p_task_name 
               AND data_dt = p_data_dt ;
            IF SQL%ROWCOUNT <> 0 THEN 
                EXECUTE IMMEDIATE 
                    'DELETE FROM hfdp.ctl_job_inst_tbl WHERE task_name=:v_1 ANd data_dt=:v_2' 
                    USING p_task_name, p_data_dt ;
            END IF ;
            -- 更新任务配置表中的相关日期和状态
            UPDATE hfdp.ctl_task_conf_tbl 
               SET task_status = 'READY' 
                  ,last_data_dt = v_data_dt 
                  ,next_data_dt = v_data_dt + 1 
                  ,hwm_data_dt = CASE WHEN hwm_data_dt < v_data_dt THEN v_data_dt END
             WHERE task_name = p_task_name 
               AND is_valid = '1' ;
        ELSIF p_mode = '2' THEN 
            -- 在任务历史表中做相关记录
            INSERT INTO hfdp.ctl_task_hist_tbl 
            VALUES ( p_task_name
                    ,p_data_dt
                    ,SYSDATE
                    ,SYSDATE
                    ,'HOLIDAY'
                    ,0
                   ) ;
            -- 更新任务配置表中的相关日期和状态
            UPDATE hfdp.ctl_task_conf_tbl 
               SET task_status = 'READY' 
                  ,last_data_dt = v_data_dt 
                  ,next_data_dt = v_data_dt + 1 
                  ,hwm_data_dt = CASE WHEN hwm_data_dt < v_data_dt THEN v_data_dt END
             WHERE task_name = p_task_name 
               AND is_valid = '1' ;
        ELSIF p_mode = '3' THEN 
            NULL ;
        END IF ;
        COMMIT ;
        
        -- 程序运行成功写日志
        v_prg_run_result := '任务清理完成' ;
        HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_CLEAN_PRC'
             ,'任务完成后清理'
             ,USER
             ,p_task_name||' | '||v_mode 
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            -- 程序运行失败写日志 
            HFDP.UTI_HFDP_TOOLS_PKG.UTI_HFDP_LOG_PRC
            ( '99991231'
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_CLEAN_PRC'
             ,'任务完成后清理'
             ,USER
             ,p_task_name||' | '||v_mode 
             ,v_prg_run_time
             ,SYSDATE
             ,(SYSDATE - v_prg_run_time)*1440
             ,0
             ,'F'
             ,SQLCODE
             ,SQLERRM
             ,'CTL'
            ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ;


END ;
/