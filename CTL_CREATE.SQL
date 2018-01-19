
/*
-- 为任务调度系统创建相关的数据库对象(Oracle 11gR2)
-- 
-- 需要预先创建和数据库对象所使用的表空间
--     数据表空间: ctl_data_ts
--     索引表空间: ctl_idx_ts
-- 默认所属用户(SCHEMA)
--     ctl
-- 数据库对象列表:
--     系统配置表     ctl_sys_conf_tbl
--     任务配置表     ctl_task_conf_tbl
--     任务实例表     ctl_task_inst_tbl
--     任务日志表     ctl_task_logs_tbl
--     任务历史表     ctl_task_hist_ptb
--     作业配置表     ctl_jobs_conf_tbl
--     作业实例表     ctl_jobs_inst_tbl
--     作业日志表     ctl_jobs_logs_tbl
--     作业历史表     ctl_jobs_hist_ptb
--     源文件配置表   ctl_sfile_conf_tbl
--     源文件登记表   ctl_sfile_reg_tbl
--     源文件统计表   ctl_sfile_sum_tbl
--     源文件历史表   ctl_sfile_hist_ptb
--     假日配置表     ctl_holiday_conf_tbl
--     系统字典表     ctl_meta_dict_tbl
--
-- LiBing  2017-05-19
*/

-- 为ctl用户创建数据表空间(需DBA权限)
-- 可根据自己的需要进行修改
CREATE TABLESPACE ctl_data_ts
    DATAFILE '/data/oradata/ctl/ctl_data_ts.dbf'
    SIZE 50M AUTOEXTEND ON
    NEXT 5M
    MAXSIZE UNLIMITED
    LOGGING
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO ;


-- 为ctl用户创建索引表空间(需DBA权限)
-- 可根据自己的需要进行修改
CREATE TABLESPACE ctl_idx_ts
    DATAFILE '/data/oradata/ctl/ctl_idx_ts.dbf'
    SIZE 50M AUTOEXTEND ON
    NEXT 5M
    MAXSIZE UNLIMITED
    LOGGING
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO ;


-- 创建用户(SCHEMA) ctl
CREATE USER ctl 
    PROFILE DEFAULT
    IDENTIFIED BY ctl123
    DEFAULT TABLESPACE ctl_data_ts
    TEMPORARY TABLESPACE temp 
    ACCOUNT UNLOCK ;
GRANT RESOURCE, CONNECT TO ctl ;
GRANT DBA TO ctl ;
GRANT CREATE ANY TABLE TO ctl ;
GRANT CREATE ANY PROCEDURE TO ctl ;
GRANT ALL PRIVILEGES TO ctl ;
GRANT SELECT_CATALOG_ROLE TO ctl ;
GRANT ALL ON DBMS_PIPE TO ctl ;
GRANT ALL ON DBMS_ALERT TO ctl ;
GRANT ALL ON DBMS_LOCK TO ctl ;


--------------------------------------------------------------------------------
-- 删除所有表
--------------------------------------------------------------------------------
DROP TABLE ctl.ctl_sys_conf_tbl ;
DROP TABLE ctl.ctl_task_conf_tbl ;
DROP TABLE ctl.ctl_task_inst_tbl ;
DROP TABLE ctl.ctl_task_logs_tbl ;
DROP TABLE ctl.ctl_task_hist_ptb ;
DROP TABLE ctl.ctl_jobs_conf_tbl ;
DROP TABLE ctl.ctl_jobs_inst_tbl ;
DROP TABLE ctl.ctl_jobs_logs_tbl ;
DROP TABLE ctl.ctl_jobs_hist_ptb ;
DROP TABLE ctl.ctl_sfile_conf_tbl ;
DROP TABLE ctl.ctl_sfile_reg_tbl ;
DROP TABLE ctl.ctl_sfile_sum_tbl ;
DROP TABLE ctl.ctl_sfile_hist_ptb ;
DROP TABLE ctl.ctl_holiday_conf_tbl ;
DROP TABLE ctl.ctl_meta_dict_tbl ;

--------------------------------------------------------------------------------
-- 表名: ctl_sys_conf_tbl
-- 描述: 系统配置
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_sys_conf_tbl 
    ( task_name    VARCHAR2(30)  DEFAULT 'CTL' NOT NULL
     ,param_name   VARCHAR2(100) NOT NULL
     ,param_value  VARCHAR2(200) NOT NULL
     ,param_desc   VARCHAR2(200) DEFAULT 'NONE'
     ,is_valid     VARCHAR2(1)   DEFAULT '1' NOT NULL
    )
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_sys_conf_tbl 
    IS 'CTL-T-系统配置' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_sys_conf_tbl.task_name 
    IS '任务名(默认值CTL)' ;
COMMENT ON COLUMN ctl_sys_conf_tbl.param_name 
    IS '配置项名称' ;
COMMENT ON COLUMN ctl_sys_conf_tbl.param_value 
    IS '配置项内容' ;
COMMENT ON COLUMN ctl_sys_conf_tbl.param_desc 
    IS '配置项说明(默认值NONE)' ;
COMMENT ON COLUMN ctl_sys_conf_tbl.is_valid 
    IS '是否启用(0禁用,1启用,默认1)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_sys_conf_tbl 
    ADD CONSTRAINT ctl_sys_conf_pk 
    PRIMARY KEY (task_name, param_name, is_valid) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_task_conf_tbl
-- 描述: 任务配置
-- 注意:
--     假日不触发的配置内容样例(task_name可根据需要修改)
--     SELECT COUNT(1) FROM ctl.ctl_holiday_conf_tbl WHERE task_name = 'TEST' AND holiday = :v_1
--------------------------------------------------------------------------------
CREATE TABLE ctl_task_conf_tbl 
    ( task_name      VARCHAR2(30)   NOT NULL
     ,task_desc      varchar2(200)  DEFAULT 'NONE'
     ,not_run_rule   VARCHAR2(200)  DEFAULT 'NONE'
     ,jobs_concur    NUMBER(3,0)    DEFAULT 10
     ,last_data_dt   VARCHAR2(10) 
     ,next_data_dt   VARCHAR2(10)   NOT NULL
     ,hwm_data_dt    VARCHAR2(10)
     ,goal_data_dt   VARCHAR2(10)   DEFAULT '99991231'
     ,task_mode      VARCHAR2(1)    DEFAULT '0' NOT NULL
     ,manual_flag    VARCHAR2(1)    DEFAULT '0' NOT NULL
     ,is_valid       VARCHAR2(1)    DEFAULT '1' NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_task_conf_tbl 
    IS 'CTL-T-任务配置' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_task_conf_tbl.task_name 
    IS '任务名称' ;
COMMENT ON COLUMN ctl_task_conf_tbl.task_desc 
    IS '任务描述' ;
COMMENT ON COLUMN ctl_task_conf_tbl.not_run_rule 
    IS '不触发规则(如无,必须填NONE)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.jobs_concur 
    IS '作业执行并发数(默认为10)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.last_data_dt 
    IS '上一次运行的数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.next_data_dt 
    IS '下一次运行的数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.hwm_data_dt 
    IS '曾经运行过的最大数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.goal_data_dt 
    IS '运行截止的目标数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.task_mode 
    IS '任务运行模式(0正常每日定时触发,1循环追数,2手动触发)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.manual_flag 
    IS '人工干预标识(0无干预,1干预)' ;
COMMENT ON COLUMN ctl_task_conf_tbl.is_valid 
    IS '任务是否启用(0禁用,1启用,默认1)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_task_conf_tbl 
    ADD CONSTRAINT ctl_task_conf_pk 
    PRIMARY KEY (task_name, is_valid) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_task_inst_tbl
-- 描述: 任务实例
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_task_inst_tbl 
    ( task_name     VARCHAR2(30) NOT NULL
     ,data_date     VARCHAR2(10) NOT NULL
     ,jobs_concurr  NUMBER(3,0)  DEFAULT 10
     ,start_ts      TIMESTAMP(6) DEFAULT SYSTIMESTAMP
     ,end_ts        TIMESTAMP(6) 
     ,task_status   VARCHAR2(1)  NOT NULL
     ,error_alert   VARCHAR2(1)  DEFAULT '0'
     ,manual_flag   VARCHAR2(1)  DEFAULT '0'
    ) 
    TABLESPACE hfdp_data_ts ;

-- 添加表注释 
COMMENT ON TABLE ctl.ctl_task_inst_tbl 
  IS 'CTL-T-任务实例' ;

-- 添加字段注释 
COMMENT ON COLUMN ctl_task_inst_tbl.task_name 
    IS '任务名称' ;
COMMENT ON COLUMN ctl_task_inst_tbl.data_date 
    IS '任务运行的数据日期' ;
COMMENT ON COLUMN ctl_task_inst_tbl.jobs_concurr 
    IS '任务运行的作业并发数' ;
COMMENT ON COLUMN ctl_task_inst_tbl.start_ts 
    IS '任务运行的开始时间' ;
COMMENT ON COLUMN ctl_task_inst_tbl.end_ts 
    IS '任务运行的结束时间' ;
COMMENT ON COLUMN ctl_task_inst_tbl.task_status 
    IS '任务状态(0正在运行,1人工干预暂停,2出错,3成功完成,4跳过)' ;
COMMENT ON COLUMN ctl_task_inst_tbl.error_alert 
    IS '出错是否已通知(0未通知,1已通知)' ;
COMMENT ON COLUMN ctl_task_inst_tbl.manual_flag 
    IS '人工干预标识(0无干预,1干预)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_task_inst_tbl 
    ADD CONSTRAINT ctl_task_inst_pk 
    PRIMARY KEY (task_name) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_task_logs_tbl
-- 描述: 任务日志
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_task_logs_tbl 
    ( task_name    VARCHAR2(30) NOT NULL
     ,data_date    VARCHAR2(10) NOT NULL
     ,start_ts     TIMESTAMP(6) NOT NULL
     ,end_ts       TIMESTAMP(6) NOT NULL
     ,run_time     VARCHAR2(50) NOT NULL
     ,run_result   VARCHAR2(1)  NOT NULL
     ,manual_flag  VARCHAR2(1)  NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_task_logs_tbl 
    IS 'CTL-T-任务日志' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_task_logs_tbl.task_name 
    IS '任务名称' ;
COMMENT ON COLUMN ctl_task_logs_tbl.data_date 
    IS '数据日期(字符串格式YYYYMMDD)' ;
COMMENT ON COLUMN ctl_task_logs_tbl.start_ts 
    IS '任务开始时间' ;
COMMENT ON COLUMN ctl_task_logs_tbl.end_ts 
    IS '任务结束时间' ;
COMMENT ON COLUMN ctl_task_logs_tbl.run_time
    IS '任务耗时(字符串,单位:秒)' ;
COMMENT ON COLUMN ctl_task_logs_tbl.run_result 
    IS '任务运行结果(0成功完成,1出错,2人工干预暂停,3跳过)' ;
COMMENT ON COLUMN ctl_task_logs_tbl.manual_flag 
    IS '人工干预标识(0无干预,1干预)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_task_logs_tbl 
    ADD CONSTRAINT ctl_task_logs_pk 
    PRIMARY KEY (task_name, data_date, start_ts) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_task_hist_ptb
-- 描述: 任务历史(日志归档)
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_task_hist_ptb 
    ( task_name    VARCHAR2(30) NOT NULL
     ,data_date    VARCHAR2(10) NOT NULL
     ,start_ts     TIMESTAMP(6) NOT NULL
     ,end_ts       TIMESTAMP(6) NOT NULL
     ,run_time     VARCHAR2(50) NOT NULL
     ,run_result   VARCHAR2(1)  NOT NULL
     ,manual_flag  VARCHAR2(1)  NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;
-- !!!!!!!还需规划和定义表分区

-- 添加表注释
COMMENT ON TABLE ctl_task_hist_ptb 
    IS 'CTL-T-任务历史' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_task_hist_ptb.task_name 
    IS '任务名称' ;
COMMENT ON COLUMN ctl_task_hist_ptb.data_date 
    IS '数据日期(字符串格式YYYYMMDD)' ;
COMMENT ON COLUMN ctl_task_hist_ptb.start_ts 
    IS '任务开始时间' ;
COMMENT ON COLUMN ctl_task_hist_ptb.end_ts 
    IS '任务结束时间' ;
COMMENT ON COLUMN ctl_task_hist_ptb.run_time
    IS '任务耗时(字符串,单位:秒)' ;
COMMENT ON COLUMN ctl_task_hist_ptb.run_result 
    IS '任务运行结果(0成功完成,1出错,2人工干预暂停,3跳过)' ;
COMMENT ON COLUMN ctl_task_hist_ptb.manual_flag 
    IS '人工干预标识(0无干预,1干预)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_task_hist_ptb 
    ADD CONSTRAINT ctl_task_hist_pk 
    PRIMARY KEY (task_name, data_date, start_ts) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_jobs_conf_tbl
-- 描述: 作业配置
-- 注意: 
--        job_prog字段的配置内容样例: 
--            hfdp.uti_hfdp_tools.pkg.uti_hfdp_log_prc(#DATA_DT#,'XXXX','XXXX', #V_OUT#)
--        在执行时,对上述内容进行替换,使用数据日期(例如20161227)替换#DATA_DT#,使用 :v_1 
--        替换#V_OUT#
--------------------------------------------------------------------------------
CREATE TABLE ctl_jobs_conf_tbl 
    ( task_name      VARCHAR2(30)   NOT NULL
     ,job_name       VARCHAR2(100)  NOT NULL
     ,job_type       VARCHAR2(20)   DEFAULT 'PROCEDURE' NOT NULL
     ,job_prog       VARCHAR2(200)  NOT NULL
     ,not_run_rule   VARCHAR2(200)  NOT NULL
     ,job_dependent  VARCHAR2(100)  DEFAULT 'NONE'
     ,tree_level     INTEGER        NOT NULL
     ,is_valid       VARCHAR2(1)    NOT NULL
     ,job_desc       VARCHAR2(500)  
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_jobs_conf_tbl 
    IS 'CTL-T-作业配置' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_jobs_conf_tbl.task_name 
    IS '作业所属任务名称' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.job_name 
    IS '作业名称(建议命名格式: 源系统名_存储过程名_目标表名)' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.job_type 
    IS '作业类型' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.job_prog 
    IS '作业执行程序内容' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.not_run_rule 
    IS '作业的不触发规则(如无必须填NONE)' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.job_dependent 
    IS '作业所依赖的前置作业(如无必须填NONE)' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.tree_level  
    IS '作业距离根节点的最远节点数' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.is_valid 
    IS '作业是否启用(0禁用,1启用)' ;
COMMENT ON COLUMN ctl_jobs_conf_tbl.job_desc 
    IS '作业描述' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_jobs_conf_tbl 
    ADD CONSTRAINT ctl_jobs_conf_pk 
    PRIMARY KEY (task_name, job_name, job_dependent, is_valid) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_jobs_inst_tbl
-- 描述: 作业实例
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_jobs_inst_tbl 
    ( data_date     VARCHAR2(10)  NOT NULL
     ,task_name     VARCHAR2(30)  NOT NULL
     ,job_type      VARCHAR2(20)  DEFAULT 'PROCEDURE' NOT NULL
     ,job_name      VARCHAR2(100) NOT NULL
     ,job_dep_name  VARCHAR2(100) NOT NULL
     ,job_prog      VARCHAR2(300) NOT NULL
     ,start_ts      TIMESTAMP(6)  NOT NULL
     ,end_ts        TIMESTAMP(6)  
     ,job_status    VARCHAR2(1)   NOT NULL
     ,tree_level    INTEGER       NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释 
COMMENT ON TABLE ctl_jobs_inst_tbl 
    IS 'CTL-T-作业实例' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_jobs_inst_tbl.data_date 
    IS '作业运行的数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.task_name 
    IS '所属任务名称' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.job_type 
    IS '作业类型' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.job_name 
    IS '作业名称' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.job_dep_name 
    IS '依赖的前置作业' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.job_prog 
    IS '作业实际运行的程序' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.start_ts 
    IS '运行开始时间' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.end_ts 
    IS '运行结束时间' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.job_status 
    IS '任务状态(0已实例化,可运行,1依赖不满足,2正在运行,3出错,4成功结束,5跳过)' ;
COMMENT ON COLUMN ctl_jobs_inst_tbl.tree_level  
    IS '作业距离根节点的最远节点数' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_jobs_inst_tbl 
    ADD CONSTRAINT ctl_jobs_inst_pk 
    PRIMARY KEY (task_name, job_name) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_jobs_logs_tbl
-- 描述: 作业日志
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_jobs_logs_tbl 
    ( data_date   VARCHAR2(10)  NOT NULL
     ,task_name   VARCHAR2(30)  NOT NULL
     ,job_name    VARCHAR2(100) NOT NULL
     ,job_prog    VARCHAR2(300) NOT NULL
     ,start_ts    TIMESTAMP(6)  NOT NULL
     ,end_ts      TIMESTAMP(6)  NOT NULL
     ,job_status  VARCHAR2(1)   NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释 
COMMENT ON TABLE ctl_jobs_logs_tbl 
    IS 'CTL-T-作业日志' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_jobs_logs_tbl.data_date
    IS '作业运行的数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_jobs_logs_tbl.task_name 
    IS '所属任务名称' ;
COMMENT ON COLUMN ctl_jobs_logs_tbl.job_name 
    IS '作业名称' ;
COMMENT ON COLUMN ctl_jobs_logs_tbl.job_prog 
    IS '作业实际运行的程序' ;
COMMENT ON COLUMN ctl_jobs_logs_tbl.start_ts 
    IS '运行开始时间' ;
COMMENT ON COLUMN ctl_jobs_logs_tbl.end_ts 
    IS '运行结束时间' ;
COMMENT ON COLUMN ctl_jobs_logs_tbl.job_status 
    IS '任务状态(0已实例化,1就绪,2正在运行,3出错,4成功结束,5跳过)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_jobs_logs_tbl 
    ADD CONSTRAINT ctl_jobs_logs_pk 
    PRIMARY KEY (task_name, job_name) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_jobs_hist_ptb
-- 描述: 作业历史(日志归档)
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_jobs_hist_ptb 
    ( data_date   VARCHAR2(10)  NOT NULL
     ,task_name   VARCHAR2(30)  NOT NULL
     ,job_name    VARCHAR2(100) NOT NULL
     ,job_prog    VARCHAR2(300) NOT NULL
     ,start_ts    TIMESTAMP(6)  NOT NULL
     ,end_ts      TIMESTAMP(6)  NOT NULL
     ,job_status  VARCHAR2(1)   NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;
-- !!!!!!!还需要规划和定义表分区

-- 添加表注释 
COMMENT ON TABLE ctl_jobs_hist_ptb 
    IS 'CTL-T-作业历史' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_jobs_hist_ptb.data_date
    IS '作业运行的数据日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_jobs_hist_ptb.task_name 
    IS '所属任务名称' ;
COMMENT ON COLUMN ctl_jobs_hist_ptb.job_name 
    IS '作业名称' ;
COMMENT ON COLUMN ctl_jobs_hist_ptb.job_prog 
    IS '作业实际运行的程序' ;
COMMENT ON COLUMN ctl_jobs_hist_ptb.start_ts 
    IS '运行开始时间' ;
COMMENT ON COLUMN ctl_jobs_hist_ptb.end_ts 
    IS '运行结束时间' ;
COMMENT ON COLUMN ctl_jobs_hist_ptb.job_status 
    IS '任务状态(0已实例化,1就绪,2正在运行,3出错,4成功结束,5跳过)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_jobs_hist_ptb 
    ADD CONSTRAINT ctl_jobs_hist_pk 
    PRIMARY KEY (task_name, job_name, start_ts) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_sfile_conf_tbl
-- 描述: 源文件配置
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_sfile_conf_tbl 
    ( task_name       VARCHAR2(30)   NOT NULL
     ,sys_name        VARCHAR2(30)   NOT NULL
     ,file_base_name  VARCHAR2(100)  NOT NULL
     ,dir_name        VARCHAR2(30)   NOT NULL
     ,file_desc       VARCHAR2(200)  DEFAULT 'NONE'
     ,is_valid        VARCHAR2(1)    NOT NULL
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_sfile_conf_tbl 
    IS 'CTL-T-源文件配置' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_sfile_conf_tbl.task_name 
    IS '调度任务名称' ;
COMMENT ON COLUMN ctl_sfile_conf_tbl.sys_name 
    IS '源系统名称' ;
COMMENT ON COLUMN ctl_sfile_conf_tbl.file_base_name 
    IS '文件基本名称(字母全大写)' ; 
COMMENT ON COLUMN ctl_sfile_conf_tbl.dir_name  
    IS '数据库DIRECTORY名' ; 
COMMENT ON COLUMN ctl_sfile_conf_tbl.file_desc 
    IS '数据文件描述' ;
COMMENT ON COLUMN ctl_sfile_conf_tbl.is_valid 
    IS '是否启用(0禁用,1启用)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_sfile_conf_tbl 
    ADD CONSTRAINT ctl_sfile_conf_pk 
    PRIMARY KEY (task_name, sys_name, file_base_name, is_valid) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_sfile_reg_tbl
-- 描述: 源文件登记
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_sfile_reg_tbl 
    ( data_date      VARCHAR2(10)   NOT NULL
     ,task_name      VARCHAR2(30)   NOT NULL 
     ,sys_name       VARCHAR2(30)   NOT NULL
     ,file_name      VARCHAR2(100)  NOT NULL
     ,file_size      NUMBER(15,0)   DEFAULT 0  
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_sfile_reg_tbl 
    IS 'CTL-T-源文件登记' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_sfile_reg_tbl.data_date 
    IS '数据文件日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_sfile_reg_tbl.task_name
    IS '调度任务名称' ;
COMMENT ON COLUMN ctl_sfile_reg_tbl.sys_name 
    IS '源系统名称' ;
COMMENT ON COLUMN ctl_sfile_reg_tbl.file_name 
    IS '文件名称' ;
COMMENT ON COLUMN ctl_sfile_reg_tbl.file_size 
    IS '文件大小(单位:字节)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_sfile_reg_tbl 
    ADD CONSTRAINT ctl_sfile_reg_pk 
    PRIMARY KEY (data_date, task_name, sys_name, file_name) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_sfile_sum_tbl
-- 描述: 源文件统计
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_sfile_sum_tbl 
    ( data_date    VARCHAR2(10) NOT NULL
     ,task_name    VARCHAR2(30) NOT NULL
     ,is_ready     VARCHAR2(1)  NOT NULL
     ,file_count   NUMBER(5,0)  NOT NULL  
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_sfile_sum_tbl 
    IS 'CTL-T-源文件统计' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_sfile_sum_tbl.data_date 
    IS '数据文件日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_sfile_sum_tbl.task_name 
    IS '调度任务名称' ;
COMMENT ON COLUMN ctl_sfile_sum_tbl.is_ready 
    IS '任务所需文件是否齐备(0未齐备,1齐备)' ;
COMMENT ON COLUMN ctl_sfile_sum_tbl.file_count 
    IS '文件数量' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_sfile_sum_tbl 
    ADD CONSTRAINT ctl_sfile_sum_pk 
    PRIMARY KEY (data_date, task_name) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


--------------------------------------------------------------------------------
-- 表名: ctl_sfile_hist_tbl
-- 描述: 源文件历史(登记归档)
-- 注意: 无
--------------------------------------------------------------------------------
CREATE TABLE ctl_sfile_hist_ptb 
    ( data_date      VARCHAR2(10)   NOT NULL
     ,task_name      VARCHAR2(30)   NOT NULL 
     ,sys_name       VARCHAR2(30)   NOT NULL
     ,file_name      VARCHAR2(100)  NOT NULL
     ,file_size      NUMBER(15,0)   DEFAULT 0  
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_sfile_hist_ptb 
    IS 'CTL-T-源文件历史' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_sfile_hist_ptb.data_date 
    IS '数据文件日期(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_sfile_hist_ptb.task_name
    IS '调度任务名称' ;
COMMENT ON COLUMN ctl_sfile_hist_ptb.sys_name 
    IS '源系统名称' ;
COMMENT ON COLUMN ctl_sfile_hist_ptb.file_name 
    IS '文件名称' ;
COMMENT ON COLUMN ctl_sfile_hist_ptb.file_size 
    IS '文件大小(单位:字节)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_sfile_hist_ptb 
    ADD CONSTRAINT ctl_sfile_hist_pk 
    PRIMARY KEY (data_date, task_name, sys_name, file_name) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


----------------------------------------------------------------------------------------------------
-- 表名: ctl_holiday_conf_tbl
-- 描述: 假日配置
-- 注意: 无
----------------------------------------------------------------------------------------------------
CREATE TABLE ctl_holiday_conf_tbl 
    ( task_name  VARCHAR2(300)  NOT NULL 
     ,hol_date   VARCHAR2(10)   NOT NULL
     ,job_name   VARCHAR2(2000) DEFAULT 'NONE' NOT NULL
     ,is_valid   VARCHAR2(1)    NOT NULL
     ,rec_dt     DATE           DEFAULT SYSDATE NOT NULL 
    ) 
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_holiday_conf_tbl
    IS 'CTL-T-假日表' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_holiday_conf_tbl.task_name 
    IS '调度任务名称' ;
COMMENT ON COLUMN ctl_holiday_conf_tbl.hol_date 
    IS '假日(字符串YYYYMMDD)' ;
COMMENT ON COLUMN ctl_holiday_conf_tbl.job_name 
    IS '调度作业名称' ;
COMMENT ON COLUMN ctl_holiday_conf_tbl.is_valid 
    IS '是否启用(0禁用,1启用)' ;
COMMENT ON COLUMN ctl_holiday_conf_tbl.rec_dt 
    IS '记录插入时间' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_holiday_conf_tbl 
    ADD CONSTRAINT ctl_holiday_conf_pk 
    PRIMARY KEY (task_name, hol_date, is_valid) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


----------------------------------------------------------------------------------------------------
-- 表名: ctl_meta_dict_tbl
-- 描述: 系统字典
-- 注意: 无
----------------------------------------------------------------------------------------------------
CREATE TABLE ctl_meta_dict_tbl 
    ( item_name
     ,item_desc
     ,is_valid
    )
    TABLESPACE ctl_data_ts ;

-- 添加表注释
COMMENT ON TABLE ctl_meta_dict_tbl
    IS 'CTL-T-假日表' ;

-- 添加字段注释
COMMENT ON COLUMN ctl_meta_dict_tbl.item_name 
    IS '字典项名称' ;
COMMENT ON COLUMN ctl_meta_dict_tbl.item_desc 
    IS '字典项解释' ;
COMMENT ON COLUMN ctl_meta_dict_tbl.is_valid 
    IS '是否废弃(0废弃,1未废弃)' ;

-- 添加主键/外键/索引
ALTER TABLE ctl_meta_dict_tbl  
    ADD CONSTRAINT ctl_meta_dict_pk  
    PRIMARY KEY (item_name, is_valid) 
    USING INDEX 
    TABLESPACE ctl_idx_ts ;


-- 一些检查语句

-- 检查表注释
SELECT *
  FROM user_tab_comments ;

-- 检查字段注释
SELECT *
  FROM user_col_comments 
 WHERE table_name NOT LIKE 'BIN$%' ;

-- 检查主键
SELECT *
  FROM user_constraints 
 WHERE constraint_name NOT LIKE 'BIN$%' 
   AND constraint_type = 'P' ;


-- END