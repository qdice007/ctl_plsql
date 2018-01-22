CREATE OR REPLACE PACKAGE ctl_task_tools_pkg 
IS

    /*
     * 名称: ctl_task_tools_pkg
     * 类型: 包头
     * 描述: 任务调度工具包
     * 包含: 
     *       ctl_sys_log_prc     - 写日志
     *       ctl_task_check_prc  - 启动任务
     *       ctl_task_inst_prc   - 实例化任务
     *       ctl_dep_check_prc   - 检查作业的依赖
     *       ctl_jobs_inst_prc   - 实例化任务的作业
     *       ctl_job_exec_prc    - 执行作业
     *       ctl_task_clean_prc  - 任务完成后的清理
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-05-18
     * 修改:
     *
     */

    /*
     * 名称: ctl_sys_log_prc
     * 类型: 存储过程
     * 描述: 写日志
     * 参数: p_batch_date  IN  VARCHAR2      --数据日期(字符串,格式YYYYMMDD)
     *       p_pkg_name    IN  VARCHAR2      --包名
     *       p_prc_name    IN  VARCHAR2      --过程名
     *       p_prc_desc    IN  VARCHAR2      --过程描述
     *       p_caller      IN  VARCHAR2      --调用者(若无则填'CTL')
     *       p_obj_name    IN  VARCHAR2      --加载或处理的主要对象名称
     *       p_start_time  IN  TIMESTAMP(6)  --运行开始时间
     *       p_end_time    IN  TIMESTAMP(6)  --运行结束时间
     *       p_run_time    IN  NUMBER        --运行耗时(分钟)
     *       p_row_count   IN  NUMBER        --数据处理条数
     *       p_run_state   IN  CHAR          --程序运行状态(R正在运行 S成功结束 F失败)
     *       p_err_cd      IN  VARCHAR2      --报错代码
     *       p_err_msg     IN  VARCHAR2      --数据库报错信息
     *       p_sys_name    IN  VARCHAR2      --数据所属源系统简称(若无源系统则填'CTL')
     * 返回: 无
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_sys_log_prc
        ( p_batch_date  IN  VARCHAR2
         ,p_pkg_name    IN  VARCHAR2
         ,p_prc_name    IN  VARCHAR2
         ,p_prc_desc    IN  VARCHAR2
         ,p_caller      IN  VARCHAR2
         ,p_obj_name    IN  VARCHAR2
         ,p_start_time  IN  DATE
         ,p_end_time    IN  DATE
         ,p_run_time    IN  NUMBER
         ,p_row_count   IN  NUMBER
         ,p_run_state   IN  CHAR
         ,p_err_cd      IN  VARCHAR2
         ,p_err_msg     IN  VARCHAR2
         ,p_sys_name    IN  VARCHAR2
        ) ;

    /*
     * 名称: ctl_task_check_prc
     * 类型: 存储过程
     * 描述: 检查任务
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_result  OUT  VARCHAR2  --运行结果
     *                                      成功: next_data_dt|goal_data_dt|
     *                                            task_mode|task_inst|task_status|
     *                                            jobs_inst
     *                                      失败: '1'
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_task_check_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;

    /*
     * 名称: ctl_task_inst_prc
     * 类型: 存储过程
     * 描述: 实例化任务
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_mode    IN   VARCHAR2  --运行模式('0' - 正常, '1' - 继续, '2' - 强制)
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_task_inst_prc
        ( p_batch_date  IN   VARCHAR2 
         ,p_task_name   IN   VARCHAR2 
         ,p_run_mode    IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;

    /*
     * 名称: ctl_dep_check_prc
     * 类型: 存储过程
     * 描述: 检查任务所有作业的依赖
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_dep_check_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;
    
    /*
     * 名称: ctl_jobs_inst_prc
     * 类型: 存储过程
     * 描述: 实例化任务的作业
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_mode    IN   VARCHAR2  --运行模式('0' - 正常, '1' - 强制)
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_jobs_inst_prc
        ( p_batch_date  IN   VARCHAR2 
         ,p_task_name   IN   VARCHAR2 
         ,p_run_mode    IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;
    
    /*
     * 名称: ctl_job_exec_prc
     * 类型: 存储过程
     * 描述: 运行一个作业
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_job_name    IN   VARCHAR2  --作业名称
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_job_exec_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_job_name    IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;
    
    /*
     * 名称: ctl_task_clean_prc
     * 类型: 存储过程
     * 描述: 任务成功完成后的清理操作
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_task_clean_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;

END ctl_task_tools_pkg ;
/




CREATE OR REPLACE PACKAGE BODY ctl_task_tools_pkg 
IS

    /*
     * 名称: ctl_task_tools_pkg
     * 类型: 包体
     * 描述: 任务调度工具包
     * 包含: 
     *       ctl_sys_log_prc     - 写日志
     *       ctl_task_check_prc  - 启动任务
     *       ctl_task_inst_prc   - 实例化任务
     *       ctl_dep_check_prc   - 检查作业的依赖
     *       ctl_jobs_inst_prc   - 实例化任务的作业
     *       ctl_job_exec_prc    - 执行作业
     *       ctl_task_clean_prc  - 任务完成后的清理
     * 参数: 无
     * 返回: 无
     * 创建: LiBing  2017-05-18
     * 修改:
     *
     */

    /*
     * 名称: ctl_sys_log_prc
     * 类型: 存储过程
     * 描述: 写日志
     * 参数: p_batch_date  IN  VARCHAR2      --数据日期(字符串,格式YYYYMMDD)
     *       p_pkg_name    IN  VARCHAR2      --包名
     *       p_prc_name    IN  VARCHAR2      --过程名
     *       p_prc_desc    IN  VARCHAR2      --过程描述
     *       p_caller      IN  VARCHAR2      --调用者(若无则填'CTL')
     *       p_obj_name    IN  VARCHAR2      --加载或处理的主要对象名称
     *       p_start_time  IN  TIMESTAMP(6)  --运行开始时间
     *       p_end_time    IN  TIMESTAMP(6)  --运行结束时间
     *       p_run_time    IN  NUMBER        --运行耗时(分钟)
     *       p_row_count   IN  NUMBER        --数据处理条数
     *       p_run_state   IN  CHAR          --程序运行状态(R正在运行 S成功结束 F失败)
     *       p_err_cd      IN  VARCHAR2      --报错代码
     *       p_err_msg     IN  VARCHAR2      --数据库报错信息
     *       p_sys_name    IN  VARCHAR2      --数据所属源系统简称(若无源系统则填'CTL')
     * 返回: 无
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_sys_log_prc
        ( p_batch_date  IN  VARCHAR2
         ,p_pkg_name    IN  VARCHAR2
         ,p_prc_name    IN  VARCHAR2
         ,p_prc_desc    IN  VARCHAR2
         ,p_caller      IN  VARCHAR2
         ,p_obj_name    IN  VARCHAR2
         ,p_start_time  IN  TIMESTAMP(6)
         ,p_end_time    IN  TIMESTAMP(6)
         ,p_run_time    IN  NUMBER
         ,p_row_count   IN  NUMBER
         ,p_run_state   IN  CHAR
         ,p_err_cd      IN  VARCHAR2
         ,p_err_msg     IN  VARCHAR2
         ,p_sys_name    IN  VARCHAR2
        )
    IS
        -- 声明为自治事务
        PRAGMA AUTONOMOUS_TRANSACTION ;
    BEGIN
        MERGE INTO ctl.ctl_sys_logs_tbl log_t
            USING ( SELECT p_batch_date AS data_date
                          ,p_pkg_name   AS pkg_name
                          ,p_prc_name   AS prc_name
                          ,p_prc_desc   AS prc_desc
                          ,p_caller     AS caller
                          ,p_obj_name   AS obj_name
                          ,p_start_time AS start_time
                          ,p_end_time   AS end_time
                          ,p_run_time   AS run_time
                          ,p_row_count  AS row_count
                          ,p_run_state  AS run_state
                          ,p_err_cd     AS err_cd
                          ,p_err_msg    AS err_msg
                          ,p_sys_name   AS sys_name
                      FROM dual
                  ) para_t
            ON ( log_t.data_date  = para_t.data_date  AND
                 log_t.pkg_name   = para_t.pkg_name   AND
                 log_t.prc_name   = para_t.prc_name   AND
                 log_t.start_time = para_t.start_time AND
                 log_t.sys_name   = para_t.sys_name
               )
        WHEN MATCHED THEN
            UPDATE
                SET log_t.caller    = para_t.caller
                   ,log_t.obj_name  = para_t.obj_name
                   ,log_t.end_time  = para_t.end_time
                   ,log_t.run_time  = para_t.run_time
                   ,log_t.row_count = para_t.row_count
                   ,log_t.run_state = para_t.run_state
                   ,log_t.err_cd    = para_t.err_cd
                   ,log_t.err_msg   = para_t.err_msg
                WHERE log_t.data_date = para_t.data_date
                  AND log_t.pkg_name   = para_t.pkg_name
                  AND log_t.prc_name   = para_t.prc_name
                  AND log_t.start_time = para_t.start_time
                  AND log_t.sys_name   = para_t.sys_name
        WHEN NOT MATCHED THEN
            INSERT ( log_t.data_date
                    ,log_t.pkg_name
                    ,log_t.prc_name
                    ,log_t.prc_desc
                    ,log_t.caller
                    ,log_t.obj_name
                    ,log_t.start_time
                    ,log_t.end_time
                    ,log_t.run_time
                    ,log_t.row_count
                    ,log_t.run_state
                    ,log_t.err_cd
                    ,log_t.err_msg
                    ,log_t.sys_name
                   )
            VALUES ( para_t.data_date
                    ,para_t.pkg_name
                    ,para_t.prc_name
                    ,para_t.prc_desc
                    ,para_t.caller
                    ,para_t.obj_name
                    ,para_t.start_time
                    ,para_t.end_time
                    ,para_t.run_time
                    ,para_t.row_count
                    ,para_t.run_state
                    ,para_t.err_cd
                    ,para_t.err_msg
                    ,para_t.sys_name
                   ) ;

        COMMIT ;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
            RAISE ;
    END ctl_sys_log_prc ;

    /*
     * 名称: ctl_task_check_prc
     * 类型: 存储过程
     * 描述: 检查任务
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_result  OUT  VARCHAR2  --运行结果
     *                                      成功: next_data_dt|goal_data_dt|
     *                                            task_mode|task_inst|task_status|
     *                                            jobs_inst
     *                                      失败: '1'
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_task_check_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) 
    IS
        -- 程序运行开始时间
        v_run_time  DATE := SYSDATE ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(1000) := 'NONE' ;
        -- 自定义异常: 任务在配置或实例表中无法找到或不唯一
        e_task_not_found  EXCEPTION ;
    BEGIN
        BEGIN
            SELECT next_data_dt || '|' || goal_data_dt || '|' || task_mode
              INTO p_run_result
              FROM ctl.ctl_task_conf_tbl 
             WHERE task_name = UPPER(p_task_name)
               AND is_valid = '1' ;

            SELECT p_run_result ||
                   '|' ||
                   TO_CHAR(COUNT(1)) ||
                   '|' ||
                   NVL(SUM(task_status), '100')
              INTO p_run_result 
              FROM ctl.ctl_task_inst_tbl 
             WHERE task_name = UPPER(p_task_name)
               AND data_date = p_batch_date ;

            SELECT p_run_result ||
                   '|' ||
                   TO_CHAR(COUNT(1))
              INTO p_run_result
              FROM ctl.ctl_jobs_inst_tbl 
             WHERE task_name = UPPER(p_task_name)
               AND data_date = p_batch_date ;
        EXCEPTION
            -- 抛出异常: 记录无法找到 或 记录不唯一
            WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
                v_prg_run_result := '任务[' || UPPER(p_task_name) || ']在配置或实例表中无法找到或不唯一' ;
                RAISE e_task_not_found ;
            WHEN OTHERS THEN
                RAISE ;
        END ;
        
        v_prg_run_result := '成功完成' ;
        ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
            ( p_batch_date
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_CHECK_PRC'
             ,'检查任务'
             ,'CTL'
             ,'TASK'
             ,v_run_time
             ,SYSDATE
             ,(SYSDATE - v_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result 
             ,'CTL'
            ) ;
    EXCEPTION
        -- 处理异常: 任务在配置或实例表中无法找到或不唯一
        WHEN e_task_not_found THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_TASK_CHECK_PRC'
                 ,'检查任务'
                 ,'CTL'
                 ,'TASK'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,v_prg_run_result
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
        WHEN OTHERS THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_TASK_CHECK_PRC'
                 ,'检查任务'
                 ,'CTL'
                 ,'TASK'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,SQLERRM
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
    END ctl_task_check_prc ;

    /*
     * 名称: ctl_task_inst_prc
     * 类型: 存储过程
     * 描述: 实例化任务
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_mode    IN   VARCHAR2  --运行模式('0' - 正常, '1' - 继续, '2' - 强制)
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_task_inst_prc
        ( p_batch_date  IN   VARCHAR2 
         ,p_task_name   IN   VARCHAR2 
         ,p_run_mode    IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) 
    IS
        -- 程序运行开始时间
        v_run_time  DATE := SYSDATE ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(1000) := 'NONE' ;
        -- 任务配置的作业执行并发数
        v_jobs_concur  PLS_INTEGER := 0 ;
        -- 自定义异常: 运行模式错误
        e_mode_error  EXCEPTION ;
    BEGIN
        SELECT NVL(jobs_concur,10)
          INTO v_jobs_concur
          FROM ctl.ctl_task_conf_tbl
         WHERE task_name = UPPER(p_task_name) 
           AND is_valid = '1' ;
        
        IF p_mode = '0' THEN
            INSERT INTO ctl.ctl_task_inst_tbl 
            VALUES 
                ( UPPER(p_task_name)
                 ,p_batch_date
                 ,v_jobs_concur
                 ,SYSDATE
                 ,NULL
                 ,0
                 ,0
                 ,0
                ) ;
            COMMIT ;
        ELSIF p_mode = '1' THEN 
            UPDATE ctl.ctl_task_inst_tbl 
               SET task_status = '0' 
             WHERE task_name = UPPER(p_task_name) 
               AND data_date = p_batch_date ;

            COMMIT ; 
        ELSIF p_mode = '2' THEN
            DELETE 
              FROM ctl.ctl_task_inst_tbl
             WHERE task_name = UPPER(p_task_name) ;

            INSERT INTO ctl.ctl_task_inst_tbl 
            VALUES
                ( p_task_name
                 ,p_batch_date
                 ,v_jobs_concur
                 ,SYSDATE
                 ,NULL
                 ,'0'
                 ,'0'
                 ,'0'
                ) ;

            COMMIT ;
        ELSE
            v_prg_run_result := '运行模式值错误' ;
            RAISE e_mode_error ;
        END IF ;

        p_run_result := '0' ;
        v_prg_run_result := '成功完成' ;
        ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
            ( p_batch_date
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_INIST_PRC'
             ,'实例化任务'
             ,'CTL'
             ,'TASK'
             ,v_run_time
             ,SYSDATE
             ,(SYSDATE - v_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN e_mode_error 
        THEN
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_TASK_INST_PRC'
                 ,'实例化任务'
                 ,'CTL'
                 ,'TASK'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,v_prg_run_result 
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
        WHEN OTHERS THEN
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_TASK_INST_PRC'
                 ,'实例化任务'
                 ,'CTL'
                 ,'TASK'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,SQLERRM
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
    END ctl_task_inst_prc ;

    /*
     * 名称: ctl_dep_check_prc
     * 类型: 存储过程
     * 描述: 检查任务所有作业的依赖
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_dep_check_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) 
    IS
        -- 程序运行开始时间
        v_run_time  DATE := SYSDATE ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(1000) := 'None' ;
    BEGIN
        NULL ;
        
        p_run_result := '0' ;
        v_prg_run_result := '成功完成' ;
        ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
            ( p_batch_date
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_DEP_CHECK_PRC'
             ,'检查任务所有作业的依赖'
             ,'CTL'
             ,'TASK'
             ,v_run_time
             ,SYSDATE
             ,(SYSDATE - v_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_DEP_CHECK_PRC'
                 ,'检查任务所有作业的依赖'
                 ,'CTL'
                 ,'JOBS'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,SQLERRM
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
    END ctl_dep_check_prc ;
    
    /*
     * 名称: ctl_jobs_inst_prc
     * 类型: 存储过程
     * 描述: 实例化任务的作业
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_mode    IN   VARCHAR2  --运行模式('0' - 正常, '1' - 强制)
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_jobs_inst_prc
        ( p_batch_date  IN   VARCHAR2 
         ,p_task_name   IN   VARCHAR2 
         ,p_run_mode    IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) ;
    IS
        -- 程序运行开始时间
        v_run_time DATE := SYSDATE ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(1000) := 'NONE' ;
        -- 任务状态
        v_task_status  VARCHAR2(1) := 'N' ;
        -- 任务的人工干预标识
        v_manual_flag  VARCHaR2(1) := 'N' ;
        -- 自定义异常: 任务状态错误
        e_task_status_error  EXCEPTION ;
        -- 自定义异常: 运行模式值错误
        e_run_mode_error  EXCEPTION ;
    BEGIN
        -- 检查任务状态
        SELECT task_status
          INTO v_task_status
          FROM ctl.ctl_task_inst_tbl 
         WHERE task_name = UPPER(p_task_name) 
           AND data_date = p_batch_date ;

        SELECT manual_flag
          INTO v_manual_flag
          FROM ctl.ctl_task_inst_tbl 
         WHERE task_name = UPPER(p_task_name) 
           AND data_date = p_batch_date ;

        IF ( v_task_status = '0' AND v_manual_flag = '0' ) THEN 
            IF p_mode = '0' THEN 
                INSERT INTO ctl.ctl_jobs_inst_tbl 
                SELECT p_batch_date
                      ,task_name
                      ,job_name
                      ,job_dependent
                      ,job_prog
                      ,SYSTIMESTAMP
                      ,NULL 
                      ,CASE job_dependent
                           WHEN 'NONE' THEN '0'
                           ELSE '1'
                       END 
                      ,tree_level
                  FROM ctl.ctl_jobs_conf_tbl 
                 WHERE task_name = UPPER(p_task_name) 
                   AND is_valid = '1' ;

                COMMIT ;
            ELSIF p_mode = '1' THEN 
                UPDATE ctl.ctl_jobs_inst_tbl 
                   SET job_status = '0' 
                 WHERE task_name = UPPER(p_task_name) 
                   AND data_date = p_batch_date 
                   AND job_status IN ('2', '3') ;

                COMMIT ;
            ELSIF p_mode = '2' THEN 
                DELETE 
                  FROM ctl.ctl_jobs_inst_tbl 
                 WHERE task_name = UPPER(p_task_name) 
                   AND data_date = p_batch_date ;

                INSERT INTO ctl.ctl_jobs_inst_tbl 
                SELECT p_batch_date
                      ,task_name
                      ,job_name
                      ,job_dependent
                      ,job_prog
                      ,SYSTIMESTAMP
                      ,NULL 
                      ,CASE job_dependent
                           WHEN 'NONE' THEN '0'
                           ELSE '1'
                       END 
                      ,tree_level
                  FROM ctl.ctl_jobs_conf_tbl 
                 WHERE task_name = UPPER(p_task_name) 
                   AND is_valid = '1' ;
                
                COMMIT ;
            ELSE 
                v_prg_run_result := 'p_mode value is error' ;
                RAISE e_run_mode_error ;
            END IF ;
        ELSE 
            v_prg_run_result := '任务状态错误,请检查任务实例表中的相关记录' ;
            RAISE e_task_status_error ;
        END IF ;
        
        p_run_result := '0' ;
        v_prg_run_result := '成功完成' ;
        ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
            ( p_batch_date
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOBS_INST_PRC'
             ,'实例化任务的作业'
             ,'CTL'
             ,'JOBS'
             ,v_run_time
             ,SYSDATE
             ,(SYSDATE - v_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN e_task_status_error 
          OR e_run_mode_error
        THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_JOBS_INST_PRC'
                 ,'实例化任务的作业'
                 ,'CTL'
                 ,'JOBS'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,v_prg_run_result 
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
        WHEN OTHERS THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_JOBS_INST_PRC'
                 ,'实例化任务的作业'
                 ,'CTL'
                 ,'JOBS'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,SQLERRM
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
    END ctl_jobs_inst_prc ;
    
    /*
     * 名称: ctl_job_exec_prc
     * 类型: 存储过程
     * 描述: 运行一个作业
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_job_name    IN   VARCHAR2  --作业名称
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_job_exec_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_job_name    IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) 
    IS
        -- 程序运行开始时间
        v_run_time  DATE := SYSDATE ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(1000) := 'None' ;
        -- 自定义异常: 作业未找到
        e_job_not_found  EXCEPTION ;
    BEGIN
        NULL ;
        
        p_run_result := '0' ;
        v_prg_run_result := 'No Errors' ;
        ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
            ( p_batch_date
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_JOB_EXEC_PRC'
             ,'运行一个作业'
             ,'CTL'
             ,'JOBS'
             ,v_run_time
             ,SYSDATE
             ,(SYSDATE - v_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result 
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN OTHERS THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_JOB_EXEC_PRC'
                 ,'运行一个作业'
                 ,'CTL'
                 ,'JOBS'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,SQLERRM
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
    END ctl_job_exec_prc ;
    
    /*
     * 名称: ctl_task_clean_prc
     * 类型: 存储过程
     * 描述: 任务成功完成后的清理操作
     * 参数: 
     *       p_batch_date  IN   VARCHAR2  --数据日期(字符串,格式YYYYMMDD)
     *       p_task_name   IN   VARCHAR2  --任务名称
     *       p_run_result  OUT  VARCHAR2  --运行结果('0' - 成功, '1' - 失败)
     * 返回: 
     *       p_run_result  运行结果
     * 创建: LiBing  2017-05-18
     * 修改:
     */
    PROCEDURE ctl_task_clean_prc
        ( p_batch_date  IN   VARCHAR2
         ,p_task_name   IN   VARCHAR2
         ,p_run_result  OUT  VARCHAR2 
        ) 
    IS
        -- 程序运行开始时间
        v_run_time  DATE := SYSDATE ;
        -- DATE类型的数据日期
        v_batch_date  DATE := TO_DATE(p_batch_date, 'YYYYMMDD') ;
        -- DATE类型的高水位数据日期
        v_hwm_data_dt  DATE ;
        -- 作业状态
        v_jobs_stat  PLS_INTEGER := 0 ;
        -- 任务状态
        v_task_status  VARCHAR2(1) ;
        -- 程序运行结果描述
        v_prg_run_result  VARCHAR2(1000) := 'NONE' ;
        -- 自定义异常: 作业尚未完成
        e_jobs_not_complete EXCEPTION ;
        -- 自定义异常: 任务尚未完成
        e_task_not_complete EXCEPTION ;
    BEGIN
        -- 获取任务及其作业的状态
        SELECT COUNT(1)
          INTO v_jobs_stat
          FROM ctl_jobs_inst_tbl 
         WHERE data_date = p_batch_date 
           AND task_name = UPPER(p_task_name)
           AND job_status NOT IN ('4', '5');

        SELECT task_status
          INTO v_task_status
          FROM ctl.ctl_task_inst_tbl
         WHERE task_name = UPPER(p_task_name)
           AND data_date = p_batch_date ;
        
        -- 清除任务实例表中的相关记录
        IF ( v_task_status = '3' AND v_jobs_stat = 0 ) THEN
            INSERT INTO ctl.ctl_task_logs_tbl
            SELECT task_name
                  ,data_date
                  ,start_ts
                  ,end_ts
                  ,TO_CHAR(EXTRACT(DAY FROM (end_ts - start_ts))*24*60*60 +
                           EXTRACT(HOUR FROM (end_ts - start_ts))*60*60 +
                           EXTRACT(MINUTE FROM (end_ts - start_ts))*60 +
                           EXTRACT(SECOND FROM (end_ts - start_ts)))
                  ,task_status
                  ,manual_flag
              FROM ctl.ctl_task_inst_tbl 
             WHERE task_name = UPPER(p_task_name) 
               AND data_date = p_batch_date ;

            DELETE 
              FROM ctl.ctl_task_inst_tbl 
             WHERE task_name = UPPER(p_task_name) 
               AND data_date = p_batch_date ;

            INSERT INTO ctl.ctl_jobs_logs_tbl 
            SELECT data_date
                  ,task_name
                  ,job_name
                  ,job_prog
                  ,start_ts
                  ,end_ts
                  ,job_status
              FROM ctl.ctl_jobs_inst_tbl 
             WHERE data_date = p_batch_date 
               AND task_name = UPPER(p_task_name) ;

            DELETE 
              FROM ctl.ctl_jobs_inst_tbl 
             WHERE task_name = UPPER(p_task_name) 
               AND data_date = p_batch_date ;

            COMMIT ;
        ELSE 
            v_prg_run_result := 'Task '|| UPPER(p_task_name) || ' not completed' ;
            RAISE e_task_not_complete ;
        END IF ;

        -- 修改任务配置表中的相关日期字段
        SELECT TO_DATE(hwm_data_dt, 'YYYYMMDD') 
          INTO v_hwm_data_dt 
          FROM ctl.ctl_task_conf_tbl 
         WHERE task_name = UPPER(p_task_name) ;

        IF v_hwm_data_dt >= v_batch_date THEN
            UPDATE ctl.ctl_task_conf_tbl 
               SET last_data_dt = p_batch_date
                  ,next_data_dt = TO_CHAR((v_batch_date + 1), 'YYYYMMDD') 
             WHERE task_name = UPPER(p_task_name) ;
            COMMIT ;
        ELSE 
            UPDATE ctl.ctl_task_conf_tbl 
               SET last_data_dt = p_batch_date
                  ,next_data_dt = TO_CHAR((v_batch_date + 1), 'YYYYMMDD') 
                  ,hwm_data_dt  = p_batch_date 
             WHERE task_name = UPPER(p_task_name) ;
        END IF ;

        p_run_result := '0' ;
        v_prg_run_result := 'No Errors' ;
        ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
            ( p_batch_date
             ,'CTL_TASK_TOOLS_PKG'
             ,'CTL_TASK_CLEAN_PRC'
             ,'任务成功完成后的清理操作'
             ,'CTL'
             ,'JOBS'
             ,v_run_time
             ,SYSDATE
             ,(SYSDATE - v_run_time)*1440
             ,0
             ,'S'
             ,'00000'
             ,v_prg_run_result
             ,'CTL'
            ) ;
    EXCEPTION
        WHEN e_task_not_complete 
        THEN
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_TASK_CLEAN_PRC'
                 ,'任务成功完成后的清理操作'
                 ,'CTL'
                 ,'TASK'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,v_prg_run_result
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
        WHEN OTHERS 
        THEN 
            p_run_result := '1' ;
            ctl.ctl_task_tools_pkg.ctl_sys_log_prc 
                ( p_batch_date
                 ,'CTL_TASK_TOOLS_PKG'
                 ,'CTL_TASK_CLEAN_PRC'
                 ,'任务成功完成后的清理操作'
                 ,'CTL'
                 ,'TASK'
                 ,v_run_time
                 ,SYSDATE
                 ,(SYSDATE - v_run_time)*1440
                 ,0
                 ,'F'
                 ,SQLCODE
                 ,SQLERRM
                 ,'CTL'
                ) ;
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
    END ctl_task_clean_prc ;

END ctl_task_tools_pkg ;
/
